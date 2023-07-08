extends Node

var playerpos
var mousepos
var coins
var buildMode = false
var skeletonBow = load("res://art/SkeletonBowIdle1.png")
var skeletonSpear = load("res://art/SkeletonSpearIdle1.png")
var spikeTrap = load("res://art/SpikeTrap1.png")
var moneyPrinter = load("res://art/MoneyPrinter1.png")
var objectToPlace = null
#                     var outline = $NavigationRegion2D.get_outline()
# Called when the node enters the scene tree for the first time.
func _ready():
	mousepos = get_viewport().get_mouse_position() / 10
	playerpos = $Player.position
	coins = 0
	$DungeonBuilderInterface/CanvasLayer.set_process(buildMode)
	$DungeonBuilderInterface/CanvasLayer.visible = buildMode
	$crawl_HUD.set_health($Player.health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Move camera
	mousepos = get_viewport().get_mouse_position() / 10
	playerpos = $Player.position
	$PlayerCamera.position = playerpos
	if Input.is_action_just_pressed( "switchMode"):
		Input.set_custom_mouse_cursor(null) #ja, dit moet er 2 keer staan...
		Input.set_custom_mouse_cursor(null)
		objectToPlace = null
		buildMode = !buildMode
		$DungeonBuilderInterface/CanvasLayer.set_process(buildMode)
		$DungeonBuilderInterface/CanvasLayer.visible = buildMode

func _input(event):
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.position.x > 900:
				var rect = $DungeonBuilderInterface/CanvasLayer/Panel.get_rect()
				if rect.has_point(event.position):
					Input.set_custom_mouse_cursor(skeletonBow)
					objectToPlace = load("res://ranged_skeleton.tscn")
				rect = $DungeonBuilderInterface/CanvasLayer/Panel2.get_rect()
				if rect.has_point(event.position):
					Input.set_custom_mouse_cursor(skeletonSpear)
					objectToPlace = load("res://melee_skeleton.tscn")
				rect = $DungeonBuilderInterface/CanvasLayer/Panel3.get_rect()
				if rect.has_point(event.position):
					Input.set_custom_mouse_cursor(moneyPrinter)
					objectToPlace = load("res://money_printer.tscn")
				rect = $DungeonBuilderInterface/CanvasLayer/Panel4.get_rect()
				if rect.has_point(event.position):
					Input.set_custom_mouse_cursor(spikeTrap)
					objectToPlace = load("res://spike_trap.tscn")
			else:
				if objectToPlace != null:
					print("Place")
					var scene = objectToPlace.instantiate()
					#scene.position = $Dungeon.get_global_mouse_position()
					var mousePos = $Dungeon.get_global_mouse_position()#get_viewport().get_mouse_position()
					var tile_pos = $Dungeon.local_to_map(mousePos)
					scene.position = $Dungeon.map_to_local(tile_pos)
					if $Dungeon.get_cell_atlas_coords(0,tile_pos) == Vector2i(0,1):
						add_child(scene)

func addCoin():
	coins += 1
	updateCoins()
	
func updateCoins():
	$DungeonBuilderInterface/CanvasLayer/CoinCountLabel.text = str(coins)

func _on_player_hit():
	$crawl_HUD.set_health($Player.health)
