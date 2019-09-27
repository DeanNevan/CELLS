extends RigidBody2D

var cells_array = []#细胞数组
var cells_total_push_strength = 0#细胞群的总推动力


var CELLS_linear_velocity := Vector2()#CELLS的线速度
var CELLS_center_point := Vector2()#global_position
var CELLS_max_bear_speed = 0#细胞群最大承受速度

var _plus_all_cells_position := Vector2()

var NerveCell
var NerveCellInstance

var ArmorCell : PackedScene
func _ready():
	NerveCell = preload("res://Assets/Cells/NerveCell.tscn")
	
	ArmorCell = preload("res://Assets/Cells/ArmorCell/ArmorCell.tscn")
	
	
	pass # Replace with function body.

func _draw():
	draw_circle(CELLS_center_point, 20, Color.red)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if cells_array.size() == 0:
		return
	update()
	var _bear_speed = []
	
	_plus_all_cells_position = Vector2()
	cells_total_push_strength = 0
	for i in cells_array.size():
		_bear_speed.append(cells_array[i].max_bear_speed)
		_plus_all_cells_position += cells_array[i].global_position
		cells_total_push_strength += cells_array[i].push_strength
	CELLS_center_point = _plus_all_cells_position / cells_array.size()
	
	CELLS_max_bear_speed = _bear_speed.min()
	for i in cells_array.size():
		#var _final_centripetal_velocity = Vector2()
		#var _centripetal_ang = 0
		#如果该细胞的向心速度达到峰值，则不再进行向心方向上的加速
		cells_array[i].centripetal_velocity = clamp(cells_array[i].centripetal_velocity, -cells_array[i].max_centripetal_velocity, cells_array[i].max_centripetal_velocity)
		cells_array[i].vector_to_nerve_cell = NerveCellInstance.global_position - cells_array[i].global_position
		
		if cells_array[i].centripetal_velocity > cells_array[i].max_centripetal_velocity:
			cells_array[i].centripetal_velocity = cells_array[i].max_centripetal_velocity
		
		cells_array[i].connected_cells = []
		for i1 in cells_array.size():
			if i1 == i:
				continue
			if (cells_array[i1].global_position - cells_array[i].global_position).length() < (cells_array[i1].cell_radius + cells_array[i].cell_radius) * 1.5:
				cells_array[i].connected_cells.append(cells_array[i1])
		
		
		
		if cells_array[i].connected_cells.size() == 0:
			cells_array[i].should_goto_center = true
		else:
			cells_array[i].should_goto_center = false
	
	if NerveCellInstance.connected_cells.size() == 0:
		for i in cells_array.size():
			cells_array[i].is_in_NN = false
	else:
		var _is_in_NN_count_1 = NerveCellInstance.connected_cells.size()
		for i in NerveCellInstance.connected_cells.size():
				NerveCellInstance.connected_cells[i].is_in_NN = true
		var _is_in_NN_count_2 = 0
		while _is_in_NN_count_1 != _is_in_NN_count_2:
			_is_in_NN_count_1 = 0
			for i in cells_array.size():
				if cells_array[i].is_in_NN:
					for i1 in cells_array[i].connected_cells.size():
						cells_array[i].connected_cells[i1].is_in_NN = true
			for i in cells_array.size():
				if cells_array[i].is_in_NN:
					_is_in_NN_count_1 += 1
			_is_in_NN_count_2 = _is_in_NN_count_1
	
	for i in cells_array.size():
		
		if !cells_array[i].is_in_NN:
			cells_array[i].should_goto_center = true
		else:
			cells_array[i].should_goto_center = false
		
		if cells_array[i].should_goto_center:
			cells_array[i].centripetal_velocity += cells_array[i].centripetal_accelaration
		else:
			cells_array[i].centripetal_velocity -= cells_array[i].centripetal_accelaration
		var _vel = cells_array[i].centripetal_velocity * ($NerveCell.global_position - cells_array[i].global_position).normalized() + CELLS_linear_velocity
		
		if (CELLS_linear_velocity.length() >= CELLS_max_bear_speed - cells_array[i].centripetal_velocity):
			CELLS_linear_velocity = CELLS_linear_velocity.normalized() * (CELLS_max_bear_speed - cells_array[i].centripetal_velocity)
		
		cells_array[i].linear_velocity = _vel.normalized() * clamp(_vel.length(), 0, CELLS_max_bear_speed)
	


func move(velocity):
	pass