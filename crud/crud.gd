class_name BinarioCRUD
extends RefCounted

const DEFAULT_PATH := "user://dados_crud.dat"

# Constantes para lápides (tombstones)
const LAPIDE_ATIVO: int = 0
const LAPIDE_REMOVIDO: int = 1

# Constantes para tamanhos de campos em bytes
const TAMANHO_LAPIDE: int = 1  # 1 byte para a lápide (int8)
const TAMANHO_CAMPO_TAMANHO: int = 4  # 4 bytes para o tamanho do registro (int32)
const TAMANHO_CABECALHO: int = TAMANHO_LAPIDE + TAMANHO_CAMPO_TAMANHO  # Total: 5 bytes
const TAMANHO_MAXIMO_REGISTRO: int = 1048576  # Proteção: máximo 1MB por registro

# Nomes dos métodos da interface de serialização
# Altere aqui se quiser renomear os métodos em todas as classes gerenciadas
const METODO_SERIALIZAR: String = "to_bytes"
const METODO_DESSERIALIZAR: String = "from_bytes"

# Caminho do arquivo de dados binário
var _file_path: String = "user://dados_crud.dat"
# Lista de posições válidas (offsets no arquivo) - PRIVADA
var _indice: Array[int] = []
# Armazena a classe dos objetos gerenciados - PRIVADA
var _tipo_classe: GDScript = null : get = get_tipo_classe, set = set_tipo_classe
# Controla se o CRUD deve imprimir logs de debug
var _debug_logging: bool = false

# Método auxiliar para prints condicionais
func _log(mensagem: String) -> void:
	if _debug_logging:
		print(mensagem)

# Ativa ou desativa o logging de debug
func ativar_debug(ativo: bool) -> void:
	_debug_logging = ativo

# Getter: retorna uma cópia somente leitura do índice
# Não permite modificação direta para proteger a integridade dos dados
func obter_indice() -> Array[int]:
	return _indice.duplicate()

# Getter: retorna o tamanho do índice (quantidade de registros ativos)
func obter_tamanho_indice() -> int:
	return _indice.size()

# Getter: retorna o tipo de classe (já existe como obter_tipo_classe())
# Mantido para compatibilidade e clareza
func get_tipo_classe() -> GDScript:
	return _tipo_classe

# Setter: define o tipo de classe com validação
# Use definir_tipo_classe() em vez deste método (mais explícito)
func set_tipo_classe(classe: GDScript) -> void:
	
	if _tipo_classe == null:
		_tipo_classe = classe
	else:
		printerr("Classe já definida, não pode mudar após configuração inicial")

## Define o tipo de classe que este CRUD irá gerenciar. Útil quando o CRUD foi criado sem especificar a classe no construtor
func definir_tipo_classe(classe: Variant) -> void:
	if not _validar_classe(classe):
		push_error("BinarioCRUD: Não foi possível definir tipo de classe - classe inválida")
		return
	
	_tipo_classe = classe
	_log("BinarioCRUD: Tipo de classe definido para: %s" % str(classe))

# Construtor: inicializa o CRUD com a classe a ser gerenciada
# Parâmetro classe_obj: Classe (script GDScript) que será gerenciada por este CRUD
func _init(classe_obj: GDScript = null, file_path: String = DEFAULT_PATH) -> void:
	if classe_obj != null:
		if not _validar_classe(classe_obj):
			push_error("BinarioCRUD: Classe fornecida não é válida. A instância não será funcional.")
			return
			
		definir_tipo_classe(classe_obj)
	
	_file_path = file_path
	carregar_indice()

# Valida se uma classe possui a estrutura necessária para ser gerenciada
func _validar_classe(classe: GDScript) -> bool:
	if classe == null:
		push_error("BinarioCRUD: Classe é nula")
		return false
	
	# Tenta criar uma instância temporária para verificar os métodos
	var instancia_teste: Variant = classe.new()
	
	if not instancia_teste.has_method(METODO_SERIALIZAR):
		push_error("BinarioCRUD: Classe não possui o método '%s'" % METODO_SERIALIZAR)
		return false
	
	if not instancia_teste.has_method(METODO_DESSERIALIZAR):
		push_error("BinarioCRUD: Classe não possui o método '%s'" % METODO_DESSERIALIZAR)
		return false
	
	return true

# Valida se um objeto possui os métodos necessários para serialização
func _validar_interface_serializavel(obj: Variant) -> bool:
	if obj == null:
		push_error("BinarioCRUD: Objeto é nulo")
		return false
	
	# Verifica se possui o método de serialização
	if not obj.has_method(METODO_SERIALIZAR):
		push_error("BinarioCRUD: Objeto não possui o método '%s'" % METODO_SERIALIZAR)
		return false
	
	# Verifica se possui o método de desserialização
	if not obj.has_method(METODO_DESSERIALIZAR):
		push_error("BinarioCRUD: Objeto não possui o método '%s'" % METODO_DESSERIALIZAR)
		return false
	
	if not obj.get_script() == _tipo_classe:
		push_error("BinarioCRUD: Objeto não possui o método '%s'" % METODO_DESSERIALIZAR)
		return false
	
	return true

