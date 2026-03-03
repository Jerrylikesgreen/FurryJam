class_name MobBody extends CharacterBody3D

@export var speed: float = 2.0
@export var move_direction: float = -1.0 # -1 = left, 1 = right
@export var knockback_force := 2.0
@export var knockback_duration := 0.01
@export var roam_radius: float = 10.0  # Max distance from current position to roam


@onready var mob_sprite: MobSprite = %MobSprite


var random_target: Vector3 = Vector3.ZERO
var target_player: PlayerBody = null
var _hit: bool = false
var _facing := 1
var knockback_timer := 0.0

var moving_to_random: bool = false

func _ready() -> void:
	randomize()
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
	
	if moving_to_random:
		var direction = random_target - global_position
		direction.y = 0
		var distance = direction.length()
	
		if distance < 0.5:
			# Reached target
			moving_to_random = false
			velocity.x = 0
			velocity.z = 0
		else:
			direction = direction.normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
	
	move_and_slide()
	_update_facing()
	_update_animation()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider is PlayerBody:
			collider.hit(global_position)
			print("Hit PLayer")
			


func world_bound_detected() -> void:
	# Stop random roaming
	moving_to_random = false
	
	# Clear player target
	target_player = null
	
	# Stop all horizontal movement immediately
	velocity.x = 0
	velocity.z = 0
	
	print("World bound detected -> Movement stopped")

func move_to_random_location() -> void:
	var rand_x = randf_range(-roam_radius, roam_radius)
	var rand_z = randf_range(-roam_radius, roam_radius)
	random_target = global_position + Vector3(rand_x, 0, rand_z)
	moving_to_random = true



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
