extends Resource
class_name DadosPersonagem

@export var nome: String 
@export var vida: int
@export var ataque: float

func _to_string() -> String:
	return "[%s]: nome: %s, nome: %d, ataque: %s" \
	 % ["DadosPersonagem", nome, vida, str(ataque).pad_decimals(2)]
	
func _init(p_nome: String = "", 
		   p_vida : int = 10, 
		   p_ataque : float = 50.5) -> void:
			
	nome = p_nome
	vida = p_vida
	ataque = p_ataque
