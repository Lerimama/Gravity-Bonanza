extends Control


signal sudden_death_active # pošlje se v hud, ki javi game managerju
signal gametime_is_up # pošlje se v hud, ki javi game managerju

var current_second: int # trenutna sekunda znotraj minutnega kroga ... ia izpis na uri
var game_time_seconds: int # čas v tajmerju v sekundah ... GLAVNI TIMER, po katerem se vse umerja ... zadelovanje timerja
var time_since_start: float # ne glede na smer timerja želiš vedet čas trajanja igre  ... za statistiko
var limitless_mode: bool # če je gejm tajm 0 in je count-up mode

onready var game_time_limit: int = Set.default_game_settings["game_time_limit"]
onready var sudden_death_mode: int = Set.default_game_settings["suddent_death_mode"]
onready var sudden_death_limit: int = Set.default_game_settings["sudden_death_limit"]
onready var countdown_mode: bool = Set.default_game_settings["timer_mode_countdown"]
onready var gameover_countdown_duration: int = Set.default_game_settings["gameover_countdown_duration"] # čas, ko je obarvan in se sliši bip bip


func _ready() -> void:
	
	modulate = Set.color_hud_base
	
	# display pred štartom
	if countdown_mode:
		$Mins.text = "%02d" % (game_time_limit / 60)
		$Secs.text = "%02d" % (game_time_limit % 60)
	elif game_time_limit == 0:
		limitless_mode = true
			
	time_since_start = 0


func _process(delta: float) -> void:
	
	# če ne štopam se tukaj ustavim
	if $Timer.is_stopped():
		return
	
	# display ko štopa
	current_second = int(game_time_seconds) % 60
	$Mins.text = "%02d" % (game_time_seconds / 60)
	$Secs.text = "%02d" % current_second
	
	if not $Timer.is_stopped():	
		if countdown_mode:
			if game_time_seconds <= 0: # time is up
				stop_timer()
				current_second = 0
				modulate = Set.color_red
				emit_signal("gametime_is_up") # pošlje se v hud, ki javi game managerju		
			if sudden_death_mode:
				if game_time_seconds > sudden_death_limit:
					modulate = Set.color_hud_base
				elif game_time_seconds == sudden_death_limit:
					emit_signal("sudden_death_active") # pošlje se v hud, ki javi game managerju		
				elif game_time_seconds < sudden_death_limit:
					modulate = Set.color_red
		else:
			if game_time_seconds >= game_time_limit and not limitless_mode: # ker uravnavam s časom, ki je PRETEKEL
				stop_timer()
				emit_signal("gametime_is_up")	
			if sudden_death_mode:
				if game_time_seconds < game_time_limit - sudden_death_limit:
					modulate = Set.color_hud_base
				elif game_time_seconds == game_time_limit - sudden_death_limit:
					emit_signal("sudden_death_active") # pošlje se v hud, ki javi game managerju		
				elif game_time_seconds > game_time_limit - sudden_death_limit:
					modulate = Set.color_red
	
	
func start_timer():
	
	modulate = Set.color_hud_base

	if countdown_mode:
		# če odštevam je začetna številka enaka time limitu v
		game_time_seconds = game_time_limit
		# sekunde v obsegu minute
		current_second = game_time_seconds % 60
		$Mins.text = "%02d" % (game_time_seconds / 60)
		$Secs.text = "%02d" % current_second
	else:
		# če prišteam je začetna številka 0
		game_time_seconds = 0
		$Mins.text = "00"
		$Secs.text = "00"	
	
	$Timer.start()
	

func pause_timer():
	
	$Timer.set_paused(true)
	modulate = Set.color_blue
	

func unpause_timer():
	
	$Timer.set_paused(false)
	modulate = Set.color_hud_base
	
		
func stop_timer():
	
	$Timer.stop()
	modulate = Set.color_red
	
		
func _on_Timer_timeout() -> void:
	
	time_since_start += 1
	
	if countdown_mode:
		game_time_seconds -= 1
		# game over countdown
		if game_time_seconds < 1:
			Ref.sound_manager.play_gui_sfx("game_countdown_b")
			modulate = Set.color_red
		elif game_time_seconds <= gameover_countdown_duration and game_time_seconds > 0:
			Ref.sound_manager.play_gui_sfx("game_countdown_a")
			modulate = Set.color_red
	else:
		game_time_seconds += 1
		# game over countdown
		if not limitless_mode:
			if game_time_seconds > game_time_limit - 1:
				Ref.sound_manager.play_gui_sfx("countdown_b")
				modulate = Set.color_red
			elif game_time_seconds >= game_time_limit - gameover_countdown_duration:
				Ref.sound_manager.play_gui_sfx("countdown_a")
				modulate = Set.color_red

	
	
