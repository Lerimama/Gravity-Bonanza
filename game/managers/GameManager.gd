extends Node


## ---------------------------------------------------------------------------------------------
## 
## KAJ DOGAJA
## - spawna plejerje in druge entitete v areni
## - spavna levele
## - uravnava potek igre (uvaljevlja pravila)
## - je centralna baza za vso statistiko igre
## - povezava med igro in HUDom
##
## KAJ NE ...
## - nima povezave z izgradnjo levela
## 
## ---------------------------------------------------------------------------------------------


signal stat_change_received (player_index, changed_stat, stat_new_value)
signal new_bolt_spawned # (name, ...)

# players
var player1_id = "P1"
var player2_id = "P2"
var player3_id = "P3"
var player4_id = "P4"
var enemy_id = "E1"
var bolts_in_game: Array
var spawned_bolt_index: int = 0

var pickables_in_game: Array
var available_pickable_positions: Array

onready var player1_profile = Pro.default_player_profiles[player1_id]
onready var player2_profile = Pro.default_player_profiles[player2_id]
onready var player3_profile = Pro.default_player_profiles[player3_id]
onready var player4_profile = Pro.default_player_profiles[player4_id]
onready var enemy_profile = Pro.default_player_profiles[enemy_id]

onready var tilemap_floor_cells: Array
onready var navigation_line: Line2D = $"../NavigationPath"
onready var enemy: KinematicBody2D = $"../Enemy"
#onready var enemy: KinematicBody2D = $"../Enemy"

onready var player_bolt = preload("res://game/player/Player.tscn")
onready var enemy_bolt = preload("res://game/enemies/Enemy.tscn")

# slovar vseh plejerjev
var game_stats: Dictionary = {
	"round": 0,
	"winner_id": "NN",
	"final_score": 0,
}


func _input(event: InputEvent) -> void:

	if Input.is_action_just_released("ui_cancel"):	
		restart()
		
	if bolts_in_game.size() < 6:
		# P1
		if Input.is_key_pressed(KEY_1):
			spawn_bolt(player_bolt, Ref.current_level.spawn_position_1.global_position, player1_id, 1)
		# P2
		if Input.is_key_pressed(KEY_2):
			spawn_bolt(player_bolt, Ref.current_level.spawn_position_2.global_position, player2_id, 2)
#		# P3
		if Input.is_key_pressed(KEY_3):
			spawn_bolt(player_bolt, Ref.current_level.spawn_position_3.global_position, player3_id, 3)
#		# P4
		if Input.is_key_pressed(KEY_4):
			spawn_bolt(player_bolt, Ref.current_level.spawn_position_4.global_position, player4_id, 4)
#		# Enemi
		if Input.is_key_pressed(KEY_5):
			spawn_bolt(enemy_bolt, get_parent().get_global_mouse_position(), enemy_id, 5)

	if Input.is_action_just_pressed("x"):
		spawn_pickable()


func _ready() -> void:
	
	Ref.game_manager = self	
	printt("Game Manager")
	

func _process(delta: float) -> void:
	bolts_in_game = get_tree().get_nodes_in_group(Ref.group_bolts)
	pickables_in_game = get_tree().get_nodes_in_group(Ref.group_pickups)	


func spawn_bolt(bolt, spawned_position, spawned_player_id, bolt_index):

	spawned_bolt_index += 1

	var new_bolt = bolt.instance()
	new_bolt.bolt_id = spawned_player_id
	new_bolt.global_position = spawned_position
#	new_bolt.z_index = 1
	Ref.node_creation_parent.add_child(new_bolt)

	new_bolt.look_at(Vector2(320,180)) # rotacija proti centru ekrana

	# če je plejer komp mu pošljem navigation area
	if new_bolt == enemy_bolt:
		new_bolt.navigation_cells = tilemap_floor_cells
	else:
		Ref.current_camera.follow_target = new_bolt

	# prikaz nav linije
#	new_bolt.connect("path_changed", self, "_on_Enemy_path_changed")
	# statistika
	new_bolt.connect("stat_changed", self, "_on_Stat_changed") # za prikaz linije, drugače ne rabiš

	# ustvarimo statistiko plejerja ...duplikat defaulta
	var spawned_player_stats = Pro.default_player_stats.duplicate()
	# statistiko plejerja damo v slovar vseh statistik
	game_stats[spawned_player_id] = spawned_player_stats

	emit_signal("new_bolt_spawned", spawned_bolt_index, spawned_player_id) # pošljem na hud, da prižge stat line in ga napolne
	printt("new_bolt_spawned", spawned_bolt_index, spawned_player_id)

func spawn_pickable():


	# uteži
	if not available_pickable_positions.empty():
#		print(available_pickable_positions.size())

		var pickables_array = Pro.Pickables_names # samo za evidenco pri debugingu

		# žrebanje tipa
		var pickables_dict = Pro.pickable_profiles
		var selected_pickable_index: int = Met.get_random_member_index(pickables_dict)
		var selected_pickable_name = Pro.Pickables_names[selected_pickable_index]
		var selected_pickable_path = pickables_dict[selected_pickable_index]["path"]

		# žrebanje pozicije
		var selected_cell_index: int = Met.get_random_member_index(tilemap_floor_cells)
		var selected_cell_position = tilemap_floor_cells[selected_cell_index]

		# spawn
		var new_pickable = selected_pickable_path.instance()
		new_pickable.global_position = selected_cell_position
		add_child(new_pickable)

		# odstranim celico iz arraya
		available_pickable_positions.remove(selected_cell_index)		


func restart():

	# če v grupi bolts obstaja kakšen bolt
	if not bolts_in_game.empty():
		for bolt in bolts_in_game:
			bolt
			bolt.queue_free()
	if not pickables_in_game.empty():
		for p in pickables_in_game:
			p.queue_free()
#	$"../UI/HUD".hide_player_stats()
	spawned_bolt_index = 0
	Ref.current_camera.follow_target = null


func check_neighbour_cells(cell_grid_position, area_span):

	var selected_cells: Array # = []
	var neighbour_in_check: Vector2

	# preveri vse celice v erase_area_span
	for y in area_span:
		for x in area_span:
			neighbour_in_check = cell_grid_position + Vector2(x - 1, y - 1)
			selected_cells.append(neighbour_in_check)
	return selected_cells


func _on_Enemy_path_changed(path: Array) -> void:
	# ta funkcija je vezana na signal bolta
	# inline connect za primer, če je bolt spawnan
	# def signal connect za primer, če je bolt "in-tree" node
	
	navigation_line.points = path


func _on_Stat_changed(stat_owner_id, changed_stat, new_stat_value):
	# ne setaš tipa parametrov, ker je lahko v različnih oblikah (index, string, float, ...)

	# beleženje statistike igralcev ... če je player_stat ga preračunam
	var player_stats_to_change: Dictionary = game_stats[stat_owner_id]
	match changed_stat:
		"player_active" :
			# value je v tem primeru sprememba stata
			player_stats_to_change["player_active"] = new_stat_value
			# value, ki ga pošljem spremenim v izračunanega
			new_stat_value = player_stats_to_change["player_active"]
		"life":
			player_stats_to_change["life"] += new_stat_value
			new_stat_value = player_stats_to_change["life"]
		"points" :
			player_stats_to_change["points"] += new_stat_value
			new_stat_value = player_stats_to_change["points"]
		"wins" :
			player_stats_to_change["wins"] += new_stat_value
			new_stat_value = player_stats_to_change["wins"]

	emit_signal("stat_change_received", stat_owner_id, changed_stat, new_stat_value) # pošljemo signal, ki je že prikloplje na HUD