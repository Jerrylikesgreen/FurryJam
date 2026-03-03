class_name MobDetectionRange extends Area3D

signal player_detected(player: PlayerBody)

func detect_area()->void:
	var bodies_detected =  get_overlapping_bodies()
	for body in bodies_detected:
		if body is PlayerBody:
			player_detected.emit(body)
			print("Player detected")
	pass
