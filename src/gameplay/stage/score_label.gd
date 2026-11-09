extends Label
class_name ScoreLabel

@export var prefix: String = "Score: "

func _ready() -> void:
	SignalBus.score_changed.connect(_on_score_changed)
	_update_text()

func _on_score_changed(_point: int) -> void:
	_update_text()

func _update_text() -> void:
	text = "%s%d" % [prefix, SignalBus.score]
