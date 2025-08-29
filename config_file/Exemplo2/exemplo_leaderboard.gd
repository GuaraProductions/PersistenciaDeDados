extends MarginContainer

#region JaFeito

@onready var grade_pontuacoes: GridContainer = %ScoreGrid

@export var estilo: StyleBoxFlat
@export var estilo_cabecalho: StyleBoxFlat
@onready var cabecalho_hbox: HBoxContainer = %Cabecalho

const CAMINHO_ARQUIVO := "user://scores.cfg"

func _ready() -> void:
	var config := ConfigFile.new()
	
	if not FileAccess.file_exists(CAMINHO_ARQUIVO):
		_criar_dados_teste(config)
	else:
		config.load(CAMINHO_ARQUIVO)

	# monta lista de jogadores
	var jogadores : Array = _ler_valores_do_jogador(config)

	# constrói o grid: limpa antes e garante 3 colunas
	_limpar_grade(grade_pontuacoes)
	grade_pontuacoes.columns = 3
	
	# Adicionar cabeçalho
	_adicionar_linha_cabecalho(grade_pontuacoes)

	# Adicionar jogadores
	for i in range(jogadores.size()):
		var j = jogadores[i]
		var posicao := i + 1

		# medalhas e cores para top 3
		var medalha := ""
		var cor := "white"
		if i == 0:
			medalha = " 🥇"
			cor = "gold"
		elif i == 1:
			medalha = " 🥈"
			cor = "silver"
		elif i == 2:
			medalha = " 🥉"
			cor = "#CD7F32" # bronze

		# --- coluna 1: posição (+ medalha)
		var rotulo_posicao := _criar_richtext("%d%s" % [posicao, medalha])
		grade_pontuacoes.add_child(rotulo_posicao)

		# --- coluna 2: nome (com cor se top-3)
		var texto_nome = j["name"]
		if i < 3:
			texto_nome = "[color=%s]%s[/color]" % [cor, texto_nome]
		var rotulo_nome := _criar_richtext(texto_nome)
		grade_pontuacoes.add_child(rotulo_nome)

		# --- coluna 3: pontuação
		var rotulo_pontuacao := _criar_richtext(str(j["score"]))
		grade_pontuacoes.add_child(rotulo_pontuacao)

func _adicionar_linha_cabecalho(grade: GridContainer) -> void:
	var cabecalhos := ["Posição", "Jogador", "Pontuação"]
	for titulo in cabecalhos:
		var cabecalho := _criar_richtext_cabecalho("[b]%s[/b]" % titulo)
		cabecalho_hbox.add_child(cabecalho)

func _criar_richtext_cabecalho(texto: String) -> RichTextLabel:
	var r := _criar_richtext(texto, estilo_cabecalho)
	# cor sutil para destacar o cabeçalho
	r.add_theme_color_override("default_color", Color.hex(0xDADADAFF))
	return r

# utilitário: cria um RichTextLabel pronto para BBCode
func _criar_richtext(texto: String, stylebox: StyleBoxFlat = estilo) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.scroll_active = false
	r.fit_content = true
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.add_theme_font_size_override("bold_font_size", 32)
	r.add_theme_stylebox_override("normal", stylebox)
	r.append_text(texto)
	return r

# utilitário: remove filhos do grid
func _limpar_grade(grade: GridContainer) -> void:
	for filho in grade.get_children():
		grade.remove_child(filho)
		filho.queue_free()

func _criar_dados_teste(config: ConfigFile) -> void:

	config.set_value("ohibrido", "score", 150)
	config.set_value("Gugu_animY", "score", 150)
	config.set_value("Pingo", "score", 125)
	config.set_value("Fireyest", "score", 125)
	config.set_value("joaobk8193", "score", 100)
	config.set_value("nightduke4909", "score", 75)
	config.set_value("LyyBrainTime", "score", 75)
	config.set_value("eduardoarmstrong8", "score", 75)
	config.set_value("meutio2009", "score", 75)
	config.set_value("elitegamer4928", "score", 75)
	config.set_value("theclipsthe", "score", 75)
	config.set_value("midodanca", "score", 75)
	config.set_value("cachorroquente17", "score", 75)
	config.set_value("gatsukai-f7k", "score", 75)
	config.set_value("elcioam", "score", 75)
	config.set_value("ItaloCassini", "score", 50)
	config.set_value("LeonardoAragaoDev1", "score", 50)
	config.set_value("ricardofrois8531", "score", 50)
	config.set_value("MarceloAugustoInf", "score", 50)
	config.set_value("julio_prado", "score", 25)
	config.set_value("wallacymazonidev", "score", 25)

	config.save(CAMINHO_ARQUIVO)
	
#endregion

func _ler_valores_do_jogador(config: ConfigFile) -> Array[Dictionary]:
	var jogadores : Array[Dictionary] = []
	
	for secao in config.get_sections():
		var jogador : Dictionary = {"name": secao}
		for chave in config.get_section_keys(secao):
			jogador[chave] = config.get_value(secao, chave)
		jogadores.append(jogador)
		
	jogadores.sort_custom(func(a,b): return b["score"] < a["score"])
		
	return jogadores
	
