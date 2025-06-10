extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	TestEsc()

func resume() -> void:
	get_tree().paused = false
	
func pause() -> void:
	get_tree().paused = true
	
func TestEsc() -> void:
	if Input.is_action_just_pressed("ui_cancel") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("ui_cancel") and get_tree().paused == true:
		resume()
		
		

func _on_button_start_pressed() -> void:
	print_rich("[font_size=15][color=tomato]func _on_button_start_pressed() text = ", %ButtonStart.text)
	##i want to : 1. make_enemies(), 2. change the button text to 'PAUSE'.
	## IF button is pressed and text is 'PAUSED': 1. pause the game and 2. change
	## button text to "RESUME" AND 3. DISPLAY A POPUP "PAUSED".
	## IF BUTTON is pressed and text is 'RESUME': 1. change text to 'PAUSED'
	## and 2. unpause the game.
	var world_var = get_node("/root/World")
	
	if %ButtonStart.text == "START":
		print_rich("[font_size=15][color=tomato]if %ButtonStart.text == START:")
		

		%ButtonStart.text = "PAUSE"
		## i don't want to create a new instance of World
		#var new_world = World.new()
		#new_world.make_enemy(new_world.marker_number)
		
		world_var.make_enemy()
	elif %ButtonStart.text == "PAUSE":
		print_rich("[font_size=15][color=tomato]elif %ButtonStart.text == PAUSED:")

		%ButtonStart.text = "RESUME"
		%PopupPanelPaused.visible = true
		get_tree().paused = true
	elif %ButtonStart.text == "RESUME":
		print_rich("[font_size=15][color=tomato]elif %ButtonStart.text == RESUME:")
		%PopupPanelPaused.visible = false
		%ButtonStart.text = "PAUSE"
		get_tree().paused = false
		
	


func _on_button_send_next_wave_pressed() -> void:
	## send next wave: for now just call make_enemy function
	## TODO eventually I will make a proper wave generator
	%ButtonStart.text = "PAUSE"
	var world_var = get_node("/root/World")
	world_var.make_enemy()


func _on_button_reset_pressed() -> void:
	## reload the scene
	%ConfirmationDialogReset.visible = true
	
	


func _on_confirmation_dialog_reset_confirmed() -> void:
	get_tree().reload_current_scene()


func _on_confirmation_dialog_reset_canceled() -> void:
	%ConfirmationDialogReset.visible = false
	
