extends RefCounted
class_name ItemSalvavel

var nome: String = ""
var quantidade: int = 0

func _init(p_nome: String = "", p_quantidade: int = 0) -> void:
	nome = p_nome
	quantidade = p_quantidade

func to_bytes() -> PackedByteArray:
	var buffer := StreamPeerBuffer.new()
	
	# Converte o nome para bytes UTF-8
	var nome_bytes := nome.to_utf8_buffer()
	
	# Armazena: tamanho_nome (4 bytes) + nome (N bytes) + quantidade (4 bytes)
	buffer.put_32(nome_bytes.size())
	buffer.put_data(nome_bytes)
	buffer.put_32(quantidade)
	
	return buffer.data_array

func from_bytes(data: PackedByteArray) -> void:
	if data.size() < 8:  # Mínimo: 4 bytes (tamanho) + 0 bytes (string vazia) + 4 bytes (quantidade)
		push_error("ItemSalvavel: dados insuficientes recebidos (tamanho: %d)" % data.size())
		return
	
	var buffer := StreamPeerBuffer.new()
	buffer.data_array = data
	
	# Lê o tamanho da string
	var nome_size := buffer.get_32()
	if nome_size < 0 or nome_size > 10000:  # Proteção contra valores absurdos
		push_error("ItemSalvavel: tamanho de nome inválido: %d" % nome_size)
		return
	
	# Verifica se há bytes suficientes
	if data.size() < 8 + nome_size:
		push_error("ItemSalvavel: dados insuficientes para ler nome (esperado: %d, total: %d)" % [8 + nome_size, data.size()])
		return
	
	# Lê os bytes do nome
	var resultado := buffer.get_data(nome_size)  # get_data retorna [erro, dados]
	var nome_bytes: PackedByteArray = resultado[1]
	nome = nome_bytes.get_string_from_utf8()
	
	# Lê a quantidade
	quantidade = buffer.get_32()

func _to_string() -> String:
	return "ItemSalvavel(nome='%s', quantidade=%d)" % [nome, quantidade]

func is_valid() -> bool:
	return nome != "" and quantidade >= 0
