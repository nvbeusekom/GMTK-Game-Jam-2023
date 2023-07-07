extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Move camera
	var mousepos = get_viewport().get_mouse_position() / 10
	var playerpos = $Player.position
	$PlayerCamera.position = playerpos
	
	
	
	
