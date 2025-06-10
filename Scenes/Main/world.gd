class_name World
extends Node2D
## sets up AStar then makes enemy Waves
@onready var popup = load("res://Scenes/UI/blocked_label.tscn")
@onready var world: World = $"."

## TEST is there any reason to @export this?
## TEST change it to @onready
## TEST result: @onready works and is simpler
@onready var Astar_var : World
#@export var Astar_var : World


## TEST is @export the best way to do this?
## TEST how about @onready?
## TEST Result: @onready works and is clearer.
@onready var enemy_scene: PackedScene = load("res://Scenes/Enemies/Creep.tscn")
#@export var enemy_scene: PackedScene

@export var seconds_between_waves : float = 10
@export var number_of_waves : int = 1
@export var creeps_in_wave : int = 10
var turret_footprint : Array = []
#var marker_number : String

#var astar_grid: AStarGrid2D
var Goal : Marker2D
var Spawn : Marker2D

###
### copied from 'Tower Defense Top Down 2D'
###
##  for easy reference to Map1.tscn
#var map_node : Node
##  a flag to control when build mode is on/off
var build_mode :bool = false
##  a flag : true when the tile is free to build a turrett on ```false otherwise.
var build_valid :bool = false 
##  the tile location on the map where a tower will be built
var build_tile : Vector2i 
##  the local coords of the place to build a tower
var build_location : Vector2
##  NOTE interacts with stringname type variables - fyi in case weird erros pop up,
##  The name of the tower to be built - ie Gun or Missile
var build_type : String
##  used in wave data
var current_wave : int = 0
var enemies_in_wave : int = 0
var base_health : int = 100
## NOTE: 'build_buttons' is the name of a group created in the engine like so:  
## with GameScene.tscn loaded: 
## Select GUN node:Inspector:node:Groups:click +:create new group: "build_buttons"
## Select 'Missile' node: go to groups in the Inspector and 'check' build_buttons' group.
##  
###
### End copy
###
var remove_tower_position : Vector2
var remove_tower_location : Vector2

var print_flag = true
var print_flag2 = true
var print_flag3 = true
var print_flag4 = true

@onready var Spawn1 = $Marker2DSpawn1
@onready var Spawn2 = $Marker2DSpawn2
@onready var Spawn3 = $Marker2DSpawn3
@onready var Spawn4 = $Marker2DSpawn4
#@onready var Goal1 = $Marker2DGoal1
#@onready var Goal2 = $Marker2DGoal2
#@onready var Goal3 = $Marker2DGoal3
#@onready var Goal4 = $Marker2DGoal4

func _ready() -> void:
	print_rich("[font_size=15][color=white]World/_ready()")
	randomize()
	#marker_number = str(randi_range(1, 4))
	#GameData.ground_v1 = $Ground
	#GameData.ground = $Ground
	## This is set up to potenttially add more maps in the future?
	#var new_groundscene : TileMapLayer = load("res://Scenes/Maps/ground1.tscn").instantiate()
	#world.add_child(new_groundscene)
	#move_child($Ground, 1)
	GameData.ground = $Ground
	GameData.wall = $Walls
	GameData.play_area = $PlayArea
	## set up UI BuildBar signals
	##  i.name = "Gun" or "Missile"
	for i in get_tree().get_nodes_in_group("build_buttons"):
		#print("i = ", i, "; i.name = ", i.name) #i.name = Gun / Missile
		i.pressed.connect(initiate_build_mode.bind(i.name))
		
	## set up astar
	setup_astar()
	
	## I want towers to be placed and have Creeps instantiated only after
	## the Start Button is pressed
	
	### Add a wave of Creeps
	#make_enemy(marker_number) # don't need 'marker_number'
	#make_enemy()
		#
	## Set markers instead of make_enemy
	set_spawn_points()

