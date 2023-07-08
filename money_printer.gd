extends Node2D

var health = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.animation = "print"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	get_node("/root/dungeoncrawl").addCoin()


func _on_money_printer_area_2d_hit(position, power):
	health -= power
	if(health <= 0):
		queue_free()
