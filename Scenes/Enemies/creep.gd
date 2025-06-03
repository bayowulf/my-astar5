class_name Creep
extends Node2D
## attached to a creep scene (when the creep scene is instantiated)
## makes the creep move thru the target positions held in the current_path_id

##SIGNAL
##emit a signal that the base took damage and the damage amount.
##The signal is emitted in the physics process function of BlueTank and 
##picked up by by the game_scene on_base_damage(damage) function.
signal base_damage(damage)
#signal tower_removed
@onready var world_node: World = $".."
@export var creep_speed : float = 300
@export var hp : int = 50
##amount deducted from Base health (every tank that reaches the end of its path across
##the map causes points to be deducted from the Base health bar.)
@export var base_damage_amt : int = 21 
##used to make sure the signal is only emitted once (not 60 times a second)
var signal_flag : bool = false
##easy access to HealthBar (display of main 'Base' healthbar)
@onready var health_bar : TextureProgressBar = get_node("HealthBar")
##easy access to BlueTank Impact node (for display of impact animation)
#@onready var impact_area : Marker2D = get_node("Impact")


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
var projectile_impact : PackedScene = preload("res://Scenes/Support/ProjectileImpact.tscn")
@onready var impact_area : Marker2D = get_node("Impact")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## connect signals
	GameData.tower_placed.connect(_on_tower_placed)
	GameData.tower_removed.connect(_on_tower_removed)
	
	##preload the scene to improve performance
##Sets initial BlueTank health bar values 

	##'hp' is a script variable set above.
	##'max_value' and 'value' can be changed in Inspector 
	health_bar.max_value = hp
	health_bar.value = hp
##disconnect the health bar position, rotation and scale from its parent node
##so when the tank rotates, the health bar stays above the tank and does not rotate with it.
##but now we have to manually update the position of the hp bar in the 'move()' function below.
	#get_node("HealthBar").set_as_top_level(true) 
	
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
	
	## this function is called on reciept of signals _on_tower_placed and _on_tower_removed
func update_creep_path() -> void:
	#print_rich("[font_size=15][color=aqua]", get_stack())
	#print_rich("[font_size=15][color=red]",get_stack())
	## initially: id_path.is_empty() is false because
	## the array is always full at the beginning.
	current_id_path =  astar_grid.get_id_path(
			ground.local_to_map(global_position),
			ground.local_to_map(Goal.global_position))
	#print_rich("[font_size=15]update creep path: current_id_path.front()" , current_id_path.front())
			
## SIGNAL defined in GameData. emmitted when a tower is pla
func _on_tower_placed() -> void:
	#print_rich("[color=pink]", get_stack())
	## call update_creep_path which alters the current_id_path
	update_creep_path()
	
func _on_tower_removed() -> void:
	#print_rich("[color=lightblue]", get_stack())
	## call update_creep_path which alters the current_id_path
	update_creep_path()
	
##calls the 'impact() function and deducts 'damage' from 'hp' of the BlueTank
func on_hit(damage):
	print("creep.gd -> func on_hit: *****POWPOWPOW***** ---> call impact()")
	##calls the 'impact()' function which plays the impact animation.
	impact()
	##deduct 'damage' from 'hp'
	hp -= damage
	##updates the health_bar value to the current hp value
	health_bar.value = hp
	##call the 'on_destroy()' function if the 'hp' is zero or less.
	if hp <=0:
		##remove the tank from the scene tree
		on_destroy()
##sets a random position of the impact animation on the BlueTank 
##and places the Impact animation there.

##called by the on_hit(damage) function when hp <=0.  Deletes the BlueTank node
func on_destroy():
	##get rid of characterbody2d and its collisionshape2d so that the turret stops firing
	#print("blue_tank.gd -> func on_destroy: blue_tank on_destroy()")
	#get_node("CharacterBody2D").queue_free()
	##keep the tank sprite2ed in the scene a bit longer to let the impact animations finish playing
	await get_tree().create_timer(0.2).timeout
	##remove the tank
	self.queue_free()
	
func impact():
	print_rich("[font_size=15][color=lightred]CREEP.GD - func impact(): ^^^^^^^impact^^^^^^^")
##NOTE the Impact node has a default position offset that we set in the Inspector
##of x:-15, y:-15.  This is the upper right corner of the tank.  
##by randomizing the x and y values to values from 0 to 30 and adding that to the default position
##we get a final position anywhere in a square area of -15,-15 to 15,15 (eg -15 + 30 = 15).
## using similar logic for the 15 px round creep, put the marker in the center and randomize +/- 7	
	
	#randomize() #randomizes the seed of the randi rng only needs to be called once.
	##a random value from -7 to 7.
	var x_pos : int = randi_range(-7, 7)
	#var x_pos : int = randi() % 31 
	var y_pos : int = randi_range(-7, 7)
	#var y_pos : int = randi() % 31
	var impact_location : Vector2 = Vector2 (x_pos, y_pos)
	##instantiate the ProjectileImpact scene - this contains the impact animation SpriteFrames
	var new_impact : Node = projectile_impact.instantiate()
	new_impact.position = impact_location
	##adding a child node 'new_impact' to Marker2D Impact node of BlueTank
	impact_area.add_child(new_impact)
