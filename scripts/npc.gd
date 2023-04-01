extends KinematicBody2D


signal path_changed (path) # pošlje array pozicij
#signal target_reached # trenutno ni v uporabi


# player data
export var player_name: String = "Enemy"
var player_color: Color = Color.turquoise
export var inputs_enabled: bool = true # za nedelovanje naprej/nazaj ... input disable bilo bolje

# osnovno gibanje
export var axis_distance: int = 9 # medosna razdalja
export (int, 0, 1000) var engine_power = 200
export (int, 0, 180) var turn_angle = 15 # kot obrata per frame (stopinje)
export var free_rotation_multiplier = 20 # omogoča dovolj hitro rotacijo kadar je pri miru
export var max_speed_reverse = 120
export var max_speed = 100 # _temp
export var force_stop_velocity: int = 8

# interakcije
export (float, 0, 1.5) var friction = -1.0 # vpliv trenja s podlago (raste linearno s hitrostjo in vpliva na pospešek)
export (float, 0, 0.0010) var drag = -0.003 # vpliv upora zraka (raste kvadratno s hitrostjo in vpliva na končno hitrost)
export (float, 0, 0.1) var side_traction = 0.01 # vpliv na slajdanje ob zavoju ... manjši je, več je slajdanja
export (float, 0, 100) var mass = 10.0 # masa vpliva na vztrajnost plejerja
export (float, 0, 1) var bounce_size = 0.3 # velikost odboja		

# motion
var velocity: Vector2 = Vector2.ZERO
var acceleration: Vector2 = Vector2.ZERO
var rotation_angle: float # obrat per frame v izbrani smeri
var rotation_dir: float

var motion_enabled: bool = true # za nedelovanje naprej/nazaj ... input disable bilo bolje
var rev_motion: bool = false
var fwd_motion: bool = false

var bounce_angle: float
var collision: KinematicCollision2D

# shield
var shields_on = false
var shield_loops_counter: int = 0
var shield_loops_limit: int = 3

# pogon
var engine_particles_rear : CPUParticles2D
var engine_particles_front_left : CPUParticles2D
var engine_particles_front_right : CPUParticles2D
var engines_alpha: float = 1.0

# trail
var bolt_trail_active: bool = false # če je je aktivna, je ravno spawnana, če ni , potem je "odklopljena"
var new_bolt_trail: Object
var bolt_trail_stop_velocity: int = 80

# weapons
var bullet_reloaded: bool = true
var bullet_reload_time: float = 0.2
var bullet_hits_counter: int = 0 
var bullet_hits_limit: int = 5 # energija 
var bullet_push_factor: float = 0.02 # kako močen je potisk metka ... delež hitrosti metka
var misile_reloaded: bool = true
var misile_reload_time: float = 1.0

# vision
var ray_rotation_range = 60 # (+ ray_rotation_range <> - ray_rotation_range)
var ray_rotation_speed = 1.5
var ray_rotation_start: float

# following
var locked_on_target: bool
var target_reached: bool
var target_location: Vector2

# taveling
var travel_time: Array = [0.5, 1.0] # sek
onready var navigation_cells: Array # sek
onready var vision_ray_distance: float = get_viewport_rect().size.x * 0.7 # dolžina v smeri lokal x ... onready, ker še ni viewporta
var direction_set: bool =  false

var time: float

onready var bolt_sprite: Sprite = $Bolt
onready var rear_engine_pos: Position2D = $Bolt/RearEnginePosition
onready var front_engine_pos_left: Position2D = $Bolt/FrontEnginePositionL
onready var front_engine_pos_right: Position2D = $Bolt/FrontEnginePositionR
onready var gun_position: Position2D = $Bolt/GunPosition
onready var bolt_collision: CollisionPolygon2D = $BoltCollision
onready var shield_collision: CollisionShape2D = $ShieldCollision
onready var shield: Sprite = $Shield
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var navigation_agent = $NavigationAgent2D
onready var vision_ray = $RayCast2D

