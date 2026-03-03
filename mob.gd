## Main Observer - Will listen to all children signals and pass informaiton along. 
class_name Mob extends Node3D


@onready var mob_body: MobBody = %MobBody
@onready var mob_sprite: AnimatedSprite3D = %MobSprite
@onready var mob_state_machine: MobStateMachine = %MobStateMachine
@onready var mob_detection_range: MobDetectionRange = %MobDetectionRange




func _ready() -> void:
	mob_state_machine.state_changed.connect(_on_state_changed)
	mob_state_machine.state_ended.connect(_on_state_ended)
	mob_detection_range.player_detected.connect(_on_player_detected)


func _on_player_detected(player: PlayerBody) -> void:
	mob_body.target_player = player
	
	mob_state_machine.idle_result(true)
	

func _on_state_changed(state: MobStateMachine.MobState)->void:
	match state:
		MobStateMachine.MobState.IDLE:
			print("ready")
			
		MobStateMachine.MobState.CHASE:
			pass
		MobStateMachine.MobState.EXPLORE:
			pass
		MobStateMachine.MobState.BATTLE:
			pass


func _on_state_ended(state: MobStateMachine.MobState)->void:
	match state:
		MobStateMachine.MobState.IDLE:
			print("Signal received")
			mob_detection_range.detect_area()
			
		MobStateMachine.MobState.CHASE:
			pass
		MobStateMachine.MobState.EXPLORE:
			pass
		MobStateMachine.MobState.BATTLE:
			pass
