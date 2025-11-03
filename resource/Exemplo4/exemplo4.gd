extends Node

@export var dados_pessoa : DadosPessoa

func _ready() -> void:
	if not dados_pessoa:
		return
	print("dados_pessoa:\n", dados_pessoa)
