extends Resource
class_name Carro

@export var nome: String 
@export_range(0, 600, 0.01, "suffix:km/h") var velocidade: float

func _to_string() -> String:
	return "Nome: %s, Velocidade: %s km/h" % [nome, str(velocidade).pad_decimals(2)]