func _process(_delta: float) -> void:
	if print_flag:
			print_rich("[font_size=15][color=white]World/_process()")
			print_flag = false

	#if Input.is_action_just_pressed("left_click"):
		##build_tile = ground.local_to_map(get_global_mouse_position())
		##build_location = ground.map_to_local(build_tile)
		#build_tile = GameData.ground.local_to_map(get_global_mouse_position())
		#build_location = GameData.ground.map_to_local(build_tile)
		#make_tower(build_tile, build_location)
	if build_mode:
		#print_rich("[font_size=15][color=green]build_mode = ", build_mode)
		update_tower_preview()
		
func setup_astar() -> void:
	print_rich("[font_size=15][color=white]World/_setup_astar()")

	#astar_grid = AStarGrid2D.new()
	#GameData.astar_grid_v1 = astar_grid
	GameData.astar_grid_v1 = AStarGrid2D.new()
	## 'ground' is the tilemaplayer
	#astar_grid.region = ground.get_used_rect()
	#astar_grid.cell_size = ground.tile_set.tile_size
	#astar_grid.region = GameData.ground.get_used_rect()
	#astar_grid.cell_size = GameData.ground.tile_set.tile_size
	##astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	#astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	#astar_grid.update()
	GameData.astar_grid_v1.region = GameData.ground.get_used_rect()
	GameData.astar_grid_v1.cell_size = GameData.ground.tile_set.tile_size
	#GameData.astar_grid_v1.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	GameData.astar_grid_v1.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	GameData.astar_grid_v1.update()
	## loop thru tiles in ground and set the astar_grid solid according to
	## the custom data layer in ground: 'solid' : bool
	#print("ground.get_used_cells() = ", ground.get_used_cells())
	#for cell in ground.get_used_cells():
	#for cell in GameData.ground.get_used_cells():
	for cell in GameData.wall.get_used_cells():
		#print("cell = ", cell)
		#astar_grid.set_point_solid(cell, is_spot_solid(cell))
		#GameData.astar_grid_v1.set_point_solid(cell, is_spot_solid(cell))
		GameData.astar_grid_v1.set_point_solid(cell, true)
	
#func make_tower(tile_to_build_on : Vector2, location_to_build : Vector2) -> void:
	#print_rich("[font_size=15][color=lightblue]make tower, build_tile = ", build_tile)
	### the code for left click is in the _process() and is currently commented out.
	### on left mouse click, if the tile is not solid, 
	### i want to place a tower at the cursor location
	### and set that spot to solid.
	### get the current tile:
	### instantiate a tower
	### check if path is blocked
	###if is_spot_solid(build_tile):
	###	return
	#var new_tower : Node = load("res://Scenes/Turrets/tower.tscn").instantiate()
	### build tower if spot is not solid
	##if not is_spot_solid(build_tile):
	#if not is_spot_solid(tile_to_build_on):
		##new_tower.position = build_location
		#new_tower.position = location_to_build
		#new_tower.name = "Tower"
		##ground.add_child(new_tower)
		#GameData.wall.add_child(new_tower)
		##make_spot_solid(build_tile)
		#make_spot_solid(tile_to_build_on)
		#if is_path_blocked():
			#print(get_stack(), "; is_path_blocked is true")
			### display a popup warning BLOCKED
			#var new_popup = popup.instantiate()
			#popup_blocked_warning(new_popup)
			### remove tower - ie undo make_solid
			##undo_make_spot_solid(build_tile)
			#undo_make_spot_solid(tile_to_build_on)
			#new_tower.queue_free()
			#await get_tree().create_timer(1).timeout
			#new_popup.queue_free()
		#GameData.emit_signal("tower_placed") 
		
#func remove_tower() -> void:
	#var tower = $Ground/Tower
	### somehow queue_free the tower at that location
	#tower.queue_free()
		
