extends Control

func _ready():
	carregar_arquivo_cfg()
	
func salvar_arquivo_cfg():
	# Criar o objeto ConfigFile
	var config = ConfigFile.new()

	# Adicionar valores
	# Nome da seccao , nome da variavel , valor
	config.set_value("Configuracoes", "vsync", true)
	config.set_value("Configuracoes", "resolucao", "1920x1080")
	config.set_value("Configuracoes", "modo_de_exibicao", "Tela cheia")
	config.set_value("Configuracoes", "volume_musica", 6)

	# Salvar arquivo
	#config.save("user://configuracoes.cfg")
	config.save_encrypted_pass("user://configuracoes.cfg","MinhaSenhaSecreta")
	
func carregar_arquivo_cfg():
	var config = ConfigFile.new()

	# Carregar arquivo do disco
	#var err = config.load("user://configuracoes.cfg")
	var err = config.load_encrypted_pass("user://configuracoes.cfg", "MinhaSenhaSecreta")

	# Se o arquivo nao existe, ou houve erros para carregar o arquivo
	# Ignore ele
	if err != OK:
		return
		
	var valores := {}
		
	# pegar todas as seccoes
	for section in config.get_sections():
		
		valores[section] = {}
		var keys = config.get_section_keys(section)
		
		for key in keys:
			valores[section][key] = config.get_value(section,key)
	
	print(valores)
	
func limpar_arquivo():
	var config = ConfigFile.new()

	# Carregar arquivo do disco
	#var err = config.load("user://configuracoes.cfg")
	var err = config.load_encrypted_pass("user://configuracoes.cfg", "MinhaSenhaSecreta")

	# Se o arquivo nao existe, ou houve erros para carregar o arquivo
	# Ignore ele
	if err != OK:
		print(err)
		return
		
	config.clear()
	#config.save("user://configuracoes.cfg")
	DirAccess.remove_absolute("user://configuracoes.cfg")
	
