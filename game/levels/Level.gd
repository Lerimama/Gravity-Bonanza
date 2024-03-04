extends Node2D


signal level_is_set(navigation, spawn_positions, other_)


var non_navigation_cell_positions: Array # elemnti, kjer navigacija ne sme potekati

onready var tilemap_floor: TileMap = $Floor
onready var tilemap_elements: TileMap = $Elements
onready var tilemap_edge: TileMap = $Edge

onready var positions: Array = $Positions.get_children()
onready var racing_line: Node2D = $RacingLine

# elements
onready var goal_pillar: PackedScene = preload("res://game/arena_elements/GoalPillar.tscn")
onready var brick_ghost: PackedScene = preload("res://game/arena_elements/BrickGhost.tscn")
onready var brick_bouncer: PackedScene = preload("res://game/arena_elements/BrickBouncer.tscn")
onready var brick_magnet: PackedScene = preload("res://game/arena_elements/BrickMagnet.tscn")
onready var brick_target: PackedScene = preload("res://game/arena_elements/BrickTarget.tscn")
onready var brick_light: PackedScene = preload("res://game/arena_elements/BrickLight.tscn")
onready var area_nitro: PackedScene = preload("res://game/arena_elements/AreaNitro.tscn")
onready var area_tracking: PackedScene = preload("res://game/arena_elements/AreaTracking.tscn")
onready var area_gravel: PackedScene = preload("res://game/arena_elements/AreaGravel.tscn")
onready var area_finish: PackedScene = preload("res://game/arena_elements/AreaFinish.tscn")
# pickables
onready var pickable_energy: PackedScene = preload("res://game/arena_elements/pickables/PickableEnergy.tscn")
onready var pickable_life: PackedScene = preload("res://game/arena_elements/pickables/PickableLife.tscn")
onready var pickable_bullet: PackedScene = preload("res://game/arena_elements/pickables/PickableBullet.tscn")
onready var pickable_misile: PackedScene = preload("res://game/arena_elements/pickables/PickableMisile.tscn")
onready var pickable_shocker: PackedScene = preload("res://game/arena_elements/pickables/PickableShocker.tscn")
onready var pickable_shield: PackedScene = preload("res://game/arena_elements/pickables/PickableShield.tscn")
onready var pickable_nitro: PackedScene = preload("res://game/arena_elements/pickables/PickableNitro.tscn")
onready var pickable_tracking: PackedScene = preload("res://game/arena_elements/pickables/PickableTracking.tscn")
onready var pickable_random: PackedScene = preload("res://game/arena_elements/pickables/PickableRandom.tscn")
onready var pickable_gas: PackedScene = preload("res://game/arena_elements/pickables/PickableGas.tscn")
# floor
var corner_cell_TopL_regions: Array = [
	Vector2(2,3), Vector2(1,5),
	Vector2(8,6), Vector2(10,6), Vector2(12,6), Vector2(14,6),
	Vector2(3,8), Vector2(5,8), Vector2(14,8),
	Vector2(2,13), Vector2(8,13), Vector2(14,13),
	Vector2(9,15), Vector2(11,15),
	Vector2(9,17), Vector2(11,17)
	]
var corner_cell_TopR_regions: Array =[
	Vector2(0,3), Vector2(5,5),
	Vector2(7,6), Vector2(9,6), Vector2(11,6), Vector2(13,6),
	Vector2(2,8), Vector2(4,8), Vector2(13,8),
	Vector2(1,13), Vector2(7,13), Vector2(13,13),
	Vector2(8,15), Vector2(10,15),
	Vector2(8,17), Vector2(10,17)
	]
var corner_cell_BtmL_regions: Array = [
	Vector2(2,1), Vector2(1,9),
	Vector2(8,5), Vector2(10,5), Vector2(12,5), Vector2(14,5),
	Vector2(3,7), Vector2(5,7), Vector2(14,7),
	Vector2(2,12), Vector2(8,12), Vector2(14,12),
	Vector2(9,14), Vector2(11,14),
	Vector2(9,16), Vector2(11,16)
	]
