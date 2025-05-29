extends Node2D
##This script is not linked to a particular scene.
##it was created by rt click on the Turrets folder and selecting 'create new script'
## by default it extends 'Node' but we changed that to: extends Node2D
##Handles the code for all Towers (Gun, Missile)


## array that holds the Node2d enemy nodes (right now just instances of BlueTank)
##value is set when the 'on_range_body_entered' signal is triggered
var enemy_array : Array = []
##value set to true in  "new_tower.built = true" in GameScene.gd func 'verify_and_build'
var built : bool = false
##value is set in the 'select_enemy' function from the 'enemy_array'
var enemy : Object
##'category' is an entry in the GameData.gd dictionary.
##the variable value is set in 'game_scene,gd' 'Verify_and_build' function
var category : String
var type : String ##this will get a value of 'build_type' in the GameScene.gd 'build_and_verify' function
##a script variable used in the _physics_process function.  its value is set in the 'fire()' function
var readyfreddy = true
var missile_ready = true
##TEST from https://kidscancode.org/godot_recipes/4.x/ai/homing_missile/index.html
@export var missile_speed = 300 ##TEST
var missile_velocity = Vector2.ZERO ##TEST
var missile_acceleration = Vector2.ZERO ##TEST
var last_enemy_looked_at = "" ##TEST used to supress duplicate print outputs
#var duplicate_missile
#@onready var rocket_prefab = preload("res://Scenes/Turrets/rocket.tscn")
var rocket_prefab = preload("res://Scenes/Turrets/Rocket.tscn")


func _ready():
	if built:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.tower_data[type]["range"]
# Add a line: "new_tower.built = true" in GameScene.gd func 'verify_and_build' 
	#duplicate_missile = $Turret/Missile1.duplicate()

##handles Selecting an enemy, turning and firing
func _physics_process(delta: float) -> void:
	if enemy_array.size() != 0 and built:
		select_enemy()
		if not get_node("AnimationPlayer").is_playing():
			turn()
		if readyfreddy:
			fire(delta)
	else:
		enemy = null 
	
func select_enemy():
	var enemy_progress_array = []
	for i in enemy_array:
		enemy_progress_array.append(i.progress) ## Progress is how may pixels enemy has travelled
##Example below:
##print(enemy_progress_array)
##print(enemy_array)
##
##[260.0] <- only one tank in range
##[BlueTank:<PathFollow2D#52042925454>] <- this one is only tank in range
##[262.5, 157.5] <- two tanks in range
##[BlueTank:<PathFollow2D#52042925454>, BlueTank2:<PathFollow2D#53619983756>] <-these two are in range
## note: the index of the max progress tank (index = 0 in this case) also identifies the enemy tank to target in the enemy_array (index = 0)
##
	var max_offset : float = enemy_progress_array.max()
	var enemy_index : int = enemy_progress_array.find(max_offset)
	
	enemy = enemy_array[enemy_index]
	#print("Turrets.gd func select_enemy: enemy.name = ", enemy.name)
	#print("last_enemy_looked_at = ", last_enemy_looked_at)
	if not enemy.name == last_enemy_looked_at:
		print('Turrets.gd func select_enemy: -> ', enemy)
		last_enemy_looked_at = enemy.name ##TEST
	##NOTE type_string(typeof())  useful in debugging
	#print("type_string(enemy) = ", type_string(typeof(enemy)))
	
#using the 'look_at' method of the 'Turret' node (Sprite2d) to make the Turret face the enemy position.
func turn():
	##"Turret" refers to the 'GunT1' or 'MissileT1', etc "turret" node - see GunT1 scene for example.
	get_node("Turret").look_at(enemy.position)
	if not enemy.name == last_enemy_looked_at:
		print("Turret turn to look at enemy")
	
