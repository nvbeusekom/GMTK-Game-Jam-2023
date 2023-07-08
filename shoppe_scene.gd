extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setPowerHave(power):
	$CanvasLayer/SwordHaveLabel.text = "You have: " + str(power)
	
func setHeartHave(heart):
	$CanvasLayer/HeartHaveLabel.text = "You have: " + str(heart)
	
func setPowerCost(cost):
	$CanvasLayer/PowerCostLabel.text = "$" + str(cost)
	
func setHeartCost(cost):
	$CanvasLayer/HeartCostLabel.text = "$" + str(cost)
	
func setMoney(money):
	pass
