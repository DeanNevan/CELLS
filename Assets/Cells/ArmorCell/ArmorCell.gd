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
	#print("left time", armor_bonus_timer.time_left)
	if Input.is_action_just_pressed("right_mouse_button"):
		#self.get_damage(15)
		pass
		#self.global_rotation += 0.1
		#print(self.global_rotation)
	#print("energy is", self.energy)
	#print("max_energy is", max_energy)
	#print("armor is", armor)
	#print("orgin armor is",orgin_armor)
	
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
	armor = 8
	energy = 180
	max_energy = 180
	
	orgin_armor = armor
	
	energy_bar.max_value = max_energy
	energy_bar.value = energy
	
	add_child(armor_bonus_timer)
	armor_bonus_timer.one_shot = false
	armor_bonus_timer.paused = true
	armor_bonus_timer.connect("timeout", self, "_on_armor_bonus_timer_timeout")
	self.connect("get_hit", self, "_on_get_hit")
	
	#NNArea.get_node("CollisionShape2D").shape.radius = NN_distance
	#NNArea.get_node("CollisionShape2D").shape.radius = NN_distance
	init_ok = true
	emit_signal("init_ok")