extends Area2D
class_name Pickable #, "res://assets/class_icons/pickable_icon.png"


enum Pickables {BULLET, MISILE, MINA, SHOCKER, SHIELD, ENERGY, GAS, LIFE, NITRO, TRACKING, POINTS, RANDOM} # mešanje zaporedja meša izbrane tipe
export (Pickables) var pickable_type 

var pickable_value: float # = 0 pobere iz profilov
var pickable_type_key: String
var pickable_color: Color # = 0 pobere iz profilov
var pickable_altitude: float = 5

onready var sprite: Sprite = $Sprite
onready var detect_area: CollisionPolygon2D = $CollisionPolygon2D
onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var pickable_shadow: Sprite = $PickableShadow

#onready var sounds: Node = $Sounds
#onready var sound_picked: AudioStreamPlayer = $Sounds/PickedDefault

func _ready() -> void:
	
	add_to_group(Ref.group_pickables)
	pickable_type_key = Pickables.keys()[pickable_type]
	pickable_value = Pro.pickable_profiles[pickable_type_key]["pickable_value"]
	pickable_color = Pro.pickable_profiles[pickable_type_key]["pickable_color"]
	modulate = pickable_color
	pickable_shadow.shadow_distance = pickable_altitude

	
func _on_Item_body_entered(body: Node) -> void:
	
	# če je med soundi kakšen poleg defaultnega, potem zaigraj zadnjega
#	var all_sounds: Array = sounds.get_children()
#	if all_sounds.size() > 1:
#		sound_picked = all_sounds[all_sounds.size() - 1] 
	
	if body.has_method("on_item_picked"):
		if pickable_type == Pickables.BULLET or pickable_type == Pickables.MISILE \
		or pickable_type == Pickables.MINA or pickable_type == Pickables.SHOCKER:
			Ref.sound_manager.play_sfx("pickable_weapon")
		elif pickable_type == Pickables.NITRO:
			Ref.sound_manager.play_sfx("pickable_nitro")
		else:
			Ref.sound_manager.play_sfx("pickable")
			pass
#		sound_picked.play()
		body.on_item_picked(pickable_type_key)
#		modulate.a = 0
#		monitorable = false
#		monitoring = false

		queue_free()

#func _on_Picked_finished() -> void:
#	queue_free()	
