extends Control

var recurso_principal: RecursoPrincipal
var recurso_com_filho_nao_interno : RecursoPrincipal

@export var recurso_filho : RecursoFilho

# Funções auxiliares para colorir texto
func cor_titulo(texto: String) -> String:
	return "[color=cyan][b]" + texto + "[/b][/color]"

func cor_secao(texto: String) -> String:
	return "[color=yellow]" + texto + "[/color]"

func cor_sucesso(texto: String) -> String:
	return "[color=green]" + texto + "[/color]"

func cor_erro(texto: String) -> String:
	return "[color=red]" + texto + "[/color]"

func cor_info(texto: String) -> String:
	return "[color=gray]" + texto + "[/color]"

func cor_destaque(texto: String) -> String:
	return "[color=magenta]" + texto + "[/color]"

func cor_aviso(texto: String) -> String:
	return "[color=orange]" + texto + "[/color]"

func _ready():
	# Criar recurso principal com sub-recurso INTERNO (criado em código)
	recurso_principal = RecursoPrincipal.new()
	recurso_principal.nome = "Principal A (com filho interno)"
	recurso_principal.imagem = load("res://assets/chibi-guara.png")
	recurso_principal.sub_recurso = RecursoFilho.new()  # RECURSO INTERNO (sem path)
	recurso_principal.sub_recurso.valor = 42
	recurso_principal.sub_recurso.arranjo = ["item1", "item2", "item3"]
	
	# Criar recurso com sub-recurso EXTERNO (carregado de arquivo .tres)
	recurso_com_filho_nao_interno = RecursoPrincipal.new()
	recurso_com_filho_nao_interno.nome = "Principal B (com filho externo)"
	recurso_com_filho_nao_interno.imagem = load("res://assets/chibi-guara.png")
	if recurso_filho:
		recurso_com_filho_nao_interno.sub_recurso = recurso_filho  # RECURSO EXTERNO (com path)
	else:
		print_rich(cor_aviso("AVISO: @export var recurso_filho não foi configurado no editor!"))
		recurso_com_filho_nao_interno.sub_recurso = RecursoFilho.new()
	
	print_rich(cor_titulo("=== EXEMPLO 6b: Demonstração de duplicate() e duplicate_deep() ===\n"))
	print_rich(cor_titulo("=== CONFIGURAÇÃO INICIAL ===\n"))
	print_rich(cor_secao("RECURSO A - Com filho INTERNO:"))
	print_estado_inicial(recurso_principal)
	
	print_rich(cor_secao("RECURSO B - Com filho EXTERNO:"))
	print_estado_inicial(recurso_com_filho_nao_interno)
	print_rich(cor_info("=".repeat(60) + "\n"))
	
	# Demonstrar cada tipo de duplicação
	exemplo_duplicate_copia_rasa()
	print_rich("\n" + cor_info("=".repeat(60)) + "\n")
	
	exemplo_duplicate_copia_profunda()
	print_rich("\n" + cor_info("=".repeat(60)) + "\n")
	
	exemplo_duplicate_deep_internal()
	print_rich("\n" + cor_info("=".repeat(60)) + "\n")
	
	exemplo_duplicate_deep_all()
	print_rich("\n" + cor_info("=".repeat(60)) + "\n")
	
	print_rich(cor_titulo("=== Fim do Exemplo 6b ==="))

#region FUNÇÕES AUXILIARES DE PRINT

func print_estado_inicial(recurso: RecursoPrincipal) -> void:
	print_rich("  Nome: " + cor_destaque(recurso.nome))
	print_rich("  Sub-recurso valor: " + cor_destaque(str(recurso.sub_recurso.valor)))
	print_rich("  Sub-recurso arranjo: " + cor_destaque(str(recurso.sub_recurso.arranjo)))
	var path_info = recurso.sub_recurso.resource_path if recurso.sub_recurso.resource_path else cor_info("(sem path - INTERNO)")
	print_rich("  Sub-recurso path: " + path_info)
	print_rich("  ID do recurso principal: " + cor_info(str(recurso.get_instance_id())))
	print_rich("  ID do sub-recurso: " + cor_info(str(recurso.sub_recurso.get_instance_id())))
	print()

