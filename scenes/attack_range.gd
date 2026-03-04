class_name AttackRange extends Area3D

signal player_hit

@export var attack_interval: float = 2.0 # seconds between attacks
var _attacking: bool = false


func attack() -> void:
	if _attacking:
		return # Already attacking

	_attacking = true
	_attack_loop()

# The actual “while” loop over frames
func _attack_loop() -> void:
	while _attacking:
		var bodies_detected = get_overlapping_bodies()
		var player_found = false
	
		for body in bodies_detected:
			if body is PlayerBody:
				player_hit.emit()
				body.hit(global_position)
				
				print("Player hit called")
				player_found = true
	
		# Wait until next frame or attack interval
		await get_tree().create_timer(attack_interval).timeout
