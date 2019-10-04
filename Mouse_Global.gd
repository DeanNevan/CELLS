extends Node

var mouse_start_position = Vector2()

var is_mouse_selecting = false

onready var MouseRegion = ColorRect.new()
onready var MouseRegionArea = Area2D.new()
onready var MouseRegionShape = CollisionShape2D.new()

onready var Main = get_node("../Main")

func _ready():
	Main.add_child(MouseRegion)
	MouseRegion.rect_size = Vector2()
	MouseRegion.color = Color(1, 1, 1, 0.2)
	
	Main.add_child(MouseRegionArea)
	#MouseRegionArea.visible = false
	MouseRegionArea.add_child(MouseRegionShape)
	MouseRegionShape.shape = RectangleShape2D.new()
	MouseRegionShape.shape.extents = Vector2()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("left_mouse_button"):
		mouse_start_position = Main.get_global_mouse_position()
	if Input.is_action_pressed("left_mouse_button"):
		is_mouse_selecting = true
		
		MouseRegionArea.global_position = mouse_start_position + ((Main.get_global_mouse_position() - mouse_start_position) / 2.0)
		MouseRegionShape.shape.extents = Vector2(abs(Main.get_global_mouse_position().x - mouse_start_position.x) / 2.0, abs(Main.get_global_mouse_position().y - mouse_start_position.y) / 2.0)
		
		MouseRegion.rect_position = mouse_start_position + Vector2(Main.get_global_mouse_position().x - mouse_start_position.x, 0)
		MouseRegion.rect_size = Vector2(abs(Main.get_global_mouse_position().x - mouse_start_position.x), abs(Main.get_global_mouse_position().y - mouse_start_position.y))
		
		if Main.get_global_mouse_position().x < mouse_start_position.x and Main.get_global_mouse_position().y < mouse_start_position.y:
			MouseRegion.rect_scale = Vector2(1, -1)
		elif Main.get_global_mouse_position().x < mouse_start_position.x and Main.get_global_mouse_position().y > mouse_start_position.y:
			MouseRegion.rect_scale = Vector2(1, 1)
		elif Main.get_global_mouse_position().x > mouse_start_position.x and Main.get_global_mouse_position().y > mouse_start_position.y:
			MouseRegion.rect_scale = Vector2(-1, 1)
		elif Main.get_global_mouse_position().x > mouse_start_position.x and Main.get_global_mouse_position().y < mouse_start_position.y:
			MouseRegion.rect_scale = Vector2(-1, -1)
	else:
		is_mouse_selecting = false
		MouseRegionShape.shape.extents = Vector2()
		MouseRegion.rect_size = Vector2()