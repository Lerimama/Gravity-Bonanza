extends StaticBody2D


var magnet_color_off: Color = Set.color_brick_magnet_off
var magnet_color_on: Color = Set.color_brick_magnet_on # opredeli se v animaciji

var magnet_on: bool

var def_particle_speed: float = 0.5
var gravity_force: float = 70.0 # sila gravitacije
var brick_altitude: float = 5

var time: float = 0
var off_time: float = 2
var on_time: float = 2

onready var force_field: Area2D = $ForceField
onready var sprite: Sprite = $Sprite
onready var blackhole_particles: Particles2D = $BlackholeParticles
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var brick_shadow: Sprite = $BrickShadow


func _ready() -> void:
	
	sprite.modulate = magnet_color_off
	brick_shadow.shadow_distance = brick_altitude


func _physics_process(delta: float) -> void:
	
	time += delta 
	if time > off_time and not magnet_on:
		intro()
		time = 0
	elif time > on_time and magnet_on:
		time = 0
		outro()

	if magnet_on:
		var detected_bodies = force_field.get_overlapping_bodies()
		for body in detected_bodies:
			if body.is_in_group(Ref.group_bolts):
				var vector_to_magnet: Vector2 = body.global_position.direction_to(global_position)
				var distance_to_magnet: float = body.global_position.distance_to(global_position)
				var gravity_velocity: float = gravity_force / (distance_to_magnet * 1)
				body.velocity += Vector2(gravity_velocity, 0).rotated(vector_to_magnet.angle())
				# points
				var points_reward: float = Ref.game_manager.game_settings["magnet_brick_points"]
				body.points = points_reward # setget
#				body.score_points(points_reward)
		

func intro():
#		blackhole_particles.emitting = true
#		blackhole_particles.speed_scale = def_particle_speed
#		animation_player.play("intro")
		
		var tween_time: float = 0.5
		var magnet_on_tween = get_tree().create_tween()#.set_ease(Tween.EASE_IN).set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
		magnet_on_tween.tween_property(self, "modulate", magnet_color_on, tween_time)
#		magnet_on_tween.tween_property(self, "modulate:a", 1, intro_time)
		yield(magnet_on_tween, "finished")
		magnet_on = true

func outro():
#		magnet_on = false
#		animation_player.play("outro")
#		blackhole_particles.speed_scale = 0.7
#		blackhole_particles.emitting = false
		magnet_on = false	
		var tween_time: float = 0.5
		var magnet_off_tween = get_tree().create_tween()#.set_ease(Tween.EASE_IN).set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
		magnet_off_tween.tween_property(self, "modulate", magnet_color_off, tween_time)
#		magnet_off_tween.tween_property(self, "modulate:a", 0.4, intro_time)


func pause_me():
	set_physics_process(false)
	blackhole_particles.speed_scale = 0
#	animation_player.stop(false)


func unpause_me():
	set_physics_process(true)
	blackhole_particles.speed_scale = def_particle_speed
#	animation_player.play()



func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	
	match anim_name:
		"intro":
			magnet_on = true
			
