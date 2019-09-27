extends Camera2D

onready var PlayerCELLS = get_node("../PlayerCELLS")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.global_position = PlayerCELLS.CELLS_center_point
