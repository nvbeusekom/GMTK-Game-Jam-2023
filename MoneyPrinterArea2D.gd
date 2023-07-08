extends Area2D
signal hit(position,power)

var invulnerability_time = 6
var invulnerability_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if invulnerability_counter > 0:
		invulnerability_counter -= 1

func damaged(position, power):
	if invulnerability_counter == 0:
		hit.emit(position,power)
		invulnerability_counter = invulnerability_time
		
