extends Node

# O prefixo "res://" salva no projeto, "user://" na pasta de dados do usuário (recomendado para escrita)
const PATH := "user://database.db"
var db : SQLite = null

func _ready() -> void:
	db = SQLite.new()
	db.path = PATH
	
	# Executa os testes atômicos
	reset_database()
	demonstrate_create()
	demonstrate_insert()
	demonstrate_select_filtered()
	demonstrate_update()
	demonstrate_delete()
	demonstrate_custom_query()

### 1. Resetar/Limpar o Banco (Bom para testes)
func reset_database() -> void:
	db.open_db()
	# Apaga a tabela se ela já existir para começar do zero no seu vídeo
	db.query("DROP TABLE IF EXISTS players;")
	db.close_db()

### 2. Criação de Tabela (DDL)
func demonstrate_create() -> void:
	db.open_db()
	var table_structure = {
		"id": {"data_type": "int", "primary_key": true, "not_null": true},
		"name": {"data_type": "text", "not_null": true},
		"score": {"data_type": "int", "default": 0},
		"active": {"data_type": "int"}, # SQLite usa 0 ou 1 para booleanos
		"avatar": {"data_type": "blob"}
	}
	db.create_table("players", table_structure)
	print("Tabela 'players' criada com sucesso.")
	db.close_db()

### 3. Inserção de Dados (DML - Insert)
func demonstrate_insert() -> void:
	db.open_db()
	var players = [
		{"id": 1, "name": "Alice", "score": 1500, "active": 1},
		{"id": 2, "name": "Bob", "score": 2500, "active": 1},
		{"id": 3, "name": "Charlie", "score": 500, "active": 0}
	]
	
	for p in players:
		db.insert_row("players", p)
	
	print("Três jogadores inseridos.")
	db.close_db()

### 4. Consultas com Filtros e Ordenação (DML - Select)
func demonstrate_select_filtered() -> void:
	db.open_db()
	# Seleciona jogadores ativos com score > 1000, ordenando pelo score descendente
	# O terceiro argumento ["*"] seleciona todas as colunas
	var result = db.select_rows("players", "active = %d AND score > %d" % [1, 100], ["name", "score"])
	
	print("Jogadores Elite (Score > 1000):")
	for row in result:
		print("- ", row["name"], ": ", row["score"])
	db.close_db()

### 5. Atualização de Dados (DML - Update)
func demonstrate_update() -> void:
	db.open_db()
	# Atualiza o score do Charlie porque ele subiu de nível
	db.update_rows("players", "name = 'Charlie'", {"score": 800, "active": 1})
	print("Dados do Charlie atualizados.")
	db.close_db()

### 6. Deleção de Dados (DML - Delete)
func demonstrate_delete() -> void:
	db.open_db()
	# Remove jogadores com score muito baixo
	db.delete_rows("players", "score < 600")
	print("Registros com score baixo removidos.")
	db.close_db()

### 7. Queries Manuais (O poder total do SQL)
# Ideal para mostrar funções como COUNT, SUM, AVG ou JOINs complexos
func demonstrate_custom_query() -> void:
	db.open_db()
	# Exemplo: Média de pontuação de todos os jogadores
	db.query("SELECT AVG(score) as media FROM players;")
	#db.query_with_bindings("SELECT AVG(score) as media FROM players WHERE score > ?;", [30])
	
	# O resultado de db.query() fica em db.query_result
	var media = db.query_result[0]["media"]
	print("A média de pontuação atual é: ", media)
	db.close_db()
