extends CanvasLayer

@onready var vida: Label = %Vida

@export var status_player : StatusPlayer

func _process(_delta: float) -> void:
	vida.text = "%d" % status_player.vida
