class_name MobBody extends CharacterBody3D

@export var speed: float = 2.0
@export var move_direction: float = -1.0 # -1 = left, 1 = right
@export var knockback_force := 2.0
@export var knockback_duration := 0.01

@onready var mob_sprite: MobSprite = %MobSprite

var target_player: PlayerBody = null
var _hit: bool = false
var _facing := 1
var knockback_timer := 0.0



func _ready() -> void:
	mob_sprite.hit_animation_ended.connect(_on_hit_animation_finished)

func _physics_process(delta: float) -> void:

	if knockback_timer > 0:
		knockback_timer -= delta

	elif not _hit and target_player:

		var direction: Vector3 = target_player.global_position - global_position
		direction.y = 0
		direction = direction.normalized()

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	elif not _hit:
		velocity.x = 0
		velocity.z = 0

	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	print("Velocity before move:", velocity)

	move_and_slide()
	_update_facing()
	_update_animation()
	
func _update_facing() -> void:
	if _hit or knockback_timer > 0:
		return  # Do not change facing while being hit

	if velocity.x > 0:
		mob_sprite.flip_h = false
		_facing = 1
	elif velocity.x < 0:
		mob_sprite.flip_h = true
		_facing = -1

func get_hit() -> void:
	_hit = true
	mob_sprite.is_hit()
	var upward_boost := 6.0   

	velocity.x = -_facing * knockback_force
	velocity.y = upward_boost

	knockback_timer = knockback_duration
	knockback_timer = knockback_duration

	print("Knockback velocity set to:", velocity)

func _on_hit_animation_finished()->void:
	_hit = false

func _update_animation() -> void:
	if _hit:
		return
	if not is_on_floor():
		mob_sprite.play("idle")
		return
	
	if abs(velocity.x) > 0.1:
		if mob_sprite.animation != "walk":
			mob_sprite.play("walk")
	else:
		if mob_sprite.animation != "idle":
			mob_sprite.play("idle")
