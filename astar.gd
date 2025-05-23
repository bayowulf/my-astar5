class_name Astar
extends Node2D

@onready var ground: TileMapLayer = $Ground

@export var enemy_scene: PackedScene

var astar_grid: AStarGrid2D

func _ready() -> void:
	print("astar.gd ready")
	astar_grid = AStarGrid2D.new()
	astar_grid.region = ground.get_used_rect()
	astar_grid.cell_size = ground.tile_set.tile_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	for cell in ground.get_used_cells():
		astar_grid.set_point_solid(cell, is_spot_solid(cell))
		
	##TODO move make_enemy call to a spawn enemies function
	make_enemy()
		
func is_spot_solid(spot_to_check: Vector2i) ->bool:
	return ground.get_cell_tile_data(spot_to_check).get_custom_data("solid")
	
func make_enemy() -> void:
	print("astar.gd/make_enemy")
	## make reference to markers.  The different Spawn and Goal markers
	## add a small amount of variation to the pathing (I hope)
	var Spawn1 = $Marker2DSpawn1
	var Spawn2 = $Marker2DSpawn2
	var Goal1 = $Marker2DGoal1
	var Goal2 = $Marker2DGoal2
	##  Add Creep1
	var creep1 = enemy_scene.instantiate()
	creep1.astar_grid = astar_grid
	creep1.ground = ground
	creep1.global_position = Spawn1.global_position
	creep1.Goal = Goal1
	add_child(creep1)
	## add creep2
	var creep2 = enemy_scene.instantiate()
	creep2.astar_grid = astar_grid
	creep2.ground = ground
	creep2.global_position = Spawn2.global_position
	creep2.Goal = Goal2
	add_child(creep2)
