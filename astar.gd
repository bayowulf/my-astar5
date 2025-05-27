class_name Astar
extends Node2D
## sets up AStar then makes enemy Waves

## signal defined,
## emit_signal("tower_placed") in the make_tower function
signal tower_placed
@onready var world: Astar = $"."

@onready var ground: TileMapLayer = $Ground

@export var enemy_scene: PackedScene

var astar_grid: AStarGrid2D
## the tile location on the map where a tower will be built
var build_tile : Vector2i 
## the local coords of the place to build a tower
var build_location : Vector2
var Goal : Marker2D
@onready var Spawn1 = $Marker2DSpawn1
@onready var Spawn2 = $Marker2DSpawn2
@onready var Goal1 = $Marker2DGoal1
@onready var Goal2 = $Marker2DGoal2

func _ready() -> void:
	print(get_stack()[0]['source'],"; ", get_stack()[0]['function'],"; ", get_stack()[0]['line'], " astar.gd ready")
	var str = "get_stack()[0]['source'],'; ', get_stack()[0]['function'],'; ', get_stack()[0]['line']"
	var s2 = get_stack()[0]["source"]
	var s3 =  get_stack()[0]['function']
	var s4 =  get_stack()[0]['line']
	print(str)
	print(s2, "; ",s3,"; ", s4)
	## set up astar
	astar_grid = AStarGrid2D.new()
	## 'ground' is the tilemaplayer
	astar_grid.region = ground.get_used_rect()
	astar_grid.cell_size = ground.tile_set.tile_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	## loop thru tiles in ground and set the astar_grid solid according to
	## the custom data layer in ground: 'solid' : bool
	for cell in ground.get_used_cells():
		#if cell == Vector2i(-3,-4):
			#print("cell = ", cell)
		astar_grid.set_point_solid(cell, is_spot_solid(cell))
		
	##TODO move make_enemy call to a spawn enemies function
	make_enemy()
		
#func _physics_process(delta: float) -> void:
		#make_enemy()
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		build_tile = ground.local_to_map(get_global_mouse_position())
		build_location = ground.map_to_local(build_tile)
		make_tower()
		

func make_tower() -> void:
	print(get_stack()[0]['source'],"; ", get_stack()[0]['function'],"; ", get_stack()[0]['line'],  "astar/50/make_tower")
	## on left mouse click,  i want to place a tower at the cursor location
	## and set that spot to solid.
	## get the current tile:
	#if not is_path_blocked():
	##instantiate a tower
	var new_tower : Node = load("res://tower.tscn").instantiate()
	new_tower.position = build_location
	ground.add_child(new_tower)
	make_spot_solid(build_tile)
	is_path_blocked()
	emit_signal("tower_placed")
		
	
func is_path_blocked() -> bool:
	##trying to come up with a robust way to tell if the paath is blocked.
	##get_id_path will return [] if the path is blocked.
	##maybe the easiest way is to get a path from Spawn1 to the Goal
	## the rest of the print statement illustrate various methods
	## to reference nodes.
	print(get_stack()[0]['source'],"; ", get_stack()[0]['function'],"; ", get_stack()[0]['line'],  "astar/65/is_path_blocked")
	#print("get node creep = ", $creep, "; position = ", $creep.position, "; global position = ", $creep.global_position)
	#print("global_position = ",global_position )
	var path = astar_grid.get_id_path(
			ground.local_to_map(Spawn1.global_position),
			ground.local_to_map(Goal.global_position))
			
	print(get_stack()[0]['source'],"; ", get_stack()[0]['function'],"; ", get_stack()[0]['line'],  "astar/is path blocked/path.size() = ", path.size())
	#print("astar/is path blocked/path = ", path)
	#for i in range(world.get_child_count()):
		#print("astar/is path blocked/world children = ", i, world.get_child(i))
		
	#if world.get_child_count() > 4:
		#print("astar/is path blocked/if world.get_child_count() > 4: world.get_child(5).position = ",world.get_child(5).position )
	return path.size() == 0
	
	
	
func make_spot_solid(spot_to_make_solid: Vector2i) -> void:
	print(get_stack()[0]['source'],"; ", get_stack()[0]['function'],"; ", get_stack()[0]['line'],  "astar/77/make_spot_solid; spot_to_make_solid = ", spot_to_make_solid)
	ground.get_cell_tile_data(spot_to_make_solid).set_custom_data("solid", true)
	astar_grid.set_point_solid(spot_to_make_solid, true)
	## I want to make set the boolean of the spot_to_make_solid 
	##in the 'solid' custom data layer to true.
	## looks like: set_custom_data(layer_name: String, value: Variant)
	## ground.get_cell_tile_data(spot_to_make_solid).set_custom_data("solid", true)
	
	
func is_spot_solid(spot_to_check: Vector2i) ->bool:
	#print("is_spot_solid()")
	## ground tilemaplayer has a custom data layer called 'solid' which is true if solid
	return ground.get_cell_tile_data(spot_to_check).get_custom_data("solid")
	
func make_enemy() -> void:
	print(get_stack()[0]['source'],"; ", get_stack()[0]['function'],"; ", get_stack()[0]['line'],  "astar.gd/92/make_enemy")
	### make reference to markers.  The different Spawn and Goal markers
	### add a small amount of variation to the pathing (I hope)
	#var Spawn1 = $Marker2DSpawn1
	#var Spawn2 = $Marker2DSpawn2
	#var Goal1 = $Marker2DGoal1
	#var Goal2 = $Marker2DGoal2
	Goal = Goal1
	## add creeps
	await get_tree().create_timer(1).timeout
	for i in 10:
		print(get_stack()[0]['source'],"; ", get_stack()[0]['function'],"; ", get_stack()[0]['line'],  "astar/make enemy/103/ i = ", i, "instantiate enemy_scene")
		var creep_instance = enemy_scene.instantiate()
		print(get_stack())
		var A = get_stack()
		print(get_stack(), "A = ", A)
		print(get_stack(), "A[0]['source'] = ", A[0]["source"])
		print_stack()
		creep_instance.astar_grid = astar_grid
		creep_instance.ground = ground
		creep_instance.global_position = Spawn1.global_position
		creep_instance.Goal = Goal1
		if i <= 2:
			print(get_stack()[0]['source'],"; ", get_stack()[0]['function'],"; ", get_stack()[0]['line'],  "		astar/111/i = ", i)
			print(get_stack()[0]['source'],"; ", get_stack()[0]['function'],"; ", get_stack()[0]['line'],  "		name = ", creep_instance.name)
			print(get_stack()[0]['source'],"; ", get_stack()[0]['function'],"; ", get_stack()[0]['line'],  "		position = ",creep_instance.global_position)
			print(get_stack()[0]['source'],"; ", get_stack()[0]['function'],"; ", get_stack()[0]['line'],  "		add_child(creep_instance)")
		add_child(creep_instance)
		await get_tree().create_timer(0.2).timeout
