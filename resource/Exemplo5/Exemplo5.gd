extends Control

@export_enum("Save", "Load") var example_state : int 

class RecursoInterno:
	extends Resource
	@export var value = 5

var caminho : String = "user://inner_class.tres"

func _ready():
	if example_state == 0:
		save_resource()
	else:
		load_resource()

func load_resource() -> void:
	print("Tentando carregar...")
	var res = load(caminho)
	print(res.value)
	print("Carregado!")

func save_resource() -> void:
	print("Tentando salvar...")
	var my_res = RecursoInterno.new()
	ResourceSaver.save(my_res, caminho)
	print("Salvo!")
