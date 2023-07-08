extends Node2D

var power = 1
var speed = 90.0
var destination
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var movement_delta = delta * speed


func _on_area_2d_body_entered(body):
	if body.has_method("damaged"):
		body.damaged(position,1,false)
	queue_free()
