## Events Autoload
extends Node

signal dialoge_text_signal(speaker: String, dialoge: String )

func dialoge_text( speaker: String, dialoge: String )->void:
	dialoge_text_signal.emit(speaker, dialoge)
