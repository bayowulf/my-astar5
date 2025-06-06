extends CanvasLayer

##when a tower type button is pressed on the map we want a iso of the tower type to follow under
## the cursor as a visual aid to placing the tower.
func set_tower_preview(tower_type, mouse_position):
	print_rich("[font_size=15][color=peru] set_tower_preview; tower_type = ", tower_type, "; mouse_position = ", mouse_position)
	##the turret tower_type that is currently following the cursor position
	##construct something like this: res://Scenes/Turrets/GunT1.tscn
	var drag_tower : Node = load("res://Scenes/Turrets/" + tower_type + ".tscn").instantiate()
	print_rich("[font_size=15][color=peru]1. drag tower = ", drag_tower)
	##its handy to give the drag_tower node a name of "DragTower" because we will be referencing it every frame as we update 
	##the color as the build location is valid/invalid.
	drag_tower.set_name("DragTower")
	print_rich("[font_size=15][color=peru]2. drag tower = ", drag_tower, "; drag tower ame = ", drag_tower.name)
	##NOTE not sure this line below does anything or it could be  overridden somewhere.
	##commenting it out changes nothing
	#drag_tower.modulate = Color("ad54ff3c")##Green
	
	##
	##setting the range_overlay behavior
	##
	##create a new sprite and offset it so it centers on the tower
	##the purpose is to visually indicate to the player the range of the tower.
	var range_texture : Sprite2D = Sprite2D.new()
	# Actually, it is centered perfectly without the offset - I don't know where this offset comes from.
	#range_texture.position = Vector2(32, 32)
	#scale the size
	#var scaling = tower_range / 600.0
	##600 is the diameter of the asset 'range_overlay.png'  
	##so 'range/600' is the scaling proportion - expected to be between 0 and 1.
	var scaling : float = GameData.tower_data[tower_type]["range"] / 600.0
	##using the 'scaling' variable we can shrink the texture with a diameter of 600
	##down to the correct size according to the range associated with the tower type. 
	range_texture.scale = Vector2(scaling, scaling)
	##load the range_overlay asset. it is a 600 diameter semitransparent cirlce
	var texture : Texture = load("res://Assets/Environment/Tilesets/range_overlay.png")
	range_texture.texture = texture
	##it might be better to make these colors as constants so they are more readable
	range_texture.modulate = Color("ad54ff3c")#Green
	##add a control node and child nodes for drag_tower, range_texture and set position to cursor.
	var control : Control = Control.new()
	print_rich("[font_size=15][color=peru] set_tower_preview; drag_tower = ", drag_tower, "; range_texture = ", range_texture, "; mouse_position = ", mouse_position)

	control.add_child(drag_tower, true)
	control.add_child(range_texture, true)
	control.set_position(mouse_position)
	control.set_name("TowerPreview")
	add_child(control, true)
	#move the node up (index 0) so that it gets rendered behind the other elements.
	move_child(get_node("TowerPreview"), 0)
	print_rich("[font_size=15][color=peru]control = ", control)
	
	
##continuously called by 'update_tower_preview()' in game_scene.gd if we are in build mode.
##moves the Tower_Preview with the cursor and changes its color if different.
func update_tower_preview(new_position : Vector2, color : String):
	#print_rich("[font_size=15][color=cornsilk]update_tower_preview")
	get_node("TowerPreview").set_position(new_position)
	##since this is called every frame while in build mode,
	##only change the color if it is different
	if get_node("TowerPreview/DragTower").modulate != Color(color):
		get_node("TowerPreview/DragTower").modulate = Color(color)
		get_node("TowerPreview/Sprite2D").modulate = Color(color)


func _on_gun_mouse_entered() -> void:
	## I want to reference the location of the 'GUN' button
	print_rich("[font_size=15][color=Goldenrod]gun button position = ", $HUD/BuildBar/Gun.global_position)
	var gun_button_position =  $HUD/BuildBar/Gun.global_position
	Popups.ItemPopup(gun_button_position, "Gun")


func _on_gun_mouse_exited() -> void:
	Popups.HideItemPopup()


func _on_missile_mouse_entered() -> void:
	var missile_button_position = $HUD/BuildBar/Missile.global_position
	Popups.ItemPopup(missile_button_position, "Missile")


func _on_missile_mouse_exited() -> void:
	Popups.HideItemPopup()
