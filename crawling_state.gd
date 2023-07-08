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
	$crawl_HUD.set_health($Player.health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Move camera
	mousepos = get_viewport().get_mouse_position() / 10
	playerpos = $Player.position
	$PlayerCamera.position = playerpos



func _on_player_hit():
	$crawl_HUD.set_health($Player.health)
