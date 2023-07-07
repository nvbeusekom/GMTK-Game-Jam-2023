extends RigidBody2D
@export var speed = 80 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

var health = 3
var power = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	$AnimatedSprite2D.play()
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	print(velocity.length())
	if velocity.length() > 0:
		$AnimatedSprite2D.animation = "walk"
	else:
		$AnimatedSprite2D.animation = "idle"
	if velocity.x != 0:
	# See the note below about boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0


func _on_body_entered(body):
	health -= 1
	$CollisionShape2D.set_deferred("disabled", true)
	# Some knockback
	$CollisionShape2D.set_deferred("disabled", false)
