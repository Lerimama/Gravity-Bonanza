extends Node

## lastnosti entitet, pikablov, boltov, plejerja, ai ...


var pickable_profiles: Dictionary = {
	# imena so ista kot enum ključi v pickables
	
	"BULLET": { # BULLET
		"pickable_value": 20,
		"pickable_time": 0, # sekunde
		"scene_path": preload("res://game/arena_elements/pickables/PickableBullet.tscn"),
	},
	"MISILE": { # MISILE
		"pickable_value": 2,
		"pickable_time": 0, # sekunde
		"scene_path": preload("res://game/arena_elements/pickables/PickableMisile.tscn"),
	}, 
	"SHOCKER": { # SHOCKER
		"pickable_value": 3,
		"pickable_time": 10, # sekunde
		"scene_path": preload("res://game/arena_elements/pickables/PickableShocker.tscn"),
	}, 
	"SHIELD": { # SHIELD
		"pickable_value": 1,
		"pickable_time": 0, # sekunde
		"scene_path": preload("res://game/arena_elements/pickables/PickableShield.tscn"),
	},
	"ENERGY": { # ENERGY
		"pickable_value": 0,
		"pickable_time": 0, # sekunde
		"scene_path": preload("res://game/arena_elements/pickables/PickableEnergy.tscn"),
	},
	"GAS": { # GAS
		"pickable_value": 200,
		"pickable_time": 0, # sekunde
		"scene_path": preload("res://game/arena_elements/pickables/PickableGas.tscn"),
	},
	"LIFE": { # LIFE
		"pickable_value": 1,
		"pickable_time": 0, # sekunde
		"scene_path": preload("res://game/arena_elements/pickables/PickableLife.tscn"),
	},
	"NITRO": { # NITRO
		"pickable_value": 700,
		"pickable_time": 1, # sekunde
		"scene_path": preload("res://game/arena_elements/pickables/PickableNitro.tscn"),
	},
	"TRACKING": { # TRACKING
		"pickable_value": 0.7,
		"pickable_time": 10, # sekunde
		"scene_path": preload("res://game/arena_elements/pickables/PickableTracking.tscn"),
	},
	"RANDOM": { # RANDOM
		"pickable_value": 0, # nepomebno, ker random range je število ključev v tem slovarju
		"pickable_time": 0, # sekunde
		"scene_path": preload("res://game/arena_elements/pickables/PickableRandom.tscn"),
	},
}

enum BoltTypes {SMALL, BASIC, BIG}
var current_bolt_type

var bolt_profiles: Dictionary = {
	BoltTypes.BASIC: {
		"bolt_texture": preload("res://assets/bolt/bolt_basic.png"),
		"reload_ability": 1,# 1 - 10 ... to je deljitelj reload timeta od orožja
		"on_hit_disabled_time": 2,
		"shield_loops_limit": 3,
		# orig
		"fwd_engine_power": 300, # 1 - 500 konjev 
		"rev_engine_power": 150, # 1 - 500 konjev 
		"turn_angle": 15, # deg per frame
		"free_rotation_multiplier": 15, # rotacija kadar miruje
		"side_traction": 0.05, # 0 - 1
		"bounce_size": 0.5, # 0 - 1 
		"inertia": 5, # kg
		"drag": 1.5, # 1 - 10 # raste kvadratno s hitrostjo
		"drag_force_quo": 100.0, # večji pomeni nižjo drag force
		"drag_force_quo_gravel": 25.0, 
		"drag_force_quo_hole": 5.0,
		"drag_force_quo_nitro": 500.0,
		"fwd_gas_usage": -0.1, # per fram
		"rev_gas_usage": -0.05, # per fram
		# v1
#		"fwd_engine_power": 300, # 1 - 500 konjev 
#		"rev_engine_power": 150, # 1 - 500 konjev 
#		"turn_angle": 15, # deg per frame
#		"free_rotation_multiplier": 15, # rotacija kadar miruje
#		"drag": 1.0, # 1 - 10 # raste kvadratno s hitrostjo
#		"side_traction": 0.05, # 0 - 1
#		"bounce_size": 0.3, # 0 - 1 
#		"inertia": 5, # kg
		},
}

enum Bolts {P1, P2, P3, P4, ENEMY}

