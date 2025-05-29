class_name Creep
extends Node2D
## attached to a creep scene (when the creep scene is instantiated)
## makes the creep move thru the target positions held in the current_path_id
#signal tower_removed
@onready var world_node: World = $".."
@export var creep_speed : float = 300
## the next three var's (Goal, ground, astar_grid) values are set in the world.gd script 
## which instantiates the creep scene.
var Goal: Marker2D
var ground: TileMapLayer
var astar_grid: AStarGrid2D

## each entry in current_id_path is a 'target', ie where to go next.
var target_position: Vector2
## current_id_path is an array of target positions
var current_id_path: Array[Vector2i]
## not used so commented out
#var current_point_path: PackedVector2Array
var is_moving: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## connect signals
	GameData.tower_placed.connect(_on_tower_placed)
	GameData.tower_removed.connect(_on_tower_removed)
	
	update_creep_path()

			#
func _physics_process(delta: float) -> void:
	## current_id_path is an array of target positions.
	## _physics_process basically moves the creep from target_position to target_position
	## popping the front of the array until the aarray is empty and the 
	## last or Goal target position has been reached.
	
	## the is_moving check is from a previous version where the Player clicked on the map 
	## to set the goal position.  initially they are not moving
	if current_id_path.is_empty():
		return

	if is_moving == false:
		## initially the creep is not moving, so set the first target position
		## and set -s_moving to true
		target_position = ground.map_to_local(current_id_path.front())
		is_moving = true
		
	global_position = global_position.move_toward(target_position, creep_speed * delta)
	
	if global_position == target_position:
		## the creep has arrived at the target_position, 
		## so pop that target to access the next target in the array
		current_id_path.pop_front()		
		##if current_id_path is not empty - meaning there more target_positions...
		if current_id_path.is_empty() == false:
			## current_id_path is an array that hold target_positions
			## so get the next target (the position at the front of the array)
			target_position = ground.map_to_local(current_id_path.front())
		else: ##if it is empty then the Goal target is reached:
			is_moving = false
			queue_free()
			print("Goal target reached")
	
func update_creep_path() -> void:
	print(get_stack())
	#print_rich("[font_size=15][color=red]",get_stack())
	## initially: id_path.is_empty() is false because
	## the array is always full at the beginning.
	current_id_path =  astar_grid.get_id_path(
			ground.local_to_map(global_position),
			ground.local_to_map(Goal.global_position))
	#print_rich("[font_size=15]update creep path: current_id_path.front()" , current_id_path.front())
			
	
func _on_tower_placed() -> void:
	print_rich("[color=pink]", get_stack())
	## call update_creep_path which alters the current_id_path
	update_creep_path()
	
func _on_tower_removed() -> void:
	print_rich("[color=lightblue]", get_stack())
	## call update_creep_path which alters the current_id_path
	update_creep_path()
