extends Node

var playerpos
var mousepos
var skeletonBow = load("res://ranged_skeleton.tscn")
var skeletonSpear = load("res://melee_skeleton.tscn")
var spikeTrap = load("res://spike_trap.tscn")
var moneyPrinter = load("res://money_printer.tscn")
var costs = [5,5,5,8]
var objectArray

var paused = false
var respawing = false
func pause():
	paused = true
	respawing = not $PlaceTimer.is_stopped()
	$PlaceTimer.stop()
func unpause():
	paused = false
	if respawing:
		$PlaceTimer.start()

#                     var outline = $NavigationRegion2D.get_outline()
# Called when the node enters the scene tree for the first time.
func _ready():
	objectArray = [skeletonBow, skeletonSpear, spikeTrap, moneyPrinter]
	mousepos = get_viewport().get_mouse_position() / 10
	playerpos = $Player.position
	get_tree().get_root().get_child(0).dungeon_coins = get_tree().get_root().get_child(0).starting_coins
	$crawl_HUD.set_health($Player.health)
	$crawl_HUD.set_strength($Player.power)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Move camera
	mousepos = get_viewport().get_mouse_position() / 10
	playerpos = $Player.position
	$PlayerCamera.position = playerpos

func _on_player_hit():
	$crawl_HUD.set_health($Player.health)
	
func _on_player_heal():
	$crawl_HUD.set_health($Player.health)


func _on_place_timer_timeout():
	# choose random placeable
	var randomInt = randi() % objectArray.size()
	if randomInt > 1:
		randomInt = randi() % objectArray.size()
	var objectToPlace = objectArray[randomInt]
	# check if can afford
	var mindistance 
	var maxdistance
	var cost
	if randomInt == 3:
		mindistance = 500
		maxdistance = 100000
		cost = costs[randomInt] + get_parent().moneyPrinterCount
	else:
		mindistance = 100
		maxdistance = 400
		cost = costs[randomInt]
	if cost > get_parent().dungeon_coins:
		return
	# find eligible tile
	var eligibleList = []
	
	for cell in $"../Dungeon/DungeonMap".get_used_cells_by_id(0,-1,Vector2i(0,1)):
		if ($"../Dungeon/DungeonMap".map_to_local(cell) - get_parent().playerpos).length() < maxdistance and ($"../Dungeon/DungeonMap".map_to_local(cell) - get_parent().playerpos).length() > mindistance:
			eligibleList.append(cell)
	if eligibleList.size() <= 0:
		return
	var tile = eligibleList[randi() % eligibleList.size()]
	# place object
	var scene = objectToPlace.instantiate()
	scene.position = $"../Dungeon/DungeonMap".map_to_local(tile)
	if randomInt <= 1:
		#skellyboi
		$"../Dungeon".add_child(scene)
	else:
		#niet skellyboi
		if !get_parent().lockedPositions.has(tile):
			get_parent().lockedPositions.append(tile)
			$"../Dungeon".add_child(scene)
			if randomInt == 3:
				get_parent().moneyPrinterCount += 1
	
