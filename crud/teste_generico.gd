extends Node

# Teste de CRUD genérico com múltiplas classes diferentes

func _ready() -> void:
	print_rich("[color=cyan][b]" + "=".repeat(70) + "[/b][/color]")
	print_rich("[color=cyan][b]TESTE CRUD GENÉRICO - MÚLTIPLAS CLASSES[/b][/color]")
	print_rich("[color=cyan][b]" + "=".repeat(70) + "[/b][/color]\n")
	
	testar_crud_com_items()
	print("\n")
	testar_crud_com_personagens()
	print("\n")
	testar_incompatibilidade_de_tipos()
	print("\n")
	
	print_rich("[color=green][b]✓ Todos os testes de CRUD genérico concluídos![/b][/color]")

func testar_crud_com_items() -> void:
	print_rich("[color=yellow][b]▶ Testando CRUD com ItemSalvavel[/b][/color]")
	
	var crud := BinarioCRUD.new()
	crud.caminho_arquivo = "user://test_items_genericos.dat"
	
	# Limpar arquivo anterior
	if FileAccess.file_exists(crud.caminho_arquivo):
		DirAccess.remove_absolute(crud.caminho_arquivo)
	
	# Criar items
	var item1 := ItemSalvavel.new("Poção de Vida", 5)
	var item2 := ItemSalvavel.new("Elixir de Mana", 3)
	var item3 := ItemSalvavel.new("Antídoto", 10)
	
	var id1 := crud.criar(item1)
	var id2 := crud.criar(item2)
	var id3 := crud.criar(item3)
	
	print_rich("  [color=gray]→ Criados 3 items com IDs: %d, %d, %d[/color]" % [id1, id2, id3])
	
	# Verificar tipo detectado
	var tipo: Variant = crud.obter_tipo_classe()
	print_rich("  [color=gray]→ Tipo detectado: %s[/color]" % str(tipo))
	
	# Ler todos
	var items: Array = crud.ler_todos()
	print_rich("  [color=gray]→ Total de items lidos: %d[/color]" % items.size())
	for item in items:
		print_rich("    [color=white]%s[/color]" % str(item))
	
	# Atualizar
	item1.quantidade = 15
	var sucesso := crud.atualizar(id1, item1)
	print_rich("  [color=gray]→ Item atualizado: %s[/color]" % ("SIM" if sucesso else "NÃO"))
	
	# Deletar
	sucesso = crud.deletar(id2)
	print_rich("  [color=gray]→ Item deletado: %s[/color]" % ("SIM" if sucesso else "NÃO"))
	
	items = crud.ler_todos()
	print_rich("  [color=green]✓ Total final de items: %d[/color]" % items.size())

func testar_crud_com_personagens() -> void:
	print_rich("[color=yellow][b]▶ Testando CRUD com PersonagemSalvavel[/b][/color]")
	
	var crud := BinarioCRUD.new()
	crud.caminho_arquivo = "user://test_personagens_genericos.dat"
	
	# Limpar arquivo anterior
	if FileAccess.file_exists(crud.caminho_arquivo):
		DirAccess.remove_absolute(crud.caminho_arquivo)
	
	# Carregar classe dinamicamente
	var PersonagemClass = load("res://crud/PersonagemSalvavel.gd")
	
	# Criar personagens
	var p1 = PersonagemClass.new("Aragorn", 45, 850, 200, 98500)
	var p2 = PersonagemClass.new("Gandalf", 99, 500, 9999, 999999)
	var p3 = PersonagemClass.new("Frodo", 12, 300, 100, 2400)
	
	var id1 := crud.criar(p1)
	var id2 := crud.criar(p2)
	var id3 := crud.criar(p3)
	
	print_rich("  [color=gray]→ Criados 3 personagens com IDs: %d, %d, %d[/color]" % [id1, id2, id3])
	
	# Verificar tipo detectado
	var tipo: Variant = crud.obter_tipo_classe()
	print_rich("  [color=gray]→ Tipo detectado: %s[/color]" % str(tipo))
	
	# Ler todos
	var personagens: Array = crud.ler_todos()
	print_rich("  [color=gray]→ Total de personagens lidos: %d[/color]" % personagens.size())
	for personagem in personagens:
		print_rich("    [color=white]%s[/color]" % str(personagem))
	
	# Atualizar (subir de nível)
	p1.nivel = 46
	p1.vida = 900
	p1.experiencia = 102000
	var sucesso := crud.atualizar(id1, p1)
	print_rich("  [color=gray]→ Personagem atualizado: %s[/color]" % ("SIM" if sucesso else "NÃO"))
	
	# Ler um específico
	var personagem_lido: Variant = crud.ler_um(id1)
	if personagem_lido:
		print_rich("  [color=gray]→ Personagem após atualização: %s[/color]" % str(personagem_lido))
	
	# Deletar
	sucesso = crud.deletar(id3)
	print_rich("  [color=gray]→ Personagem deletado: %s[/color]" % ("SIM" if sucesso else "NÃO"))
	
	personagens = crud.ler_todos()
	print_rich("  [color=green]✓ Total final de personagens: %d[/color]" % personagens.size())

func testar_incompatibilidade_de_tipos() -> void:
	print_rich("[color=yellow][b]▶ Testando validação de tipos incompatíveis[/b][/color]")
	
	var crud := BinarioCRUD.new()
	crud.caminho_arquivo = "user://test_tipo_unico.dat"
	
	# Limpar arquivo anterior
	if FileAccess.file_exists(crud.caminho_arquivo):
		DirAccess.remove_absolute(crud.caminho_arquivo)
	
	# Criar com ItemSalvavel
	var item := ItemSalvavel.new("Espada Lendária", 1)
	var id1 := crud.criar(item)
	print_rich("  [color=gray]→ Criado ItemSalvavel com ID: %d[/color]" % id1)
	
	# Carregar classe dinamicamente
	var PersonagemClass = load("res://crud/PersonagemSalvavel.gd")
	
	# Tentar criar com PersonagemSalvavel (deve falhar)
	var personagem = PersonagemClass.new("Intruso", 1, 100, 50, 0)
	var id2 := crud.criar(personagem)
	
	if id2 == -1:
		print_rich("  [color=green]✓ Validação funcionou: tipo incompatível rejeitado[/color]")
	else:
		print_rich("  [color=red]✗ ERRO: tipo incompatível foi aceito![/color]")
	
	# Verificar conteúdo do arquivo
	var items: Array = crud.ler_todos()
	print_rich("  [color=gray]→ Total de registros: %d (esperado: 1)[/color]" % items.size())
	
	# Criar novo CRUD do zero para PersonagemSalvavel
	var crud2 := BinarioCRUD.new()
	crud2.caminho_arquivo = "user://test_tipo_novo.dat"
	
	if FileAccess.file_exists(crud2.caminho_arquivo):
		DirAccess.remove_absolute(crud2.caminho_arquivo)
	
	var id3 := crud2.criar(personagem)
	print_rich("  [color=gray]→ PersonagemSalvavel criado em novo arquivo com ID: %d[/color]" % id3)
	print_rich("  [color=green]✓ Cada CRUD mantém seu próprio tipo[/color]")
