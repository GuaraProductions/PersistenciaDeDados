extends Node

@export var carro : Carro

func _ready() -> void:
	print("Carro em Node 1: ", carro)
	
	var carro_duplicado := carro.duplicate()
	carro_duplicado.velocidade = 255
	print("Carro duplicado em Node 1: ", carro_duplicado)
