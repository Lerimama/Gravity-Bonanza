extends Control


onready var FinalRankingLine: PackedScene = preload("res://game/ui/FinalRankingLine.tscn")


func _ready() -> void:
	
	Ref.level_over = self
	visible = false


func open(bolts_on_finish_line: Array, bolts_on_start: Array):
	
	set_scorelist(bolts_on_finish_line, bolts_on_start)
	
	var background_fadein_transparency: float = 0.9
	
	$VBoxContainer/Menu/ContinueBtn.grab_focus()
	
	var fade_in = get_tree().create_tween()
	fade_in.tween_callback(self, "show")
	fade_in.tween_property(self, "modulate:a", 1, 1).from(0.0)
	# fade_in.parallel().tween_callback(Global.sound_manager, "stop_music", ["game_music_on_gameover"])
	# fade_in.parallel().tween_callback(Global.sound_manager, "play_gui_sfx", [selected_gameover_jingle])
	fade_in.parallel().tween_property($Panel, "modulate:a", background_fadein_transparency, 0.5).set_delay(0.5) # a = cca 140
	fade_in.tween_callback(self, "show_gameover_menu").set_delay(2)	
	
	
func set_scorelist(bolts_on_finish_line: Array, bolts_on_start: Array):

	var results: VBoxContainer = $VBoxContainer/Content/Results
	
	# uvrščeni
	for bolt_on_finish_line in bolts_on_finish_line:
		# spawn ranking line
		var new_ranking_line = FinalRankingLine.instance() # spawn ranking line
		# set ranking line
		var bolt_index = bolts_on_finish_line.find(bolt_on_finish_line)
		new_ranking_line.get_node("Rank").text = str(bolt_index + 1) + ". Place"
		new_ranking_line.get_node("Bolt").text = bolt_on_finish_line[0].player_name
		new_ranking_line.get_node("Result").text = Met.get_clock_time(bolt_on_finish_line[1])
		results.add_child(new_ranking_line)
		
		# izbrišem iz arraya, da ga ne upoštevam pri pisanju neuvrščenih
		if bolts_on_start.has(bolt_on_finish_line[0]):
			bolts_on_start.erase(bolt_on_finish_line[0])
			
	# neuvrščeni
	for bolt in bolts_on_start: # array je že brez uvrščenih
		if not bolts_on_finish_line.has(bolt):
			var new_ranking_line = FinalRankingLine.instance() # spawn ranking line
			new_ranking_line.get_node("Rank").text = "NN"
			new_ranking_line.get_node("Bolt").text = str(bolt.player_name)
			new_ranking_line.get_node("Result").text = "did no finish"
			results.add_child(new_ranking_line)
			

func _on_QuitBtn_pressed() -> void:
	Ref.main_node.game_out()


func _on_QuitGameBtn_pressed() -> void:
	get_tree().quit()


func _on_ContinueBtn_pressed() -> void:
	Ref.main_node.to_next_level()