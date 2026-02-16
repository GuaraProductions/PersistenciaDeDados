extends Resource
class_name StatusPlayer

signal morreu()

@export var vida : int : set = set_vida

func set_vida(p_vida: int) -> void:
	vida = p_vida
	if vida <= 0:
		morreu.emit()