var corner_cell_BtmR_regions: Array = [
	Vector2(0,1), Vector2(5,9),
	Vector2(7,5), Vector2(9,5), Vector2(11,5), Vector2(13,5),
	Vector2(2,7), Vector2(4,7), Vector2(13,7),
	Vector2(1,12), Vector2(7,12), Vector2(13,12),
	Vector2(8,14), Vector2(10,14),
	Vector2(8,16), Vector2(10,16)
	]
onready var corner_tile: PackedScene = preload("res://game/arena_elements/AreaHoleCorner.tscn")
onready var test_tile: PackedScene = preload("res://game/arena_elements/AreaHole.tscn")	


func _ready() -> void:
	
	Ref.current_level = self # zaenkrat samo zaradi pozicij ... lahko bi bolje
	printt("LEVEL")
	set_level_floor()
	set_level_elements()
	set_level_edge() # more bit po elementsih zato, da se prilagodi navigacija


func get_tilemap_cells(tilemap: TileMap):
	# kadar me zanimajo tudi prazne celice
	
	var tilemap_cells: Array # celice v gridu
	
	for x in tilemap.get_used_rect().size.x:
		for y in tilemap.get_used_rect().size.y:	
			var cell: Vector2 = Vector2(x, y)
			tilemap_cells.append(cell)
	
	return tilemap_cells


# EDGE ---------------------------------------------------------------------------------------------------------------------------------


func set_level_edge():
	
	var edge_cells = get_tilemap_cells(tilemap_edge) # celice v obliki grid koordinat
	var navigation_cells: Array
	var navigation_cells_positions: Array
	
	for cell in edge_cells:
		var cell_index = tilemap_edge.get_cellv(cell)
		var cell_local_position = tilemap_edge.map_to_world(cell)
		var cell_global_position = tilemap_edge.to_global(cell_local_position)
		
		# če je prazna in ni zasedena z elemenotom, jo zamenjam z navigacijsko celico
		if cell_index == -1 and not non_navigation_cell_positions.has(cell_global_position):
			tilemap_edge.set_cellv(cell, 13)
			navigation_cells.append(cell) # grid pozicije
			navigation_cells_positions.append(cell_global_position)
			
			# če ima za soseda rob, potem jo odstranim
			var cell_in_check: Vector2
			for y in 5: # pregledam 5 celic v ver in hor smeri
				for x in 5:
					cell_in_check = cell + Vector2(x - 2, y - 2) # čekirana celica je v sredini 5 pregledanih celic
					if tilemap_edge.get_cellv(cell_in_check) == 0:
						tilemap_edge.set_cellv (cell, -1)
						# zbrišem iz arrayev navigacije
						navigation_cells.erase(cell)
						navigation_cells_positions.erase(cell_global_position)
						break
	
	emit_signal("level_is_set", positions, navigation_cells, navigation_cells_positions)


# ELEMENTS ---------------------------------------------------------------------------------------------------------------------------------


func set_level_elements():
	

