extends StaticBody2D


var turned_on: bool = false
var bolts_in_goal_area: Array = []
var pillar_altitude: float = 5

onready var light_2d: Light2D = $Light2D
onready var light_poly: Polygon2D = $LightPoly
onready var pillar_shadow: Sprite = $PillarShadow


func _ready() -> void:
	
	light_2d.color = Set.color_red
	light_poly.color = Set.color_red
	pillar_shadow.shadow_distance = pillar_altitude
	

func goal_reached(bolt: KinematicBody2D):
	
	if not turned_on:
		turned_on = true
		light_2d.color = Set.color_green
		light_poly.color = Set.color_green
		# points
		var points_reward: float = Ref.game_manager.game_settings["goal_points"]
		bolt.points = points_reward # setget
	

func _on_DetectArea_body_entered(body: Node) -> void:
	
	if body.is_in_group(Ref.group_bolts):
		bolts_in_goal_area.append(body)


func _on_DetectArea_body_exited(body: Node) -> void:

	if bolts_in_goal_area.has(body):
		bolts_in_goal_area.erase(body)
		goal_reached(body)
