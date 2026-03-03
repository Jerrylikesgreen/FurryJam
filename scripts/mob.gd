## Main Observer - Will listen to all children signals and pass informaiton along. 
class_name Mob extends Node3D


@onready var mob_body: MobBody = %MobBody
@onready var mob_sprite: MobSprite = %MobSprite
@onready var mob_state_machine: MobStateMachine = %MobStateMachine
@onready var mob_detection_range: MobDetectionRange = %MobDetectionRange




func _ready() -> void:
	mob_state_machine.state_changed.connect(_on_state_changed)
	mob_state_machine.state_ended.connect(_on_state_ended)
	mob_detection_range.player_detected.connect(_on_player_detected)
	mob_detection_range.player_not_detected.connect(_on_player_not_detected)
	mob_detection_range.world_boundary_detected.connect(_on_world_boundary_detected)


func _on_world_boundary_detected()->void:
	mob_body.world_bound_detected()

func _on_player_detected(player: PlayerBody) -> void:
	mob_body.target_player = player
	
	mob_state_machine.idle_result(true)

func _on_player_not_detected()->void:
	mob_state_machine.idle_result(false)


func _on_state_changed(state: MobStateMachine.MobState)->void:
	match state:
		MobStateMachine.MobState.IDLE:
			print("_on_state_changed Idle")
			
		MobStateMachine.MobState.CHASE:
			pass
		MobStateMachine.MobState.EXPLORE:
			mob_body.move_to_random_location()
			
		MobStateMachine.MobState.BATTLE:
			pass


func _on_state_ended(state: MobStateMachine.MobState)->void:
	print(mob_state_machine.mob_state_to_string[state])
	match state:
		MobStateMachine.MobState.IDLE:
			print("Signal received")
			mob_detection_range.detect_area()
			
		MobStateMachine.MobState.CHASE:
			pass
		MobStateMachine.MobState.EXPLORE:
			mob_state_machine.explore_result()
			print("Signal received")

		MobStateMachine.MobState.BATTLE:
			pass
