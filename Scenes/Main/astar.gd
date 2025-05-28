class_name Astar
extends Node2D
## sets up AStar then makes enemy Waves
@onready var popup = load("res://Scenes/UI/blocked_label.tscn")

## signal defined,
## emit_signal("tower_placed") in the make_tower function
signal tower_placed
signal blocked
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
	## set up UI BuildBar signals
	##  i.name = "Gun" or "Missile"
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.pressed.connect(initiate_build_mode.bind(i.name))
	## set up astar
	astar_grid = AStarGrid2D.new()
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
		
	make_enemy()
		

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		
		build_tile = ground.local_to_map(get_global_mouse_position())
		build_location = ground.map_to_local(build_tile)
		#print("click, build_tile = ", build_tile)
		make_tower()
		

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
		emit_signal("tower_placed") 
		
func popup_blocked_warning(new_popup) -> void:
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
	#print("make_spot_solid, build_tile = ", build_tile)
	## set the ground custom data layer 'solid' to true
	## set the astar_grid point to 'solid'
	#ground.get_cell_tile_data(spot_to_make_solid).set_custom_data("solid", true)
	astar_grid.set_point_solid(spot_to_make_solid, true)

	
func undo_make_spot_solid(spot_to_undo: Vector2i) -> void:
	print("undo_make_spot_solid")
	## set the ground custom data layer 'solid' to false
	## set the astar_grid point 'solid' = false
	#ground.get_cell_tile_data(spot_to_undo).set_custom_data("solid", false)
	astar_grid.set_point_solid(spot_to_undo, false)
	
func is_spot_solid(spot_to_check: Vector2i) ->bool:
	## ground tilemaplayer has a custom data layer called 'solid' which is true if solid
	#return ground.get_cell_tile_data(spot_to_check).get_custom_data("solid")
	return astar_grid.is_point_solid(spot_to_check) or ground.get_cell_tile_data(spot_to_check).get_custom_data("solid")
	
func make_enemy() -> void:
	### make reference to markers.  The different Spawn and Goal markers
	### add a small amount of variation to the pathing (I hope)
	Goal = Goal1
	## add creeps
	await get_tree().create_timer(1).timeout
	for i in 10:
		var creep_instance = enemy_scene.instantiate()
		creep_instance.astar_grid = astar_grid
		creep_instance.ground = ground
		creep_instance.global_position = Spawn1.global_position
		creep_instance.Goal = Goal1
		add_child(creep_instance)
		await get_tree().create_timer(1.5).timeout
		
func initiate_build_mode(tower_type: String) -> void:
	pass
