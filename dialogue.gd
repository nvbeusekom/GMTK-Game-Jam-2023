extends Node2D

var messages = [
	[
	["My First Message",0], 
	["Second Message For You",1]
]
]

var activeMessagesID = 0

var typing_speed = .1

var current_message = 0
var display = ""
var current_char = 0

var readyForNext = false

func _ready():
	start_dialogue(0)
	$SpaceBarIcon.hide()
	
func _process(delta):
	if readyForNext and Input.is_action_just_pressed("switchMode"):
		$Label.text = ""
		current_message += 1
		readyForNext = false
		if current_message < len(messages[activeMessagesID]):
			start_dialogue(current_message)
		
func start_dialogue(cm):
	$SpaceBarIcon.hide()
	current_message = cm
	display = ""
	current_char = 0
	if messages[activeMessagesID][cm][1] == 0:
		$knightHead.show()
		$darkKnightHead.hide()
	else:
		$knightHead.hide()
		$darkKnightHead.show()
	$next_char.set_wait_time(typing_speed)
	$next_char.start()

func stop_dialogue():
	# get_parent().remove_child(self)
	queue_free()

func _on_next_char_timeout():
	if (current_char < len(messages[activeMessagesID][current_message][0])):
		var next_char = messages[activeMessagesID][current_message][0][current_char]
		display += next_char
		
		$Label.text = display
		current_char += 1
	else:
		$next_char.stop()
		readyForNext = true
		$spacebartimer.start()

func _on_spacebartimer_timeout():
	$SpaceBarIcon.show()
