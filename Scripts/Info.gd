extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _draw():
	draw_circle(get_parent().target_goto_cell.global_position - get_parent().global_position, 5, Color.blue)

func _ready():
	self.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (get_parent().is_mouse_entered or get_parent().is_picked) and Input.is_key_pressed(KEY_SPACE):
		display()
	else:
		self.visible = false
	self.global_rotation = 0
func display():
	self.visible = true
	if get_parent().is_in_NN:
		$Label.modulate = Color.green
	else:
		$Label.modulate = Color.red
	update()
	$Label.text = str(get_parent().name_CN) + "\n" + "------" + "\n" + "能量" + str(get_parent().energy) + "/" + str(get_parent().max_energy) + "\n" + "护甲" + str(get_parent().armor) + "\n" + str(get_parent().is_connect_NerveCell)