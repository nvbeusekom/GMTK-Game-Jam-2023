extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Removes skeletons placed by player
func clear_skeletons():	
	for child in get_children():
		if child.name.contains("Skeleton"):
			if child.placed_by_player:
				child.queue_free()
