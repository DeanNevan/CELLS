extends "res://Scripts/CELLSTemplate.gd"

var is_controlling := true

var _wheel_count = 0


var _count = 1
var _point = Vector2()

var just_pressed_left_mouse_position = Vector2()

func _draw():
	for i in cells_array.size():
		if cells_array[i].is_selected and cells_array[i].tag == "player_cell" and cells_array[i].type != "nerve_cell" and Input.is_action_pressed("right_mouse_button"):
			draw_circle(cells_array[i].LabelCell.global_position - global_position, 5, Color.green)

func _ready():
	var NerveCell1 = NerveCell.instance()
	NerveCell1.tag = "player_cell"
	add_child(NerveCell1)
	NerveCell1.global_position = get_global_mouse_position()
	cells_array.append(NerveCell1)
	
	NerveCellInstance = NerveCell1
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("key_1"):
		var ArmorCell1 = ArmorCell.instance()
		ArmorCell1.tag = "player_cell"
		add_child(ArmorCell1)
		ArmorCell1.global_position = get_global_mouse_position()
		
		cells_array.append(ArmorCell1)
	
	if Input.is_action_just_pressed("key_2"):
		var ThornCell1 = ThornCell.instance()
		ThornCell1.tag = "player_cell"
		add_child(ThornCell1)
		ThornCell1.global_position = get_global_mouse_position()
		
		cells_array.append(ThornCell1)
	
	if Input.is_action_just_pressed("right_mouse_button"):
		_wheel_count = 0
		for i in cells_array.size():
			if cells_array[i].is_selected and cells_array[i].tag == "player_cell" and cells_array[i].type != "nerve_cell":
				#cells_array[i].on_command = false
				cells_array[i].command_start_position = cells_array[i].global_position
		
	if Input.is_action_pressed("right_mouse_button"):
		
		update()
		_count = 1
		_point = Vector2()
		for i in cells_array.size():
			if cells_array[i].is_selected and cells_array[i].tag == "player_cell" and cells_array[i].type != "nerve_cell":
				if (cells_array[i].global_position - cells_array[i].LabelCell.global_position).length() > cells_array[i].cell_radius:
					cells_array[i].on_command = true
				_count += 1
				_point += cells_array[i].global_position
		on_command_cells_center_point = _point / (_count - 1)
		
		if Input.is_action_just_released("wheel_up"):
			 _wheel_count -= 1
		elif Input.is_action_just_released("wheel_down"):
			_wheel_count += 1
		
		var _ang = 0
		for i in cells_array.size():
			if cells_array[i].is_selected and cells_array[i].tag == "player_cell" and cells_array[i].type != "nerve_cell":
				cells_array[i].command_to_center_ang = (cells_array[i].global_position - on_command_cells_center_point).angle()
				var _final_ang = cells_array[i].command_to_center_ang + _wheel_count * 0.3
				cells_array[i].LabelCell.global_position = get_global_mouse_position() + (Vector2(cos(_final_ang), sin (_final_ang))) * (cells_array[i].global_position - on_command_cells_center_point).length()
		
	if Input.is_action_just_released("right_mouse_button"):
		for i in cells_array.size():
			if cells_array[i].is_selected and cells_array[i].tag == "player_cell" and cells_array[i].type != "nerve_cell":
				cells_array[i].on_command = true
	
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
			elif self.turn_speed <= _delta / (120.0 + cells_array.size() * 42) and turn_speed != 0:
				self.turn_speed += _delta / (120.0 + cells_array.size() * 42)