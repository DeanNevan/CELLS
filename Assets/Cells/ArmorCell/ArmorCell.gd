extends "res://Scripts/Cells/CellTemplate.gd"

var armor_bonus_explanation = "ArmorCell受到攻击会增加1护甲，可叠加，未受到攻击时，每一秒减少1护甲，护甲不低于最初护甲值"

var orgin_armor#最初护甲值
onready var armor_bonus_timer = Timer.new()#
# Called when the node enters the scene tree for the first time.
func _ready():
	name_CN = "护甲细胞"
	type = "support_cell"
	init()

func _process(delta):

	init_ok = true
	
	if armor > orgin_armor and armor_bonus_timer.paused == true:
		#print("!!!!!!!!")
		_restart_armor_bonus_timer()
	if armor == orgin_armor:
		armor_bonus_timer.paused = true

func _on_armor_bonus_timer_timeout():
	if armor > orgin_armor:
		armor -= 1

func _restart_armor_bonus_timer():
	armor_bonus_timer.paused = false
	armor_bonus_timer.start(1)

func _on_get_hit(final_damage):
	if final_damage > 0:
		self.armor += 1

func init():
	cell_radius = 15
	max_command_speed = 50
	command_accelaration = 3
	armor = 8
	strength = 10
	energy = 180
	max_energy = energy
	push_strength = 8
	max_push_strength = push_strength
	max_bear_speed = 100
	max_centripetal_velocity = 25
	origin_max_centripetal_velocity = max_centripetal_velocity
	centripetal_accelaration = 1.4
	alert_distance = 140
	invincible_time = 0.2
	
	energy_bar.max_value = max_energy
	energy_bar.value = energy
	
	orgin_armor = armor
	
	
	add_child(armor_bonus_timer)
	armor_bonus_timer.one_shot = false
	armor_bonus_timer.paused = true
	armor_bonus_timer.connect("timeout", self, "_on_armor_bonus_timer_timeout")
	self.connect("get_hit", self, "_on_get_hit")
	
	clear_collision_bit(self)
	set_collision_bit(self)
	
	emit_signal("init_ok")