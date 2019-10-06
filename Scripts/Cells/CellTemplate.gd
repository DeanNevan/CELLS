extends RigidBody2D

signal get_hit

signal init_ok

signal get_damage

var name_CN = "细胞"

var tag = "cell"#player_cell, enemy_cell, neutral_cell, cell
var type#support_cell, melee_cell, ranged_cell, nerve_cell

var vector_to_NerveCell = 0
var is_in_NN = false#是否在神经网络中
var connected_cells := []#与此细胞相连的细胞数组
var should_goto_center = true#是否需要向中心移动

var is_connect_NerveCell = false

var target_goto_cell

var keys = []#连接的键

var cell_radius = 15#细胞半径#基础属性之一

var linear_speed = Vector2()#两帧之间的位置差值
var pos1 = Vector2()
var pos2 = Vector2()

var init_ok = false#是否初始化完成

var is_mouse_entered := false#鼠标是否进入
var is_selected := false#是否被拾起
var on_command = false
var command_position = Vector2()
var vector_to_command_position = Vector2()
var max_command_speed = 60#基础属性之一
var command_accelaration = 4#基础属性之一
var command_velocity = Vector2()
var command_speed = 0

var armor = 5#护甲#基础属性之一
var strength = 10#伤害/强度#基础属性之一

var max_energy = 100#最大能量值#基础属性之一
var energy = 100#能量值#基础属性之一

var max_push_strength = 10#最大推进力量#基础属性之一
var push_strength = 10#推动力#基础属性之一
#var push_acceleration = 1#推动加速度 0.0-1.0

var max_bear_speed = 80#基础属性之一

var max_centripetal_velocity = 30#基础属性之一
var origin_max_centripetal_velocity = 30#基础属性之一
var centripetal_velocity = 0
var centripetal_accelaration = 1.8#基础属性之一
#var origin_centripetal_accelaration = 1.8


var alert_distance = 200#警戒距离#基础属性之一

enum {
	STATE_GOTO_NERVECELL
	STATE_INVINCIBLE
	STATE_WORKING
	STATE_MOVING
	STATE_TURNING
	STATE_IN_NN
	STATE_MISS
}

var state = {STATE_GOTO_NERVECELL : false, STATE_INVINCIBLE : false, STATE_WORKING : false, STATE_MOVING : false, STATE_TURNING : false, STATE_IN_NN : false, STATE_MISS = false}
#var basic_state = {"can_work" : true, "can_push" : true, "can_turn" : true, "invincible" : false}#基础状态

var target_count = 1#目标数量
onready var target = {}#作用目标

var invincible_time = 0.1#基础属性之一
onready var invincible_timer = Timer.new()#无敌时间计时器

onready var energy_bar = $EnergyBar#能量条

onready var float_particle = $Float#游动时的尾部粒子

onready var NerveCell = get_parent().get_node("NerveCell")

onready var LabelCell = RigidBody2D.new()
var command_start_position = Vector2()
var command_to_center_ang = 0

onready var NNArea = $NNArea

onready var BodyArea = Area2D.new()
onready var BodyAreaShape = CollisionShape2D.new()

onready var SelectedArrow = preload("res://Assets/Extra/SelectedArrow/SelectedArrow.tscn").instance()