##Handles firing for gun or missile and calls enemy.on_hit function of BlueTank (the only enemy type so far)
func fire(delta):
	print("Turrets.gd fire()")
	readyfreddy = false
	
	if category == "Projectile":
		fire_gun()
		enemy.on_hit(GameData.tower_data[type]["damage"])
		##creating a timer that waits for the amount of time specified in the 'rof' variable
		await(get_tree().create_timer(GameData.tower_data[type]["rof"]).timeout)
		readyfreddy = true
	elif category == "Missile":
		if missile_ready:
			fire_missile(delta)
			
		#readyfreddy = true
	##'enemy' is a specific instance of, for example, BlueTank which has an 'on_hit(damage) function.
	##TODO any additional enemies should have this function: on_hit(damaage) as well. 
	##TODO all enemies should inherit from an Enemies.gd script, using blue_tank.gd as a template.
	
#The await keyword functions the exact same way the old yield keyword does.
# The only thing that changes here is the syntax.
#Before you would use:
#yield(get_tree().create_timer(1.0), "timeout")
#var value = yield(some_function(), "completed")
#Now you simply use:
#await get_tree().create_timer(1.0).timeout
#var value = await some_function()

##plays the 'fire' animation
func fire_gun():
	##'Fire' animation setup in GunT1 scene/Inspector
	##note this is a different method of animating than used for the AnimatedSprite animations for 'Impact'.
	get_node("AnimationPlayer").play("Fire")
	
##TODO set up an AnimationPlayer for 'fire_millse' fuction
func fire_missile(_delta):
	#var rocket : Node = load("res://Scenes/Turrets/MissileT1.tscn").instantiate()
##alternate launching missile1 and Missile2 - maybe a toggle variable will work for this
##Launching a missile will consist of 1. moving the missile forward a short distance
##2.point towards enemy 3. update current direction to desired direction 4.repeat until missile enters the collisionshape2d of the enemy tank
	print("Turrets.gd func fire_missile()")
	missile_ready = false
	var rocket = rocket_prefab.instantiate()
	rocket.connect("rocket_impact", _rocket_impacted_something)
	rocket.position = global_position
	rocket.target = enemy
	get_tree().root.add_child(rocket)
	#rocket.position = rocket.position.move_toward(enemy.global_position, missile)
	
	
	#duplicate_missile = $Turret/Missile1.duplicate()
	
	#missile_turn()
	#$Turret/Missile1.position = $Turret/Missile1.position.move_toward(enemy.global_position, missile_speed * delta)
	#print("Turrets.gd: func fire_missilee: Missile1.position = ", $Turret/Missile1.position )

		
#func missile_turn():
	#$Turret/Missile1.look_at(enemy.position)
	#print("Turrets.gd: func Missile Turn")
	
	
	#
#func _on_body_entered(body: Node2D) -> void:
	#print("ROCKET SIGNAL TRIGGERED")
	#enemy.on_hit(GameData.tower_data[type]["damage"])
###creating a timer that waits for the amount of time specified in the 'rof' variable
	#await(get_tree().create_timer(GameData.tower_data[type]["rof"]).timeout)
	#missile_ready = true


##Missile1 SIGNAL
#func _on_missile_1_body_entered(_body: Node2D) -> void:
	#print("********Turrets.gd: on missile1 body entered")
	#enemy.on_hit(GameData.tower_data[type]["damage"])
	###creating a timer that waits for the amount of time specified in the 'rof' variable
	#await(get_tree().create_timer(GameData.tower_data[type]["rof"]).timeout)
	#readyfreddy = true
	#$Turret/Missile1.queue_free()
	
	
##Range SIGNAL 
func _on_range_body_entered(body: Node2D) -> void:
	enemy_array.append(body.get_parent())

##Range SIGNAL
func _on_range_body_exited(body: Node2D) -> void:
	enemy_array.erase(body.get_parent())
	
##SIGNAL
func _rocket_impacted_something():
	print("Turrets.gd -> func _rocket_impacted_something() -> SIGNAL CONNECTED ROCKET IMPACTED SOMETHING - LAUNCH enemy.on_hit")
	enemy.on_hit(GameData.tower_data[type]["damage"])
