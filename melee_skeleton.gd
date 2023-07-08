extends Area2D

var movement_speed = 40.0
var movement_delta
@export var SPEED = 80 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

@export var KB_DIST = 3
@export var KB_DURATION = 32
@export var KB_REDUCTION = 1

var knockback_velocity = Vector2(0,0)
var knockback_counter = 0

var colliding = false

var wall_collide = false

var health = 30
var power = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	position = Vector2(100,100)
	$BodySpriteAnimation.animation = "idle"

func _process(delta):
	
	$NavigationAgent2D.set_target_position(get_node("/root/dungeoncrawl").playerpos)
	
	$BodySpriteAnimation.flip_h = get_node("/root/dungeoncrawl").playerpos.x < position.x
	$BodySpriteAnimation.play()
	
		
func _physics_process(delta):
	if (get_node("/root/dungeoncrawl").playerpos - position).length() < 10:
		$BodySpriteAnimation.animation = "attack"            
	elif (get_node("/root/dungeoncrawl").playerpos - position).length() < 200:
		$BodySpriteAnimation.animation = "walk"
		movement_delta = movement_speed * delta
		var next_path_position: Vector2 = $NavigationAgent2D.get_next_path_position()
		var current_agent_position: Vector2 = global_position
		var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * movement_delta
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
	else:
		$BodySpriteAnimation.animation = "idle"
func _on_velocity_computed(safe_velocity: Vector2) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)
	
func damaged(origin, damage):
	health -= damage
	var knockback = (position - origin) 
	knockback_velocity = knockback.normalized() * KB_DIST * SPEED
	knockback_counter = KB_DURATION
	if(health <= 0):
		queue_free()
	
	
func _on_body_entered(body):
	var player := body as CharacterBody2D
	if not player:
		var tilemap := body as TileMap
		if not tilemap:
			return
		wall_collide = true
		return
	if not colliding:
		player.damaged(position,power,true)
	colliding = true
	
	
func _on_body_exited(body: PhysicsBody2D):
	var player := body as CharacterBody2D
	if not player:
		return
	colliding = false


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)
