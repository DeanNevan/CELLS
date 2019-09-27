extends RigidBody2D

signal get_hit

signal get_damage

var name_CN = "细胞"

var tag = "cell"#player_cell, enemy_cell, cell
var type#support_cell, melee_cell, ranged_cell, nerve_cell

var vector_to_nerve_cell = 0
var is_in_NN = false#是否在神经网络中
var connected_cells := []#与此细胞相连的细胞数组
var should_goto_center = true#是否需要向中心移动

var keys = []#连接的键

var cell_radius = 15#细胞半径

var linear_speed#两帧之间的位置差值
var pos1 = Vector2()
var pos2 = Vector2()

var init_ok = false#是否初始化完成

var is_mouse_entered := false#鼠标是否进入
var is_picked := false#是否被拾起

var armor = 5#护甲
var strength = 10#伤害/强度

var max_energy = 100#最大能量值
var energy = 100#能量值

var max_push_strength = 10#最大推进力量
var push_strength = 10#推动力
var push_acceleration = 1#推动加速度 0.0-1.0

var max_bear_speed = 80

var max_centripetal_velocity = 25
var centripetal_velocity = 0
var centripetal_accelaration = 0.8

var alert_distance = 200#警戒距离

var basic_state = {"can_work" : true, "can_push" : true, "can_turn" : true, "invincible" : false}#基础状态

var target_count = 1#目标数量
onready var target = {}#作用目标

var invincible_time = 0.1
onready var invincible_timer = Timer.new()#无敌时间计时器

onready var energy_bar = $EnergyBar#能量条

onready var float_particle = $Float#游动时的尾部粒子
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(invincible_timer)
	invincible_timer.wait_time = invincible_time
	invincible_timer.autostart = false
	invincible_timer.one_shot = true
	invincible_timer.connect("timeout", self, "_on_invincible_timer_timeout")
	
	#energy_bar.value = 100

func _process(delta):
	if !init_ok:
		print("haven`t init ok")
		return
	
	pos1 = self.global_position#两帧之间的位置差值
	linear_speed = pos1 - pos2
	pos2 = pos1
	
	if !Input.is_mouse_button_pressed(BUTTON_LEFT):
		is_picked = false
	if (get_global_mouse_position() - self.global_position).length() < cell_radius:
		is_mouse_entered = true
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			is_picked = true
	else:
		is_mouse_entered = false
	
	if is_picked:
		#$CollisionShape2D.disabled = true
		self.global_position = get_global_mouse_position()
	
	#_update_energy_bar()

func _on_invincible_timer_timeout():
	basic_state["invincible"] = false

func _update_energy_bar():
	energy_bar.value = energy

func get_damage(damage, is_hit = true):
	if basic_state["invincible"]:
		print(self, "is invincible")
		return
	var final_damage
	emit_signal("get_damage")
	if is_hit:
		invincible_timer.start()
		final_damage = clamp(damage - armor, 0, 100)
		energy -= final_damage
		emit_signal("get_hit", final_damage)
	else:
		energy -= damage
	
	_update_energy_bar()