#	var element_cells = get_tilemap_cells(tilemap_edge) # poberem celice edga, da je prave velikosti
	if tilemap_elements.get_used_cells().empty():
		return
		
	for cell in tilemap_elements.get_used_cells():
		
		var cell_index = tilemap_elements.get_cellv(cell)
		var cell_local_position = tilemap_elements.map_to_world(cell)
		var cell_global_position = tilemap_elements.to_global(cell_local_position)	
	
		match cell_index:
			6: # goal pillar
				spawn_element(cell_global_position, goal_pillar, Vector2(13,12))
				tilemap_elements.set_cellv(cell, -1)
				non_navigation_cell_positions.append(cell_global_position)
				
			7: # brick ghost
				spawn_element(cell_global_position, brick_ghost, Vector2(5,4))
				tilemap_elements.set_cellv(cell, -1)
				non_navigation_cell_positions.append(cell_global_position)
			8: # brick bouncer
				spawn_element(cell_global_position, brick_bouncer, Vector2(5,4))
				tilemap_elements.set_cellv(cell, -1)
				non_navigation_cell_positions.append(cell_global_position)
			9: # brick magnet
				spawn_element(cell_global_position, brick_magnet, Vector2(5,4))
				tilemap_elements.set_cellv(cell, -1)
				non_navigation_cell_positions.append(cell_global_position)
			10: # brick target
				spawn_element(cell_global_position, brick_target, Vector2(5,4))
				tilemap_elements.set_cellv(cell, -1)
				non_navigation_cell_positions.append(cell_global_position)
			11: # brick light
				spawn_element(cell_global_position, brick_light, Vector2(5,4))
				tilemap_elements.set_cellv(cell, -1)
				
			28: # area nitro ... 12
				spawn_element(cell_global_position, area_nitro, Vector2(5,4))
			29: # area gravel ... 13
				spawn_element(cell_global_position, area_gravel, Vector2(5,4))
				non_navigation_cell_positions.append(cell_global_position)
			23: # area finish
				spawn_element(cell_global_position, area_finish, Vector2(9,8))
				non_navigation_cell_positions.append(cell_global_position)
#				tilemap_elements.set_cellv(cell, -1)
				
			14: # pickable bullet
				spawn_element(cell_global_position, pickable_bullet, Vector2(9,8))
				tilemap_elements.set_cellv(cell, -1)
			15: # pickable misile
				spawn_element(cell_global_position, pickable_misile, Vector2(9,8))
				tilemap_elements.set_cellv(cell, -1)
			16: # pickable shocker
				spawn_element(cell_global_position, pickable_shocker, Vector2(9,8))
				tilemap_elements.set_cellv(cell, -1)
			17: # pickable shield
				spawn_element(cell_global_position, pickable_shield, Vector2(9,8))
				tilemap_elements.set_cellv(cell, -1)
			18: # pickable energy
				spawn_element(cell_global_position, pickable_energy, Vector2(9,8))
				tilemap_elements.set_cellv(cell, -1)
			19: # pickable life
				spawn_element(cell_global_position, pickable_life, Vector2(9,8))
				tilemap_elements.set_cellv(cell, -1)
			20: # pickable nitro
				spawn_element(cell_global_position, pickable_nitro, Vector2(9,8))
				tilemap_elements.set_cellv(cell, -1)
			21: # pickable tracking
				spawn_element(cell_global_position, pickable_tracking, Vector2(9,8))
				tilemap_elements.set_cellv(cell, -1)
			22: # pickable random
				spawn_element(cell_global_position, pickable_random, Vector2(9,8))
				tilemap_elements.set_cellv(cell, -1)
			27: # pickable gas
				spawn_element(cell_global_position, pickable_gas, Vector2(9,8))
				tilemap_elements.set_cellv(cell, -1)


func spawn_element(element_global_position: Vector2, element_scene: PackedScene, element_center_offset: Vector2):
	
	var new_element_scene = element_scene.instance() #
	new_element_scene.position = element_global_position + element_center_offset
	add_child(new_element_scene)	


# FLOOR --------------------------------------------------------------------------------------------------------------------------------
	
	
func set_level_floor():
	# poberi vse celice podna, tudi prazne
	# vsem praznim pripiši luknjo
	# vse ostale so background	
	
	var floor_cells = get_tilemap_cells(tilemap_floor)
	
	if floor_cells.empty(): # če je prazen se navigacija ne seta
		return
		
	for cell in floor_cells:
		var cell_index = tilemap_floor.get_cellv(cell)
		var cell_local_position = tilemap_floor.map_to_world(cell)
		var cell_global_position = tilemap_floor.to_global(cell_local_position)
		
		if cell_index == -1:
			spawn_hole(cell_global_position)
		

func spawn_hole(global_pos):
	
	var new_tile = test_tile.instance()
	new_tile.global_position = global_pos + Vector2(5,4)
	get_parent().call_deferred("add_child",new_tile)


func _on_Edge_navigation_completed() -> void:
	pass # Replace with function body.
