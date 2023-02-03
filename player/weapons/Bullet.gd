extends Node2D


#signal Get_hit (hit_location, bullet_velocity, bullet_owner)

var speed: float = 800.00

var BulletTrail = preload("res://player/weapons/BulletTrail.tscn") 
var TrailParticles = preload("res://player/weapons/TrailParticles.tscn") 
var HitParticles = preload("res://player/weapons/BulletHitParticles.tscn")
onready var raycast = $RayCast2D

var trail_particles: Object
var bullet_trail: Object


func _ready() -> void:
	
	add_to_group("Bullets")
	set_as_toplevel(true)
	
	trail_particles = TrailParticles.instance()
	AutoGlobal.node_creation_parent.add_child(trail_particles)
	trail_particles.position = $TrailPosition.global_position
	trail_particles.rotation = $TrailPosition.global_rotation
	trail_particles.set_emitting(false)
	
	
	trail_particles.set_as_toplevel(true) # načeloma ne rabi, ampak se mi občasno pokaže kar nekje
	
	bullet_trail = BulletTrail.instance()
	AutoGlobal.node_creation_parent.add_child(bullet_trail)
	bullet_trail.set_as_toplevel(true)
#	$TrailParticles.set_emitting(false)
	
#	hit_particles.position = part_location
#	hit_particles.rotation = raycast.get_collision_normal().angle() # rotacija partiklov glede na normalo površine
#	hit_particles.set_emitting(true)
#	AutoGlobal.node_creation_parent.add_child(hit_particles)
func _process(delta: float) -> void:
	
	$BulletTrail.add_points($TrailPosition.global_position)
	bullet_trail.add_points($TrailPosition.global_position)
	position += transform.x * speed * delta

	# partliki sledijo raketi
#	engine_particles_rear.position = $Bolt/RearEnginePosition_alt.position
#	trail_particles.position = $TrailPosition.global_position
#	trail_particles.rotation = $TrailPosition.global_rotation
#	engine_particles_frontL.position = $FrontEnginePositionL.global_position
#	engine_particles_frontR.position = $FrontEnginePositionR.global_position
#	engine_particles_rear.rotation = $Bolt/RearEnginePosition_alt.global_rotation
#	engine_particles_rear.rotation = $Bolt.global_rotation
#	engine_particles_frontL.rotation = global_rotation - deg2rad(180)
#	engine_particles_frontR.rotation = global_rotation - deg2rad(180)	
	
#	print($RayCast2D.force_raycast_update())
#	$Line2D.rotation = $RayCast2D.rotation

	
	 
func _physics_process(delta: float) -> void:
	trail_particles.position = $TrailPosition.global_position
	trail_particles.rotation = $TrailPosition.global_rotation
	# ker so navadne kolizije prepočasne, uporabim raycast
	
	
	if raycast.is_colliding():
		
		var collision_position = raycast.get_collision_point()
		var distance_to_collision = raycast.get_collision_point() - global_position
		var part_location = global_position + distance_to_collision
		
		# rotacija partiklov glede na kot zadete površine
		var hit_particles = HitParticles.instance()
		hit_particles.position = part_location
		hit_particles.rotation = raycast.get_collision_normal().angle() # rotacija partiklov glede na normalo površine
#		hit_particles.set_one_shot(true)
		hit_particles.set_emitting(true)
		AutoGlobal.node_creation_parent.add_child(hit_particles)
		
#		trail_particles.modulate.a = 0.0
		trail_particles.set_emitting(false)
#		trail_particles.modulate.a(false)
		
	
		
		queue_free()
#		modulate.a = 0.0
#		$BulletTrail.stop()
#		speed = 10.0

func _on_BulletArea_body_entered(collider: Object) -> void:
	
	if collider != owner: # če telo ni od avtorja 
		
		print("colided")
#		if $RayCast2D.is_colliding():
#			print("hit")
		# hit efekt
#		var new_hit_particles = hit_particles.instance()
#		new_hit_particles.position = global_position
#		new_hit_particles.rotation = global_rotation - deg2rad(180)
#		new_hit_particles.set_emitting(true)
#		AutoGlobal.node_creation_parent.add_child(new_hit_particles)
		
#		queue_free()
		
		if collider.has_method("on_hit"):
			collider.on_hit()
