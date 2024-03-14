extends Area2D


func _on_AreaFinish_body_entered(body: Node) -> void:
	# more bit ob prihodu, da ni možnosti, da greš ven na napačni strani in se šteje, da si prečkal
	
	if body is Bolt:
#		body.modulate = Color.green
		if body.bolt_active:
			Ref.game_manager.on_bolt_across_finish_line(body)
	

func _on_AreaFinish_body_exited(body: Node) -> void:
	
	pass
 
