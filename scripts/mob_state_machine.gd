class_name MobStateMachine extends Node



signal state_changed(state: MobState)
signal state_ended(state: MobState)
signal attack_logic_start


@onready var mob_state_machine_timer: Timer = %MobStateMachineTimer



enum MobState { IDLE, CHASE, EXPLORE, BATTLE}

var mob_state_to_string: Dictionary = {
	MobState.IDLE : "Idle", 
	MobState.CHASE : "Chase", 
	MobState.EXPLORE : "Explore", 
	MobState.BATTLE : "Battle", 
	
}
	


var _current_state: MobState = MobState.IDLE
var _prior_state: MobState




func _ready() -> void:
	_run_state_machine()
	mob_state_machine_timer.timeout.connect(_on_time_out)

func idle_result(value: bool)->void:
	if value == false:
		_change_state(MobState.EXPLORE)
	else:
		_change_state(MobState.CHASE)


func enter_battle(value: bool)->void:
	if value:
		_change_state(MobState.BATTLE)
	else:
		_change_state(MobState.CHASE)

func explore_result() ->void:
	_change_state(MobState.IDLE)
	print("explore result received")

func _run_state_machine()->void:
	match _current_state:
		MobState.IDLE:
			mob_state_machine_timer.start(3.0)
			pass
		MobState.CHASE:
			pass
		MobState.EXPLORE:
			print("Explore logic")
			mob_state_machine_timer.start(3.0)
		MobState.BATTLE:
			mob_state_machine_timer.start(3.0)
	
	print("State machine is running -> " , mob_state_to_string[_current_state])

func _change_state(state: MobState)->void:
	_prior_state = _current_state
	_current_state = state
	
	state_changed.emit(_current_state)
	_run_state_machine()
	print("State machine changd to -> " , mob_state_to_string[_current_state])


func _on_time_out()->void:
	
	match _current_state:
		
		MobState.IDLE:
			state_ended.emit(_current_state)
			
		MobState.CHASE:
			state_ended.emit(_current_state)
			
		MobState.EXPLORE:
			_change_state(MobState.IDLE)
			
		MobState.BATTLE:
			pass
			attack_logic_start.emit()

	
	print("State machine emited state ended to ->   " , mob_state_to_string[_current_state])

	
	
