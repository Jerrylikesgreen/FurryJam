class_name PlayerBody
extends CharacterBody3D



@export var speed: float = 4.0
@export var jump_velocity: float = 10.5
@onready var player_controller: PlayerController = $PlayerController
@onready var sprite: AnimatedSprite3D = $Sprite
@onready var hit_range: HitRange = %HitRange
@export var upward_boost := 6.0
@export var knockback_force := 20.0
@export var knockback_duration := 0.08
var combo_buffer_timer: float = 0.0
@export var combo_buffer_time: float = 0.2  # 0.5 seconds
@onready var combo_tracker: ComboTracker = %ComboTracker

var _hit: bool = false
var _facing := 1
var knockback_timer := 0.0



enum AnimationState {  IDLE, STRONG, WEAK, WALK, JUMP, HIT, DEAD}
var _current_animation_state: AnimationState = AnimationState.IDLE
var move_input: Vector2 = Vector2.ZERO
var _right_facing: bool = true

func _ready() -> void:
	# Connect movement
	player_controller.move.connect(_on_move)
	# Connect attacks
	player_controller.weak_attack.connect(_on_weak_attack)
	player_controller.strong_attack.connect(_on_strong_attack)
	# Connecting animation finished
	sprite.animation_finished.connect(_on_animation_finished)

func _on_move(dir: Vector2) -> void:
	move_input = dir
	
	# Update facing direction based on horizontal input
	if dir.x > 0:
		_right_facing = true
	elif dir.x < 0:
		_right_facing = false


func _on_weak_attack() -> void:

	if combo_buffer_timer <= 0:
		# Buffer expired → execute attack
		print("[PlayerBody] Weak Attack Registered, is in Combo")
		_set_animation_state(AnimationState.WEAK)
		hit_range.hit()
		combo_tracker.register_weak()

		# Start buffer
		combo_buffer_timer = combo_buffer_time
	else:
		# Within buffer → ignore input
		print("[PlayerBody] Weak Attack Ignored Within Buffer")

func _on_strong_attack() -> void:

	if combo_buffer_timer <= 0:
		print("[PlayerBody] Strong Attack Registered, is in Combo")
		_set_animation_state(AnimationState.STRONG)
		hit_range.hit()
		combo_tracker.register_strong()

		combo_buffer_timer = combo_buffer_time
	else:
		print("[PlayerBody] Strong Attack Ignored Within Buffer")

func hit(from_position: Vector3) -> void:
	if knockback_timer > 0:
		return  # Already in knockback

	_set_animation_state(AnimationState.HIT)

	# Correct horizontal knockback: away from attacker
	var knockback_dir = global_position - from_position
	knockback_dir.y = 0  # ignore vertical
	knockback_dir = knockback_dir * knockback_force

	# Apply horizontal + vertical knockback
	velocity.x = knockback_dir.x
	velocity.z = knockback_dir.z
	velocity.y = upward_boost

	knockback_timer = knockback_duration
	_hit = true


func _physics_process(delta: float) -> void:
	# Update buffer timer
	if combo_buffer_timer > 0:
		combo_buffer_timer -= delta

	# Update input
	move_input = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	if knockback_timer > 0:
		# Knockback in progress, preserve horizontal velocity
		knockback_timer -= delta
	else:
		# Only apply input movement if NOT in knockback
		velocity.x = move_input.x * speed
		velocity.z = move_input.y * speed

		# Jump
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	# Gravity
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	else:
		if velocity.y < 0:
			velocity.y = 0

	move_and_slide()
	_update_facing()
	update_animation()


func _set_animation_state(new_state: AnimationState) -> void:
	_current_animation_state = new_state

	match new_state:
		AnimationState.IDLE:
			sprite.play("idle")
		AnimationState.WALK:
			sprite.play("walk")
		AnimationState.JUMP:
			sprite.play("jump")
		AnimationState.WEAK:
			sprite.stop()  # ensure animation restarts
			sprite.play("weak")
		AnimationState.STRONG:
			sprite.stop()
			sprite.play("strong")
		AnimationState.HIT:
			sprite.stop()
			sprite.play("hit")
		AnimationState.DEAD:
			sprite.stop()
			sprite.play("dead")


func update_animation() -> void:
	# Don't override attack/hit/dead animations while playing
	if _current_animation_state in [
		AnimationState.WEAK,
		AnimationState.STRONG,
		AnimationState.HIT,
		AnimationState.DEAD
	]:
		return

	# Air state
	if not is_on_floor():
		_set_animation_state(AnimationState.JUMP)
		return

	# Movement
	if move_input.length() > 0.1:
		_set_animation_state(AnimationState.WALK)
	else:
		_set_animation_state(AnimationState.IDLE)

func _update_facing() -> void:
	var offset := 0.5 # distance in front of mob
	
	if velocity.x > 0:
		sprite.flip_h = false
		_facing = 1
		hit_range.position.x = offset
	elif velocity.x < 0:
		sprite.flip_h = true
		_facing = -1
		hit_range.position.x = -offset

func _is_attack_anim_playing() -> bool:
	return _current_animation_state in [
		AnimationState.WEAK,
		AnimationState.STRONG
	]

func _on_animation_finished() -> void:
	if _current_animation_state in [
		AnimationState.WEAK,
		AnimationState.STRONG,
		AnimationState.HIT
	]:
		_set_animation_state(AnimationState.IDLE)