onready var CollisionParticles: PackedScene = preload("res://scenes/bolt/BoltCollisionParticles.tscn")
onready var EngineParticles: PackedScene = preload("res://scenes/bolt/EngineParticles.tscn") 
onready var ExplodingBolt: PackedScene = preload("res://scenes/bolt/ExplodingBolt.tscn") # trianguliran razpad bolta
onready var BoltTrail: PackedScene = preload("res://scenes/bolt/BoltTrail.tscn")
onready var Bullet: PackedScene = preload("res://scenes/weapons/Bullet.tscn")
onready var Misile: PackedScene = preload("res://scenes/weapons/Misile.tscn")
onready var Shocker: PackedScene = preload("res://scenes/weapons/Shocker.tscn")


func _ready() -> void:
	
	randomize()
	
	add_to_group("Enemies")
	add_to_group("Bolts")
	name = player_name # lahko da mora bit ugasnjeno zaradi nekega erorja
	bolt_sprite.modulate = player_color
	bolt_collision.disabled = false
	
	engines_setup() # postavi partikle za pogon
	
	# shield
	shield.modulate.a = 0 
	shield.self_modulate = player_color 
	shield_collision.disabled = true 
	
	# bolt wiggle šejder
	bolt_sprite.material.set_shader_param("noise_factor", 0)
	
	# raycast
	ray_rotation_start = rotation
	vision_ray.cast_to.x = vision_ray_distance


func _physics_process(delta: float) -> void:
	
	time += delta
	
	set_target_location(target_location)
	
	if locked_on_target: # not traveling
		look_at(navigation_agent.get_next_location())
	
	acceleration = position.direction_to(navigation_agent.get_next_location()) * engine_power # * 0
	apply_friction(delta) # adaptacija "acceleration"
	calculate_steering(delta) # adaptacija "rotacijo"
	velocity += acceleration * delta
	navigation_agent.set_velocity(velocity) # vedno za kustom velocity izračunom
	
	if not _arrived_at_location(): # ... motion move inside navigation signal
		fwd_motion = true
		collision = move_and_collide(velocity * delta, false)
	elif not target_reached:
		fwd_motion = false
		target_reached = true
		emit_signal("path_changed", []) # pošljemo prazen array, tako se linija sprazne
#		emit_signal("target_reached")	
			
	if collision:
		on_collision()
			
	apply_vision(delta)
	apply_motion_effects()
	add_trail_points()
	update_engine_position()
	shield.rotation = -rotation


func apply_vision(delta): # možgani ki odločajo ... delovanje (telo) pa je ph procesu
	
	# obračanje pogleda
	vision_ray.rotation += ray_rotation_speed * delta
	
	# določanje razpona
	if vision_ray.get_rotation_degrees() > ray_rotation_range or vision_ray.get_rotation_degrees() < -ray_rotation_range: 
		ray_rotation_speed *= -1
	
	# lockanje na tarčo
	if vision_ray.is_colliding():
		
		var collider = vision_ray.get_collider()
		
		if collider.is_in_group("Bolts"):
			target_location = collider.global_position
			look_at(collider.global_position)
			vision_ray.rotation = 0.0
			locked_on_target = true
			# shooting("misile")
		else:
			locked_on_target = false
			direction_set = false
			apply_travel_direction()
	

func apply_travel_direction(): # sproži se vsakič ko poteče ena smer
	
	# smer NI določena
	if not direction_set:
		
		var random_cell: Vector2 #= Vector2.ZERO
		var travel_area: Array
		var travel_angle: float = 90  # plus in minus

		# celice ma voljo		
		if not navigation_cells.empty(): # v prvem poskus je area prazen
			for cell_position in navigation_cells:
				# če je polju dosega
				if rad2deg(get_angle_to(cell_position)) > -travel_angle and rad2deg(get_angle_to(cell_position)) < travel_angle:
					travel_area.append(cell_position)
			
			# random travel celica 
			random_cell = travel_area[randi() % travel_area.size()]
		
		direction_set = true # smer je zdaj določena
	
		# random time
		var direction_time = rand_range(travel_time[0], travel_time[1])
		if time > direction_time:
			time = 0
			target_location = random_cell
			apply_travel_direction()
		
		
