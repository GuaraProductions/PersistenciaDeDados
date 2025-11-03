extends Node

var crud: BinarioCRUD

# Funções auxiliares para colorir texto
func cor_titulo(texto: String) -> String:
	return "[color=cyan][b]" + texto + "[/b][/color]"

func cor_secao(texto: String) -> String:
	return "[color=yellow]" + texto + "[/color]"

func cor_sucesso(texto: String) -> String:
	return "[color=green]" + texto + "[/color]"

func cor_erro(texto: String) -> String:
	return "[color=red]" + texto + "[/color]"

func cor_info(texto: String) -> String:
	return "[color=gray]" + texto + "[/color]"

func cor_destaque(texto: String) -> String:
	return "[color=magenta]" + texto + "[/color]"

func _ready() -> void:
	print_rich(cor_titulo("=== TESTE COMPLETO DO CRUD BINÁRIO ===\n"))
	
	# Criar instância do CRUD
	crud = BinarioCRUD.new()
	add_child(crud)
	
	# Limpar dados anteriores para começar do zero
	crud.limpar_tudo()
	
	# Executar todos os testes
	teste_criar_registros()
	print_rich("\n" + cor_info("=".repeat(60)) + "\n")
	
	teste_ler_todos()
	print_rich("\n" + cor_info("=".repeat(60)) + "\n")
	
	teste_ler_um()
	print_rich("\n" + cor_info("=".repeat(60)) + "\n")
	
	teste_atualizar()
	print_rich("\n" + cor_info("=".repeat(60)) + "\n")
	
	teste_deletar()
	print_rich("\n" + cor_info("=".repeat(60)) + "\n")
	
	teste_validacoes()
	print_rich("\n" + cor_info("=".repeat(60)) + "\n")
	
	teste_persistencia()
	print_rich("\n" + cor_info("=".repeat(60)) + "\n")
	
	print_rich(cor_titulo("=== TESTES CONCLUÍDOS ==="))

func teste_criar_registros() -> void:
	print_rich(cor_secao("--- TESTE 1: Criar Registros ---"))
	print_rich("Criando 5 itens no CRUD...\n")
	
	var itens := [
		ItemSalvavel.new("Poção de Vida", 10),
		ItemSalvavel.new("Espada de Ferro", 1),
		ItemSalvavel.new("Escudo de Madeira", 1),
		ItemSalvavel.new("Moedas de Ouro", 500),
		ItemSalvavel.new("Pergaminho Mágico", 3)
	]
	
	for i in itens.size():
		var id := crud.criar(itens[i])
		if id >= 0:
			print_rich("  " + cor_sucesso("✓") + " Item criado com ID " + cor_destaque(str(id)) + ": " + cor_info(str(itens[i])))
		else:
			print_rich("  " + cor_erro("✗") + " Falha ao criar item: " + str(itens[i]))
	
	print_rich("\nTotal de registros no CRUD: " + cor_destaque(str(crud.contar())))

func teste_ler_todos() -> void:
	print_rich(cor_secao("--- TESTE 2: Ler Todos os Registros ---"))
	
	var itens := crud.ler_todos()
	print_rich("Registros encontrados: " + cor_destaque(str(itens.size())) + "\n")
	
	for i in itens.size():
		print_rich("  [" + cor_destaque(str(i)) + "] " + cor_info(str(itens[i])))

func teste_ler_um() -> void:
	print_rich(cor_secao("--- TESTE 3: Ler Um Registro Específico ---"))
	
	# Ler um registro válido
	var id := 2
	print_rich("Lendo registro com ID " + cor_destaque(str(id)) + "...\n")
	
	var item = crud.ler_um(id)
	if item != null:
		print_rich("  " + cor_sucesso("✓") + " Registro lido: " + cor_info(str(item)))
	else:
		print_rich("  " + cor_erro("✗") + " Falha ao ler registro")
	
	# Tentar ler um registro inválido
	print_rich("\nTentando ler registro com ID inválido (999)...")
	var item_invalido = crud.ler_um(999)
	if item_invalido == null:
		print_rich("  " + cor_sucesso("✓") + " Validação funcionou: retornou null para ID inválido")

