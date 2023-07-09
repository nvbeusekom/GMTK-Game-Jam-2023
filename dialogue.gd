extends Node2D

#ID 0: start of game
#ID 1: Hero loses
#ID 2: Hero wins, first shop visit
#ID 3: Dark knight loses
#ID 4: Dark knight wins

var messages = [
	[
	["Dark knight!",0], 
	["Your dark days are numbered!",0], 
	["I'm coming to get you!",0], 
	["It's the hero!",1],
	["I better get my dungeon defenses in order.",1],
	["I shouldn't forget my money printers. Otherwise, I could run out of money!",1],
	["Hey! Printing money is illegal!",0]
]
]

signal dialogueFinished

var activeMessagesID = 0

var typing_speed = .05

var current_message = 0
var display = ""
var current_char = 0

var readyForNext = false

func _ready():
	start_dialogue(0)
	$CanvasLayer/SpaceBarIcon.hide()
	
func _process(delta):
	if  Input.is_action_just_pressed("switchMode"):
		if readyForNext:
			$spacebartimer.stop()
			$next_char.stop()
			$CanvasLayer/Label.text = ""
			current_message += 1
			readyForNext = false
			if current_message < len(messages[activeMessagesID]):
				start_dialogue(current_message)
			else:
				dialogueFinished.emit()
		else:
			$next_char.stop()
			$spacebartimer.start()
			if current_message < len(messages[activeMessagesID]):
				display = messages[activeMessagesID][current_message][0]
			$CanvasLayer/Label.text = display
			readyForNext = true
	
func start_dialogue(cm):
	$CanvasLayer/SpaceBarIcon.hide()
	current_message = cm
	display = ""
	current_char = 0
	if messages[activeMessagesID][cm][1] == 0:
		$CanvasLayer/knightHead.show()
		$CanvasLayer/darkKnightHead.hide()
	else:
		$CanvasLayer/knightHead.hide()
		$CanvasLayer/darkKnightHead.show()
	$next_char.set_wait_time(typing_speed)
	$next_char.start()

func stop_dialogue():
	# get_parent().remove_child(self)
	queue_free()

func _on_next_char_timeout():
	if (current_char < len(messages[activeMessagesID][current_message][0])):
		var next_char = messages[activeMessagesID][current_message][0][current_char]
		display += next_char
		
		$CanvasLayer/Label.text = display
		current_char += 1
	else:
		$next_char.stop()
		readyForNext = true
		$spacebartimer.start()

func _on_spacebartimer_timeout():
	$CanvasLayer/SpaceBarIcon.show()