func on_collision():
	
	velocity = velocity.bounce(collision.normal) * bounce_size # gibanje pomnožimo z bounce vektorjem normale od objekta kolizije
	bounce_angle = collision.normal.angle_to(velocity)
	
	# odbojni partikli
	if velocity.length() > 10: # ta omenitev je zato, da ne prši, ko si fiksiran v steno
		var new_collision_particles = CollisionParticles.instance()
		new_collision_particles.position = collision.position
		new_collision_particles.rotation = collision.normal.angle() # rotacija partiklov glede na normalo površine 
		new_collision_particles.amount = velocity.length()/15 # količnik je korektor	
		new_collision_particles.color = player_color
		new_collision_particles.set_emitting(true)
		Global.effects_creation_parent.add_child(new_collision_particles)
		
		
func apply_motion_effects() -> void:

	if fwd_motion == true:
		engine_particles_rear.set_emitting(true)
		if bolt_trail_active == false && velocity.length() > 0: # če ne dodam hitrosti, se mi v primeru trka ob steno začnejo noro množiti
			new_bolt_trail = BoltTrail.instance()
			Global.effects_creation_parent.add_child(new_bolt_trail)
			bolt_trail_active = true 
	else:
		engine_particles_rear.set_emitting(false)
	
	if rev_motion:
		engine_particles_front_left.set_emitting(true)
		engine_particles_front_right.set_emitting(true)
		if bolt_trail_active == false && velocity.length() > 0: 
			new_bolt_trail = BoltTrail.instance()
			Global.effects_creation_parent.add_child(new_bolt_trail)
			bolt_trail_active = true 
	else:
		engine_particles_front_right.set_emitting(false)
		engine_particles_front_left.set_emitting(false)
	
	
func shooting(weapon) -> void:
	
	match weapon:
		"bullet": 
			if bullet_reloaded == true:
				var new_bullet = Bullet.instance()
				new_bullet.position = gun_position.global_position
				new_bullet.rotation = gun_position.global_rotation
				new_bullet.spawned_by = name # ime avtorja izstrelka
				new_bullet.spawned_by_color = player_color
				Global.node_creation_parent.add_child(new_bullet)
				
				bullet_reloaded = false
				yield(get_tree().create_timer(bullet_reload_time), "timeout")
				bullet_reloaded= true		
		"misile": 
			if misile_reloaded == true:	
				var new_misile = Misile.instance()
				new_misile.position = gun_position.global_position
				new_misile.rotation = gun_position.global_rotation
				new_misile.spawned_by = name # ime avtorja izstrelka
				new_misile.spawned_by_color = player_color
				new_misile.spawned_by_speed = velocity.length()
				Global.node_creation_parent.add_child(new_misile)
				
				misile_reloaded = false
				yield(get_tree().create_timer(misile_reload_time), "timeout")
				misile_reloaded= true	
		"shocker": 
			if bullet_reloaded == true:	
				var new_shocker = Shocker.instance()
				new_shocker.rotation = rear_engine_pos.global_rotation
				new_shocker.global_position = rear_engine_pos.global_position
				new_shocker.spawned_by = name # ime avtorja izstrelka
				new_shocker.spawned_by_color = player_color
				Global.effects_creation_layer.add_child(new_shocker)

				misile_reloaded = false
				yield(get_tree().create_timer(misile_reload_time), "timeout")
				misile_reloaded= true	
				
		
	# shield		
	if Input.is_action_just_pressed("shift"):
		
		if shields_on == false:
			shield.modulate.a = 1
			animation_player.play("shield_on")
			shields_on = true
			bolt_collision.disabled = true
			shield_collision.disabled = false
		else:
			animation_player.play_backwards("shield_on")
			# shields_on = false # premaknjeno dol na konec animacije
			# collisions setup premaknjeno dol na konec animacije
			shield_loops_counter = shield_loops_limit # imitiram zaključek loop tajmerja
			
	# test explozije
	if Input.is_action_just_pressed("x"):
#		die()
		explode_and_reset()
			
		
