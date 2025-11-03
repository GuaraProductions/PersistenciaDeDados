extends MarginContainer

@onready var nome_line_edit: LineEdit = %NomeLineEdit
@onready var vida_line_edit: LineEdit = %VidaLineEdit
@onready var ataque_line_edit: LineEdit = %AtaqueLineEdit

@export_flags("Relative Path", 
			"Bundle Resources", 
			"Change path",
			"Omit editor properties", 
			"Big Endian", 
			"Compress", 
			"Replace Subresource") var flags_resource : int 

const nome_do_arquivo : String = "user://save.res"

func _on_salvar_pressed() -> void:
	
	var nome : String = nome_line_edit.text
	var vida : int = int(vida_line_edit.text)
	var ataque : float = float(ataque_line_edit.text)
	
	var personagem := DadosPersonagem.new(nome, vida, ataque)
	
	var error := ResourceSaver.save(personagem, nome_do_arquivo, flags_resource)
	
	if error != OK:
		printerr("Não foi possível salvar o arquivo: ", error)


func _on_carregar_pressed() -> void:
	
	var personagem : DadosPersonagem = ResourceLoader.load(nome_do_arquivo)

	if personagem == null:
		printerr("Não foi possível carregar o arquivo")
		
	nome_line_edit.text = personagem.nome
	vida_line_edit.text = "%d" % [personagem.vida]
	ataque_line_edit.text = str(personagem.ataque).pad_decimals(2)