func print_comparacao_recursos(copia: RecursoPrincipal, original: RecursoPrincipal, label: String = "") -> void:
	if label:
		print_rich(label)
	var sao_iguais = copia == original
	print_rich("  Recurso principal é o mesmo? " + (cor_erro("true") if sao_iguais else cor_sucesso("false")) + " " + cor_info("(false)"))
	print_rich("  ID da cópia: " + cor_destaque(str(copia.get_instance_id())) + " | ID original: " + cor_destaque(str(original.get_instance_id())))

func print_comparacao_subrecursos(copia: RecursoPrincipal, original: RecursoPrincipal, esperado_compartilhado: bool = false) -> void:
	var sao_iguais = copia.sub_recurso == original.sub_recurso
	var status = cor_aviso("(true - COMPARTILHADO!)") if esperado_compartilhado else cor_sucesso("(false - DUPLICADO!)")
	var cor_resultado = cor_aviso(str(sao_iguais)) if sao_iguais else cor_sucesso(str(sao_iguais))
	print_rich("  Sub-recurso é o mesmo? " + cor_resultado + " " + status)
	print_rich("  ID sub-recurso cópia: " + cor_destaque(str(copia.sub_recurso.get_instance_id())))
	print_rich("  ID sub-recurso original: " + cor_destaque(str(original.sub_recurso.get_instance_id())))
	print()

func print_modificacao_propriedade(copia: RecursoPrincipal, original: RecursoPrincipal, propriedade: String, novo_valor) -> void:
	print_rich("Mudando copia.%s para '%s':" % [propriedade, novo_valor])
	print_rich("  %s da cópia: " % propriedade + cor_destaque(str(copia.get(propriedade))))
	print_rich("  %s do original: " % propriedade + cor_destaque(str(original.get(propriedade))) + " " + cor_sucesso("(não foi afetado)"))
	print()

func print_modificacao_subrecurso(copia: RecursoPrincipal, original: RecursoPrincipal, novo_valor: int, novo_item: String, foi_afetado: bool = false) -> void:
	var status = cor_erro("(FOI AFETADO!)") if foi_afetado else cor_sucesso("(NÃO foi afetado)")
	print_rich("Mudando copia.sub_recurso.valor para %d e adicionando '%s' ao arranjo:" % [novo_valor, novo_item])
	print_rich("  Sub-recurso valor da cópia: " + cor_destaque(str(copia.sub_recurso.valor)))
	print_rich("  Sub-recurso valor do original: " + cor_destaque(str(original.sub_recurso.valor)) + " " + status)
	print_rich("  Sub-recurso arranjo da cópia: " + cor_destaque(str(copia.sub_recurso.arranjo)))
	print_rich("  Sub-recurso arranjo do original: " + cor_destaque(str(original.sub_recurso.arranjo)) + " " + status)

func print_teste_modificacao_interna(copia: RecursoPrincipal, original: RecursoPrincipal, valor_original: int) -> void:
	print_rich("Mudando copia_internal.sub_recurso.valor para 333:")
	print_rich("  Valor da cópia: " + cor_destaque(str(copia.sub_recurso.valor)))
	print_rich("  Valor do original: " + cor_destaque(str(original.sub_recurso.valor)))
	
	if valor_original == original.sub_recurso.valor:
		print_rich("  -> Sub-recurso " + cor_sucesso("FOI duplicado") + " (era local)")
	else:
		print_rich("  -> Sub-recurso " + cor_aviso("NÃO foi duplicado") + " (era compartilhado)")

