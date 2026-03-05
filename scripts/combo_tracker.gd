class_name ComboTracker
extends Node

enum AttackType { WEAK, STRONG }

# --- CONFIG ---
@export var combo_window_time: float = 0.5
@export var max_combo_length: int = 3

# --- STATE ---
var input_buffer: Array[AttackType] = []
var combo_timer: float = 0.0

# --- SIGNALS ---
signal combo_updated(pattern: String)
signal combo_finished(pattern: String)
signal combo_successful(combo_name: String)
signal combo_broken(pattern: String)  # NEW signal

# --- COMBOS ---
var combos = {
	"WWW": "combo_weak_3",
	"WWS": "combo_launcher",
	"WSW": "combo_mix_1",
	"SWW": "combo_heavy_chain", 
	"SSS": "combo_strong_3"
}

# ---------------------------------------------------
# PUBLIC INPUT METHODS
# Called from PlayerBody
# ---------------------------------------------------
func register_weak() -> void:
	_register_input(AttackType.WEAK)

func register_strong() -> void:
	_register_input(AttackType.STRONG)

# ---------------------------------------------------
# CORE INPUT LOGIC
# ---------------------------------------------------
func _register_input(type: AttackType) -> void:
	var pattern = _get_pattern_from_buffer(type)

	# Check if input is still valid for any combo
	var valid = false
	for combo_key in combos.keys():
		if combo_key.begins_with(pattern):
			valid = true
			break
	
	if not valid:
		# Invalid input → combo broken
		if input_buffer.size() > 0:
			var broken_pattern = _get_pattern()
			print("Combo broken by input:", type, "current pattern:", broken_pattern)
			combo_broken.emit(broken_pattern)  # Emit combo_broken
			_finish_combo()
		input_buffer.clear()
		pattern = ""
	
	# Add input to buffer if combo not broken
	input_buffer.append(type)
	combo_timer = combo_window_time
	
	# Limit buffer size
	if input_buffer.size() > max_combo_length:
		input_buffer.pop_front()
	
	pattern = _get_pattern()
	print("Combo updated:", pattern)
	combo_updated.emit(pattern)

	# Check for full combo match → emit successful signal
	if combos.has(pattern):
		var combo_name = combos[pattern]
		print("Combo completed successfully:", pattern, "->", combo_name)
		combo_successful.emit(combo_name)
		_finish_combo()

# ---------------------------------------------------
# TIMER HANDLING
# ---------------------------------------------------
func _physics_process(delta: float) -> void:
	if input_buffer.size() == 0:
		return
	
	combo_timer -= delta
	if combo_timer <= 0:
		_finish_combo()

# ---------------------------------------------------
# INTERNAL HELPERS
# ---------------------------------------------------
func _get_pattern_from_buffer(next_type: AttackType) -> String:
	var temp_buffer = input_buffer.duplicate()
	temp_buffer.append(next_type)
	var pattern := ""
	for input in temp_buffer:
		match input:
			AttackType.WEAK:
				pattern += "W"
			AttackType.STRONG:
				pattern += "S"
	return pattern

func _get_pattern() -> String:
	var pattern := ""
	for input in input_buffer:
		match input:
			AttackType.WEAK:
				pattern += "W"
			AttackType.STRONG:
				pattern += "S"
	return pattern

func _finish_combo() -> void:
	var pattern := _get_pattern()
	if pattern != "":
		print("Combo finished:", pattern)
		combo_finished.emit(pattern)
	input_buffer.clear()
	combo_timer = 0
