extends CharacterBody2D

@export var SPEED = 80 # How fast the player will move (pixels/sec).
@export var KB_DIST = 3
@export var KB_DURATION = 16
@export var KB_REDUCTION = 0.5
var screen_size # Size of the game window.

var knockback_velocity = Vector2(0,0)
var knockback_counter = 0

var health = 3
var power = 1
var swingReady = true
var swingUp = false
var swingDown = false
var lockDirection = false
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_just_pressed("Attack") and swingReady == true:
		lockDirection = true
		swingReady = false
		swingUp = true
		
	swordSwing(delta)
	
	$BodySpriteAnimation.play()
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
	
	if velocity.length() > 0:
		$BodySpriteAnimation.animation = "walk"
	else:
		$BodySpriteAnimation.animation = "idle"
	if velocity.x != 0 and lockDirection == false:
	# See the note below about boolean assignment.
		$BodySpriteAnimation.flip_h = velocity.x < 0
		$SwordSprite.flip_h = velocity.x < 0
		if velocity.x > 0:
			$SwordSprite.position.x = -6
		elif velocity.x < 0:
			$SwordSprite.position.x = 6
	
	if knockback_counter > 0:
		knockback_counter -= 1
		velocity += knockback_velocity
		knockback_velocity *= 1
			
	move_and_slide()
	
	
	
func swordSwing(delta):
	var swingSpeed = 1
	if $BodySpriteAnimation.flip_h:
		if swingUp:
			$SwordSprite.rotation += delta * 20 * swingSpeed
			if $SwordSprite.rotation > .75 * PI:
				swingUp = false
				swingDown = true
		if swingDown:
			$SwordSprite.play()
			$SwordSprite.animation = "swing"
			$SwordSprite.rotation -= delta * 30 * swingSpeed
			if $SwordSprite.rotation < 0:
				$SwordSprite.rotation = 0
				swingDown = false
				swingReady = true
				lockDirection = false
	else:
		if swingUp:
			$SwordSprite.rotation -= delta * 20 * swingSpeed
			if $SwordSprite.rotation < -.75 * PI:
				swingUp = false
				swingDown = true
		if swingDown:
			$SwordSprite.play()
			$SwordSprite.animation = "swing"
			$SwordSprite.rotation += delta * 30 * swingSpeed
			if $SwordSprite.rotation > 0:
				$SwordSprite.rotation = 0
				swingDown = false
				swingReady = true
				lockDirection = false
	

func damaged(origin):
	health -= 1
	print(health)
	var knockback = (position - origin) 
	knockback_velocity = knockback.normalized() * KB_DIST * SPEED
	knockback_counter = KB_DURATION
	
	
	
