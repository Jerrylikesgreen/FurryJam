class_name MobBody extends CharacterBody3D

signal entered_attack_range
signal exited_attack_range


@export var speed: float = 2.0
@export var move_direction: float = -1.0 # -1 = left, 1 = right
@export var knockback_force := 2.0
@export var knockback_duration := 0.01
@export var roam_radius: float = 10.0  # Max distance from current position to roam
@export var battle_radius: float = 5.0  # distance from player to get in engage 
@onready var attack_range: AttackRange = %AttackRange

@onready var mob_sprite: MobSprite = %MobSprite


var random_target: Vector3 = Vector3.ZERO
var target_player: PlayerBody = null
var _hit: bool = false
var _facing := 1
var knockback_timer := 0.0
var moving_to_random: bool = false
var in_attack_range: bool = false
var _attacking: bool = false

func attack() -> void:
	if _attacking:
		return  # Already attacking
	if knockback_timer > 0 or _hit:
		return
	_attacking = true
	print("Attack started") # debug
	
	


func _ready() -> void:
	randomize()
	mob_sprite.hit_animation_ended.connect(_on_hit_animation_finished)
	mob_sprite.attack_animation_ended.connect(_on_attack_animation_ended)

func _on_attack_animation_ended() -> void:
	_attacking = false
	print("Attack finished")

func _physics_process(delta: float) -> void:
	handle_knockback(delta)
	handle_movement(delta)
	apply_gravity(delta)
	move_and_slide()
	_update_facing()
	_update_animation()
	check_collisions()



func handle_knockback(delta: float) -> void:
	if knockback_timer > 0:
		knockback_timer -= delta

func handle_movement(delta: float) -> void:
	if knockback_timer > 0 or _hit:
		return

	if _attacking:
		attack_range.attack()
		print("Attacking")
		return

	if moving_to_random:
		move_to_random_target()
	elif target_player:
		move_toward_or_circle_player()
	else:
		_stop_movement()
		if in_attack_range:
			in_attack_range = false
			exited_attack_range.emit()
			_attacking = false
func _stop_movement() -> void:
	velocity.x = 0
	velocity.z = 0

func move_to_random_target() -> void:
	var to_random = random_target - global_position
	to_random.y = 0
	var distance = to_random.length()
	if distance < 0.5:
		moving_to_random = false
		velocity.x = 0
		velocity.z = 0
	else:
		var dir = to_random.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed

func move_toward_or_circle_player() -> void:
	var to_player = target_player.global_position - global_position
	to_player.y = 0
	var distance = to_player.length()

	# Update attack range flag & emit signals
	var new_in_attack_range = distance <= battle_radius
	if new_in_attack_range != in_attack_range:
		in_attack_range = new_in_attack_range
		if in_attack_range:
			entered_attack_range.emit()
		else:
			exited_attack_range.emit()

	if not in_attack_range:
		var dir = to_player.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
	else:
		var radial_dir = to_player.normalized()
		var tangent_dir = Vector3(-radial_dir.z, 0, radial_dir.x)
		var circle_dir = (tangent_dir + radial_dir * 0.3).normalized()
		velocity.x = circle_dir.x * speed
		velocity.z = circle_dir.z * speed

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	else:
		velocity.y = 0


func check_collisions() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider is PlayerBody:
			collider.hit(global_position)
			print("Hit Player")

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
	_attacking = false
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
	if _attacking:
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
