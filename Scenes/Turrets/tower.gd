extends Node2D
## define signal
#signal tower_removed
## delete the tower on right click
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	#print("event = ", event)
	if event.is_action_pressed("right_click"):
		print_rich("[color=lightgreen]", get_stack())
		##set the tile to not solid (ie solid = false) and queue_free the tower
		## get the tile position
		var tile = GameData.ground_v1.local_to_map(get_global_mouse_position())
		## set the tile point to 'solid = false'
		GameData.astar_grid_v1.set_point_solid(tile, false)
		## delete the tower
		queue_free()
		## signal that the tower has been deleted.
		GameData.emit_signal("tower_removed")
