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
	print("creep/22/ _ready")
	print("creep/23/ self.name =  ", self.name)
	world_node.tower_placed.connect(_on_tower_placed)
	#move_creep()
	init_creep()

#func _input(event):
	#if event.is_action_pressed("move") == false:
		#return
	#print("creep.gd/_input(event)")
	#var id_path: Array[Vector2i]
	#
	#if is_moving:
		#id_path = astar_grid.get_id_path(
			#ground.local_to_map(target_position),
			#ground.local_to_map(Goal.global_position))
			##ground.local_to_map(get_global_mouse_position()))
	#else: 
		#id_path = astar_grid.get_id_path(
			#ground.local_to_map(global_position),
			#ground.local_to_map(Goal.global_position))
			##ground.local_to_map(get_global_mouse_position()))#.slice(1)
	### if id_path is not empty ...
	#if id_path.is_empty() == false:
		#current_id_path = id_path
		#'''
		#following a youtube tutorial https://youtu.be/DkAmGxRuCk4?si=pjAbgqImu6tbsun7
		#that used the Path node and polyline to create line paths
		#but I couldn't get that to work.  so I used line2d instead which works great. 
		#one issue was that the first click the target position was 0.0, 0.0.  
		#thats why I now use self.global position in the local_to_map().
		#that came from https://youtu.be/qJKBT3KOLiY?si=aYEG4O5y17aQybZC.
		#'''
		#current_point_path = astar_grid.get_point_path(
			#ground.local_to_map(self.global_position),
			#ground.local_to_map(Goal.global_position))
			##ground.local_to_map(get_global_mouse_position()))
		##debug_line.points = current_point_path
			#
func _physics_process(delta: float) -> void:
	## current_id_path is an array of target positions.
	## _physics_process basically moves the creep from target_position to target_position
	## popping the front of the array until the aarray is empty and the 
	## last or Goal target position has been reached.
	
	## the is_moving check is from a previous version where the Player clicked on the map 
	## to set the goal position.  initially they are not moving
	if current_id_path.is_empty():
		#print("creep: current path is empty")
		return
		
	
		
	

	#print("creep.gd/physics process")
	if is_moving == false:
		## initially the creep is not moving, so set the first target position
		target_position = ground.map_to_local(current_id_path.front())
		is_moving = true
		
	global_position = global_position.move_toward(target_position, creep_speed * delta)
	#print("physics_process. global_position = ", global_position)
	
	if global_position == target_position:
		#print("physics_process: global_position == target_position.  current_id_path.pop_front() ")
		current_id_path.pop_front()
		#print("current_id_path = ", current_id_path)
		
		##if current_id_path is not empty ...
		if current_id_path.is_empty() == false:
			target_position = ground.map_to_local(current_id_path.front())
		else: #if it is empty target is reached:
			is_moving = false
			queue_free()
			print("target reached")
	
#func move_creep() -> void:
func init_creep() -> void:
	## since this is called in the _ready(), it is only run once,
	## before the _physics process starts.  is_moving is always false.
	## id_path.is_empty() is always false - that is it is never empty,
	## because it is the array is always full at the beginning.
	print("creep/104/init creep")
	var id_path: Array[Vector2i]
	
	#if is_moving:
		#print("		is_moving = ", is_moving)
		#id_path = astar_grid.get_id_path(
			#ground.local_to_map(target_position),
			#ground.local_to_map(Goal.global_position))
	#else: 
		#print("		is_moving = ", is_moving)
		#id_path = astar_grid.get_id_path(
			#ground.local_to_map(global_position),
			#ground.local_to_map(Goal.global_position))
	### if id_path is not empty ...
	#print("		id_path.is_empty() = ", id_path.is_empty())
	#if id_path.is_empty() == false:
		#current_id_path = id_path
		#current_point_path = astar_grid.get_point_path(
			#ground.local_to_map(self.global_position),
			#ground.local_to_map(Goal.global_position))
			
			##++++++++++++++++++++++++++++++++++++++++++++++
		
	id_path = astar_grid.get_id_path(
			ground.local_to_map(global_position),
			ground.local_to_map(Goal.global_position))
	print("creep/130/id_path.size = ", id_path.size())
			
	current_id_path = id_path
		#
		#current_point_path = astar_grid.get_point_path(
			#ground.local_to_map(self.global_position),
			#ground.local_to_map(Goal.global_position))
func _on_tower_placed() -> void:
	print("creep/137/_on_tower_placed()")
	init_creep()