func print_comparacao_arrays(copia: RecursoPrincipal, original: RecursoPrincipal) -> void:
	var array_duplicado = copia.sub_recurso.arranjo != original.sub_recurso.arranjo
	var resultado = cor_sucesso("true") if array_duplicado else cor_erro("false")
	print_rich("  Array foi duplicado? " + resultado)
	if array_duplicado:
		print_rich("  -> " + cor_sucesso("Arrays são independentes"))
	else:
		print_rich("  -> " + cor_aviso("Arrays são compartilhados"))

func print_comparacao_recursos_externos(copia: RecursoPrincipal, original: RecursoPrincipal) -> void:
	var imagem_duplicada = copia.imagem != original.imagem
	var resultado = cor_sucesso("true") if imagem_duplicada else cor_aviso("false")
	print_rich("  Recurso externo (imagem) foi duplicado? " + resultado)
	if imagem_duplicada:
		print_rich("  -> " + cor_sucesso("Recursos externos foram duplicados"))
	else:
		print_rich("  -> " + cor_info("Recursos externos são compartilhados"))

#endregion

#region FUNÇÕES DE DEMONSTRAÇÃO

# duplicate(false) - Shallow Copy (Cópia Rasa)
func exemplo_duplicate_copia_rasa():
	print_rich(cor_secao("--- 1. duplicate(false) - SHALLOW COPY (Cópia Rasa) ---"))
	print_rich("Cria uma nova instância do recurso, mas sub-recursos e arrays são " + cor_aviso("COMPARTILHADOS"))
	print()
	
	var copia_rasa = recurso_principal.duplicate(false)
	
	print_rich(cor_info("Após duplicar:"))
	print_comparacao_recursos(copia_rasa, recurso_principal)
	print_comparacao_subrecursos(copia_rasa, recurso_principal, true)
	
	# Modificar propriedade do recurso principal
	copia_rasa.nome = "Cópia Rasa Modificada"
	print_modificacao_propriedade(copia_rasa, recurso_principal, "nome", "Cópia Rasa Modificada")
	
	# Modificar sub-recurso (este AFETA o original!)
	copia_rasa.sub_recurso.valor = 999
	copia_rasa.sub_recurso.arranjo.append("item4")
	print_modificacao_subrecurso(copia_rasa, recurso_principal, 999, "item4", true)
	
	# Restaurar para próximos testes
	recurso_principal.sub_recurso.valor = 42
	recurso_principal.sub_recurso.arranjo = ["item1", "item2", "item3"]

# duplicate(true) - Deep Copy (Cópia Profunda)
func exemplo_duplicate_copia_profunda():
	print_rich(cor_secao("--- 2. duplicate(true) - DEEP COPY (Cópia Profunda) ---"))
	print_rich("Duplica o recurso e " + cor_sucesso("TODOS") + " os sub-recursos, arrays e dicionários recursivamente")
	print_rich("Recursos locais são duplicados, recursos externos podem ser compartilhados")
	print()
	
	var copia_profunda = recurso_principal.duplicate(true)
	
	print_rich(cor_info("Após duplicar:"))
	print_comparacao_recursos(copia_profunda, recurso_principal)
	print_comparacao_subrecursos(copia_profunda, recurso_principal, false)
	
	# Modificar sub-recurso (NÃO afeta o original)
	copia_profunda.sub_recurso.valor = 777
	copia_profunda.sub_recurso.arranjo.append("item_novo")
	print_modificacao_subrecurso(copia_profunda, recurso_principal, 777, "item_novo", false)

