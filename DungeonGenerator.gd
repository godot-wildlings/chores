"""

Use a simple algorithm to generate a dungeon layout, then populate
the map with 'rooms' that fit the layout. Rooms can be chosed from
a selection of connection types: StraightThru, Corner, etc.

Design decision:
	* Each room could be a standard size - OR -
	* ...have position2D nodes to indicate connection points

Build a 2D array of a dungeon, then convert that into a map


"""


extends Node2D

var dungeon_map = []
var map_height = 5
var map_width = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	build_dungeon_map()
	print_dungeon_map()


func build_dungeon_map():
	for row in range(map_height):
		dungeon_map.push_back([])
		for col in range(map_width):
			dungeon_map[row].push_back(0)

func print_dungeon_map():
	for row in range(map_height):
		var rowStr = ""
		for col in range(map_width):
			rowStr += str(dungeon_map[row][col])
		print(rowStr)
	
		
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
