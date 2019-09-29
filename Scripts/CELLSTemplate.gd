extends RigidBody2D

signal cells_array_change

var cells_array = []#细胞数组
var cells_total_push_strength = 0#细胞群的总推动力

var CELLS_linear_velocity := Vector2()#CELLS的线速度
var CELLS_center_point := Vector2()#global_position
var CELLS_max_bear_speed = 0#细胞群最大承受速度

var _plus_all_cells_position := Vector2()

var _should_update_NNArea = true
var _cells_count = 0

var NerveCell
var NerveCellInstance

var is_turning = false
var turn_speed = 0
var max_turn_speed = 3
var turn_way = 1#1,clockwise;-1, anticlockwise

var ArmorCell : PackedScene
func _ready():
	NerveCell = preload("res://Assets/Cells/NerveCell.tscn")
	
	ArmorCell = preload("res://Assets/Cells/ArmorCell/ArmorCell.tscn")
	
	
	pass # Replace with function body.

func _draw():
	draw_circle(CELLS_center_point, 20, Color.red)
	for i in cells_array.size():
		for i1 in cells_array[i].connected_cells.size():
			if cells_array[i].connected_cells[i1].is_in_NN:
				draw_line(cells_array[i].global_position, cells_array[i].connected_cells[i1].global_position, Color.green, 3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if cells_array.size() == 0:
		return
	
	
	
	update()
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
	for i in cells_array.size():
		cells_array[i].is_in_NN = false
		#var _final_centripetal_velocity = Vector2()
		#var _centripetal_ang = 0
		#如果该细胞的向心速度达到峰值，则不再进行向心方向上的加速
		cells_array[i].centripetal_velocity = clamp(cells_array[i].centripetal_velocity, -cells_array[i].max_centripetal_velocity, cells_array[i].max_centripetal_velocity)
		cells_array[i].vector_to_NerveCell = NerveCellInstance.global_position - cells_array[i].global_position
		
		if cells_array[i].centripetal_velocity > cells_array[i].max_centripetal_velocity:
			cells_array[i].centripetal_velocity = cells_array[i].max_centripetal_velocity
		
	
	
	if CELLS_linear_velocity.length() >= CELLS_max_bear_speed:
		CELLS_linear_velocity = CELLS_linear_velocity.normalized() * CELLS_max_bear_speed
	NerveCellInstance.linear_velocity = CELLS_linear_velocity.normalized() * clamp(CELLS_linear_velocity.length(), 0, CELLS_max_bear_speed)
	
	for i in cells_array.size():
		if cells_array[i].type == "nerve_cell":
			continue
		if cells_array[i].should_goto_center:
			cells_array[i].centripetal_velocity += cells_array[i].centripetal_accelaration
		else:
			cells_array[i].centripetal_velocity -= cells_array[i].centripetal_accelaration
		var _vel = cells_array[i].centripetal_velocity * ($NerveCell.global_position - cells_array[i].global_position).normalized() + CELLS_linear_velocity
		
		if cells_array[i].on_command:
			cells_array[i].linear_velocity = NerveCellInstance.linear_velocity
		else:
			cells_array[i].linear_velocity = cells_array[i].centripetal_velocity * ($NerveCell.global_position - cells_array[i].global_position).normalized() + NerveCellInstance.linear_velocity
		#cells_array[i].linear_velocity = _vel.normalized() * clamp(_vel.length(), 0, CELLS_max_bear_speed)
		if is_turning:
			var _cen_ang = cells_array[i].vector_to_NerveCell.angle()
			var _vel_ang = _cen_ang + turn_way * PI / 2
			turn_speed = clamp(turn_speed, 0, max_turn_speed)
			cells_array[i].linear_velocity += cells_array[i].vector_to_NerveCell.length() * 0.35 * Vector2(cos(_vel_ang), sin(_vel_ang)) * turn_speed
			
		if cells_array[i].on_command and cells_array[i].command_position != null:
			cells_array[i].linear_velocity += (cells_array[i].push_strength / 2.0) * (cells_array[i].command_position - cells_array[i].global_position).normalized()