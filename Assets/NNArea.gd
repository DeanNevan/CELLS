extends Area2D

export var NN_distance = 60

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D.shape.radius = NN_distance

func _process(delta):
	pass