func apply_friction(delta: float) -> void:
	
	var friction_force = velocity * friction # linearna rast s hitrostjo
	var drag_force = velocity * velocity.length() * drag # ekspotencialno naraščanje, zato je velocity na kvadrat
	
	acceleration += drag_force + friction_force


func calculate_steering(delta: float) -> void:
	
	# lokacija sprednje in zadnje osi
	var rear_axis_position = position - transform.x * axis_distance / 2.0 # sredinska pozicija vozila minus polovica medosne razdalje
	var front_axis_position = position + transform.x * axis_distance / 2.0
	
	# sprememba lokacije osi ob gibanju (per frame)
	rear_axis_position += velocity * delta	
	front_axis_position += velocity.rotated(rotation_angle) * delta
	
	# nova smer je seštevek smeri obeh osi
	var new_heading = (front_axis_position - rear_axis_position).normalized()
	
	# rikverc?
	if rev_motion == true:
		velocity = velocity.linear_interpolate(-new_heading * min(velocity.length(), max_speed_reverse), 0.1)
	else:
		velocity = velocity.linear_interpolate(new_heading * velocity.length(), side_traction) # željeno smer gibanja doseže z zamikom "side-traction"	
	
	rotation = new_heading.angle() # sprite se obrne v smeri

			
func engines_setup():
	
	# naprej
	engine_particles_rear = EngineParticles.instance()
	engine_particles_rear.position = rear_engine_pos.global_position
	engine_particles_rear.rotation = rear_engine_pos.global_rotation
	engine_particles_rear.modulate.a = engines_alpha
	Global.effects_creation_parent.add_child(engine_particles_rear)
	
	# rikverc levo
	engine_particles_front_left = EngineParticles.instance()
	engine_particles_front_left.emission_rect_extents = Vector2.ZERO
	engine_particles_front_left.amount = 20
	engine_particles_front_left.initial_velocity = 50
	engine_particles_front_left.lifetime = 0.05
	engine_particles_front_left.position = front_engine_pos_left.global_position
	engine_particles_front_left.rotation = front_engine_pos_left.global_rotation - deg2rad(180)
	engine_particles_front_left.modulate.a = engines_alpha
	Global.effects_creation_parent.add_child(engine_particles_front_left)
	
	# rikverc desno
	engine_particles_front_right = EngineParticles.instance()
	engine_particles_front_right.emission_rect_extents = Vector2.ZERO
	engine_particles_front_right.amount = 20
	engine_particles_front_right.initial_velocity = 50
	engine_particles_front_right.lifetime = 0.05
	engine_particles_front_right.position = front_engine_pos_right.global_position
	engine_particles_front_right.rotation = front_engine_pos_right.global_rotation - deg2rad(180)	
	engine_particles_front_right.modulate.a = engines_alpha
	Global.effects_creation_parent.add_child(engine_particles_front_right)


func update_engine_position():
	
	engine_particles_rear.position = rear_engine_pos.global_position
	engine_particles_rear.rotation = rear_engine_pos.global_rotation
	
	engine_particles_front_left.position = front_engine_pos_left.global_position
	engine_particles_front_left.rotation = front_engine_pos_left.global_rotation - deg2rad(180)
	
	engine_particles_front_right.position = front_engine_pos_right.global_position
	engine_particles_front_right.rotation = front_engine_pos_right.global_rotation - deg2rad(180)	
	
		
func add_trail_points():
	
	if bolt_trail_active == true:
		if velocity.length() > 0:
			new_bolt_trail.gradient.colors[1] = player_color
			new_bolt_trail.add_points(global_position)
		elif velocity.length() == 0 && Input.is_action_pressed("ui_up") == false && Input.is_action_pressed("ui_down") == false: # "input" je, da izločim za hitre prehode med naprej nazaj
			new_bolt_trail.start_decay() # trail decay tween start
			bolt_trail_active = false # postane neaktivna, a je še vedno prisotna ... queue_free je šele na koncu decay tweena

	