func popup_blocked_warning(new_popup) -> void:
	print_rich("[font_size=15][color=white]World/popup_blocked_warning()")

	## display a popup warning message 'BLOCKED'
	new_popup.position = get_global_mouse_position() + Vector2(-50, 0)
	new_popup.visible = true
	add_child(new_popup)
	
func is_path_blocked() -> bool:
	print_rich("[font_size=15][color=white]World/is_path_blocked()")
	## get a path from Spawn1 to the Goal
	## path is blocked if the path.size == 0.
	#var path = astar_grid.get_id_path(
	var path = GameData.astar_grid_v1.get_id_path(
			#ground.local_to_map(Spawn1.global_position),
			#ground.local_to_map(Goal.global_position))
			GameData.ground.local_to_map(Spawn1.global_position),
			GameData.ground.local_to_map(Goal.global_position))
	return path.size() == 0
	
func make_spot_solid(spot_to_make_solid: Vector2i) -> void:
	print_rich("[font_size=15][color=white]World/make_spot_solid()")

	## set the ground custom data layer 'solid' to true
	## set the astar_grid point to 'solid'
	## NOTE 'set_custom_data' changes ALL the tiles, not just one.
	## NOTE do not do: ground.get_cell_tile_data(spot_to_make_solid).set_custom_data("solid", true)
	#astar_grid.set_point_solid(spot_to_make_solid, true)
	GameData.astar_grid_v1.set_point_solid(spot_to_make_solid, true)

	
func undo_make_spot_solid(spot_to_undo: Vector2i) -> void:
	print_rich("[font_size=15][color=white]World/undo_make_spot_solid()")

	## set the ground custom data layer 'solid' to false
	## set the astar_grid point 'solid' = false
	print("undo_make_spot_solid")
	## NOTE see above note. ground.get_cell_tile_data(spot_to_undo).set_custom_data("solid", false)
	#astar_grid.set_point_solid(spot_to_undo, false)
	GameData.astar_grid_v1.set_point_solid(spot_to_undo, false)
	
func is_spot_solid(spot_to_check: Vector2i) ->bool:
	if print_flag4:
		print_rich("[font_size=15][color=white]World/is_spot_solid()")
		print_flag4 = false
	## check if the tile is solid: two things to check:
	## 1. check if the base tile map indicates that 'spot_to_check' is solid (ie walls) with:
	##      ground.get_cell_tile_data(spot_to_check).get_custom_data("solid")
	## 2. check if astar_grid has marked 'spot_to_check' as solid.
	#return astar_grid.is_point_solid(spot_to_check) or ground.get_cell_tile_data(spot_to_check).get_custom_data("solid")
	#return astar_grid.is_point_solid(spot_to_check) or GameData.ground.get_cell_tile_data(spot_to_check).get_custom_data("solid")
	#return GameData.astar_grid_v1.is_point_solid(spot_to_check) or GameData.wall.get_cell_tile_data(spot_to_check).get_custom_data("solid")
	return GameData.astar_grid_v1.is_point_solid(spot_to_check)

