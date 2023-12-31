extends CharacterBody2D

signal hit
signal died
signal heal
signal victory

@export var SPEED = 80 # How fast the player will move (pixels/sec).
@export var KB_DIST = 3
@export var KB_DURATION = 16
@export var KB_REDUCTION = 0.99

var screen_size # Size of the game window.

var knockback_velocity = Vector2(0,0)
var knockback_counter = 0

var MAX_HEALTH = 0
var health = MAX_HEALTH
var power = 0
var swingReady = true
var swingUp = false
var swingDown = false
var lockDirection = false
var lookingLeft = false

var paused = false

func pause():
	paused = true
func unpause():
	paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$SwordSwing/SwordCollision.set_deferred("disabled",true)

func _process(delta):
	if paused:
		return
	if health <= 0:
		$BodySpriteAnimation.play()
		$BodySpriteAnimation.animation = "death"
		if $BodySpriteAnimation.frame == 21:
			hide()
		return
		
	
	
	if(swingReady == true):
		$SwordSwing/SwordCollision.set_deferred("disabled",true)
	
	
	velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		if not lockDirection:
			lookingLeft = false
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		if not lockDirection:
			lookingLeft = true
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_just_pressed("Attack") and swingReady == true:
		lockDirection = true
		swingReady = false
		swingUp = true
		
	swordSwingAnimation(delta)
	
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
		knockback_velocity *= KB_REDUCTION
			
	move_and_slide()
	
	
	
func swordSwingAnimation(delta):
	var swingSpeed = 1
	if $BodySpriteAnimation.flip_h:
		if swingUp:
			if !$swordSlash.playing:
				$swordSlash.play()
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
			swordSwingCollision(delta)
	else:
		if swingUp:
			if !$swordSlash.playing:
				$swordSlash.play()
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
			swordSwingCollision(delta)
	

func swordSwingCollision(delta):
	if(lookingLeft):
		$SwordSwing/SwordCollision.scale.x=-1
	else:
		$SwordSwing/SwordCollision.scale.x=1
	$SwordSwing/SwordCollision.set_deferred("disabled",false)

func damaged(origin, damage, KBbool):
	if knockback_counter > 0:
		return
	health -= damage
	if health <= 0:
		# But first do a nice animation
		died.emit()
		# Probably freeze the game here
	if KBbool:
		var knockback = (position - origin) 
		knockback_velocity = knockback.normalized() * KB_DIST * SPEED
		knockback_counter = KB_DURATION
	hit.emit()
	var tween: Tween = create_tween()
	tween.tween_property($BodySpriteAnimation, "modulate:v", 1, 0.25).from(15)

func healed(healAmount):
	if health < MAX_HEALTH:
		health += healAmount
	if health > MAX_HEALTH:
		health = MAX_HEALTH
	hit.emit()
	$heal.play()

func gainCoin(coinAmount):
	get_parent().get_parent().crawling_coins += 5
	get_parent().get_parent().updateCoins()
	$coin.play()

func _on_sword_swing_area_entered(area):
	if area.is_in_group("Enemy"):
		area.damaged(position, power)
		$SwordSwing/SwordCollision.set_deferred("disabled",true)


func _on_sword_swing_body_entered(body):
	if body.is_in_group("HeroCrawling"):
		body.damaged(position, power,true)
		$SwordSwing/SwordCollision.set_deferred("disabled",true)


func _on_sword_swing_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	pass # Replace with function body.
