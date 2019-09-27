extends Particles2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var myself = get_parent()
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.global_rotation = 0
	
	if myself.linear_speed.length() > 0.1:
		self.emitting = true
		self.process_material.initial_velocity = myself.linear_speed.length() * 20
		self.global_rotation = (-myself.linear_speed).angle()
	else:
		self.emitting = false
