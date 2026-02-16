extends Node2D

@export var status_player : StatusPlayer

func _ready() -> void:
	
	status_player.morreu.connect(_player_morreu)
	
func _player_morreu() -> void:
	print("morreu!")
