extends Control

## function to call built-in popup() function
func ItemPopup(slot :Vector2i, tower : String):
	## Set values before showing popup

	#var mouse_position = get_viewport().get_mouse_position()
	#var correction
	#var padding  = 4
	#print("slot position = ", slot.position, "; slot.size= ", slot.size, "; %ItemPopup.size = ", %ItemPopup.size)
	#if mouse_position.x <= get_viewport_rect().size.x/2:
		#correction = Vector2i(slot.size.x + padding, 0)
	#else:
		#correction = -Vector2i(%ItemPopup.size.x + padding, 0)
	## .popup(Rect2i(position, size); slot.position is the upper left corner of the slot.
	## the left side correction is the width of the slot, so the final position is 
	## the right side of the slot.
	## the right side correction is the width of the popup.  
	## The popup is shifted left by its width so that it dislays to the left of the slot.
	#%ItemPopup.popup(Rect2i(slot.position + correction, %ItemPopup.size))
	
	if tower == "Gun":
		%Name.text = "Pellet Gun"
		%Description.text = "Cheap Gun that fires pellets"
		%Cost.text = "5"
		%Damage.text = "10"
		%Range.text = "60"
		%Speed.text = "slow"
	elif tower == "Missile":
		%Name.text = "Rocket Launcher"
		%Description.text = "Slow firing tower that does area damage"
		%Cost.text = "20"
		%Damage.text = "8"
		%Range.text = "90"
		%Speed.text = "very slow"
		
	var correction = Vector2i(0, 80)
	%ItemPopup.popup(Rect2i(slot + correction, %ItemPopup.size))
	
func HideItemPopup():
	%ItemPopup.hide() 
