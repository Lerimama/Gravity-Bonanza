extends Node2D


onready var enemy_navigation_line: Line2D = $NavigationPath # greba GM
onready var camera_screen_area: Area2D = $ScreenArea # greba GM
onready var level_placeholder: Position2D = $LevelPosition # greba GM
onready var bolt_navigation_line: Line2D = $BoltNavigationLine



func _ready() -> void:
	
	if not Set.debug_mode:
		enemy_navigation_line.hide()
	
			
	Ref.node_creation_parent = $NCP
#	modulate = Color.black
#	Ref.node_creation_parent = self
	print("ARENA")
