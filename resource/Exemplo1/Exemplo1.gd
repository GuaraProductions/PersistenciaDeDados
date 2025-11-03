extends MarginContainer

@export var dados_pessoa : DadosPersonagem

func _ready() -> void:
	if not dados_pessoa:
		return
		
	print("dados_pessoa:\n", dados_pessoa)
