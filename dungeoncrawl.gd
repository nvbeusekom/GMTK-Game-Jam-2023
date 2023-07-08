extends Node

var playerpos
var mousepos
var coins
#                     var outline = $NavigationRegion2D.get_outline()
# Called when the node enters the scene tree for the first time.
func _ready():
	mousepos = get_viewport().get_mouse_position() / 10
	playerpos = $Player.position
	coins = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Move camera
	mousepos = get_viewport().get_mouse_position() / 10
	playerpos = $Player.position
	$PlayerCamera.position = playerpos

func addCoin():
	coins += 1
	print(coins)