## Carrega o índice com base no conteúdo atual do arquivo, Lê todos os registros e monta um índice em memória com as posições dos registros ativos
func carregar_indice() -> void:
	_indice.clear()
	if not FileAccess.file_exists(_file_path):
		_log("BinarioCRUD: Arquivo não existe ainda, será criado na primeira escrita.")
		return
	
	var file := FileAccess.open(_file_path, FileAccess.READ)
	if file == null:
		push_error("BinarioCRUD: Erro ao abrir arquivo para leitura: %s" % FileAccess.get_open_error())
		return
	
	# Percorre o arquivo inteiro, registro por registro
	while file.get_position() < file.get_length():
		var pos := file.get_position()
		var lapide := file.get_8()
		var tamanho := file.get_32()
		
		# Proteção contra registros corrompidos
		if tamanho < 0 or tamanho > TAMANHO_MAXIMO_REGISTRO:
			push_error("BinarioCRUD: Tamanho de registro inválido: %d na posição %d" % [tamanho, pos])
			break
		
		# Se o registro está ativo, adiciona ao índice
		if lapide == LAPIDE_ATIVO:
			_indice.append(pos)
		
		# Pular para o próximo registro
		# Estrutura: [lápide: 1 byte] [tamanho: 4 bytes] [dados: N bytes]
		var proxima_pos := pos + TAMANHO_CABECALHO + tamanho
		if proxima_pos > file.get_length():
			push_error("BinarioCRUD: Registro excede tamanho do arquivo")
			break
		file.seek(proxima_pos)
	
	file.close()
	_log("BinarioCRUD: Índice carregado com %d registros ativos" % _indice.size())

## Retorna o número de registros ativos
func contar() -> int:
	return _indice.size()

## Limpa todos os dados (apaga o arquivo e o índice) Use com cuidado - esta operação é irreversível!
func limpar_tudo() -> bool:
	if FileAccess.file_exists(_file_path):
		var erro := DirAccess.remove_absolute(_file_path)
		if erro != OK:
			push_error("BinarioCRUD: Erro ao remover arquivo: %s" % erro)
			return false
	_indice.clear()
	_log("BinarioCRUD: Todos os dados foram limpos")
	return true

## Verifica se um ID de índice é válido
func indice_valido(indice_id: int) -> bool:
	return indice_id >= 0 and indice_id < _indice.size()

## Retorna o tipo de classe gerenciado por este CRUD
func obter_tipo_classe() -> Variant:
	return _tipo_classe

## Verifica se um objeto é compatível com o tipo gerenciado por este CRUD
func eh_tipo_compativel(obj: Variant) -> bool:
	if obj == null:
		return false
	
	if _tipo_classe == null:
		return _validar_interface_serializavel(obj)
	
	return obj.get_script() == _tipo_classe and _validar_interface_serializavel(obj)

## Cria um novo registro no arquivo. Retorna o ID (índice) do registro criado, ou -1 em caso de erro
func criar(obj: Variant) -> int:
	# Validar interface
	if not _validar_interface_serializavel(obj):
		return -1
	
	# Define o tipo de classe na primeira criação (se não foi definido no construtor)
	if _tipo_classe == null:
		_tipo_classe = obj.get_script()
		_log("BinarioCRUD: Tipo de classe detectado automaticamente: %s" % str(_tipo_classe))
	
	# Abre o arquivo para leitura/escrita, ou cria se não existir
	var file := FileAccess.open(_file_path, FileAccess.READ_WRITE)
	if file == null:
		# Se o arquivo não existe, cria
		file = FileAccess.open(_file_path, FileAccess.WRITE_READ)
		if file == null:
			push_error("BinarioCRUD: Erro ao criar arquivo: %s" % FileAccess.get_open_error())
			return -1
	
	# Posiciona no final do arquivo
	file.seek_end()
	var pos := file.get_position()
	
	# Serializa o objeto usando o método definido na interface
	var bytes: PackedByteArray = obj.call(METODO_SERIALIZAR)
	
	# Estrutura do registro: [lápide: 1 byte] [tamanho: 4 bytes] [dados: N bytes]
	file.store_8(LAPIDE_ATIVO)  # 0 = registro ativo
	file.store_32(bytes.size())
	file.store_buffer(bytes)
	file.close()
	
	# Adiciona ao índice
	_indice.append(pos)
	_log("BinarioCRUD: Registro criado no índice %d (posição %d)" % [_indice.size() - 1, pos])
	return _indice.size() - 1  # Retorna o ID do índice

