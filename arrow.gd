extends Node2D

var power = 1
var speed = 90.0
var destination
var direction

var paused = false

func pause():
	paused = true
func unpause():
	paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(destination)
	direction = (destination - position).normalized()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if paused:
		return
	var movement_delta = delta * speed
	position += direction * movement_delta

func _on_area_2d_body_entered(body):
	if body.is_in_group("Enemy"):
		return
	if body.has_method("damaged"):
		body.damaged(position,1,false)
	queue_free()
