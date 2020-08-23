extends CanvasLayer
signal retry
signal quit

func _retry():
	emit_signal("retry")

func _quit():
	emit_signal("quit")
