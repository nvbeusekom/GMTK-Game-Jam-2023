extends Area2D

var movement_speed = 40.0
var movement_delta
@export var SPEED = 80 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

@export var KB_DIST = 3
@export var KB_DURATION = 32
@export var KB_REDUCTION = 1
@export var MAX_HEALTH = 6

var knockback_velocity = Vector2(0,0)
var knockback_counter = 0

var colliding = false

var wall_collide = false

var health = MAX_HEALTH
var power = 1

var placed_by_player = false

var playerpos = Vector2(0,0)

var attacking = false
var arrow = load("res://arrow.tscn")
var healBerries = load("res://healing_berries.tscn")
var coinScene = load("res://coin.tscn")
var rng = RandomNumberGenerator.new()

var paused = false
var timer_running = false
func pause():
	paused = true
	timer_running = not $Timer.is_stopped()
	$Timer.stop()
func unpause():
	paused = false
	if timer_running:
		$Timer.start()

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$BodySpriteAnimation.animation = "idle"

func _process(delta):
	if paused:
		return
	playerpos = get_tree().get_root().get_child(0).playerpos	

	$NavigationAgent2D.set_target_position(playerpos)
	
	$BodySpriteAnimation.flip_h = playerpos.x < position.x
	
	if($BodySpriteAnimation.flip_h):
		$CollisionPolygon2D.scale.x = -1
	else:
		$CollisionPolygon2D.scale.x = 1
	
	$BodySpriteAnimation.play()
	
func _physics_process(delta):
	if paused:
		return
	var new_velocity = Vector2(0,0)
	if (playerpos - position).length() < 120 && knockback_counter == 0:
		$walk.stop()
		if !attacking:
			attacking = true
			$BodySpriteAnimation.animation = "attack"
			$Timer.start()
			
	elif ((playerpos - position).length() < 200 and !attacking) or knockback_counter > 0:
		if !$walk.playing:
			$walk.play()
		$BodySpriteAnimation.animation = "walk"
		movement_delta = movement_speed * delta
		var next_path_position: Vector2 = $NavigationAgent2D.get_next_path_position()
		var current_agent_position: Vector2 = global_position
		new_velocity = (next_path_position - current_agent_position).normalized() * movement_delta
		if knockback_counter > 0:
			knockback_counter -= 1
			var new_location = knockback_velocity
			movement_delta *= KB_DIST
			knockback_velocity *= KB_REDUCTION
			if not wall_collide:
				_on_velocity_computed(new_location)
		else:
			wall_collide = false
			if $NavigationAgent2D.avoidance_enabled:
				$NavigationAgent2D.set_velocity(new_velocity)
			else:
				_on_velocity_computed(new_velocity)
	elif !attacking:
		$walk.stop()
		$BodySpriteAnimation.animation = "idle"

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)
	
func damaged(origin, damage):
	if knockback_counter > 0:
		return
	health -= damage
	var knockback = (position - origin) 
	knockback_velocity = knockback.normalized() * KB_DIST * SPEED
	knockback_counter = KB_DURATION
	var tween: Tween = create_tween()
	tween.tween_property($BodySpriteAnimation, "modulate:v", 1, 0.25).from(15)
	if(health <= 0):
		rng.randomize()
		if rng.randi_range(0,10) < 4:
			var berry = healBerries.instantiate()
			berry.position = position
			add_sibling(berry)
		var coin = coinScene.instantiate()
		coin.position.x = position.x + randf_range(-2,2)
		coin.position.y = position.y + randf_range(-2,2)
		add_sibling(coin)
		queue_free()
	else:
		$HealthbarFront.scale.x = 30 * health/MAX_HEALTH
	
func _on_body_entered(body):
	var player := body as CharacterBody2D
	if not player:
		var tilemap := body as TileMap
		if not tilemap:
			return
		wall_collide = true
		return
	if not colliding:
		player.damaged(position,power, true)
	colliding = true
	
func _on_body_exited(body: PhysicsBody2D):
	var player := body as CharacterBody2D
	if not player:
		return
	colliding = false

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)

func _on_timer_timeout():
	$AudioStreamPlayer2D.play()
	var arrowObject = arrow.instantiate()
	arrowObject.destination = playerpos
	arrowObject.position = position
	add_sibling(arrowObject)
	attacking = false
