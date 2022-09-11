extends KinematicBody

var MaxVelocidade = 10.0 #Velocidade máxima de movimento
var Axys = Vector2(0, 0)#Vetor de movimentação
var AnimatorRes = null #Referência ao recurso que controla a tróca de animações
var Correr = false #Controle de correr
var Target = null #Referência ao objeto que o espantalho vai perseguir
var Vida = 3 #Variável que armazena a vida do espantalho
var PermitirMovimento = true #Variável que permite a movimentação
var Tempo = 6.0
var Interface = null
signal Pontuar

func _ready():
	#Pegando referências
	AnimatorRes = $AnimationTree["parameters/StateMachine/playback"]
	$AnimationTree["parameters/StateMachine/Normal/blend_position"] = 0
	Interface = get_parent().get_node("interface")
	connect("Pontuar", Interface, "AumentarPontos")
	pass

func _process(delta):
	if PermitirMovimento:
		var Velocidade = 0.0
		var a = 0.0
		var Distance = 0.0
		Axys = Vector2(0, 0)
		if not Target == null and Target.EstaVivo:
			Distance = translation.distance_to(Target.translation)
			Axys = Vector2(Target.translation.z - translation.z, Target.translation.x - translation.x) / Distance
			a = Axys.angle_to_point(Vector2(0, 0))
			Correr = Distance > 10
			if Distance < 2.5:
				Target.Dano(1)
				AnimatorRes.travel("hook")
				PermitirMovimento = false
			$RootNode.rotation.y = a
		if Axys.x != 0 or Axys.y != 0:
			if Correr:
				Velocidade = MaxVelocidade
			else:
				Velocidade = MaxVelocidade / 2
		else:
			Velocidade = 0
		if Velocidade > 0:
			$AnimationTree["parameters/StateMachine/Normal/blend_position"] = Velocidade / MaxVelocidade
		else:
			$AnimationTree["parameters/StateMachine/Normal/blend_position"] = 0
		move_and_slide(Vector3(Axys.y, 0, Axys.x).normalized() * Velocidade)
	else:
		if Vida <= 0:
			Tempo -= delta
			if Tempo <= 0:
				queue_free()
	pass

func Dano(valor):
	if Vida > 0:
		Vida -= valor #Reduz a vida com base no valor do dano
		if Vida <= 0:
			#Se a vida for menor que zero é feito uma transição de animação e a variável "PermitirMovimento" é desabilitada
			AnimatorRes.travel("death")
			PermitirMovimento = false
			emit_signal("Pontuar", 10)
		else:
			emit_signal("Pontuar", 1)
	pass

func FimAnimacao():
	PermitirMovimento = true
	pass

func _on_Area_body_entered(body):
	#Disparado sempre que é detectado um novo objeto dentro do node área
	#"body" é a referência até o objeto que disparou o evento
	if body.is_in_group("player"):
		#Caso o body (objeto que disparou o evento) pertença ao grupo
		#A variável target armazena a referência
		Target = body
	pass
