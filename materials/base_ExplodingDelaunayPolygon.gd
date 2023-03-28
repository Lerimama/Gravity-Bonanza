extends Polygon2D

export var add_points_count: int = 3 # 0 = poligon ima samo vogale ... dva fragmenta

export var fragment_gravity: float = 0
export var fragment_speed: Array = [22, 25]
export var fragment_rotation: float = 300 # negativno je v smeri urinega kazalca
export var fragment_lifetime = 0.05 # sekunda?
export var fragment_scale: float = 1.0

var per_fragment_points = 3 # trikotnik pač
var fragment_direction_map = {} # slovar  za shranjevanje pozicije sredine trikotnika glede na center spriteta

var texture_width = texture.get_width()
var texture_height = texture.get_height()
export var explode_center = Vector2(0.5, 0.5)


func _ready() -> void:
	randomize()
	

func _input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("space"):
		reset()
		triangulate_polygon()
	if Input.is_action_just_pressed("pavza"):
		reset()
	
		
func _process(delta: float) -> void:
	
	if polygon: 
		# aplikacija gibanja, ko poligon obstaja
		for frag in fragment_direction_map.keys():
			frag.position -= fragment_direction_map[frag] * delta * rand_range(fragment_speed[0], fragment_speed[1])
			frag.rotation -= fragment_direction_map[frag].y * delta * fragment_rotation  # y je za variacijo rotacije glede na fragment
			fragment_direction_map[frag].x -= delta * fragment_gravity 
			
			
func triangulate_polygon():
	
	# definicija poligona
	var poly_points = polygon # array s točkami v trenutnem poligonu (vec2 pozicija)
	
	# fragmentiranje ... dodajanje točk znotraj poligona
	for point in range(add_points_count):
		var random_x = randi() % texture_width
		var random_y = randi() % texture_height
		var random_point: Vector2 = Vector2(random_x, random_y)
		poly_points.append(random_point)
		
	# triangulacija ... vlečenje robov med točkami
	var texture_center = Vector2(texture_width * explode_center.x, texture_height * explode_center.y) # center explozije preračunan v pixle
	var triangulate_points = Geometry.triangulate_delaunay_2d(poly_points) # array s točkami triangulacije
	
	if not triangulate_points: # error ček
		print ("error ... ni poligona")
	
	# število trikotnikov
	var triangulate_points_count: int = len(triangulate_points)
	var fragment_count: int = triangulate_points_count / per_fragment_points
	
	# fragment
	for fragment in fragment_count: # triangl dobi index trikotnika na katerem smo
		
		# koordinate točk trenutnega trikotnika
		var fragment_points = PoolVector2Array() # vec2 array ... je še prazen
		var fragment_center = Vector2.ZERO # je še default vrednosti
		for point in range(per_fragment_points):
			var current_point: Vector2 = poly_points[triangulate_points[(fragment * per_fragment_points) + point]] # predelimo trenutno točko trenutnega trikotnika
			fragment_points.append(current_point) # točko dodamo v array točk trenutnega trikotnika
			fragment_center += current_point # vec2 centru prištejemo vec2 lokacijo pike ... potem delim s št. točk
		
		# center trenutnega trikotnika
		fragment_center = fragment_center / per_fragment_points
		
		# vizualizacija trenutnega trikotnika		
		var fragment_polygon = Polygon2D.new()
		fragment_polygon.polygon = fragment_points # točke fragmenta so točke trikotnika
#		fragment.texture = texture # tekstura fragmenta je tekstura original poligona 
		fragment_polygon.color = Color (randf(), randf(), randf(), 1)
		
		# smer gibanja trikotnika od centra teksture proti centru trikotnika
		fragment_direction_map[fragment_polygon] = texture_center - fragment_center
		
		add_child(fragment_polygon)
	
	# ko so narejeni vsi fragmenti, skrijem original teksturo
	color.a = 0 
	
	
func reset():
	for child in get_children():
		if child.name != "Camera2D":
			remove_child(child)
	color.a = 1
	
