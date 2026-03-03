class_name MobSprite extends AnimatedSprite3D

signal hit_animation_ended

var _hit: bool = false

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	


func _on_animation_finished()->void:
	if _hit:
		_hit = false
		hit_animation_ended.emit()

func is_hit()->void:
	_hit = true
	play("hit")
	print(get_animation())
	
