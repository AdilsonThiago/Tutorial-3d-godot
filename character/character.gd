extends KinematicBody

var MaxVelocidade = 10.0 #Velocidade máxima de movimento
var Axys = Vector2(0, 0) #Vetor de movimentação
var AnimatorRes = null #Referência ao recurso que controla a tróca de animações
var Correr = false #Controle de correr
var Angulo = 0.0 #Angulo de visão do jogador
var Vida = 5.0
var EstaVivo = true
export(NodePath) var InterfacePath = ""
var Interface = null
onready var Bala = preload("res://objects/effects/bullet.tscn") #Carrega em memória a scene "bullet.tscn" para que possa ser gerado cópias
signal VidaAlterada

func _ready():
	#Armazenando referências
	AnimatorRes = $AnimationTree["parameters/StateMachine/playback"]
	$AnimationTree["parameters/StateMachine/normalmove/blend_position"] = 0
	Interface = get_node(InterfacePath)
	connect("VidaAlterada", Interface, "AtualizarBarraVida")
	pass

func _input(event):
	#Processamento de entrada de dados, identifica as teclas e toma uma decisão com base
	if event.is_action_pressed("b_direita"):
		Axys.x = 1
	elif event.is_action_pressed("b_esquerda"):
		Axys.x = - 1
	elif event.is_action_pressed("b_cima"):
		Axys.y = 1
	elif event.is_action_pressed("b_baixo"):
		Axys.y = -1
	if event.is_action_released("b_direita") or event.is_action_released("b_esquerda"):
		Axys.x = 0
	if event.is_action_released("b_cima") or event.is_action_released("b_baixo"):
		Axys.y = 0
	if event.is_action_pressed("b_correr"):
		Correr = true
	elif event.is_action_released("b_correr"):
		Correr = false
	if event.is_action_pressed("b_atirar"):
		Atirar()
	pass

func Atirar():
	#Método de atirar, invocado ao apertar o botão de atirar
	var objeto = Bala.instance() #Cria uma cópia da scene
	get_parent().add_child(objeto) #Atribui um parêntesco a cópia criada
	objeto.translation = translation + $Armature/Skeleton/BoneAttachment.translation #Muda sua posição com base na posição do jogador + a posição do "BoneAttachment"
	objeto.AplicarVelocidade(Vector3(sin(Angulo), 0, cos(Angulo))) #Passa o vetor de movimentação para a referida cópia criada
	$GunAnimation.play("Atirar")
	pass

func Dano(valor):
	Vida -= valor #Reduz a vida com base no valor do dano
	if Vida <= 0:
		#Se a vida for menor que zero é feito uma transição de animação e a variável "PermitirMovimento" é desabilitada
		AnimatorRes.travel("death")
		EstaVivo = false
	emit_signal("VidaAlterada", Vida)
	pass

func _process(delta):
	if EstaVivo:
		var Velocidade = 0.0
		Angulo = - get_viewport().get_mouse_position().angle_to_point(Vector2(514, 300))
		$Armature.rotation.y = Angulo
		if Axys.x != 0 or Axys.y != 0:
			if Correr:
				Velocidade = MaxVelocidade
			else:
				Velocidade = MaxVelocidade / 2
		else:
			Velocidade = 0
		if Velocidade > 0:
			$AnimationTree["parameters/StateMachine/normalmove/blend_position"] = Velocidade / MaxVelocidade
		else:
			$AnimationTree["parameters/StateMachine/normalmove/blend_position"] = 0
		move_and_slide(Vector3(Axys.y, 0, Axys.x).normalized() * Velocidade)
	pass
