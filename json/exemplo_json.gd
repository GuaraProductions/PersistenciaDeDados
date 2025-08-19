extends MarginContainer

@onready var nome_line_edit: LineEdit = %NomeLineEdit
@onready var vida_line_edit: LineEdit = %VidaLineEdit
@onready var ataque_line_edit: LineEdit = %AtaqueLineEdit

const nome_do_arquivo : String = "res://save.json"

func _ready() -> void:
	_on_carregar_pressed()

func _on_salvar_pressed() -> void:
	
	var dados = {
		"nome" : nome_line_edit.text.strip_edges(),
		"vida" : int(vida_line_edit.text.strip_edges()),
		"ataque" : int(ataque_line_edit.text.strip_edges())
	}
	
	var arquivo = FileAccess.open(nome_do_arquivo, FileAccess.WRITE)

	if arquivo == null:
		printerr("Não foi possível abrir o arquivo")
		return
		
	var json = JSON.stringify(dados)
	arquivo.store_string(json)
	
	arquivo.close()


func _on_carregar_pressed() -> void:
	
	if not FileAccess.file_exists(nome_do_arquivo):
		printerr("Não existe esse arquivo")
		return
		
	var arquivo = FileAccess.open(nome_do_arquivo, FileAccess.READ)

	if arquivo == null:
		printerr("Não foi possível abrir o arquivo")
		return
		
	var conteudo = arquivo.get_as_text()
	arquivo.close()
	
	var dados = JSON.parse_string(conteudo)
	
	if not dados:
		printerr("Não foi possível abrir o JSON")
		return
	
	nome_line_edit.text = dados["nome"]
	vida_line_edit.text = "%d" % dados["vida"]
	ataque_line_edit.text = "%d" % dados["ataque"]
	
	
	
