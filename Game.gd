extends Node 
var states = ["main menu","building","crawling","shop"]
var game_state = "building"

const starting_coins = 40

var dungeon_node = null

var building_scene = preload("res://building_state.tscn")
var main_menu_scene = preload("res://main_menu.tscn")
var crawling_scene = preload("res://crawling_state.tscn")
var shop_scene = preload("res://shoppe_scene.tscn")
var dialogue_scene = preload("res://dialogue.tscn")

var main_menu_node = null
var building_node = null
var crawling_node = null
var shop_node = null
var dialogue_node = null

var playerpos = Vector2(0,0)

var dungeon_coins = starting_coins

var crawling_coins = 10

var player_max_hp = 3
var player_power = 1

var shoppe_heart_cost = 3
var shoppe_power_cost = 3


var first_hero_death = true
var first_shop_visit = true

# (Minus cutscenes)
# Game states: Main menu -> Building -> Crawling <-> Shop

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match game_state:
		"main menu":
			process_main_menu(delta)
		"building":
			process_building(delta)
		"crawling":
			process_crawling(delta)
		"shop":
			process_shop(delta)

func process_main_menu(delta):
	if main_menu_node == null:
		main_menu_node = main_menu_scene.instantiate()
		add_child(main_menu_node)
		$MainMenu/CanvasLayer/NewGameButton.pressed.connect(_new_game)
	
func _new_game():
	$MainMenu.queue_free()
	main_menu_node = null
	
func process_building(delta):
	if building_node == null:
		building_node = building_scene.instantiate()
		add_child(building_node)
		updateCoins()
		start_dialogue(0)
		
	playerpos = $BuildingState/Hero.position
	if ($BuildingState/Hero.position - $BuildingState.hero_goal).length() < 10:
		start_dialogue(2)
		playerpos = Vector2(10000,10000)
		$BuildingState.queue_free()
		building_node = null
		game_state = "shop"
		crawling_coins = dungeon_coins
		dungeon_coins = starting_coins
		

func start_dialogue(id):
	if dialogue_node == null:
		dialogue_node = dialogue_scene.instantiate()
		dialogue_node.activeMessagesID = id
		add_child(dialogue_node)
	$Dialogue.dialogueFinished.connect(_on_finishDialogue)
	pause(self)

func _on_finishDialogue():
	$Dialogue.queue_free()
	unpause(self)
	
func process_crawling(delta):
	if crawling_node == null:
		crawling_node = crawling_scene.instantiate()
		add_child(crawling_node)
		#updateCoins()
		$CrawlingState/Player.MAX_HEALTH = player_max_hp
		$CrawlingState/Player.health = player_max_hp
		$CrawlingState/Player.power = player_power
		$CrawlingState/Player.died.connect(_on_player_died)
		$CrawlingState/Player.victory.connect(_on_victory)
		$CrawlingState/crawl_HUD.set_health($CrawlingState/Player.health)
		$CrawlingState/crawl_HUD.set_strength($CrawlingState/Player.power)
	playerpos = $CrawlingState/Player.position
	
func _on_player_died():
	playerpos = Vector2(10000,10000)
	crawling_node.queue_free()
	crawling_node = null
	game_state = "shop"
	reinit_shop()
	
func _on_victory():
	pass
	# Todo: cinematic -> destroy crawling and shop -> main menu
	
func reinit_shop():
	updateCoins()
	$ShoppeScene/CanvasLayer/HeartBuyButton.pressed.connect(_on_heart_buy)
	$ShoppeScene/CanvasLayer/SwordBuyButton.pressed.connect(_on_sword_buy)
	$ShoppeScene/CanvasLayer/ContinueButton.pressed.connect(_on_continue)
	$ShoppeScene/CanvasLayer.show()
	
func process_shop(delta):
	if shop_node == null:
		shop_node = shop_scene.instantiate()
		add_child(shop_node)
		reinit_shop()


func _on_heart_buy():
	if crawling_coins >= shoppe_heart_cost:
		crawling_coins -= shoppe_heart_cost
		player_max_hp += 1
		shoppe_heart_cost += 1
		$ShoppeScene/buySound.play()
		updateCoins()
	
func _on_sword_buy():
	if crawling_coins >= shoppe_power_cost:
		crawling_coins -= shoppe_power_cost
		player_power += 1
		shoppe_power_cost += 1
		$ShoppeScene/buySound.play()
		updateCoins()
	
func _on_continue():
	$ShoppeScene/CanvasLayer/HeartBuyButton.pressed.disconnect(_on_heart_buy)
	$ShoppeScene/CanvasLayer/SwordBuyButton.pressed.disconnect(_on_sword_buy)
	$ShoppeScene/CanvasLayer/ContinueButton.pressed.disconnect(_on_continue)
	$ShoppeScene/CanvasLayer.hide()
	game_state = "crawling"

func addCoin():
	dungeon_coins += 1
	updateCoins()
	
func pause(node):
	if game_state == "shop":
		$ShoppeScene/CanvasLayer/HeartBuyButton.pressed.disconnect(_on_heart_buy)
		$ShoppeScene/CanvasLayer/SwordBuyButton.pressed.disconnect(_on_sword_buy)
		$ShoppeScene/CanvasLayer/ContinueButton.pressed.disconnect(_on_continue)
	for child in node.get_children():
		if child.has_method("pause"):
			child.pause()
		pause(child) 
		
func unpause(node):
	if game_state == "shop":
		$ShoppeScene/CanvasLayer/HeartBuyButton.pressed.connect(_on_heart_buy)
		$ShoppeScene/CanvasLayer/SwordBuyButton.pressed.connect(_on_sword_buy)
		$ShoppeScene/CanvasLayer/ContinueButton.pressed.connect(_on_continue)
	for child in node.get_children():
		if child.has_method("unpause"):
			child.unpause()
		unpause(child) 
		
func updateCoins():
	if building_node != null:
		$BuildingState.updateCoins(dungeon_coins)
	if shop_node != null:
		$ShoppeScene.setPowerHave(player_power)
		$ShoppeScene.setHeartHave(player_max_hp)
		$ShoppeScene.setPowerCost(shoppe_power_cost)
		$ShoppeScene.setHeartCost(shoppe_heart_cost)
		$ShoppeScene.setMoney(crawling_coins)
