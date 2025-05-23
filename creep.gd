class_name Creep
extends Node2D

@onready var debug_line: Line2D = $"../DebugLine"

var Goal: Marker2D
var ground: TileMapLayer
var astar_grid: AStarGrid2D
var target_position: Vector2
var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var is_moving: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("creep.gd _ready")

func _input(event):
	if event.is_action_pressed("move") == false:
		return
	print("creep.gd/_input(event)")
	var id_path: Array[Vector2i]
	
	if is_moving:
		id_path = astar_grid.get_id_path(
			ground.local_to_map(target_position),
			ground.local_to_map(Goal.global_position))
			#ground.local_to_map(get_global_mouse_position()))
	else: 
		id_path = astar_grid.get_id_path(
			ground.local_to_map(global_position),
			ground.local_to_map(Goal.global_position))
			#ground.local_to_map(get_global_mouse_position()))#.slice(1)
	## if id_path is not empty ...
	if id_path.is_empty() == false:
		current_id_path = id_path
		'''
		following a youtube tutorial https://youtu.be/DkAmGxRuCk4?si=pjAbgqImu6tbsun7
		that used the Path node and polyline to create line paths
		but I couldn't get that to work.  so I used line2d instead which works great. 
		one issue was that the first click the target position was 0.0, 0.0.  
		thats why I now use self.global position in the local_to_map().
		that came from https://youtu.be/qJKBT3KOLiY?si=aYEG4O5y17aQybZC.
		'''
		current_point_path = astar_grid.get_point_path(
			ground.local_to_map(self.global_position),
			ground.local_to_map(Goal.global_position))
			#ground.local_to_map(get_global_mouse_position()))
		debug_line.points = current_point_path
			
func _physics_process(delta: float) -> void:
	if current_id_path.is_empty():
		return

	#print("creep.gd/physics process")
	if is_moving == false:
		target_position = ground.map_to_local(current_id_path.front())
		is_moving = true
		
	global_position = global_position.move_toward(target_position, 300 * delta)
	#print("physics_process. global_position = ", global_position)
	
	if global_position == target_position:
		#print("physics_process: global_position == target_position.  current_id_path.pop_front() ")
		current_id_path.pop_front()
		#print("current_id_path = ", current_id_path)
		
		##if current_id_path is not empty ...
		if current_id_path.is_empty() == false:
			target_position = ground.map_to_local(current_id_path.front())
		else: #if it is empty
			is_moving = false
	
