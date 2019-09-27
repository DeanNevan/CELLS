extends RigidBody2D

var connect_cell_1#连接的细胞
var connect_cell_2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func connect_cells(cell_1, cell_2):
	connect_cell_1 = cell_1
	connect_cell_2 = cell_2
	connect_cell_1.keys.append(self)