extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("3,ready")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().get_frame() == 60:
		print("3,process")