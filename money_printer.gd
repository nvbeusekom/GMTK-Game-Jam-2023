extends Node2D

var health = 3

var paused = false

func pause():
	paused = true
	$Timer.stop()
func unpause():
	$AnimatedSprite2D.play()
	paused = false
	$Timer.start()

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.animation = "print"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	get_parent().get_parent().addCoin()


func _on_money_printer_area_2d_hit(position, power):
	health -= power
	var tween: Tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "modulate:v", 1, 0.25).from(15)
	if(health <= 0):
		queue_free()
