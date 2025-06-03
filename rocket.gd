extends Area2D
##rocket.tscn
##Area2d (rocket)
	##Sprite2D
	##CollisionShape2D


##SIGNAL
signal rocket_impact	
##a rocket needs a speed and a direction and a target
var speed = 600
var direction : Vector2 = Vector2.RIGHT
var target : Object
var print_flag = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if print_flag: ## DELETE_ME if print_flag ...
		print_rich("[font_size=15][color=Chartreuse]rocket physics process ------------------->")
		#print(name)
		print_flag = false
	if not target:  ## so far there is always a target.
		#print_rich("[font_size=15][color=yellow] =rocket -> physics_process -> if not target .....")
		translate(direction * speed * delta)
		return
	#print_rich("[font_size=15][color=red]rocket -> physics_process -> TARGET ACQUIRED  TARGET ACQUIRED TARGET ACQUIRED")
	##This is the main part of this function: look at target, move towards target
	##and repeat until body_enered SIGNAL 
	look_at(target.global_position)
	position = position.move_toward(target.global_position, speed * delta)
		
##SIGNAL Rocket has a 'body_entered' signal which triggers this function
##SIGNAL This function then emits a 'rocket_impact" signal
##the 'rocket_impact' signal is connected in Turrets.gd to the 'rocket_impacted_something' function


func _on_body_entered(body: Node2D) -> void:
	print("rocket.gd -> func _on_body_entered : ROCKET SIGNAL TRIGGERED")
	print("rocket.gd -> func _on_body_entered : BODY = ", body)
	print("rocket.gd -> func _on_body_entered --> emit_signal('rocket_impact')")
	emit_signal("rocket_impact") ##connected to Turret/rocket_impacted_something
	queue_free()
