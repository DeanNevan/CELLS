extends Camera2D

onready var PlayerCELLS = get_node("../PlayerCELLS")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.global_position = PlayerCELLS.CELLS_center_point
	if Input.is_action_just_released("wheel_up") and !Input.is_action_pressed("right_mouse_button"):
		self.zoom -= Vector2(0.04, 0.04)
		#print("UP!!!")
	elif Input.is_action_just_released("wheel_down") and !Input.is_action_pressed("right_mouse_button"):
		self.zoom += Vector2(0.04, 0.04)
	var _zoom = zoom.x
	_zoom = clamp(_zoom, 0.3, 1)
	self.zoom = Vector2(_zoom, _zoom)