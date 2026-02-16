extends Node
class_name SQLController

const PATH := "user://players_data.db"
const STOCK_IMAGE := "res://icon.svg" # Caminho da imagem padrão

var db : SQLite = null

func _ready() -> void:
	db = SQLite.new()
	db.path = PATH

# --- 1. GERENCIAMENTO DA TABELA ---
func create_database() -> void:
	db.open_db()
	var table = {
		"id": {"data_type": "int", "primary_key": true, "auto_increment": true},
		"name": {"data_type": "text", "not_null": true},
		"score": {"data_type": "int"},
		"active": {"data_type": "int"}, # 0 = False, 1 = True
		"avatar": {"data_type": "blob"}
	}
	db.create_table("players", table)
	db.close_db()
	print("Tabela criada!")

func clean_database() -> void:
	db.open_db()
	db.query("DROP TABLE IF EXISTS players;")
	db.close_db()
	print("Banco limpo/deletado!")

# --- 2. INSERIR JOGADOR (CREATE) ---
func insert_player(p_name: String, p_score: int, p_active: bool, img_path: String) -> void:
	var buffer = null
	
	# Lógica do BLOB: Se o arquivo existe, converte para binário
	if img_path != "" and FileAccess.file_exists(img_path):
		var image = load(img_path).get_image()
		buffer = image.save_png_to_buffer()
	
	db.open_db()
	var data = {
		"name": p_name,
		"score": p_score,
		"active": 1 if p_active else 0, # Converte Bool para Int
		"avatar": buffer # Salva o binário ou NULL
	}
	db.insert_row("players", data)
	db.close_db()
	print("Jogador inserido!")

# --- 3. ATUALIZAR JOGADOR (UPDATE) ---
func update_player(id: int, p_name: String, p_score: int, p_active: bool) -> void:
	db.open_db()
	# Nota: Neste exemplo simplificado, não estou atualizando a imagem no update, mas poderia.
	var condition = "id = " + str(id)
	var data = {
		"name": p_name,
		"score": p_score,
		"active": 1 if p_active else 0
	}
	db.update_rows("players", condition, data)
	db.close_db()
	print("Jogador atualizado!")

# --- 4. DELETAR JOGADOR (DELETE) ---
func delete_player(id: int) -> void:
	db.open_db()
	db.delete_rows("players", "id = " + str(id))
	db.close_db()
	print("Jogador deletado!")

# --- 5. CONSULTAR (READ) ---
func get_all_players() -> Array:
	db.open_db()
	var result = db.select_rows("players", "", ["*"])
	db.close_db()
	return result

# Helper para a UI converter o BLOB de volta para Textura
func blob_to_texture(blob_data) -> ImageTexture:
	var img = Image.new()
	var error = ERR_INVALID_DATA
	
	# Tenta carregar do buffer se ele existir e não estiver vazio
	if blob_data != null:
		if blob_data is PackedByteArray:
			error = img.load_png_from_buffer(blob_data)
	
	# Se deu erro ou é nulo, usa a Stock Image
	if error != OK:
		img = load(STOCK_IMAGE).get_image()
	
	return ImageTexture.create_from_image(img)
