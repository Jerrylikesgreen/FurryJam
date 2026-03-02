class_name PlayerBody
extends CharacterBody3D

@export var speed: float = 4.0
@export var jump_velocity: float = 10.5
@onready var player_controller: PlayerController = $PlayerController

var move_input: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Connect movement
	player_controller.move.connect(_on_move)
	# Connect attacks
	player_controller.weak_attack.connect(_on_weak_attack)
	player_controller.strong_attack.connect(_on_strong_attack)

func _on_move(dir: Vector2) -> void:
	move_input = dir

func _on_weak_attack() -> void:
	print("[PlayerBody] Weak Attack Received")
	# TODO: Play weak attack animation/effects

func _on_strong_attack() -> void:
	print("[PlayerBody] Strong Attack Received")
	# TODO: Play strong attack animation/effects

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