## Lê todos os registros válidos (não deletados). Retorna um Array com todos os objetos
func ler_todos() -> Array:
	var lista: Array = []
	
	if _tipo_classe == null:
		push_error("BinarioCRUD: Tipo de classe não foi definido. Use definir_tipo_classe() ou crie um registro primeiro")
		return lista
	
	if not FileAccess.file_exists(_file_path):
		return lista
	
	var file := FileAccess.open(_file_path, FileAccess.READ)
	if file == null:
		push_error("BinarioCRUD: Erro ao abrir arquivo para leitura: %s" % FileAccess.get_open_error())
		return lista
	
	# Percorre todos os registros do índice
	for pos in _indice:
		file.seek(pos)
		var _lapide := file.get_8()  # Pula o byte da lápide
		var tamanho := file.get_32()
		var dados := file.get_buffer(tamanho)
		
		# Cria nova instância e desserializa usando o método definido na interface
		var obj: Variant = _tipo_classe.new()
		obj.call(METODO_DESSERIALIZAR, dados)
		lista.append(obj)
	
	file.close()
	_log("BinarioCRUD: %d registros lidos" % lista.size())
	return lista

## Lê um único registro pelo seu ID (índice). Retorna o objeto ou null se não encontrado
func ler_um(indice_id: int) -> Variant:
	if _tipo_classe == null:
		push_error("BinarioCRUD: Tipo de classe não foi definido")
		return null
	
	if indice_id < 0 or indice_id >= _indice.size():
		push_error("BinarioCRUD: Índice inválido %d (válidos: 0-%d)" % [indice_id, _indice.size() - 1])
		return null
	
	if not FileAccess.file_exists(_file_path):
		push_error("BinarioCRUD: Arquivo não existe")
		return null
	
	var file := FileAccess.open(_file_path, FileAccess.READ)
	if file == null:
		push_error("BinarioCRUD: Erro ao abrir arquivo: %s" % FileAccess.get_open_error())
		return null
	
	# Localiza o registro pelo índice
	var pos := _indice[indice_id]
	file.seek(pos)
	var _lapide := file.get_8()  # Pula o byte da lápide
	var tamanho := file.get_32()
	var dados := file.get_buffer(tamanho)
	file.close()
	
	# Cria nova instância e desserializa usando o método definido na interface
	var obj: Variant = _tipo_classe.new()
	obj.call(METODO_DESSERIALIZAR, dados)
	_log("BinarioCRUD: Registro %d lido: %s" % [indice_id, obj])
	return obj

### Atualiza um registro existente. Marca o registro antigo como deletado e cria um novo registro no final. Retorna true se a atualização foi bem-sucedida
func atualizar(indice_id: int, novo_obj: Variant) -> bool:
	if indice_id < 0 or indice_id >= _indice.size():
		push_error("BinarioCRUD: Índice inválido %d para atualizar" % indice_id)
		return false
	
	# Validar interface
	if not _validar_interface_serializavel(novo_obj):
		return false
	
	var file := FileAccess.open(_file_path, FileAccess.READ_WRITE)
	if file == null:
		push_error("BinarioCRUD: Erro ao abrir arquivo: %s" % FileAccess.get_open_error())
		return false
	
	# Lê o tamanho do registro antigo
	var pos_antigo := _indice[indice_id]
	file.seek(pos_antigo)
	var _lapide_antiga := file.get_8()
	var tamanho_antigo := file.get_32()
	
	# Serializa o novo objeto
	var bytes_novos: PackedByteArray = novo_obj.call(METODO_SERIALIZAR)
	var tamanho_novo := bytes_novos.size()
	
	# Se o novo registro cabe no espaço do antigo, faz overlap
	if tamanho_novo <= tamanho_antigo:
		# Volta para o início do registro e sobrescreve
		file.seek(pos_antigo)
		file.store_8(LAPIDE_ATIVO)
		file.store_32(tamanho_novo)
		file.store_buffer(bytes_novos)
		file.close()
		
		_log("BinarioCRUD: Registro %d atualizado in-place (posição: %d)" % [indice_id, pos_antigo])
		# Índice permanece o mesmo (mesma posição)
		return true
	else:
		# Registro novo é maior, precisa deletar o antigo e criar no final
		file.close()
		
		_log("BinarioCRUD: Registro %d maior que o espaço disponível, movendo para o final" % indice_id)
		
		# Deleta o registro antigo
		if not deletar(indice_id):
			return false
		
		# Cria o novo registro no final
		var novo_id := criar(novo_obj)
		if novo_id == -1:
			return false
		
		return true

## Marca um registro como deletado (soft delete usando lápide). Remove o registro do índice em memória. Retorna true se a deleção foi bem-sucedida
func deletar(indice_id: int) -> bool:
	if indice_id < 0 or indice_id >= _indice.size():
		push_error("BinarioCRUD: Índice inválido %d para deletar" % indice_id)
		return false
	
	var file := FileAccess.open(_file_path, FileAccess.READ_WRITE)
	if file == null:
		push_error("BinarioCRUD: Erro ao abrir arquivo: %s" % FileAccess.get_open_error())
		return false
	
	# Marca como removido no arquivo (lápide = 1)
	var pos := _indice[indice_id]
	file.seek(pos)
	file.store_8(LAPIDE_REMOVIDO)
	file.close()
	
	_log("BinarioCRUD: Registro %d deletado" % indice_id)
	# Remove do índice em memória
	_indice.remove_at(indice_id)
	return true
