extends Node


var game_sfx_set_to_off: bool = false
var menu_music_set_to_off: bool = false
var game_music_set_to_off: bool = false

var currently_playing_track_index: int = 1 # ga ne resetiraš, da ostane v spominu skozi celo igro

onready var game_music: Node2D = $GameMusic
#onready var menu_music: AudioStreamPlayer = $Music/MenuMusic/WarmUpShort
#onready var menu_music_volume_on_node = menu_music.volume_db # za reset po fejdoutu (game over)

	
func _ready() -> void:
	
	Ref.sound_manager = self
	randomize()

	
# SFX --------------------------------------------------------------------------------------------------------
	
onready var fx: Node = $Fx
onready var music: Node = $Music
	
	
func play_sfx(effect_for: String):
	
	if game_sfx_set_to_off:
		return	
		
	match effect_for:
		"bolt_engine": 
			if not $Sfx/BoltEngine.is_playing():
				$Sfx/BoltEngine.play()
		"bullet_shoot": $Sfx/BulletShoot.play()
		"misile_shoot": 
			$Sfx/MisileFlight.set_volume_db(0)
			$Sfx/MisileShoot.set_volume_db(0)
			$Sfx/MisileShoot.play()
		"misile_explode": 
			$Sfx/MisileExplode.play()
			# ustavim, če se pleja ...
			$Sfx/MisileFlight.set_volume_db(-80)
			$Sfx/MisileShoot.set_volume_db(-80)
			$Sfx/MisileFlight.stop()
			$Sfx/MisileShoot.stop()
		"misile_dissarm": 
			$Sfx/MisileDissarm.play()
			$Sfx/MisileFlight.set_volume_db(-80)
			$Sfx/MisileShoot.set_volume_db(-80)
			$Sfx/MisileFlight.stop()
			$Sfx/MisileShoot.stop()
		"mina_shoot": $Sfx/MisileDissarm.play()
		"mina_explode": 
			$Sfx/MisileExplode.play()
			# ustavim, če se pleja ...
			$Sfx/MisileFlight.set_volume_db(-80)
			$Sfx/MisileShoot.set_volume_db(-80)
			$Sfx/MisileFlight.stop()
			$Sfx/MisileShoot.stop()
		"shocker_effect": $Sfx/ShockerEffect.play()
		"pickable": $Sfx/Pickable.play()
		"pickable_weapon": $Sfx/PickableWeapon.play()
		"pickable_nitro": $Sfx/PickableNitro.play()
		
		
			
		"stray_step":
			$GameSfx/StraySlide.play()
		"blinking": # GM na strays spawn, ker se bolje sliši
			Met.get_random_member($GameSfx/Blinking).play() # nekateri so na mute, ker so drugače prepogosti soundi
			Met.get_random_member($GameSfx/BlinkingStatic).play()
		"thunder_strike": # intro in GM na strays spawn
			$GameSfx/Burst.play()

func stop_sfx(effect_for: String):
	
	match effect_for:
		"shocker_effect":
			$Sfx/ShockerEffect.stop()
#			if $Sfx/ShockerEffect.is_playing():
#				 $Sfx/ShockerEffect.stop()
		"bolt_engine": 
			pass
			if $Sfx/BoltEngine.is_playing():
				$Sfx/BoltEngine.stop()
	
			
func play_gui_sfx(effect_for: String):
	
	match effect_for:
		# events
		"start_countdown_a":
			$GuiSfx/Events/StartCoundownA.play()
		"start_countdown_b":
			$GuiSfx/Events/StartCoundownB.play()
		"game_countdown_a":
			$GuiSfx/Events/GameCoundownA.play()
		"game_countdown_b":
			$GuiSfx/Events/GameCoundownB.play()
		"win_jingle":
			$GuiSfx/Events/Win.play()
		"lose_jingle":
			$GuiSfx/Events/Loose.play()
#		"record_cheers":
#			$GuiSfx/Events/RecordFanfare.play()
		"tutorial_stage_done":
			$GuiSfx/Events/TutorialStageDone.play()
		# input
		"typing":
			Met.get_random_member($GuiSfx/Inputs/Typing).play()
		"btn_confirm":
			$GuiSfx/Inputs/BtnConfirm.play()
		"btn_cancel":
			$GuiSfx/Inputs/BtnCancel.play()
		"btn_focus_change":
#			if Global.allow_focus_sfx:
				$GuiSfx/Inputs/BtnFocus.play()
		# menu
		"menu_fade":
			$GuiSfx/MenuFade.play()
		"screen_slide":
			$GuiSfx/ScreenSlide.play()
		

# MUSKA --------------------------------------------------------------------------------------------------------
		

func play_music():
	
	if game_music_set_to_off:
		return

	# set track
	var current_track: AudioStreamPlayer
	
	if Ref.game_manager.level_settings["level"] == Set.Levels.NITRO:
		var nitro_track: AudioStreamPlayer = $"../Sounds/NitroMusic"
		current_track = game_music.get_node("Nitro")
	else:
		current_track = game_music.get_child(currently_playing_track_index - 1)
	
	# Met.sound_play_fade_in(game_music, 0, 2)
	current_track.play()	


func stop_music():
#func stop_music(stop_reason: String):
	
	for music in game_music.get_children():
		if music.is_playing():
			Met.sound_stop_fade_out(music, 2)
			
#	match stop_reason:
#		"game_music":
#			for music in game_music.get_children():
#				if music.is_playing():
#					music.stop()
#		"game_music_on_gameover":
#			for music in game_music.get_children():
#				if music.is_playing():
#					var current_music_volume = music.volume_db
#					var fade_out = get_tree().create_tween().set_ease(Tween.EASE_IN).set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
#					fade_out.tween_property(music, "volume_db", -80, 2)
#					fade_out.tween_callback(music, "stop")
#					# volume reset
#					fade_out.tween_callback(music, "set_volume_db", [current_music_volume]) # reset glasnosti
					

func set_game_music_volume(value_on_slider: float): # kliče se iz settingsov
	
	# slajder je omejen med -30 in 10
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("GameMusic"), value_on_slider)
		
		
func skip_track():
	
	currently_playing_track_index += 1
	
	if currently_playing_track_index > game_music.get_child_count():
		currently_playing_track_index = 1
	
	for music in game_music.get_children():
		if music.is_playing():
			var current_music_volume = music.volume_db
			var fade_out = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)	
			fade_out.tween_property(music, "volume_db", -80, 0.5)
			fade_out.tween_callback(music, "stop")
			fade_out.tween_callback(music, "set_volume_db", [current_music_volume]) # reset glasnosti
			fade_out.tween_callback(self, "play_music", ["game_music"])


func _on_MisileShoot_finished() -> void:
	$Sfx/MisileFlight.play()
	
	
	pass # Replace with function body.
