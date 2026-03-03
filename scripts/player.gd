class_name PlayerBody
extends CharacterBody3D

@export var speed: float = 4.0
@export var jump_velocity: float = 10.5
@onready var player_controller: PlayerController = $PlayerController
@onready var sprite: AnimatedSprite3D = $Sprite
@onready var hit_range: HitRange = %HitRange

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
	print("[PlayerBody] Weak Attack Received")
	_set_animation_state(AnimationState.WEAK)
	hit_range.hit()

func _on_strong_attack() -> void:
	print("[PlayerBody] Strong Attack Received")
	_set_animation_state(AnimationState.STRONG)
	hit_range.hit()

func _physics_process(delta: float) -> void:
	# Horizontal movement
	velocity.x = move_input.x * speed
	velocity.z = move_input.y * speed

	# Gravity
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	# Jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	# Move character
	
	move_and_slide()
	_update_facing()
	update_animation()


func _set_animation_state(new_state: AnimationState) -> void:
	if _current_animation_state == new_state:
		return
	
	_current_animation_state = new_state
	
	match new_state:
		AnimationState.IDLE:
			sprite.play("idle")
		AnimationState.WALK:
			sprite.play("walk")
		AnimationState.JUMP:
			sprite.play("jump")
		AnimationState.WEAK:
			sprite.play("weak")
		AnimationState.STRONG:
			sprite.play("strong")
		AnimationState.HIT:
			sprite.play("hit")
		AnimationState.DEAD:
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
		hit_range.position.x = offset
	elif velocity.x < 0:
		sprite.flip_h = true
		hit_range.position.x = -offset

func _on_animation_finished() -> void:
	if _current_animation_state in [
		AnimationState.WEAK,
		AnimationState.STRONG,
		AnimationState.HIT
	]:
		_set_animation_state(AnimationState.IDLE)
