extends Node2D

var bodiesList = []

var power = 1

var paused = false

var spike_playing = false

func pause():
	paused = true
	$Timer.stop()
	spike_playing = $AudioStreamPlayer2D.playing
	$AudioStreamPlayer2D.stop()
func unpause():
	paused = false
	$Timer.start()
	if spike_playing:
		$AudioStreamPlayer2D.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	var player := body as CharacterBody2D
	if not player:
		return
	if not bodiesList.has(body):
		bodiesList.append(body)

func _on_area_2d_body_exited(body):
	var player := body as CharacterBody2D
	if not player:
		return
	if bodiesList.has(body):
		bodiesList.erase(body)

func _on_timer_timeout():
	$AnimatedSprite2D.play()
	$AudioStreamPlayer2D.play()
	for body in bodiesList:
		body.damaged(position,power,false)
