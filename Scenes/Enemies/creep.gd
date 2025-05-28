class_name Creep
extends Node2D

@onready var world_node: Astar = $".."
@export var creep_speed : float = 300
var Goal: Marker2D
var ground: TileMapLayer
var astar_grid: AStarGrid2D
var target_position: Vector2
## current_id_path is an array of target positions
var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var is_moving: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_node.tower_placed.connect(_on_tower_placed)
	init_creep()

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
		target_position = ground.map_to_local(current_id_path.front())
		is_moving = true
		
	global_position = global_position.move_toward(target_position, creep_speed * delta)
	
	if global_position == target_position:
		current_id_path.pop_front()		
		##if current_id_path is not empty ...
		if current_id_path.is_empty() == false:
			target_position = ground.map_to_local(current_id_path.front())
		else: #if it is empty target is reached:
			is_moving = false
			queue_free()
			print("target reached")
	
func init_creep() -> void:
	## since this is called in the _ready(), it is only run once,
	## before the _physics process starts.  is_moving is always false.
	## id_path.is_empty() is always false - that is it is never empty,
	## because it is the array is always full at the beginning.
	var id_path: Array[Vector2i]
	id_path = astar_grid.get_id_path(
			ground.local_to_map(global_position),
			ground.local_to_map(Goal.global_position))
	current_id_path = id_path
func _on_tower_placed() -> void:
	init_creep()
