extends Control

func _on_play_button_clicked() -> void:
	SignalBus.play_clicked.emit()
