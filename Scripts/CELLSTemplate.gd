extends RigidBody2D

signal cells_array_change

var cells_array = []#细胞数组
var cells_total_push_strength = 0#细胞群的总推动力

var CELLS_linear_velocity := Vector2()#CELLS的线速度
var CELLS_center_point := Vector2()#global_position
var CELLS_max_bear_speed = 0#细胞群最大承受速度

var on_command_cells_center_point = Vector2()

var _plus_all_cells_position := Vector2()

var turn_speed = 0.0
var max_turn_speed = 2.5

var NerveCellInstance
var NerveCell : PackedScene
var ArmorCell : PackedScene
var ThornCell : PackedScene
func _ready():
	NerveCell = preload("res://Assets/Cells/NerveCell.tscn")
	ArmorCell = preload("res://Assets/Cells/ArmorCell/ArmorCell.tscn")
	ThornCell = preload("res://Assets/Cells/ThornCell/ThornCell.tscn")
	pass # Replace with function body.

func _draw():
	for i in cells_array.size():
		if cells_array[i].is_selected and cells_array[i].on_command:
			match cells_array[i].tag:
				"player_cell":
					draw_line(cells_array[i].global_position - global_position, cells_array[i].LabelCell.global_position - global_position, Color.green, 3)
					#draw_circle(LabelCell.global_position - global_position, 5, Color.green)
				"enemy_cell":
					draw_line(cells_array[i].global_position - global_position, cells_array[i].LabelCell.global_position - global_position, Color.red, 3)
				"neutral_cell":
					draw_line(cells_array[i].global_position - global_position, cells_array[i].LabelCell.global_position - global_position, Color.yellow, 3)
				"cell":
					draw_line(cells_array[i].global_position - global_position, cells_array[i].LabelCell.global_position - global_position, Color.white, 3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if cells_array.size() == 0:
		return
	
	update()
	
	###计算细胞群中心位置、最大承受速度###
	var _bear_speed = []
	_plus_all_cells_position = Vector2()
	cells_total_push_strength = 0
	for i in cells_array.size():
		cells_array[i].is_connect_NerveCell = false
	for i in NerveCellInstance.connected_cells.size():
		NerveCellInstance.connected_cells[i].is_connect_NerveCell = true
	for i in cells_array.size():
		_bear_speed.append(cells_array[i].max_bear_speed)
		_plus_all_cells_position += cells_array[i].global_position
		cells_total_push_strength += cells_array[i].push_strength
	CELLS_center_point = _plus_all_cells_position / cells_array.size()
	CELLS_max_bear_speed = _bear_speed.min()
	#################################
	
	###更新细胞的NN状态、到神经细胞的向量###
	for i in cells_array.size():
		cells_array[i].is_in_NN = false
		cells_array[i].vector_to_NerveCell = NerveCellInstance.global_position - cells_array[i].global_position
	###################################
	
	###clmap细胞群线速度，并把细胞群线速度赋予神经细胞###
	if CELLS_linear_velocity.length() >= CELLS_max_bear_speed:
		CELLS_linear_velocity = CELLS_linear_velocity.normalized() * CELLS_max_bear_speed
	NerveCellInstance.linear_velocity = CELLS_linear_velocity.normalized() * clamp(CELLS_linear_velocity.length(), 0, CELLS_max_bear_speed)
	
	###更新并赋予细胞的向心速度###
	for i in cells_array.size():
		if cells_array[i].type == "nerve_cell":
			continue
		if !cells_array[i].on_command:
			if cells_array[i].should_goto_center:
				cells_array[i].centripetal_velocity += cells_array[i].centripetal_accelaration
			else:
				cells_array[i].centripetal_velocity -= cells_array[i].centripetal_accelaration
			cells_array[i].centripetal_velocity = clamp(cells_array[i].centripetal_velocity, -cells_array[i].max_centripetal_velocity, cells_array[i].max_centripetal_velocity)
		else:
			if cells_array[i].centripetal_velocity > 0:
				cells_array[i].centripetal_velocity -= cells_array[i].centripetal_accelaration
				cells_array[i].centripetal_velocity = clamp(cells_array[i].centripetal_velocity, 0, cells_array[i].max_centripetal_velocity)
			elif cells_array[i].centripetal_velocity < 0:
				cells_array[i].centripetal_velocity += cells_array[i].centripetal_accelaration
				cells_array[i].centripetal_velocity = clamp(cells_array[i].centripetal_velocity, -cells_array[i].max_centripetal_velocity, 0)
		var _vel = cells_array[i].centripetal_velocity * ($NerveCell.global_position - cells_array[i].global_position).normalized() + NerveCellInstance.linear_velocity
		cells_array[i].linear_velocity = _vel
		#print(cells_array[i].centripetal_velocity)
		##################
		
		###赋予神经细胞以外的细胞转向速度###
		var _cen_ang = cells_array[i].vector_to_NerveCell.angle()
		var _vel_ang = _cen_ang + PI / 2
		turn_speed = clamp(turn_speed, -max_turn_speed, max_turn_speed)
		cells_array[i].linear_velocity += cells_array[i].vector_to_NerveCell.length() * 0.35 * Vector2(cos(_vel_ang), sin(_vel_ang)) * turn_speed
		_cen_ang = (NerveCellInstance.global_position - cells_array[i].LabelCell.global_position).angle()
		_vel_ang = _cen_ang + PI / 2
		cells_array[i].LabelCell.linear_velocity = NerveCellInstance.linear_velocity + (NerveCellInstance.global_position - cells_array[i].LabelCell.global_position).length() * 0.35 * Vector2(cos(_vel_ang), sin(_vel_ang)) * turn_speed
		################################
		
		###赋予细胞鼠标命令速度###
		#if cells_array[i].on_command and cells_array[i].command_position != Vector2():
			#cells_array[i].command_speed += cells_array[i].push_strength / 10.0
			#cells_array[i].command_speed = clamp(cells_array[i].command_speed, 0, cells_array[i].max_command_speed)
		#if !cells_array[i].on_command:
			#cells_array[i].command_speed -= cells_array[i].push_strength / 10.0
			#cells_array[i].command_speed = clamp(cells_array[i].command_speed, 0, cells_array[i].max_command_speed)
		if cells_array[i].on_command:
			cells_array[i].command_velocity += cells_array[i].vector_to_command_position.normalized() * cells_array[i].command_accelaration
		if cells_array[i].command_velocity.length() > cells_array[i].max_command_speed and cells_array[i].on_command:
			cells_array[i].command_velocity = cells_array[i].command_velocity.normalized() * cells_array[i].max_command_speed
		if !cells_array[i].on_command:
			cells_array[i].command_velocity -= cells_array[i].command_velocity.normalized() * cells_array[i].command_accelaration
		
		var _command_distance_bonus = clamp((cells_array[i].global_position - cells_array[i].LabelCell.global_position).length() / 5.0, 0, 75)
		#print(_command_distance_bonus)
		cells_array[i].linear_velocity += cells_array[i].command_velocity.normalized() * (clamp(cells_array[i].command_velocity.length(), 0, cells_array[i].max_command_speed) + _command_distance_bonus)
		#######################