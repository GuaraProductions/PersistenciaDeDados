class_name BinarioCRUD
extends Node

@export_file("*.dat") var file_path: String = "user://dados_crud.dat"
const LAPIDE_ATIVO: int = 0
const LAPIDE_REMOVIDO: int = 1

var indice: Array[int] = []  # Lista de posições válidas (offsets no arquivo)
var tipo_classe: Variant = null  # Armazena a classe dos objetos gerenciados

func _ready() -> void:
	carregar_indice()

# Valida se um objeto possui os métodos necessários para serialização
func _validar_interface_serializavel(obj: Variant) -> bool:
	if obj == null:
		push_error("BinarioCRUD: Objeto é nulo")
		return false
	
	# Verifica se possui o método to_bytes
	if not obj.has_method("to_bytes"):
		push_error("BinarioCRUD: Objeto não possui o método 'to_bytes()'")
		return false
	
	# Verifica se possui o método from_bytes
	if not obj.has_method("from_bytes"):
		push_error("BinarioCRUD: Objeto não possui o método 'from_bytes()'")
		return false
	
	# Opcional: verifica se possui is_valid
	if obj.has_method("is_valid"):
		if not obj.is_valid():
			push_error("BinarioCRUD: Objeto não passou na validação is_valid()")
			return false
	
	return true

# Define o tipo de classe que este CRUD irá gerenciar
func definir_tipo_classe(classe: Variant) -> void:
	tipo_classe = classe
	print("BinarioCRUD: Tipo de classe definido para: %s" % str(classe))

# Carrega o índice com base no conteúdo atual do arquivo
func carregar_indice() -> void:
	indice.clear()
	if not FileAccess.file_exists(file_path):
		print("BinarioCRUD: Arquivo não existe ainda, será criado na primeira escrita.")
		return
	
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("BinarioCRUD: Erro ao abrir arquivo para leitura: %s" % FileAccess.get_open_error())
		return
	
	while file.get_position() < file.get_length():
		var pos := file.get_position()
		var lapide := file.get_8()
		var tamanho := file.get_32()
		
		if tamanho < 0 or tamanho > 1048576:  # Proteção: máximo 1MB por registro
			push_error("BinarioCRUD: Tamanho de registro inválido: %d na posição %d" % [tamanho, pos])
			break
		
		if lapide == LAPIDE_ATIVO:
			indice.append(pos)
		
		# Pular para o próximo registro
		var proxima_pos := pos + 1 + 4 + tamanho
		if proxima_pos > file.get_length():
			push_error("BinarioCRUD: Registro excede tamanho do arquivo")
			break
		file.seek(proxima_pos)
	
	file.close()
	print("BinarioCRUD: Índice carregado com %d registros ativos" % indice.size())

# Cria um novo registro
func criar(obj: Variant) -> int:
	# Validar interface
	if not _validar_interface_serializavel(obj):
		return -1
	
	# Define o tipo de classe na primeira criação
	if tipo_classe == null:
		tipo_classe = obj.get_script()
		print("BinarioCRUD: Tipo de classe detectado automaticamente: %s" % str(tipo_classe))
	
	var file := FileAccess.open(file_path, FileAccess.READ_WRITE)
	if file == null:
		# Se o arquivo não existe, cria
		file = FileAccess.open(file_path, FileAccess.WRITE_READ)
		if file == null:
			push_error("BinarioCRUD: Erro ao criar arquivo: %s" % FileAccess.get_open_error())
			return -1
	
	file.seek_end()
	var pos := file.get_position()
	
	# Usa reflexão para chamar to_bytes()
	var bytes: PackedByteArray = obj.call("to_bytes")
	
	file.store_8(LAPIDE_ATIVO)  # 0 = registro ativo
	file.store_32(bytes.size())
	file.store_buffer(bytes)
	file.close()
	
	indice.append(pos)
	print("BinarioCRUD: Registro criado no índice %d (posição %d)" % [indice.size() - 1, pos])
	return indice.size() - 1  # Retorna o ID do índice

# Lê todos os registros válidos
func ler_todos() -> Array:
	var lista: Array = []
	
	if tipo_classe == null:
		push_error("BinarioCRUD: Tipo de classe não foi definido. Use definir_tipo_classe() ou crie um registro primeiro")
		return lista
	
	if not FileAccess.file_exists(file_path):
		return lista
	
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("BinarioCRUD: Erro ao abrir arquivo para leitura: %s" % FileAccess.get_open_error())
		return lista
	
	for pos in indice:
		file.seek(pos)
		var _lapide := file.get_8()  # Não usado, mas necessário para pular
		var tamanho := file.get_32()
		var dados := file.get_buffer(tamanho)
		
		# Usa reflexão para criar instância e chamar from_bytes
		var obj: Variant = tipo_classe.new()
		obj.call("from_bytes", dados)
		lista.append(obj)
	
	file.close()
	print("BinarioCRUD: %d registros lidos" % lista.size())
	return lista

