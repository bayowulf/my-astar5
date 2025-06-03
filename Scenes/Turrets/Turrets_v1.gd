extends Node2D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	turn()
	
func turn():
	var enemy_position = get_global_mouse_position()
	get_node("Turret").look_at(enemy_position)
