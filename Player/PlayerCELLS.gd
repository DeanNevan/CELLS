extends "res://Scripts/CELLSTemplate.gd"

var is_controlling := true

# Called when the node enters the scene tree for the first time.
func _ready():
	var NerveCell1 = NerveCell.instance()
	add_child(NerveCell1)
	NerveCell1.global_position = get_global_mouse_position()
	cells_array.append(NerveCell1)
	NerveCellInstance = NerveCell1
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("key_1"):
		var ArmorCell1 = ArmorCell.instance()
		add_child(ArmorCell1)
		ArmorCell1.global_position = get_global_mouse_position()
		ArmorCell1.tag = "player_cell"
		cells_array.append(ArmorCell1)
	_control_move()

func _control_move():
	if is_controlling:
		if Input.is_action_pressed("ui_up"):
			self.CELLS_linear_velocity.y -= cells_total_push_strength / 5.0
		if Input.is_action_pressed("ui_down"):
			self.CELLS_linear_velocity.y += cells_total_push_strength / 5.0
		if Input.is_action_pressed("ui_right"):
			self.CELLS_linear_velocity.x += cells_total_push_strength / 5.0
		if Input.is_action_pressed("ui_left"):
			self.CELLS_linear_velocity.x -= cells_total_push_strength / 5.0