func _ready():
	self.connect("init_ok", self, "on_init_ok")
	
	add_child(SelectedArrow)
	SelectedArrow.visible = false
	#add_child(BodyArea)
	#BodyAreaShape.shape = CircleShape2D.new()
	#BodyAreaShape.shape.radius = cell_radius
	#BodyArea.add_child(BodyAreaShape)
	#BodyArea.connect("area_entered", self, "_on_area_entered")
	#BodyArea.connect("area_exited", self, "_on_area_exited")
	
	get_parent().add_child(LabelCell)
	
	get_parent().connect("cells_array_change", self, "_on_cells_array_change")
	NNArea.connect("body_entered", self, "_on_body_enter_NNArea")
	NNArea.connect("body_exited", self, "_on_body_exit_NNArea")
	
	get_parent().add_child(invincible_timer)
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
	
	if !state[STATE_IN_NN]:
		max_centripetal_velocity = origin_max_centripetal_velocity * 1.5
	else:
		max_centripetal_velocity = origin_max_centripetal_velocity
	
	if is_selected:
		SelectedArrow.global_rotation = 0
		SelectedArrow.visible = true
		SelectedArrow.play("default")
		SelectedArrow.global_position = global_position + Vector2(0, -cell_radius * 1.1)
		match tag:
			"player_cell":
				SelectedArrow.modulate = Color.green
			"enemy_cell":
				SelectedArrow.modulate = Color.red
			"neutral_cell":
				SelectedArrow.modulate = Color.yellow
			"cell":
				SelectedArrow.modulate = Color.white
	else:
		SelectedArrow.visible = false
		SelectedArrow.stop()
	
	
	var _target_goto_cell = NerveCell
	var _cloest_goto_cell_distance = 0
	var _smallest_angle = 10000
	for i in connected_cells.size():
		if (NerveCell.global_position - connected_cells[i].global_position).length() < (NerveCell.global_position - self.global_position).length() and (NerveCell.global_position - connected_cells[i].global_position).length() > _cloest_goto_cell_distance:
			_target_goto_cell = connected_cells[i]
			_cloest_goto_cell_distance = (NerveCell.global_position - connected_cells[i].global_position).length()
		#if abs((NerveCell.global_position - global_position).angle_to(NerveCell.global_position - _target_goto_cell.global_position)) < _smallest_angle:
			#_smallest_angle = (NerveCell.global_position - global_position).angle_to(NerveCell.global_position - _target_goto_cell.global_position)
			#_target_goto_cell = connected_cells[i]
	if (NerveCell.global_position - global_position).angle_to(NerveCell.global_position - _target_goto_cell.global_position) > PI / 2.2 and connected_cells.has(NerveCell):
		_target_goto_cell = NerveCell
	target_goto_cell = _target_goto_cell
	if (_target_goto_cell.global_position - self.global_position).length() > _target_goto_cell.cell_radius + self.cell_radius + 25:
		self.should_goto_center = true
	else:
		self.should_goto_center = false
	
	if !self.is_in_NN:
		self.should_goto_center = true
	
	if on_command:
		should_goto_center = false
		vector_to_command_position = LabelCell.global_position - global_position
		command_position = (global_position + vector_to_command_position) - NerveCell.global_position
		if (LabelCell.global_position - global_position).length() < cell_radius:
			on_command = false
			command_position = Vector2()
	
	if (get_global_mouse_position() - self.global_position).length() < cell_radius:
		is_mouse_entered = true
	else:
		is_mouse_entered = false
	
	#_update_energy_bar()

func _on_invincible_timer_timeout():
	state[STATE_INVINCIBLE] = false

func _on_body_enter_NNArea(body):
	if body == self or !body.has_method("_update_energy_bar"):
		return
	#print("enter!!!")
	connected_cells.append(body)

func _on_body_exit_NNArea(body):
	connected_cells.erase(body)

func _update_energy_bar():
	energy_bar.value = energy

func get_damage(damage, is_hit = true):
	if state[STATE_INVINCIBLE]:
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

func clear_collision_bit(target):
	for i in 12:
		target.set_collision_layer_bit(i, false)
		target.set_collision_mask_bit(i, false)

func set_collision_bit(body):
	#print(body.tag)
	body.set_collision_mask_bit(0, true)#player_cell
	body.set_collision_mask_bit(1, true)#enemy_cell
	body.set_collision_mask_bit(2, true)#neutral_cell
	body.set_collision_mask_bit(10, true)#wall
	match body.tag:
		"player_cell":
			#print("wahoo")
			body.set_collision_layer_bit(0, true)#player_cell
			body.set_collision_mask_bit(4, true)#enemy_projectile
			body.set_collision_mask_bit(5, true)#neutral_projectile
			body.set_collision_mask_bit(7, true)#enemy_weapon
			body.set_collision_mask_bit(8, true)#neutral_weapon
			body.set_collision_mask_bit(9, true)#collection
		"enemy_cell":
			body.set_collision_layer_bit(0, true)#player_cell
			body.set_collision_mask_bit(3, true)#player_projectile
			body.set_collision_mask_bit(5, true)#neutral_projectile
			body.set_collision_mask_bit(6, true)#player_weapon
			body.set_collision_mask_bit(8, true)#neutral_weapon
			#body.set_collision_mask_bit(9, true)#collection
		"neutral_cell":
			body.set_collision_layer_bit(0, true)#player_cell
			body.set_collision_mask_bit(3, true)#player_projectile
			body.set_collision_mask_bit(4, true)#enemy_projectile
			body.set_collision_mask_bit(6, true)#player_weapon
			body.set_collision_mask_bit(7, true)#enemy_weapon
			#body.set_collision_mask_bit(9, true)#collection

func on_init_ok():
	set_collision_bit(self)