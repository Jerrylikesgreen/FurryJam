class_name MobStateMachine extends Node

enum MobState { IDLE, CHASE, EXPLORE, BATTLE}
@onready var mob_state_machine_timer: Timer = %MobStateMachineTimer

var mob_state_to_string: Dictionary = {
	MobState.IDLE : "Idle", 
	MobState.CHASE : "Chase", 
	MobState.EXPLORE : "Explore", 
	MobState.BATTLE : "Battle", 
	
}
	


var _current_state: MobState = MobState.IDLE
var _prior_state: MobState

signal state_changed(state: MobState)
signal state_ended(state: MobState)

func _ready() -> void:
	_run_state_machine()
	mob_state_machine_timer.timeout.connect(_on_time_out)

func idle_result(value: bool)->void:
	if value == false:
		_change_state(MobState.EXPLORE)
	else:
		_change_state(MobState.CHASE)

func _run_state_machine()->void:
	match _current_state:
		MobState.IDLE:
			mob_state_machine_timer.start(3.0)
			pass
		MobState.CHASE:
			pass
		MobState.EXPLORE:
			pass
		MobState.BATTLE:
			pass
	
	print("State machine is running -> " , mob_state_to_string[_current_state])

func _change_state(state: MobState)->void:
	_prior_state = _current_state
	_current_state = state
	
	state_changed.emit(_current_state)
	print("State machine changd to -> " , mob_state_to_string[_current_state])


func _on_time_out()->void:
	match _current_state:
		MobState.IDLE:
			state_ended.emit(_current_state)
			pass
		MobState.CHASE:
			pass
		MobState.EXPLORE:
			pass
		MobState.BATTLE:
			pass
	
	print("State machine emited state ended to -> " , mob_state_to_string[_current_state])
