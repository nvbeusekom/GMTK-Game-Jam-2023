extends RigidBody2D
@export var speed = 80 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

var health = 3
var power = 1
var swingReady = true
var swingUp = false
var swingDown = false
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
	if Input.is_action_just_pressed("Attack") and swingReady == true:
		swingReady = false
		swingUp = true
		
	swordSwing(delta)
	
	$BodySpriteAnimation.play()
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	print(velocity.length())
	if velocity.length() > 0:
		$BodySpriteAnimation.animation = "walk"
	else:
		$BodySpriteAnimation.animation = "idle"
	if velocity.x != 0:
	# See the note below about boolean assignment.
		$BodySpriteAnimation.flip_h = velocity.x < 0
		$SwordSprite.flip_h = velocity.x < 0
	
	

func swordSwing(delta):
	
	if swingUp:
		$SwordSprite.rotation -= delta * 10
		if $SwordSprite.rotation < -.5 * PI:
			swingUp = false
			swingDown = true
	if swingDown:
		$SwordSprite.rotation += delta * 30
		if $SwordSprite.rotation > 0:
			swingDown = false
			swingReady = true
	

func _on_body_entered(body):
	health -= 1
	$CollisionShape2D.set_deferred("disabled", true)
	# Some knockback
	$CollisionShape2D.set_deferred("disabled", false)
