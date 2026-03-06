class_name DialogeDisplay
extends CanvasLayer

@onready var speaker_name_lable: Label = %SpeakerNameLable
@onready var dialoge_text: RichTextLabel = %DialogeText

@export var type_speed: float = 0.02

func _ready() -> void:
	Events.dialoge_text_signal.connect(_on_dialog_text_signal)


func _on_dialog_text_signal(speaker_name: String, dialoge: String) -> void:
	visible = true
	
	speaker_name_lable.text = speaker_name
	dialoge_text.text = dialoge
	dialoge_text.visible_ratio = 0.0
	
	await _type_writer()
	
	await get_tree().create_timer(2.0).timeout
	
	visible = false


func _type_writer() -> void:
	while dialoge_text.visible_ratio < 1.0:
		dialoge_text.visible_ratio += type_speed
		await get_tree().process_frame
