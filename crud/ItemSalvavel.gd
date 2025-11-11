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
	if data.size() < 8:
		push_error("Impossivel carregar esses dados")
		return
		
	var buffer := StreamPeerBuffer.new()
	buffer.data_array = data
	
	var nome_size := buffer.get_32()
	var resultado := buffer.get_data(nome_size)
	
	if resultado[0] != OK:
		printerr("Nao foi possivel carregar os dados")
		return
		
	nome = resultado[1].get_string_from_utf8()
	quantidade = buffer.get_32()

func _to_string() -> String:
	return "ItemSalvavel(nome='%s', quantidade=%d)" % [nome, quantidade]

func is_valid() -> bool:
	return nome != "" and quantidade >= 0
