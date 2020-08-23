extends CanvasLayer
signal start
signal quit

const two = preload("res://Assets/Instructions/02.png")

var page : int = 1

func _start():
	emit_signal("start")

func _quit():
	emit_signal("quit")


func _next_page():
	page += 1
	if page == 2:
		$Panel/Instruction.texture = two
	else:
		$Panel/Instruction.visible = false
		$Panel/Final.visible = true
		$Panel/NextInstruction.disabled = true