# duplicate_deep(0) - DEEP_DUPLICATE_NEVER
func exemplo_duplicate_deep_none():
	print_rich(cor_secao("--- 3. duplicate_deep(Resource.DEEP_DUPLICATE_NONE) ---"))
	print_rich(cor_erro("NENHUM") + " sub-recurso é duplicado, mas arrays e dicionários " + cor_sucesso("SIM"))
	print_rich("Útil para ter arrays/dicts independentes mas apontando para os mesmos recursos")
	print()
	
	var copia_none = recurso_principal.duplicate_deep(Resource.DEEP_DUPLICATE_NONE)
	
	print_rich(cor_info("Após duplicar:"))
	print_rich("  Recurso principal é o mesmo? " + cor_sucesso("false") + " " + cor_info("(false)"))
	print_rich("  Sub-recurso é o mesmo? " + cor_aviso("true") + " " + cor_aviso("(true - NÃO duplicado)"))
	print_rich("  ID sub-recurso cópia: " + cor_destaque(str(copia_none.sub_recurso.get_instance_id())))
	print_rich("  ID sub-recurso original: " + cor_destaque(str(recurso_principal.sub_recurso.get_instance_id())))
	print()
	
	# Testar arrays
	print_rich(cor_info("Testando arrays:"))
	copia_none.sub_recurso.arranjo.append("item_none")
	print_rich("  Adicionou 'item_none' ao array da cópia")
	print_rich("  Array da cópia: " + cor_destaque(str(copia_none.sub_recurso.arranjo)))
	print_rich("  Array do original: " + cor_destaque(str(recurso_principal.sub_recurso.arranjo)))
	print_comparacao_arrays(copia_none, recurso_principal)
	print()
	
	# Testar modificação no sub-recurso (afeta o original pois não foi duplicado)
	var valor_backup = recurso_principal.sub_recurso.valor
	copia_none.sub_recurso.valor = 111
	print_rich("Mudando copia_none.sub_recurso.valor para 111:")
	print_rich("  Valor da cópia: " + cor_destaque(str(copia_none.sub_recurso.valor)))
	print_rich("  Valor do original: " + cor_destaque(str(recurso_principal.sub_recurso.valor)) + " " + cor_erro("(FOI AFETADO - sub-recurso compartilhado)"))
	
	# Restaurar
	recurso_principal.sub_recurso.valor = valor_backup
	recurso_principal.sub_recurso.arranjo = ["item1", "item2", "item3"]

