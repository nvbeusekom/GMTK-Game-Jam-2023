extends Node

var playerpos
var mousepos
# Called when the node enters the scene tree for the first time.
func _ready():
	mousepos = get_viewport().get_mouse_position() / 10
	playerpos = $Player.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Move camera
	mousepos = get_viewport().get_mouse_position() / 10
	playerpos = $Player.position
	$PlayerCamera.position = playerpos
	
	
	
	
