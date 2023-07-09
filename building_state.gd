extends Node

var buildMode = false
var skeletonBow = load("res://art/SkeletonBowIdle1.png")
var skeletonSpear = load("res://art/SkeletonSpearIdle1.png")
var spikeTrap = load("res://art/SpikeTrap1.png")
var moneyPrinter = load("res://art/MoneyPrinter1.png")
var objectToPlace = null

var hero_scene = preload("res://hero.tscn")
var hero_node
var printer = false

var cost = 0
var lock = false

var hero_goal = Vector2(1168,-240)

@export var cost_spike = 5
@export var cost_printer = 8
@export var cost_bow = 5
@export var cost_spear = 5

var paused = false
var respawing = false
func pause():
	paused = true
	respawing = not $RespawnTimer.is_stopped()
	$RespawnTimer.stop()
func unpause():
	paused = false
	if respawing:
		$RespawnTimer.start()

# Called when the node enters the scene tree for the first time.
func _ready():
	$DungeonBuilderInterface/CanvasLayer/CostSpike.text = str(cost_spike)
	$DungeonBuilderInterface/CanvasLayer/CostPrinter.text = str(cost_printer)
	$DungeonBuilderInterface/CanvasLayer/CostSpear.text = str(cost_spear)
	$DungeonBuilderInterface/CanvasLayer/CostBow.text = str(cost_bow)
	$Hero.goal = hero_goal
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	
	if paused:
		return
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if event.position.x > 900:
				printer = false
				var rect = $DungeonBuilderInterface/CanvasLayer/Panel.get_rect()
				if rect.has_point(event.position):
					Input.set_custom_mouse_cursor(skeletonBow, 0 , Vector2(16,16))
					objectToPlace = load("res://ranged_skeleton.tscn")
					cost = cost_bow
					lock = false
				rect = $DungeonBuilderInterface/CanvasLayer/Panel2.get_rect()
				if rect.has_point(event.position):
					Input.set_custom_mouse_cursor(skeletonSpear, 0 , Vector2(16,16))
					objectToPlace = load("res://melee_skeleton.tscn")
					cost = cost_spear
					lock = false
				rect = $DungeonBuilderInterface/CanvasLayer/Panel3.get_rect()
				if rect.has_point(event.position):
					Input.set_custom_mouse_cursor(moneyPrinter, 0 , Vector2(16,16))
					objectToPlace = load("res://money_printer.tscn")
					cost = cost_printer
					lock = true
					printer = true
				rect = $DungeonBuilderInterface/CanvasLayer/Panel4.get_rect()
				if rect.has_point(event.position):
					Input.set_custom_mouse_cursor(spikeTrap, 0 , Vector2(16,16))
					objectToPlace = load("res://spike_trap.tscn")
					cost = cost_spike
					lock = true
			else:
				if printer:
					cost = cost_printer + get_parent().moneyPrinterCount
				if objectToPlace != null and cost <= get_parent().dungeon_coins:
					var scene = objectToPlace.instantiate()
					#scene.position = $Dungeon.get_global_mouse_position()
					var mousePos = $"../Dungeon/DungeonMap".get_global_mouse_position()#get_viewport().get_mouse_position()
					var tile_pos = $"../Dungeon/DungeonMap".local_to_map(mousePos)
					scene.position = $"../Dungeon/DungeonMap".map_to_local(tile_pos)
					if $"../Dungeon/DungeonMap".get_cell_atlas_coords(0,tile_pos) == Vector2i(0,1) and (!get_parent().lockedPositions.has(tile_pos) or !lock):
						$"../Dungeon".add_child(scene)
						get_parent().dungeon_coins -= cost
						get_parent().updateCoins()
						if lock:
							$"../Dungeon".move_child(scene,2)
							get_parent().lockedPositions.append(tile_pos)
						else: #it must be a skeleton
							scene.placed_by_player = true
							$"../Dungeon".add_child(scene)
						print(printer)
						if printer:
							get_parent().moneyPrinterCount += 1
							$DungeonBuilderInterface/CanvasLayer/CostPrinter.text = str(cost_printer + get_parent().moneyPrinterCount)
		elif event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			objectToPlace = null
			Input.set_custom_mouse_cursor(null) #ja, dit moet er 2 keer staan...
			Input.set_custom_mouse_cursor(null)

func updateCoins(amount):
	$DungeonBuilderInterface/CanvasLayer/CoinCountLabel.text = str(amount)


func _on_hero_died():
	print("Hero dead!")
	$Hero.hide()
	$Hero.position = Vector2(-10000,-10000)
	$"../Dungeon".clear_skeletons()
	$RespawnTimer.start()
	


func _on_respawn_timer_timeout():
	print("Hero respawned")
	$Hero.health = $Hero.MAX_HEALTH
	$Hero/HealthbarFront.scale.x = 30
	
	$Hero.position = Vector2(0,10)
	$Hero.show()
	$RespawnTimer.stop()
