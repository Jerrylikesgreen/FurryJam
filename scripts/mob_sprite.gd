class_name MobSprite extends AnimatedSprite3D

signal hit_animation_ended
signal attack_animation_ended
var _hit: bool = false
var _attack: bool = false

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	


func attack()->void:
	play("weak")
	_attack = true


func _on_animation_finished()->void:
	if _hit:
		_hit = false
		hit_animation_ended.emit()
	if _attack:
		_attack = false
		attack_animation_ended.emit()
		print("attack_animation_finished")

func is_hit()->void:
	_hit = true
	play("hit")
	print(get_animation())
	
