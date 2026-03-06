class_name DialiogeTrigger extends Area3D

@export var speaker_name: String
@export var dialoge: String
@export var one_shot: bool 

var _active: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	

func _on_body_entered( body: Node3D )->void:
	if body is PlayerBody:
		Events.dialoge_text(speaker_name, dialoge)
		if one_shot:
			queue_free()
			
