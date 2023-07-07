extends Area2D

@export var speed = 80 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

var colliding = false

var power = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	position = Vector2(100,100)

func _process(delta):
		
	
	$BodySpriteAnimation.play()
	
func _on_body_entered(body: PhysicsBody2D):
	var player := body as CharacterBody2D
	if not player:
		return
	if not colliding:
		player.damaged(position)
	colliding = true
	
func _on_body_exited(body: PhysicsBody2D):
	var player := body as CharacterBody2D
	if not player:
		return
	colliding = false
