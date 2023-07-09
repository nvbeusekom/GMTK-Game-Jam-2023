extends CharacterBody2D

var screen_size # Size of the game window.

signal victory
signal firstencounter

@export var SPEED = 80 # How fast the player will move (pixels/sec).
@export var KB_DIST = 3
@export var KB_DURATION = 16
@export var KB_REDUCTION = 0.99
@export var MAX_HEALTH = 10

var knockback_velocity = Vector2(0,0)
var knockback_counter = 0
var health = MAX_HEALTH
var power = 2
var swingReady = true
var swingUp = false
var swingDown = false
var lockDirection = false
var lookingLeft = false
var movement_speed = 60.0
var movement_delta
var lookingleft = false

var goal = Vector2(0,0)

var paused = false

var playerpos = Vector2(0,0)

func pause():
	paused = true
func unpause():
	paused = false
	$BodySpriteAnimation.play()


func _ready():
	screen_size = get_viewport_rect().size
	$SwordSwing/SwordCollision.set_deferred("disabled",true)
	$BodySpriteAnimation.play()
	position = Vector2(1168,-240)

func _process(delta):
	if paused:
		return
	var length = 1000000
	velocity = Vector2.ZERO # The player's movement vector.
	
	for enemy in get_tree().get_nodes_in_group("Player"):
		if (enemy.position - position).length() < 100:
			firstencounter.emit()
			if length > (enemy.position - position).length():
				length = (enemy.position - position).length()
				$NavigationAgent2D.set_target_position(enemy.position)
		if (enemy.position - position).length() < 40 and swingReady == true:
			lockDirection = true
			swingReady = false
			swingUp = true
			
	swordSwingAnimation(delta)
	if knockback_counter > 0:
		knockback_counter -= 1
		velocity += knockback_velocity
		knockback_velocity *= KB_REDUCTION
			
	move_and_slide()


func _physics_process(delta):
	if paused:
		return
	
	movement_delta = movement_speed * delta
	var next_path_position: Vector2 = $NavigationAgent2D.get_next_path_position()
	var current_agent_position: Vector2 = global_position
	var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * movement_delta
	
	if new_velocity.length() > 0:
		$BodySpriteAnimation.animation = "walk"
	else:
		$BodySpriteAnimation.animation = "idle"
	$BodySpriteAnimation.flip_h = new_velocity.x < 0
	$SwordSprite.flip_h = new_velocity.x < 0
	if new_velocity.x > 0:
		$SwordSprite.position.x = -6
	elif new_velocity.x < 0:
		$SwordSprite.position.x = 6
	
	if $NavigationAgent2D.avoidance_enabled:
		$NavigationAgent2D.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)

func swordSwingAnimation(delta):
	var swingSpeed = 1
	if $BodySpriteAnimation.flip_h:
		if swingUp:
			if !$AudioStreamPlayer2D.playing:
				$AudioStreamPlayer2D.play()
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
			if !$AudioStreamPlayer2D.playing:
				$AudioStreamPlayer2D.play()
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
	if($BodySpriteAnimation.flip_h):
		$SwordSwing/SwordCollision.scale.x=-1
	else:
		$SwordSwing/SwordCollision.scale.x=1
	$SwordSwing/SwordCollision.set_deferred("disabled",false)


func damaged(origin, damage, KBbool):
	if knockback_counter > 0:
		return
	health -= damage
	
	if KBbool:
		var knockback = (position - origin) 
		knockback_velocity = knockback.normalized() * KB_DIST * SPEED
		knockback_counter = KB_DURATION
	
	var tween: Tween = create_tween()
	tween.tween_property($BodySpriteAnimation, "modulate:v", 1, 0.25).from(15)
	$HealthbarFront.scale.x = 30 * health/MAX_HEALTH
	
	if(health <= 0):
		victory.emit()
		return

func healed(healAmount):
	if health < MAX_HEALTH:
		health += healAmount
	if health > MAX_HEALTH:
		health = MAX_HEALTH

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)


func _on_sword_swing_body_entered(body):
	if body.is_in_group("Player"):
		body.damaged(position, power,true)
		$SwordSwing/SwordCollision.set_deferred("disabled",true)
