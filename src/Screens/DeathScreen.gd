extends CanvasLayer
signal retry
signal quit

func _ready():
	$Panel/RetryButton.grab_focus()
	
func _retry():
	emit_signal("retry")

func _quit():
	emit_signal("quit")
