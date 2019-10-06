extends "res://Scripts/Cells/CellTemplate.gd"
# Called when the node enters the scene tree for the first time.

func _ready():
	name_CN = "神经细胞"
	type = "nerve_cell"
	
	init()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	is_in_NN = true
	init_ok = true

func init():
	cell_radius = 15
	#max_command_speed = 65
	#command_accelaration = 3.5
	armor = 6
	strength = 10
	energy = 500
	max_energy = energy
	push_strength = 10
	max_push_strength = push_strength
	max_bear_speed = 150
	#max_centripetal_velocity = 30
	#origin_max_centripetal_velocity = max_centripetal_velocity
	#centripetal_accelaration = 1.8
	alert_distance = 400
	invincible_time = 0.2
	
	energy_bar.max_value = max_energy
	energy_bar.value = energy
	self.connect("get_hit", self, "_on_get_hit")
	
	clear_collision_bit(self)
	set_collision_bit(self)
	init_ok = true
	emit_signal("init_ok")