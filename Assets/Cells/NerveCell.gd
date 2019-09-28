extends "res://Scripts/Cells/CellTemplate.gd"
# Called when the node enters the scene tree for the first time.
func _ready():
	name_CN = "神经细胞"
	type = "nerve_cell"
	
	init()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	is_in_NN = true

func init():
	max_energy = 500
	energy = 500
	armor = 6
	
	energy_bar.max_value = max_energy
	energy_bar.value = energy
	#NNArea.get_node("CollisionShape2D").shape.radius = NN_distance
	
	init_ok = true
	emit_signal("init_ok")