# Lê um único registro pelo índice
func ler_um(indice_id: int) -> Variant:
	if tipo_classe == null:
		push_error("BinarioCRUD: Tipo de classe não foi definido")
		return null
	
	if indice_id < 0 or indice_id >= indice.size():
		push_error("BinarioCRUD: Índice inválido %d (válidos: 0-%d)" % [indice_id, indice.size() - 1])
		return null
	
	if not FileAccess.file_exists(file_path):
		push_error("BinarioCRUD: Arquivo não existe")
		return null
	
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("BinarioCRUD: Erro ao abrir arquivo: %s" % FileAccess.get_open_error())
		return null
	
	var pos := indice[indice_id]
	file.seek(pos)
	var _lapide := file.get_8()
	var tamanho := file.get_32()
	var dados := file.get_buffer(tamanho)
	file.close()
	
	# Usa reflexão para criar instância e chamar from_bytes
	var obj: Variant = tipo_classe.new()
	obj.call("from_bytes", dados)
	print("BinarioCRUD: Registro %d lido: %s" % [indice_id, obj])
	return obj

# Atualiza o registro no índice dado
func atualizar(indice_id: int, novo_obj: Variant) -> bool:
	if indice_id < 0 or indice_id >= indice.size():
		push_error("BinarioCRUD: Índice inválido %d para atualizar" % indice_id)
		return false
	
	# Validar interface
	if not _validar_interface_serializavel(novo_obj):
		return false
	
	var file := FileAccess.open(file_path, FileAccess.READ_WRITE)
	if file == null:
		push_error("BinarioCRUD: Erro ao abrir arquivo: %s" % FileAccess.get_open_error())
		return false
	
	# Marca o antigo como apagado
	var pos_antigo := indice[indice_id]
	file.seek(pos_antigo)
	file.store_8(LAPIDE_REMOVIDO)  # lápide = 1, marca como removido
	
	# Cria novo registro no final
	file.seek_end()
	var pos_novo := file.get_position()
	
	# Usa reflexão para chamar to_bytes()
	var bytes: PackedByteArray = novo_obj.call("to_bytes")
	
	file.store_8(LAPIDE_ATIVO)
	file.store_32(bytes.size())
	file.store_buffer(bytes)
	file.close()
	
	indice[indice_id] = pos_novo  # Atualiza índice com nova posição
	print("BinarioCRUD: Registro %d atualizado (nova posição: %d)" % [indice_id, pos_novo])
	return true

# Marca um registro como deletado
func deletar(indice_id: int) -> bool:
	if indice_id < 0 or indice_id >= indice.size():
		push_error("BinarioCRUD: Índice inválido %d para deletar" % indice_id)
		return false
	
	var file := FileAccess.open(file_path, FileAccess.READ_WRITE)
	if file == null:
		push_error("BinarioCRUD: Erro ao abrir arquivo: %s" % FileAccess.get_open_error())
		return false
	
	var pos := indice[indice_id]
	file.seek(pos)
	file.store_8(LAPIDE_REMOVIDO)  # lápide
	file.close()
	
	print("BinarioCRUD: Registro %d deletado" % indice_id)
	indice.remove_at(indice_id)
	return true

# Retorna o número de registros ativos
func contar() -> int:
	return indice.size()

# Limpa todos os dados (apaga o arquivo)
func limpar_tudo() -> bool:
	if FileAccess.file_exists(file_path):
		var erro := DirAccess.remove_absolute(file_path)
		if erro != OK:
			push_error("BinarioCRUD: Erro ao remover arquivo: %s" % erro)
			return false
	indice.clear()
	print("BinarioCRUD: Todos os dados foram limpos")
	return true

# Verifica se um índice é válido
func indice_valido(indice_id: int) -> bool:
	return indice_id >= 0 and indice_id < indice.size()

# Retorna o tipo de classe gerenciado por este CRUD
func obter_tipo_classe() -> Variant:
	return tipo_classe

# Verifica se um objeto é compatível com este CRUD
func eh_tipo_compativel(obj: Variant) -> bool:
	if obj == null:
		return false
	
	if tipo_classe == null:
		return _validar_interface_serializavel(obj)
	
	return obj.get_script() == tipo_classe and _validar_interface_serializavel(obj)
