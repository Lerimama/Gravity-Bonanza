extends Node2D


var tag_owner: Node

var hor_offset: float = 0
var ver_offset: float = 0

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var label: Label = $Tag/Label


func _ready() -> void:

	modulate.a = 1
	animation_player.play("float_lap")
	# KVEFRI je v animaciji


func _physics_process(delta: float) -> void:
	
	if tag_owner:
		global_position = tag_owner.global_position
	
	# klampanje znotraj ekrana
	var x_offset: float = (label.rect_size.x + 10) / 2 # širina labele
	var x_limit_left: float = Ref.current_camera.get_camera_screen_center().x - get_viewport().size.x/2 + x_offset
	var x_limit_right: float = Ref.current_camera.get_camera_screen_center().x + get_viewport().size.x/2 - x_offset
	var y_offset: float = 20 # razlika v višini po animaciji
	var y_limit_left: float = Ref.current_camera.get_camera_screen_center().y - get_viewport().size.y/2 + y_offset
	var y_limit_right: float = Ref.current_camera.get_camera_screen_center().y + get_viewport().size.y/2 - y_offset
	global_position.x = clamp(global_position.x, x_limit_left, x_limit_right)
	global_position.y = clamp(global_position.y, y_limit_left, y_limit_right)
