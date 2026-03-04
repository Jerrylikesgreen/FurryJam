class_name MobDetectionRange extends Area3D

signal player_detected(player: PlayerBody)
signal player_not_detected





func detect_area() -> void:
	var bodies_detected = get_overlapping_bodies()
	var player_found = false

	for body in bodies_detected:
		if body is PlayerBody:
			player_detected.emit(body)
			print("Player detected")
			player_found = true

	if not player_found:
		player_not_detected.emit()
