extends "res://Scripts/Cells/CellTemplate.gd"

var is_attacking = false

func _ready():
	name_CN = "尖刺细胞"
	type = "melee_cell"
	
	init()
	pass # Replace with function body.

func _process(delta):
	init_ok = true
	
	$Thorn.global_position = global_position + Vector2(cos(global_rotation), sin(global_rotation)) * 20
	$Thorn.global_rotation = global_rotation
	
	
func attack():
	if !is_attacking:
		is_attacking = true

func hit_body(body):
	pass

func init():
	cell_radius = 15
	max_command_speed = 65
	command_accelaration = 3.5
	armor = 5
	strength = 10
	energy = 80
	max_energy = energy
	push_strength = 10
	max_push_strength = push_strength
	max_bear_speed = 85
	max_centripetal_velocity = 30
	origin_max_centripetal_velocity = max_centripetal_velocity
	centripetal_accelaration = 1.8
	alert_distance = 180
	invincible_time = 0.12
	
	energy_bar.max_value = max_energy
	energy_bar.value = energy
	self.connect("get_hit", self, "_on_get_hit")
	
	clear_collision_bit(self)
	set_collision_bit(self)
	init_ok = true
	emit_signal("init_ok")