# duplicate_deep(1) - DEEP_DUPLICATE_INTERNAL (padrão)
func exemplo_duplicate_deep_internal():
	print_rich(cor_secao("--- 3. duplicate_deep(Resource.DEEP_DUPLICATE_INTERNAL) - Padrão ---"))
	print_rich("Duplica apenas recursos " + cor_sucesso("LOCAIS") + " (sem path ou com path local da cena)")
	print_rich("Recursos externos (.tres, .res) são " + cor_aviso("compartilhados"))
	print()
	
	print_rich(cor_titulo("TESTE A - Recurso com filho INTERNO:"))
	var copia_internal_a = recurso_principal.duplicate_deep(Resource.DEEP_DUPLICATE_INTERNAL)
	
	print_rich(cor_info("Após duplicar:"))
	print_rich("  Recurso principal é o mesmo? " + cor_sucesso("false") + " " + cor_info("(false)"))
	var sub_igual_a = copia_internal_a.sub_recurso == recurso_principal.sub_recurso
	print_rich("  Sub-recurso é o mesmo? " + (cor_erro("true") if sub_igual_a else cor_sucesso("false")))
	print_rich("  ID sub-recurso cópia: " + cor_destaque(str(copia_internal_a.sub_recurso.get_instance_id())))
	print_rich("  ID sub-recurso original: " + cor_destaque(str(recurso_principal.sub_recurso.get_instance_id())))
	
	# Verificar se o sub-recurso foi duplicado
	var sub_recurso_path_a = recurso_principal.sub_recurso.resource_path
	print_rich("  Path do sub-recurso: " + (sub_recurso_path_a if sub_recurso_path_a else cor_info("(sem path - LOCAL)")))
	
	# Testar modificação
	var valor_original_a = recurso_principal.sub_recurso.valor
	copia_internal_a.sub_recurso.valor = 333
	print_rich("  Modificando valor para 333:")
	print_rich("  Valor da cópia: " + cor_destaque(str(copia_internal_a.sub_recurso.valor)))
	print_rich("  Valor do original: " + cor_destaque(str(recurso_principal.sub_recurso.valor)))
	
	if valor_original_a == recurso_principal.sub_recurso.valor:
		print_rich("  " + cor_sucesso("✅ Sub-recurso FOI duplicado") + " (era INTERNO)")
	else:
		print_rich("  " + cor_erro("❌ Sub-recurso NÃO foi duplicado") + " (era compartilhado)")
	
	print()
	print_rich(cor_info("-".repeat(60)))
	print()
	
	print_rich(cor_titulo("TESTE B - Recurso com filho EXTERNO:"))
	var copia_internal_b = recurso_com_filho_nao_interno.duplicate_deep(Resource.DEEP_DUPLICATE_INTERNAL)
	
	print_rich(cor_info("Após duplicar:"))
	print_rich("  Recurso principal é o mesmo? " + cor_sucesso("false") + " " + cor_info("(false)"))
	var sub_igual_b = copia_internal_b.sub_recurso == recurso_com_filho_nao_interno.sub_recurso
	print_rich("  Sub-recurso é o mesmo? " + (cor_aviso("true") if sub_igual_b else cor_sucesso("false")))
	print_rich("  ID sub-recurso cópia: " + cor_destaque(str(copia_internal_b.sub_recurso.get_instance_id())))
	print_rich("  ID sub-recurso original: " + cor_destaque(str(recurso_com_filho_nao_interno.sub_recurso.get_instance_id())))
	
	# Verificar se o sub-recurso foi duplicado
	var sub_recurso_path_b = recurso_com_filho_nao_interno.sub_recurso.resource_path
	print_rich("  Path do sub-recurso: " + (cor_aviso(sub_recurso_path_b) if sub_recurso_path_b else cor_info("(sem path - LOCAL)")))
	
	# Testar modificação
	var valor_original_b = recurso_com_filho_nao_interno.sub_recurso.valor
	copia_internal_b.sub_recurso.valor = 444
	print_rich("  Modificando valor para 444:")
	print_rich("  Valor da cópia: " + cor_destaque(str(copia_internal_b.sub_recurso.valor)))
	print_rich("  Valor do original: " + cor_destaque(str(recurso_com_filho_nao_interno.sub_recurso.valor)))
	
	if valor_original_b == recurso_com_filho_nao_interno.sub_recurso.valor:
		print_rich("  " + cor_sucesso("✅ Sub-recurso FOI duplicado") + " (era INTERNO)")
	else:
		print_rich("  " + cor_aviso("❌ Sub-recurso NÃO foi duplicado") + " (era EXTERNO - compartilhado)")
	
	print()
	
	# Testar recurso externo (imagem)
	print_rich(cor_info("Testando recurso externo (imagem) no Recurso A:"))
	print_comparacao_recursos_externos(copia_internal_a, recurso_principal)
	
	# Restaurar valores se necessário
	if valor_original_a != recurso_principal.sub_recurso.valor:
		recurso_principal.sub_recurso.valor = valor_original_a
	if valor_original_b != recurso_com_filho_nao_interno.sub_recurso.valor:
		recurso_com_filho_nao_interno.sub_recurso.valor = valor_original_b

