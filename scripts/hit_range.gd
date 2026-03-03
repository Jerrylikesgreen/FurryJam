class_name HitRange extends Area3D


func hit()->void:
	print("Hit")
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is MobBody:
			body.get_hit()
			print("calling hit")
