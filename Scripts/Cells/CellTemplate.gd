extends RigidBody2D

signal get_hit

signal init_ok

signal get_damage

var name_CN = "细胞"

var tag = "cell"#player_cell, enemy_cell, cell
var type#support_cell, melee_cell, ranged_cell, nerve_cell

var vector_to_NerveCell = 0
var is_in_NN = false#是否在神经网络中
var connected_cells := []#与此细胞相连的细胞数组
var should_goto_center = true#是否需要向中心移动

var is_connect_NerveCell = false

var target_goto_cell

var keys = []#连接的键

var cell_radius = 15#细胞半径

var linear_speed#两帧之间的位置差值
var pos1 = Vector2()
var pos2 = Vector2()

var init_ok = false#是否初始化完成

var is_mouse_entered := false#鼠标是否进入
var is_selected := false#是否被拾起
var on_command = false
var command_target_position = Vector2()
var command_start_global_position = Vector2()
var command_left_vector = Vector2()

var armor = 5#护甲
var strength = 10#伤害/强度

var max_energy = 100#最大能量值
var energy = 100#能量值

var max_push_strength = 10#最大推进力量
var push_strength = 10#推动力
var push_acceleration = 1#推动加速度 0.0-1.0

var max_bear_speed = 80

var max_centripetal_velocity = 35
var centripetal_velocity = 0
var centripetal_accelaration = 2

var alert_distance = 200#警戒距离

var basic_state = {"can_work" : true, "can_push" : true, "can_turn" : true, "invincible" : false}#基础状态

var target_count = 1#目标数量
onready var target = {}#作用目标

var invincible_time = 0.1
onready var invincible_timer = Timer.new()#无敌时间计时器

onready var energy_bar = $EnergyBar#能量条

onready var float_particle = $Float#游动时的尾部粒子

onready var NerveCell = get_parent().get_node("NerveCell")

onready var NNArea = $NNArea

onready var BodyArea = Area2D.new()
onready var BodyAreaShape = CollisionShape2D.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("init_ok", self, "on_init_ok")
	
	#add_child(BodyArea)
	#BodyAreaShape.shape = CircleShape2D.new()
	#BodyAreaShape.shape.radius = cell_radius
	#BodyArea.add_child(BodyAreaShape)
	#BodyArea.connect("area_entered", self, "_on_area_entered")
	#BodyArea.connect("area_exited", self, "_on_area_exited")
	
	get_parent().connect("cells_array_change", self, "_on_cells_array_change")
	NNArea.connect("body_entered", self, "_on_body_enter_NNArea")
	NNArea.connect("body_exited", self, "_on_body_exit_NNArea")
	
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
	
	#is_selected = false
	pos1 = self.global_position#两帧之间的位置差值
	linear_speed = pos1 - pos2
	pos2 = pos1
	
	_detect_MouseRegion()
	
	if self.is_in_NN:
		for i in connected_cells.size():
			connected_cells[i].is_in_NN = true
	
	var _target_goto_cell = NerveCell
	var _cloest_goto_cell_distance = 0
	for i in connected_cells.size():
		if (NerveCell.global_position - connected_cells[i].global_position).length() < (NerveCell.global_position - self.global_position).length() and (NerveCell.global_position - connected_cells[i].global_position).length() > _cloest_goto_cell_distance:
			_target_goto_cell = connected_cells[i]
			_cloest_goto_cell_distance = (NerveCell.global_position - connected_cells[i].global_position).length()
	if (NerveCell.global_position - global_position).angle_to(NerveCell.global_position - _target_goto_cell.global_position) > PI / 3 and connected_cells.has(NerveCell):
		_target_goto_cell = NerveCell
	target_goto_cell = _target_goto_cell
	if (_target_goto_cell.global_position - self.global_position).length() > _target_goto_cell.cell_radius + self.cell_radius + 20:
		self.should_goto_center = true
	else:
		self.should_goto_center = false
	
	if !self.is_in_NN:
		self.should_goto_center = true
	
	if on_command:
		command_left_vector = command_target_position - (global_position - command_start_global_position)
		if abs((global_position - command_start_global_position).length() - command_target_position.length()) <= cell_radius:
			on_command = false
			command_target_position = Vector2()
			command_left_vector = Vector2()
	
	if (get_global_mouse_position() - self.global_position).length() < cell_radius:
		is_mouse_entered = true
	else:
		is_mouse_entered = false
	
	#_update_energy_bar()

func _on_invincible_timer_timeout():
	basic_state["invincible"] = false

func _on_body_enter_NNArea(body):
	if body == self:
		return
	#print("enter!!!")
	connected_cells.append(body)

func _on_body_exit_NNArea(body):
	connected_cells.erase(body)

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

func _detect_MouseRegion():
	if $CollisionShape2D.shape.collide(Transform2D(0, self.global_position), Mouse_Global.MouseRegionShape.shape, Transform2D(0, Mouse_Global.MouseRegionArea.global_position)):
		self.is_selected = true
		#print("!!")
	#elif Mouse_Global.is_mouse_selecting and self.is_selected and Input.is_key_pressed(KEY_SHIFT):
		#self.is_selected = true
	elif Input.is_action_just_pressed("left_mouse_button") and !Input.is_key_pressed(KEY_SHIFT):
		self.is_selected = false

func on_init_ok():
	pass