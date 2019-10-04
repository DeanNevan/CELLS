extends "res://Scripts/CELLSTemplate.gd"

var is_controlling := true

# Called when the node enters the scene tree for the first time.
func _ready():
	var NerveCell1 = NerveCell.instance()
	add_child(NerveCell1)
	NerveCell1.global_position = get_global_mouse_position()
	cells_array.append(NerveCell1)
	NerveCell1.tag = "player_cell"
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
		
	if Input.is_action_just_pressed("right_mouse_button"):
		for i in cells_array.size():
			if cells_array[i].is_selected:
				cells_array[i].on_command = true
				cells_array[i].command_target_position = get_global_mouse_position() - cells_array[i].global_position
				cells_array[i].command_start_global_position = cells_array[i].global_position
	
	_control_move()

func _control_move():
	if is_controlling:
		var _delta = cells_total_push_strength / cells_array.size()
		if Input.is_action_pressed("ui_up"):
			self.CELLS_linear_velocity.y -= _delta / 5.0
		if Input.is_action_pressed("ui_down"):
			self.CELLS_linear_velocity.y += _delta / 5.0
		if Input.is_action_pressed("ui_right"):
			self.CELLS_linear_velocity.x += _delta / 5.0
		if Input.is_action_pressed("ui_left"):
			self.CELLS_linear_velocity.x -= _delta / 5.0
		if Input.is_action_pressed("key_q"):
			#self.is_turning = true
			#self.turn_way = 1
			self.turn_speed += _delta / (120.0 + cells_array.size() * 42)
		if Input.is_action_pressed("key_e"):
			#self.is_turning = true
			#self.turn_way = -1
			if !Input.is_action_pressed("key_q"):
				self.turn_speed -= _delta / (120.0 + cells_array.size() * 42)
		elif !Input.is_action_pressed("key_q"):
			#self.is_turning = false
			if self.turn_speed >= _delta / (120.0 + cells_array.size() * 42):
				self.turn_speed -= _delta / (120.0 + cells_array.size() * 42)
			elif self.turn_speed <= _delta / (120.0 + cells_array.size() * 42):
				self.turn_speed += _delta / (120.0 + cells_array.size() * 42)