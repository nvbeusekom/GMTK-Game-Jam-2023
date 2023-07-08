extends CanvasLayer

var heartArray = []
var swordArray = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_health(health):
	for n in heartArray.size():
		if n > 0:
			heartArray[1].queue_free()
			heartArray.remove_at(1)
	for n in range(health):
		var heart = $Heart.duplicate()
		heart.position.x -= 32 * n
		heart.show()
		add_child(heart)
		heartArray.append(heart)

func set_strength(power):
	for n in swordArray.size():
		if n > 0:
			swordArray[1].queue_free()
			swordArray.remove_at(1)
	for n in range(power):
		var sword = $Sword.duplicate()
		sword.position.x -= 32 * n
		sword.show()
		add_child(sword)
		swordArray.append(sword)
