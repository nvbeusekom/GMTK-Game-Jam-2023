extends Node 
var states = ["main menu","building","crawling","shop"]
var game_state = "building"

var dungeon_node = null

var main_menu_node = null
var building_node = null
var crawling_node = null
var shop_node = null
# (Minus cutscenes)
# Game states: Main menu -> Building -> Crawling <-> Shop

#TODO Make Dungeon node that contains Dungeon Map, Mobs, Money and Traps

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
	pass
	
func process_building(delta):
	if building_node == null:
		pass #init

func process_crawling(delta):
	pass
	
func process_shop(delta):
	pass
