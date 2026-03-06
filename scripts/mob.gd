## Main Observer - Will listen to all children signals and pass informaiton along. 
class_name Mob extends Node3D


@onready var mob_body: MobBody = %MobBody
@onready var mob_sprite: MobSprite = %MobSprite
@onready var mob_state_machine: MobStateMachine = %MobStateMachine
@onready var mob_detection_range: MobDetectionRange = %MobDetectionRange
@onready var attack_range: AttackRange = %AttackRange
@onready var world_boundary_detection: Area3D = %WorldBoundaryDetection




func _ready() -> void:
	mob_state_machine.state_changed.connect(_on_state_changed)
	mob_state_machine.state_ended.connect(_on_state_ended)
	mob_state_machine.attack_logic_start.connect(_on_attack_logic_start)
	mob_detection_range.player_detected.connect(_on_player_detected)
	mob_detection_range.player_not_detected.connect(_on_player_not_detected)
	world_boundary_detection.area_entered.connect(_on_world_boundary_detected)
	mob_body.entered_attack_range.connect(_on_entered_attack_range)
	mob_body.exited_attack_range.connect(_on_exited_attack_range)
	attack_range.player_hit.connect(_on_player_hit)


func _on_attack_logic_start() -> void:
	mob_body.attack() 
	print("on attack")

func _on_player_hit()->void:
	mob_sprite.attack()


func _on_entered_attack_range()->void:
	mob_state_machine.enter_battle(true)

func _on_exited_attack_range()->void:
	mob_state_machine.enter_battle(false)

func _on_world_boundary_detected(node: Node3D)->void:
	mob_body.world_bound_detected()
	print("Word Detected")

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
