extends KinematicBody2D


signal Get_hit_by_bullet (hit_location, bullet_velocity, bullet_owner)

var spawned_by: String
var spawned_by_color: Color

export var speed: float = 1400.00
var direction: Vector2
var velocity: Vector2
var collision: KinematicCollision2D

var away_from_owner_time_limit: float = 0.030 # za pedenanje kontakta z lastnikom
var away_from_owner: bool 
var away_from_owner_time: float

var new_bullet_trail: Object

#onready var detect_area: Area2D = $DetectArea
onready var trail_position: Position2D = $TrailPosition
onready var collision_shape: CollisionShape2D = $BulletCollision

onready var BulletTrail: PackedScene = preload("res://scenes/weapons/BulletTrail.tscn") 
onready var HitParticles: PackedScene = preload("res://scenes/weapons/BulletHitParticles.tscn")


func _ready() -> void:
	
	add_to_group("Bullets")
	modulate = spawned_by_color
	
	collision_shape.disabled = true # da ne trka z avtorjem ... ga vključimo ko area zazna izhod
		
	# set movement vector
	direction = Vector2(cos(rotation), sin(rotation))
	velocity = direction * speed	
	
	# spawn trail
	new_bullet_trail = BulletTrail.instance()
	new_bullet_trail.gradient.colors[1] = spawned_by_color
	Global.effects_creation_parent.add_child(new_bullet_trail)
	
	
func _process(delta: float) -> void:
	
	new_bullet_trail.add_points(trail_position.global_position)
	
	away_from_owner_time += 1.5 * delta
	if away_from_owner_time >= away_from_owner_time_limit:
		collision_shape.disabled = false


func _physics_process(delta: float) -> void:

	move_and_slide(velocity) 

	
	if get_slide_count() != 0: # preverjamo obstoj kolizije
		collision = get_slide_collision(0) # prva kolizija, da odstranimo morebitne erorje v debuggerju
		destroy_bullet()
		
		if collision.collider.has_method("on_hit"):
			
			# trenutno specialno za tilemap
			# oddam signal s sporočilom o poziciji
			emit_signal("Get_hit_by_bullet", collision.position + velocity.normalized()) 
			# tilemap prevede pozicijo na najbližjo pozicijo tileta v tilempu  
			# to pomeni da lahko izbriše prazen tile
			# s tem ko poziciji dodamo nekaj malega v smeri gibanja izstrelka, poskrbimo, da je izbran pravi tile 
			
			# pošljem kolizijo in node ... tam naredimo isto kot v zgornjem signalu
			collision.collider.on_hit(self)
			

func destroy_bullet():	
		
	# hit partikli
	var new_hit_particles = HitParticles.instance()
	new_hit_particles.position = collision.position
	new_hit_particles.rotation = collision.normal.angle() # rotacija partiklov glede na normalo površine 
	new_hit_particles.color = spawned_by_color
	new_hit_particles.set_emitting(true)
	Global.effects_creation_parent.add_child(new_hit_particles)
	
	new_bullet_trail.start_decay(collision.position) # zadnja pika se pripne na mesto kolizije
#		print ("KUFRI - Bullet")
	print("destroy")
	queue_free()
	
	
# za onemogočanje kolizije z avtorjem
func _on_DetectArea_body_exited(body: Node) -> void:
	
	if body.name == spawned_by:
#		collision_shape.disabled = false # v ready ga setamo true
		print ("collision_shape.disabled")
		print (collision_shape.disabled)