#func make_enemy(marker_num : String) -> void:
func make_enemy() -> void:
	print_rich("[font_size=15][color=white]World/make_enemy()")
	#var marker_number = str(randi_range(1, 4)) 
	## The different Spawn and Goal markers add a small amount of variation to the pathing (I hope)
	#Goal = Goal1
	#Goal = get_node("Marker2DGoal" + marker_number)
	#print_rich("[font_size=15][color=azure]marker_number = ", marker_number, "; Goal = ", Goal)
	## add creeps
	## time between waves
	await get_tree().create_timer(1).timeout
	
	## HACK TODO I need to build a proper wave generator
	## there are 4 Spawn points and 4 Goal points.  Randomly choose between them
	## in order to introduce some variation.
	## Instantiate a Creep
	for j in int(number_of_waves):
		print("j= ", j)
		for i in creeps_in_wave:
			print("i = ", i)
			#set_spawn_points(marker_num)
			set_spawn_points()
		#marker_num = str(randi_range(1, 4))
		#Goal = get_node("Marker2DGoal" + marker_num)
		#Spawn = get_node("Marker2DSpawn" + marker_num)
		
		## Instantiate creep, initialize creep variables and add to scene tree
			instantiate_creep()
		
		#var creep_instance = enemy_scene.instantiate()
		##creep_instance.astar_grid = astar_grid
		### .astar_grid is used by the creep (creep.gd) to get its path
		#creep_instance.astar_grid = GameData.astar_grid_v1
		##creep_instance.ground = ground
		#creep_instance.ground = GameData.ground
		#creep_instance.global_position = Spawn.global_position
		#creep_instance.Goal = Goal
		#add_child(creep_instance)
		#await get_tree().create_timer(1.5).timeout
		## time between individual creeps
			#print("Start Creep timer")
			await get_tree().create_timer(randf_range(0.1, 1.0)).timeout
			#print("End Creep Timer")
		#print("start wave timer")
		await get_tree().create_timer(seconds_between_waves).timeout
		#print("End Wave timer")
		
		
func set_spawn_points() -> void:
	var marker = str(randi_range(1, 4))
	Goal = get_node("Marker2DGoal" + marker)
	Spawn = get_node("Marker2DSpawn" + marker)
	
func instantiate_creep() -> void:
	var creep_instance = enemy_scene.instantiate()
	#creep_instance.astar_grid = astar_grid
	## .astar_grid is used by the creep (creep.gd) to get its path
	creep_instance.astar_grid = GameData.astar_grid_v1
	#creep_instance.ground = ground
	creep_instance.ground = GameData.ground
	creep_instance.global_position = Spawn.global_position
	creep_instance.Goal = Goal
	add_child(creep_instance)
	
## from _ready(), called by a programatically generated signal with button_name bound. - see _ready line 79 above
func initiate_build_mode(tower_type: String) -> void:
	print_rich("[font_size=15][color=white]World/initiate_build_mode; tower_type = ", tower_type, "; build_mode = ", build_mode)
	#check if already in build mode - preventing piling up of towers around the build tower ui buttons
	if build_mode:
		cancel_build_mode()
	#the guns/missile are saved as scenes. T1=built, T2=upgraded.
	build_type = tower_type + "T1"
	build_mode = true 
	#print_rich("[font_size=15][color=bisque]build_mode = ", build_mode)
	## call the function 'get_tower_preview' in the UI script
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())
	#print_rich("[font_size=15][color=bisque]return from UI/set_tower_preview, build_mode = ", build_mode)
	
	
## activated when player clicks right mouse button to cancel the build
func cancel_build_mode():
	print_rich("[font_size=15][color=white]World/cancel_build_mode()")
	## flag that build mode is false
	build_mode = false 
	## flag that a valid build locaation has not been found or decided on
	build_valid = false 
	#get_node("UI/TowerPreview").queue_free()
	get_node("UI/TowerPreview").free()
	
## Move the drag texture along with the mouse cursor when you are building a tower.
func update_tower_preview():
	if print_flag3:
		print_rich("[font_size=15][color=white]World/update_tower_preview()")
		print_flag3 = false
	#print("update_tower_preview")
	## Get the mouse coords
	var mouse_position : Vector2 = get_global_mouse_position()
	
