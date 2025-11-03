extends Resource
class_name DadosPessoa

@export_group("Informações Pessoais")
@export var nome: String = "Fulano"

@export_group("Data de Nascimento")
@export_range(1, 31) var dia_nascimento: int = 1
@export_range(1, 12) var mes_nascimento: int = 1
@export var ano_nascimento: int = 2000

var idade: int : get = _get_idade
var fase_da_vida: String : get = _get_fase_da_vida

func _init(p_dia_nascimento: int = 1,
		   p_mes_nascimento: int = 1,
		   p_ano_nascimento: int = 2005) -> void:
	
	dia_nascimento = p_dia_nascimento
	mes_nascimento = p_mes_nascimento
	ano_nascimento = p_ano_nascimento
	var dados : Dictionary = _calcular_dados()
	
	idade = dados.idade
	fase_da_vida = dados.fase

func cache_de_dados() -> void:
	pass

func _get_idade() -> int:
	return _calcular_dados().idade
	
func _get_fase_da_vida() -> String:
	return _calcular_dados().fase

func _calcular_dados() -> Dictionary:
	var data_hoje = Time.get_date_dict_from_system()
	var idade_calculada = data_hoje.year - ano_nascimento
	
	if data_hoje.month < mes_nascimento or \
	   (data_hoje.month == mes_nascimento and data_hoje.day < dia_nascimento):
		idade_calculada -= 1
	
	var fase_calculada: String = "Idoso"
	
	if idade_calculada <= 12:
		fase_calculada = "Criança"
	elif idade_calculada <= 17:
		fase_calculada = "Adolescente"
	elif idade_calculada < 60:
		fase_calculada = "Adulto"
		
	return {"idade": idade_calculada, "fase": fase_calculada}

func _to_string() -> String:
	var resultado = "Nome: %s\nIdade: %d\nFase da vida: %s" % \
	 [nome, idade, fase_da_vida]
	
	return resultado
