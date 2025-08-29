extends MarginContainer

@onready var nome_line_edit: LineEdit = %NomeLineEdit
@onready var vida_line_edit: LineEdit = %VidaLineEdit
@onready var ataque_line_edit: LineEdit = %AtaqueLineEdit
@onready var world_environment: WorldEnvironment = $WorldEnvironment

const nome_do_arquivo : String = "user://save.cfg"

func _on_salvar_pressed() -> void:
	
	var config : ConfigFile = ConfigFile.new()

	config.set_value("Player", "nome", nome_line_edit.text.strip_edges())
	config.set_value("Player", "vida", int(vida_line_edit.text))
	config.set_value("Player", "ataque", int(ataque_line_edit.text))
	
	var error = config.save(nome_do_arquivo)

	if error != OK:
		printerr("Alguma coisa deu errado: %d" % error)

func _on_carregar_pressed() -> void:
	
	if not FileAccess.file_exists(nome_do_arquivo):
		printerr("Não existe esse arquivo")
		return
		
	var config : ConfigFile = ConfigFile.new()
	var error = config.load(nome_do_arquivo)
	if error != OK:
		printerr("Não foi possível abrir o arquivo: %d" % error)
		return

	nome_line_edit.text = config.get_value("Player", "nome", "")
	vida_line_edit.text = "%d" % config.get_value("Player", "vida", "")
	ataque_line_edit.text = "%d" % config.get_value("Player", "ataque", "")