## NOTE global, local and map coords NOTE 
## local_to_map: Returns the map coordinates of the cell containing the given local_position.
## but the mouse_position is global so what gives?
## it turns out that the global mouse position and the local mouse position are the same numbers.
## but thats because i think, that the game scene takes up the entire canvas,
## so local to the game scene is the same as global and vice versa.
## NOTE (from some rando on the internet): Global will be the same as Local if the parent has no transformations, scale at 1,1 position at 0,0 rotation 0; Chances are your Tilemap is not offset from global 0,0 so the Local coordinates will not be offset either.
## NOTE A majority of nodes do spend their lifetime at 0,0 so their children are not offset either and happen to share global coordinate space.
## NOTE the logic is like this 1. get the mouse coords; 2. identify the tile under the mouse; 3. Get the coords of that tile
	
	##  retrieve the 2d tile index for where the mouse is - ie identify the tile under the mouse
	#var current_tile : Vector2i = map_node.get_node("TowerExclusion").local_to_map(mouse_position)
	var current_tile : Vector2i = GameData.ground.local_to_map(mouse_position)
	## map_to_local: Returns the centered position of a cell in the TileMapLayer's local coordinate space.
	## ie get the local coords of the tile.
	#var tile_position : Vector2 = map_node.get_node("TowerExclusion").map_to_local(current_tile)
	var tile_position : Vector2 = GameData.ground.map_to_local(current_tile)
	## get_cell_source_id" Returns the tile source ID of the cell at coordinates coords. 
	## Returns -1 if the cell does not exist.
	#if map_node.get_node("TowerExclusion").get_cell_source_id(current_tile) == -1:
	if not is_spot_solid(current_tile) and GameData.play_area.get_used_cells().has(current_tile):
		#print_rich("[font_size=15][color=hotpink] play_area = ", GameData.play_area.get_used_cells().has(current_tile))
		## if the current tile is not solid then it is valid to build on.
		### update_tower_preview is a function in the ui.gd script
		### since the tile is not present in the TowerExclusion layer,
		###  it is valid to build there, so color that tile green. 
		### call 'UI/update_tower_preview(new_position, color)'
		
		get_node("UI").update_tower_preview(tile_position, "59ff29")## Green
		
		### flag that a valid build tile has been found
		
		build_valid = true 
		
		### get the coords for the build_location
		
		build_location = tile_position
		
		### identify the tile to build on
		
		build_tile = current_tile
	else:
		### color the tile red
		### call 'UI/update_tower_preview(new_position, color)'
		get_node("UI").update_tower_preview(tile_position, "d11b0d")## RED
		### flag that a valid build locaation has not been found
		build_valid = false
		
##  Listens for mouse clicks from the player (left for build and right for cancel)
##  this is setup in Project->project settings->Input Map
func _unhandled_input(event):
	
	if print_flag2:
		print_rich("[font_size=15][color=white]World/unhandled_input()")
		print_flag2 = false
	#print_rich("[color=pink]unhandled input")
	##  rt click and in build mode -> cancel placing the tower
	if event.is_action_released("ui_cancel") and build_mode == true:
		cancel_build_mode()
	##  left click and in build mode -> continue wwith building the tower
	if event.is_action_released("ui_accept") and build_mode == true:
		verify_and_build()
		cancel_build_mode()## because done building
		
		
## activated when player clicks left mouse button - 
## verify the location is appropriate for building and if so build the tower.
func verify_and_build():
	print_rich("[font_size=15][color=white]World/verify_and_build()")
	#print_rich("[font_size=15] verify and build, build valid = ", build_valid)
	## if the tile has been identified as valid to build a tower on
	if build_valid:
		print_rich("[wave][font_size=15][color=lightgreen]build_valid = true; build_type = ", build_type)
		## instantiate a Turret node.
		var new_tower : Node = load("res://Scenes/Turrets/" + build_type + ".tscn").instantiate()
		print_rich("[font_size=15][color=lightgreen]build type = ", build_type, "; new tower.built = ", new_tower.built)
		new_tower.position = build_location
		print_rich("[font_size=15][color=lightgreen] new_tower.position", new_tower.position )
		new_tower.built = true
		new_tower.type = build_type ##  the '.type' variable is defined in the Turrets.gd script
		## GameData.gd contains aa dictionary with tower data
		new_tower.category = GameData.tower_data[build_type]["category"] #add var category to Turrets.gd
		print_rich("[font_size=15][color=lightgreen] new_tower.category", new_tower.category )

		## add a new tower to Map1/Turrets node.  'true' means human readable name
		#map_node.get_node("Turrets").add_child(new_tower, true)
		#GameData.ground.get_node("Turrets").add_child(new_tower, true)
		print_rich("[font_size=15][color=lightgreen] new_tower.name = ", new_tower.name )
		## NOTE I changed true to false so that the name is an engine assigned dummy name.
		#GameData.wall.add_child(new_tower, true)
		GameData.wall.add_child(new_tower, false)
		## "2, Vector2i(1,0)" refers to a special invisible tile that is placed on TowerExclusion
