extends CanvasLayer



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_health(health):
	for n in get_children().size():
		if n > 0:
			get_children()[n].queue_free()
	for n in range(health):
		var heart = $Heart.duplicate()
		heart.position.x -= 32 * n
		heart.show()
		add_child(heart)
	