func explode_and_reset():
	if visible == true:
		var new_exploding_bolt = ExplodingBolt.instance()
		new_exploding_bolt.global_position = global_position
		new_exploding_bolt.global_rotation = bolt_sprite.global_rotation
		new_exploding_bolt.spawned_by_color = player_color
		new_exploding_bolt.velocity = velocity # podamo hitrost, da se premika s hitrostjo bolta
		Global.node_creation_parent.add_child(new_exploding_bolt)
		visible = false
	else:
		visible = true
	
	
func on_hit(collision_object: Node):
	
	if shields_on != true:
		
		if collision_object.is_in_group("Bullets"):
			bullet_hits_counter += 1
			velocity = collision_object.velocity * bullet_push_factor
			# blink efekt ... more bit na koncu zaradi tajmerja
			modulate = Color.black
			yield(get_tree().create_timer(0.05), "timeout")
			modulate = Color.white 
			if bullet_hits_counter >= bullet_hits_limit:
				die()

		elif collision_object.is_in_group("Misiles"):
			die()
	
		elif collision_object.is_in_group("Shockers"):
			if motion_enabled == true: # catch
				motion_enabled = false
				velocity = lerp(velocity, Vector2.ZERO, 0.8)
				bolt_sprite.material.set_shader_param("noise_factor", 2.0)
				bolt_sprite.material.set_shader_param("speed", 0.7)
				
				var modulate_tween = get_tree().create_tween()
				modulate_tween.tween_property(bolt_sprite, "modulate", Color.white, 0.5)
				
			elif motion_enabled != true: # release
				motion_enabled = true
				bolt_sprite.material.set_shader_param("noise_factor", 0.0)
				bolt_sprite.material.set_shader_param("speed", 0.0)
				
				var modulate_tween = get_tree().create_tween()
				modulate_tween.tween_property(bolt_sprite, "modulate", player_color, 0.5)		


func die():
	
	# najprej explodiraj 
	# potem ugasni sprite in coll 
	# potem ugasni motor in štartaj trail decay
	# explozijo izključi ko grejo partikli ven
	var new_exploding_bolt = ExplodingBolt.instance()
	new_exploding_bolt.global_position = global_position
	new_exploding_bolt.global_rotation = bolt_sprite.global_rotation
	new_exploding_bolt.modulate = modulate
	new_exploding_bolt.modulate.a = 1
	new_exploding_bolt.velocity = velocity # podamo hitrost, da se premika s hitrostjo bolta
	Global.node_creation_parent.add_child(new_exploding_bolt)
	queue_free()		


func set_target_location (target: Vector2):
	target_reached = false
	navigation_agent.set_target_location(target)


func _arrived_at_location()-> bool:
	return navigation_agent.is_navigation_finished()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	
	shield_loops_counter += 1
	
	match anim_name:
		"shield_on":	
			# končan outro ... resetiramo lupe in ustavimo animacijo
			if shield_loops_counter > shield_loops_limit:
				animation_player.stop(false) # včasih sem rabil, da se ne cikla, zdaj pa je okej, ker ob
				shield_loops_counter = 0
				shields_on = false
				bolt_collision.disabled = false
				shield_collision.disabled = true
			# končan intro ... zaženi prvi loop
			else:
				animation_player.play("shielding")
		"shielding":
			# dokler je loop manjši od limita ... replayamo animacijo
			if shield_loops_counter < shield_loops_limit:
				animation_player.play("shielding") # animacija ni naštimana na loop, ker se potem ne kliče po vsakem loopu
			# konec loopa, ko je limit dosežen
			elif shield_loops_counter >= shield_loops_limit:
				animation_player.play_backwards("shield_on")


func _on_NavigationAgent2D_velocity_computed(safe_velocity: Vector2, delta) -> void:
	
	# moved from phys process + safe_velocity
	if not _arrived_at_location():
		collision = move_and_collide(safe_velocity * delta, false) # infinite_inertia = false
	elif not target_reached: # če je prišel na lokacijo in je has arrived false
		target_reached = true
		emit_signal("path_changed", []) # pošljemo prazen array, tako se linija sprazne
		emit_signal("target_reached")

	
func _on_NavigationAgent2D_path_changed() -> void:
	emit_signal("path_changed", navigation_agent.get_nav_path()) # pošljemo točke poti do cilja
