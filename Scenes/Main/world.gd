class_name World
extends Node2D
## sets up AStar then makes enemy Waves
@onready var popup = load("res://Scenes/UI/blocked_label.tscn")

## signal defined,
## emit_signal("tower_placed") in the make_tower function
#signal tower_placed
#signal tower_removed
#signal blocked
@onready var world: World = $"."
@onready var ground: TileMapLayer = $Ground

@export var Astar_var : World
@export var enemy_scene: PackedScene

var astar_grid: AStarGrid2D
var Goal : Marker2D

###
### copied from 'Tower Defense Top Down 2D'
###
##  for easy reference to Map1.tscn
var map_node : Node
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

@onready var Spawn1 = $Marker2DSpawn1
@onready var Spawn2 = $Marker2DSpawn2
@onready var Goal1 = $Marker2DGoal1
@onready var Goal2 = $Marker2DGoal2

func _ready() -> void:
	GameData.ground_v1 = $Ground

	## set up UI BuildBar signals
	##  i.name = "Gun" or "Missile"
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.pressed.connect(initiate_build_mode.bind(i.name))
		
	## set up astar
	setup_astar()
	## DEBUG 
	#astar_grid = AStarGrid2D.new()
	### 'ground' is the tilemaplayer
	#astar_grid.region = ground.get_used_rect()
	#astar_grid.cell_size = ground.tile_set.tile_size
	#astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	#astar_grid.update()
	## loop thru tiles in ground and set the astar_grid solid according to
	## the custom data layer in ground: 'solid' : bool
	#print("ground.get_used_cells() = ", ground.get_used_cells())
	#for cell in ground.get_used_cells():
		#astar_grid.set_point_solid(cell, is_spot_solid(cell))
		
	make_enemy()
		

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		
		build_tile = ground.local_to_map(get_global_mouse_position())
		build_location = ground.map_to_local(build_tile)
		#print("click, build_tile = ", build_tile)
		make_tower()
	#elif Input.is_action_just_pressed("right_click"):
		#remove_tower_position = ground.local_to_map(get_global_mouse_position())
		#remove_tower_location = ground.map_to_local(remove_tower_position)
		#remove_tower()
	
		
func setup_astar() -> void:
	astar_grid = AStarGrid2D.new()
	GameData.astar_grid_v1 = astar_grid
	## 'ground' is the tilemaplayer
	astar_grid.region = ground.get_used_rect()
	astar_grid.cell_size = ground.tile_set.tile_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	## loop thru tiles in ground and set the astar_grid solid according to
	## the custom data layer in ground: 'solid' : bool
	#print("ground.get_used_cells() = ", ground.get_used_cells())
	for cell in ground.get_used_cells():
		astar_grid.set_point_solid(cell, is_spot_solid(cell))
	
func make_tower() -> void:
	#print("make tower, build_tile = ", build_tile)
	## on left mouse click, if the tile is not solid, 
	## i want to place a tower at the cursor location
	## and set that spot to solid.
	## get the current tile:
	## instantiate a tower
	## check if path is blocked
	##if is_spot_solid(build_tile):
	##	return
	var new_tower : Node = load("res://Scenes/Turrets/tower.tscn").instantiate()
	## build tower if spot is not solid
	if not is_spot_solid(build_tile):
		new_tower.position = build_location
		new_tower.name = "Tower"
		ground.add_child(new_tower)
		make_spot_solid(build_tile)
		if is_path_blocked():
			print(get_stack(), "; is_path_blocked is true")
			## display a popup warning BLOCKED
			var new_popup = popup.instantiate()
			popup_blocked_warning(new_popup)
			## remove tower - ie undo make_solid
			undo_make_spot_solid(build_tile)
			new_tower.queue_free()
			await get_tree().create_timer(1).timeout
			new_popup.queue_free()
		GameData.emit_signal("tower_placed") 
		
#func remove_tower() -> void:
	#var tower = $Ground/Tower
	### somehow queue_free the tower at that location
	#tower.queue_free()
		
func popup_blocked_warning(new_popup) -> void:
	## display a popup warning message 'BLOCKED'
	new_popup.position = get_global_mouse_position() + Vector2(-50, 0)
	new_popup.visible = true
	add_child(new_popup)
	
func is_path_blocked() -> bool:
	## get a path from Spawn1 to the Goal
	## path is blocked if the path.size == 0.
	var path = astar_grid.get_id_path(
			ground.local_to_map(Spawn1.global_position),
			ground.local_to_map(Goal.global_position))
	return path.size() == 0
	
func make_spot_solid(spot_to_make_solid: Vector2i) -> void:
	## set the ground custom data layer 'solid' to true
	## set the astar_grid point to 'solid'
	## NOTE 'set_custom_data' changes ALL the tiles, not just one.
	## NOTE do not do: ground.get_cell_tile_data(spot_to_make_solid).set_custom_data("solid", true)
	astar_grid.set_point_solid(spot_to_make_solid, true)

	
func undo_make_spot_solid(spot_to_undo: Vector2i) -> void:
	## set the ground custom data layer 'solid' to false
	## set the astar_grid point 'solid' = false
	print("undo_make_spot_solid")
	## NOTE see above note. ground.get_cell_tile_data(spot_to_undo).set_custom_data("solid", false)
	astar_grid.set_point_solid(spot_to_undo, false)
	
func is_spot_solid(spot_to_check: Vector2i) ->bool:
	## check if the tile is solid: two things to check:
	## 1. check if the base tile map indicates that 'spot_to_check' is solid (ie walls) with:
	##      ground.get_cell_tile_data(spot_to_check).get_custom_data("solid")
	## 2. check if astar_grid has marked 'spot_to_check' as solid.
	return astar_grid.is_point_solid(spot_to_check) or ground.get_cell_tile_data(spot_to_check).get_custom_data("solid")
	
func make_enemy() -> void:
	## The different Spawn and Goal markers add a small amount of variation to the pathing (I hope)
	Goal = Goal1
	## add creeps
	await get_tree().create_timer(1).timeout
	## HACK TODO I need to build a proper wave generator
	for i in 3:
		var creep_instance = enemy_scene.instantiate()
		creep_instance.astar_grid = astar_grid
		creep_instance.ground = ground
		creep_instance.global_position = Spawn1.global_position
		creep_instance.Goal = Goal1
		add_child(creep_instance)
		await get_tree().create_timer(1.5).timeout
		
func initiate_build_mode(_tower_type: String) -> void:
	pass
