extends Control

@export var recurso_filho : RecursoFilho
@export_flags("Relative Path", 
			"Bundle Resources", 
			"Change path",
			"Omit editor properties", 
			"Big Endian", 
			"Compress", 
			"Replace Subresource") var flags_resource : int 

var recurso_principal: RecursoPrincipal
var caminho : String = "user://meu_recurso.tres"
var caminho2 : String = "user://meu_recurso_com_flags.tres"

func _ready() -> void:
	recurso_principal = RecursoPrincipal.new()
	recurso_principal.nome = "Recurso Principal"
	recurso_principal.imagem = load("res://assets/chibi-guara.png")
	
	if recurso_filho:
		recurso_principal.sub_recurso = recurso_filho
	else:
		recurso_principal.sub_recurso = RecursoFilho.new()
		recurso_principal.sub_recurso.valor = 123
		recurso_principal.sub_recurso.arranjo = ["item1", "item2", "item3"]
		
	print("Estado inicial — nome:", recurso_principal.nome, "| valor do sub:", recurso_principal.sub_recurso.valor)
	salvar_no_disco()
	salvar_no_disco_com_flags()

func salvar_no_disco() -> void:
	var erro = ResourceSaver.save(recurso_principal, caminho)
	if erro == OK:
		print("Salvo com sucesso em:", caminho)
	else:
		printerr("Erro ao salvar:", erro)
		
func salvar_no_disco_com_flags() -> void:
	var erro = ResourceSaver.save(recurso_principal, caminho2, flags_resource)
	if erro == OK:
		print("Salvo com sucesso em:", caminho2)
	else:
		printerr("Erro ao salvar:", erro)

func carregar_do_disco() -> void:
	var res = ResourceLoader.load(caminho)
	if res and res is RecursoPrincipal:
		recurso_principal = res
		print("Carregado com sucesso:")
		print("  nome:", recurso_principal.imagem)
		print("  sub_recurso.valor:", recurso_principal.sub_recurso.valor)
	else:
		printerr("Falha ao carregar ou tipo incorreto")
