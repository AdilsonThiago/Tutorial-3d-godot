extends Area

var VecMov = Vector3(0, 0, 0) #Definindo vetor de movimentação da bala
export(float) var Velocidade = 10.0 #Velocidade de movimentação da bala
var Tempo = 3.0

func AplicarVelocidade(vetor):
	VecMov = vetor #Recebendo o vetor de movimentação passado pelo script do jogador
	rotation.y = Vector2(vetor.z, vetor.x).angle_to_point(Vector2(0, 0)) #Aplicando rotação com base no vetor de movimentação
	pass

func _process(delta):
	translation += VecMov * Velocidade * delta #Aplicando a movimentação
	Tempo -= delta
	if Tempo <= 0:
		queue_free()
	pass


func _on_Area_body_entered(body):
	#Identificando colisão com objetos do grupo "enemy"
	if body.is_in_group("enemy"):
		body.Dano(1) #Aplicando dano
		queue_free() #Se auto deletando
	pass
