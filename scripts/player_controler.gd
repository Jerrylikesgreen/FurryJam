class_name PlayerController
extends Node

signal move(dir: Vector2)
signal weak_attack
signal strong_attack

func _physics_process(delta: float) -> void:
	_process_movement_input()
	_process_attack_input()

func _process_movement_input() -> void:
	var input_dir = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

	if input_dir.length() > 0:
		input_dir = input_dir.normalized()

	move.emit(input_dir)


func _process_attack_input() -> void:
	if Input.is_action_just_pressed("weak_attack"):
		weak_attack.emit()

	if Input.is_action_just_pressed("strong_attack"):
		strong_attack.emit()