##  to populate it to indicate that a tower has been placed in that location on the map.
## Map1.tscn/TowerExclusion/TileSet:Obstructed.png - has Atlas ID:2 and atlas coordinates (1, 0)
		#map_node.get_node("TowerExclusion").set_cell(build_tile, 2, Vector2i(1,0))
		#map_node.get_node("TowerExclusion").set_cell(build_tile, 2, Vector2i(1,0))
		
		## update the astar_grid to mark the footprint of the toweer just to solid 
		#print_rich("[font_size=15][color=khaki]build_location = ", build_location, "GameData.ground.local_to_map(build_location) = ", GameData.ground.local_to_map(build_location))
		#print_rich("[font_size=15][color=khaki]build_tile = ", build_tile)
		#print_rich("[font_size=15][color=khaki]GameData.ground.get_neighbor_cell(build_tile, TileSet.CELL_NEIGHBOR_TOP_SIDE)", GameData.ground.get_neighbor_cell(build_tile, TileSet.CELL_NEIGHBOR_TOP_SIDE)) 
		#print_rich("[font_size=15][color=khaki]GameData.ground.get_neighbor_cell(build_tile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)", GameData.ground.get_neighbor_cell(build_tile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE))
		#var currrent_tile = GameData.ground.local_to_map(build_location)
	 
		## the towers are 32x32 px.  I think godot uses the upper left corner of the 
		## sprite to place it.
		## So if i want to make the 4 16x16 pixel squares solid then for example
		## sprite placed on (50,7) make that solid as well as (51,7), (50,8), (51, 8).
		## just guessing.
		
		var build_tile_top = Vector2i(build_tile.x, build_tile.y-1)
		var build_tile_bottom = Vector2i(build_tile.x, build_tile.y+1)
		var build_tile_right = Vector2i(build_tile.x+1, build_tile.y)
		var build_tile_left = Vector2i(build_tile.x-1, build_tile.y)
		turret_footprint = [
		build_tile,
		build_tile_top,
		build_tile_bottom,
		build_tile_right,
		build_tile_left ]
		
		make_spot_solid(build_tile)
		make_spot_solid(build_tile_top)
		make_spot_solid(build_tile_bottom)
		make_spot_solid(build_tile_right)
		make_spot_solid(build_tile_left)
		#print("build_tile",build_tile)
		#print("top = ", Vector2i(build_tile.x, build_tile.y-1))
		#print("bottom = ", Vector2i(build_tile.x, build_tile.y+1))
		#print("right = ", Vector2i(build_tile.x+1, build_tile.y))
		#print("left = ",  Vector2i(build_tile.x-1, build_tile.y))
		#print("left = ", )
		# signals _on_tower_placed and _on_tower_removed
		GameData.emit_signal("tower_placed")
		if is_path_blocked():
			print_rich( "[font_size=15][color=honeydew]; is_path_blocked is true")
			## display a popup warning BLOCKED
			var new_popup = popup.instantiate()
			popup_blocked_warning(new_popup)
			## remove tower - ie undo make_solid
			#undo_make_spot_solid(build_tile)
			for i in turret_footprint:
				undo_make_spot_solid(i)
				
			new_tower.queue_free()
			await get_tree().create_timer(1).timeout
			new_popup.queue_free()
			GameData.emit_signal("tower_removed") 
		
		