func teste_atualizar() -> void:
	print_rich(cor_secao("--- TESTE 4: Atualizar Registro ---"))
	
	var id := 1
	print_rich("Atualizando registro com ID " + cor_destaque(str(id)) + "...\n")
	
	# Ler o item atual
	var item_antigo = crud.ler_um(id)
	print_rich("  Antes: " + cor_info(str(item_antigo)))
	
	# Atualizar
	var item_novo := ItemSalvavel.new("Espada de Aço (Melhorada)", 1)
	var sucesso := crud.atualizar(id, item_novo)
	
	if sucesso:
		print_rich("  " + cor_sucesso("✓") + " Atualização bem-sucedida")
		var item_atualizado = crud.ler_um(id)
		print_rich("  Depois: " + cor_sucesso(str(item_atualizado)))
	else:
		print_rich("  " + cor_erro("✗") + " Falha na atualização")

func teste_deletar() -> void:
	print_rich(cor_secao("--- TESTE 5: Deletar Registro ---"))
	
	var total_antes := crud.contar()
	print_rich("Registros antes da deleção: " + cor_destaque(str(total_antes)))
	
	var id := 3
	print_rich("Deletando registro com ID " + cor_destaque(str(id)) + "...\n")
	
	var sucesso := crud.deletar(id)
	
	if sucesso:
		print_rich("  " + cor_sucesso("✓") + " Registro deletado com sucesso")
		var total_depois := crud.contar()
		print_rich("  Registros após deleção: " + cor_destaque(str(total_depois)))
		
		# Mostrar itens restantes
		print_rich("\n  Itens restantes:")
		var itens := crud.ler_todos()
		for i in itens.size():
			print_rich("    [" + cor_destaque(str(i)) + "] " + cor_info(str(itens[i])))
	else:
		print_rich("  " + cor_erro("✗") + " Falha ao deletar")

func teste_validacoes() -> void:
	print_rich(cor_secao("--- TESTE 6: Validações e Proteções ---"))
	
	# Tentar criar item inválido (nome vazio)
	print_rich("1. Tentando criar item com nome vazio...")
	var item_invalido := ItemSalvavel.new("", 10)
	var id := crud.criar(item_invalido)
	if id < 0:
		print_rich("  " + cor_sucesso("✓") + " Validação funcionou: item inválido rejeitado\n")
	else:
		print_rich("  " + cor_erro("✗") + " Validação falhou: item inválido foi aceito\n")
	
	# Tentar criar item nulo
	print_rich("2. Tentando criar item nulo...")
	id = crud.criar(null)
	if id < 0:
		print_rich("  " + cor_sucesso("✓") + " Validação funcionou: item nulo rejeitado\n")
	else:
		print_rich("  " + cor_erro("✗") + " Validação falhou: item nulo foi aceito\n")
	
	# Tentar atualizar com índice inválido
	print_rich("3. Tentando atualizar com índice inválido (999)...")
	var item_valido := ItemSalvavel.new("Item Teste", 1)
	var sucesso := crud.atualizar(999, item_valido)
	if not sucesso:
		print_rich("  " + cor_sucesso("✓") + " Validação funcionou: índice inválido rejeitado\n")
	else:
		print_rich("  " + cor_erro("✗") + " Validação falhou: índice inválido foi aceito\n")
	
	# Tentar deletar com índice inválido
	print_rich("4. Tentando deletar com índice inválido (-1)...")
	sucesso = crud.deletar(-1)
	if not sucesso:
		print_rich("  " + cor_sucesso("✓") + " Validação funcionou: índice inválido rejeitado")
	else:
		print_rich("  " + cor_erro("✗") + " Validação falhou: índice inválido foi aceito")

func teste_persistencia() -> void:
	print_rich(cor_secao("--- TESTE 7: Persistência de Dados ---"))
	print_rich("Verificando se os dados persistem após recarregar o índice...\n")
	
	# Contar registros atuais
	var total_antes := crud.contar()
	print_rich("Registros antes de recarregar: " + cor_destaque(str(total_antes)))
	
	# Recarregar o índice (simula fechar e reabrir o jogo)
	crud.carregar_indice()
	
	var total_depois := crud.contar()
	print_rich("Registros após recarregar: " + cor_destaque(str(total_depois)))
	
	if total_antes == total_depois:
		print_rich("\n  " + cor_sucesso("✓") + " Persistência funcionando: dados foram preservados")
		
		# Mostrar os dados
		print_rich("\n  Dados persistidos:")
		var itens := crud.ler_todos()
		for i in itens.size():
			print_rich("    [" + cor_destaque(str(i)) + "] " + cor_info(str(itens[i])))
	else:
		print_rich("\n  " + cor_erro("✗") + " Falha na persistência: dados foram perdidos")