var default_player_profiles: Dictionary = { # ime profila ime igralca ... pazi da je CAPS, ker v kodi tega ne pedenam	
	Bolts.P1 : { # ključi bodo kasneje samo indexi
#	"P1" : { # ključi bodo kasneje samo indexi
		"player_name" : "Moe",
		"player_avatar" : preload("res://assets/sprites/avatars/avatar_01.png"),
		"player_color" : Set.color_blue, # color_yellow, color_green, color_red ... pomembno da se nalagajo za Settingsi
		"controller_profile" : "ARROWS",
		"bolt_type:": BoltTypes.BASIC,
	},
	Bolts.P2 : {
		"player_name" : "Zed",
		"player_avatar" : preload("res://assets/sprites/avatars/avatar_02.png"),
		"player_color" : Set.color_red,
		"controller_profile" : "WASD",
		"bolt_type:": BoltTypes.BASIC,
	},
	Bolts.P3 : {
		"player_name" : "Dot",
		"player_avatar" : preload("res://assets/sprites/avatars/avatar_03.png"),
		"player_color" : Set.color_yellow, # color_yellow, color_green, color_red
#		"controller_profile" : "ARROWS",
		"controller_profile" : "JP1",
		"bolt_type:": BoltTypes.BASIC,
	},
	Bolts.P4 : {
		"player_name" : "Jax",
		"player_avatar" : preload("res://assets/sprites/avatars/avatar_04.png"),
		"player_color" : Set.color_green,
		"controller_profile" : "JP2",
#		"controller_profile" : "WASD",
		"bolt_type:": BoltTypes.BASIC,
	},
	Bolts.ENEMY : {
		"player_name" : "Rat",
		# "player_controller" : "Up/Le/Do/Ri/Al",
		"player_avatar" : preload("res://assets/sprites/avatars/avatar_05.png"),
		"player_color" : Set.color_gray0,
		"controller_profile" : "AI",
		"bolt_type:": BoltTypes.BASIC,
	},
#	"E2" : {
#		"player_name" : "Bub",
#		# "player_controller" : "W/A/S/D/Sp",
#		"player_avatar" : preload("res://assets/sprites/avatars/avatar_06.png"),
#		"player_color" : Set.color_gray0,
#		"controller_profile" : "AI",
#		"bolt_type:": BoltTypes.BASIC,
#	},
}


var enemy_profile: Dictionary = {
	
	"aim_time": 1,
	"seek_rotation_range": 60,
	"seek_rotation_speed": 3,
	"seek_distance": 640 * 0.7,
	"engine_power_idle": 35,
	"engine_power_battle": 120, # je enaka kot od  bolta 
#	"bullet_push_factor": 0.1,
#	"misile_push_factor": 0.5,
	"shooting_ability": 0.5, # adaptacija hitrosti streljanja, adaptacija natančnosti ... 1 pomeni, da adaptacij ni - 2 je že zajebano u nulo 
}

var default_bolt_stats : Dictionary = { # tole ne uporabljam v zadnji varianti
#	"player_start_position" : Vector2(0, 0),
#	"life" : 5,
	"energy" : 10,
	"bullet_power" : 0.1,
	"bullet_count" : 1,
	"misile_count" : 1,
	"shocker_count" : 1,
	"gas_count" : 300, # 300 je kul
}

var default_player_stats : Dictionary = { # tole ne uporabljam v zadnji varianti
# statse ima tudi enemy
#	"player_active" : true,
	"player_life" : 5,
	"player_points" : 0,
	"player_wins" : 2,
}

var weapon_profiles : Dictionary = {
	"bullet": {
		"reload_time": 0.2,
		"hit_damage": 1,
		"speed": 1000,
		"lifetime": 1.0, #domet vedno merim s časom
		"inertia": 50,
		"direction_start_range": [0, 0] , # natančnost misile
	},
	"misile": {
		"reload_time": 3, # ga ne rabi, ker mora misila bit uničena
		"hit_damage": 5,
		"speed": 150,
		"lifetime": 1.0, #domet vedno merim s časom
		"inertia": 100,
		"direction_start_range": [-0.1, 0.1] , # natančnost misile
	},
	"shocker": {
		"reload_time": 1.0, #
		"hit_damage": 2,
		"speed": 50,
		"lifetime": 10, #domet vedno merim s časom
		"inertia": 1,
		"direction_start_range": [0, 0] , # natančnost misile
	},
}

# v plejerja pošljem imena akcij iz input mapa
var default_controller_actions : Dictionary = {
	"ARROWS" : {
		fwd_action = "p1_fwd", 
		rev_action = "p1_rev",
		left_action = "p1_left",
		right_action = "p1_right",
		shoot_bullet_action = "p1_bullet",
		shoot_misile_action = "p1_misile",
		shoot_shocker_action = "p1_shocker",
		select_feat_action = "p1_select_feat",
		},
	"WASD" : {
		fwd_action = "p2_fwd", 
		rev_action = "p2_rev",
		left_action = "p2_left",
		right_action = "p2_right",
		shoot_bullet_action = "p2_bullet",
		shoot_misile_action = "p2_misile",
		shoot_shocker_action = "p2_shocker",
		select_feat_action = "p2_select_feat",
	},
	"JP1" : {
		fwd_action = "jp1_fwd",
		rev_action = "jp1_rev",
		left_action = "jp1_left",
		right_action = "jp1_right",
		shoot_bullet_action = "jp1_bullet",
		shoot_misile_action = "jp1_misile",
		shoot_shocker_action = "jp1_shocker",
		select_feat_action = "jp1_select_feat",
	},
	"JP2" : {
		fwd_action = "jp2_fwd",
		rev_action = "jp2_rev",
		left_action = "jp2_left",
		right_action = "jp2_right",
		shoot_bullet_action = "jp2_bullet",
		shoot_misile_action = "jp2_misile",
		shoot_shocker_action = "jp2_shocker",
		select_feat_action = "jp2_select_feat",
	},
}

# za generator
var arena_tilemap_profiles: Dictionary = {
	"default_arena" : Vector2.ONE,
}
