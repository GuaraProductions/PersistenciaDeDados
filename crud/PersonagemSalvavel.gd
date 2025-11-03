extends RefCounted
class_name PersonagemSalvavel

var nome: String = ""
var nivel: int = 1
var vida: int = 100
var mana: int = 50
var experiencia: int = 0

func _init(p_nome: String = "", p_nivel: int = 1, p_vida: int = 100, p_mana: int = 50, p_experiencia: int = 0) -> void:
	nome = p_nome
	nivel = p_nivel
	vida = p_vida
	mana = p_mana
	experiencia = p_experiencia

func to_bytes() -> PackedByteArray:
	var buffer := StreamPeerBuffer.new()
	
	# Converte o nome para bytes UTF-8
	var nome_bytes := nome.to_utf8_buffer()
	
	# Armazena: tamanho_nome (4 bytes) + nome (N bytes) + stats (4x4 = 16 bytes)
	buffer.put_32(nome_bytes.size())
	buffer.put_data(nome_bytes)
	
	# Stats
	buffer.put_32(nivel)
	buffer.put_32(vida)
	buffer.put_32(mana)
	buffer.put_32(experiencia)
	
	return buffer.data_array

func from_bytes(data: PackedByteArray) -> void:
	if data.size() < 20:  # Mínimo: 4 bytes (tamanho) + 0 bytes (string) + 16 bytes (4 ints)
		push_error("PersonagemSalvavel: dados insuficientes recebidos (tamanho: %d)" % data.size())
		return
	
	var buffer := StreamPeerBuffer.new()
	buffer.data_array = data
	
	# Lê o tamanho da string
	var nome_size := buffer.get_32()
	if nome_size < 0 or nome_size > 10000:
		push_error("PersonagemSalvavel: tamanho de nome inválido: %d" % nome_size)
		return
	
	# Verifica se há bytes suficientes
	if data.size() < 20 + nome_size:
		push_error("PersonagemSalvavel: dados insuficientes para ler nome (esperado: %d, total: %d)" % [20 + nome_size, data.size()])
		return
	
	# Lê os bytes do nome
	var resultado := buffer.get_data(nome_size)
	var nome_bytes: PackedByteArray = resultado[1]
	nome = nome_bytes.get_string_from_utf8()
	
	# Stats
	nivel = buffer.get_32()
	vida = buffer.get_32()
	mana = buffer.get_32()
	experiencia = buffer.get_32()

func _to_string() -> String:
	return "PersonagemSalvavel(nome='%s', nivel=%d, vida=%d, mana=%d, exp=%d)" % [nome, nivel, vida, mana, experiencia]

func is_valid() -> bool:
	return nome != "" and nivel > 0 and vida >= 0 and mana >= 0 and experiencia >= 0
