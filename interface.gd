extends CanvasLayer

export(Array) var SpawnPoints
var RefSpawnPoints = []
onready var Espantalho = preload("res://objects/monsters/monster1.tscn")
var TempoGerarMax = 6.0
var TempoGerar = TempoGerarMax
var TempoAumentarDificuldade = 13.0
var Pontos = 0

func _ready():
	for i in range(SpawnPoints.size()):
		RefSpawnPoints.append(get_node(SpawnPoints[i]))
	pass

func AtualizarBarraVida(vida):
	var escala = (vida / 5) * 118
	$barracontainer/barra.scale.x = escala
	pass

func AumentarPontos(pontos):
	Pontos += pontos
	$labelpontos.text = "Pontos:" + str(Pontos)
	pass

func _process(delta):
	TempoGerar -= delta
	TempoAumentarDificuldade -= delta
	if TempoGerar <= 0:
		var o = Espantalho.instance()
		var indice = floor(rand_range(0, SpawnPoints.size()))
		var pos = RefSpawnPoints[indice].translation
		pos.y = 0
		TempoGerar = TempoGerarMax
		get_parent().add_child(o)
		o.translation = pos
	if TempoAumentarDificuldade <= 0:
		if TempoGerarMax > 0.5:
			TempoGerarMax -= 0.5
		TempoAumentarDificuldade = 13.0
	pass
