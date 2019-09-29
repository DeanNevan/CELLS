extends Node

var mouse_start_position = Vector2()

onready var MouseRegion = Area2D.new()
onready var MouseRegionShape = CollisionShape2D.new()

onready var Main = get_node("../Main")

func _ready():
	Main.add_child(MouseRegion)
	MouseRegion.connect("body_entered", self, "_on_body_entered")
	MouseRegion.connect("body_exited", self, "_on_body_exited")
	MouseRegion.add_child(MouseRegionShape)
	#MouseRegion.space_override = Area2D.SPACE_OVERRIDE_REPLACE_COMBINE
	MouseRegionShape.shape = RectangleShape2D.new()
	MouseRegionShape.shape.extents = Vector2()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("left_mouse_button"):
		mouse_start_position = Main.get_global_mouse_position()
		
	if Input.is_action_pressed("left_mouse_button"):
		MouseRegionShape.global_position = Main.get_global_mouse_position() + ((mouse_start_position - Main.get_global_mouse_position()) / 2.0)
		MouseRegionShape.shape.extents = Vector2((mouse_start_position - Main.get_global_mouse_position()).x / 2.0, (mouse_start_position - Main.get_global_mouse_position()).y / 2.0)
		
	else:
		MouseRegionShape.shape.extents = Vector2()