# duplicate_deep(2) - DEEP_DUPLICATE_ALL
func exemplo_duplicate_deep_all():
	print_rich(cor_secao("--- 4. duplicate_deep(Resource.DEEP_DUPLICATE_ALL) ---"))
	print_rich(cor_sucesso("TODOS") + " os sub-recursos são duplicados, incluindo recursos externos")
	print_rich("Até recursos grandes armazenados separadamente são duplicados")
	print()
	
	print_rich(cor_titulo("TESTE A - Recurso com filho INTERNO:"))
	var copia_all_a = recurso_principal.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	print_rich(cor_info("Após duplicar:"))
	print_rich("  Recurso principal é o mesmo? " + cor_sucesso("false") + " " + cor_info("(false)"))
	print_rich("  Sub-recurso é o mesmo? " + cor_sucesso("false") + " " + cor_sucesso("(false - SEMPRE duplicado)"))
	print_rich("  ID sub-recurso cópia: " + cor_destaque(str(copia_all_a.sub_recurso.get_instance_id())))
	print_rich("  ID sub-recurso original: " + cor_destaque(str(recurso_principal.sub_recurso.get_instance_id())))
	
	# Testar modificação
	copia_all_a.sub_recurso.valor = 888
	copia_all_a.sub_recurso.arranjo.append("item_all_a")
	print_rich("  Modificando valor para 888 e adicionando 'item_all_a':")
	print_rich("  Valor da cópia: " + cor_destaque(str(copia_all_a.sub_recurso.valor)))
	print_rich("  Valor do original: " + cor_destaque(str(recurso_principal.sub_recurso.valor)) + " " + cor_sucesso("(NÃO foi afetado)"))
	print_rich("  Array da cópia: " + cor_destaque(str(copia_all_a.sub_recurso.arranjo)))
	print_rich("  Array do original: " + cor_destaque(str(recurso_principal.sub_recurso.arranjo)) + " " + cor_sucesso("(NÃO foi afetado)"))
	
	print()
	print_rich(cor_info("-".repeat(60)))
	print()
	
	print_rich(cor_titulo("TESTE B - Recurso com filho EXTERNO:"))
	var copia_all_b = recurso_com_filho_nao_interno.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	print_rich(cor_info("Após duplicar:"))
	print_rich("  Recurso principal é o mesmo? " + cor_sucesso("false") + " " + cor_info("(false)"))
	print_rich("  Sub-recurso é o mesmo? " + cor_sucesso("false") + " " + cor_sucesso("(false - SEMPRE duplicado)"))
	print_rich("  ID sub-recurso cópia: " + cor_destaque(str(copia_all_b.sub_recurso.get_instance_id())))
	print_rich("  ID sub-recurso original: " + cor_destaque(str(recurso_com_filho_nao_interno.sub_recurso.get_instance_id())))
	
	# Testar modificação
	var valor_backup = recurso_com_filho_nao_interno.sub_recurso.valor
	copia_all_b.sub_recurso.valor = 999
	copia_all_b.sub_recurso.arranjo.append("item_all_b")
	print_rich("  Modificando valor para 999 e adicionando 'item_all_b':")
	print_rich("  Valor da cópia: " + cor_destaque(str(copia_all_b.sub_recurso.valor)))
	print_rich("  Valor do original: " + cor_destaque(str(recurso_com_filho_nao_interno.sub_recurso.valor)))
	
	if valor_backup == recurso_com_filho_nao_interno.sub_recurso.valor:
		print_rich("  " + cor_sucesso("✅ Sub-recurso externo FOI duplicado") + " (modo ALL)")
	else:
		print_rich("  " + cor_erro("❌ Sub-recurso ainda compartilhado") + " (não deveria acontecer)")
	
	print()
	
	# Testar recursos externos (imagens)
	print_rich(cor_info("Testando recurso externo (imagem) - Recurso A:"))
	print_comparacao_recursos_externos(copia_all_a, recurso_principal)
	print()
	print_rich(cor_info("Testando recurso externo (imagem) - Recurso B:"))
	print_comparacao_recursos_externos(copia_all_b, recurso_com_filho_nao_interno)
	print_rich("  -> Com DEEP_DUPLICATE_ALL, " + cor_sucesso("TODOS") + " os recursos são duplicados!")
	
	# Restaurar valores
	recurso_principal.sub_recurso.arranjo = ["item1", "item2", "item3"]
	if recurso_com_filho_nao_interno.sub_recurso.valor != valor_backup:
		recurso_com_filho_nao_interno.sub_recurso.valor = valor_backup

#endregion
