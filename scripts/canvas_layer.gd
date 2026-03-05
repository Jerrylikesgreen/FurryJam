class_name ComboDebugUI
extends CanvasLayer

@onready var combo_tracker: ComboTracker = %ComboTracker
@onready var combo_debug_label: Label = %ComboDebugLabel
@onready var player_controller: PlayerController = %PlayerController

var default_color: Color
var flash_scale: float = 1.2
var default_scale: Vector2
var flash_duration: float = 0.2

func _ready() -> void:
	# Save default label state
	default_color = combo_debug_label.modulate
	default_scale = combo_debug_label.scale  # <-- Use scale, not rect_scale

	# Connect signals
	combo_tracker.combo_updated.connect(_on_combo_updated)
	combo_tracker.combo_finished.connect(_on_combo_finished)
	combo_tracker.combo_successful.connect(_on_combo_successful)
	combo_tracker.combo_broken.connect(_on_combo_broken)

	combo_debug_label.text = "Combo: "



# Update the label whenever a new input is registered
func _on_combo_updated(pattern: String) -> void:
	combo_debug_label.text = "Combo: " + pattern

# When combo finishes (timeout)
func _on_combo_finished(pattern: String) -> void:
	combo_debug_label.text = "Finished: " + pattern

# When a combo is successfully completed
func _on_combo_successful(combo_name: String) -> void:
	combo_debug_label.text = "Combo Success: " + combo_name
	_play_flash_effect(Color(0, 1, 0))  # Green flash for success

func _on_combo_broken(pattern: String) -> void:
	combo_debug_label.text = "Combo Broken: " + pattern
	_play_flash_effect(Color(1, 0, 0))  # Red flash for failure

func _play_flash_effect(flash_color: Color) -> void:
	# Immediately apply flash state
	combo_debug_label.modulate = flash_color
	combo_debug_label.scale = default_scale * flash_scale

	# Tween back to default color and scale
	var t = create_tween()
	t.tween_property(combo_debug_label, "modulate", default_color, flash_duration)
	t.tween_property(combo_debug_label, "scale", default_scale, flash_duration)
