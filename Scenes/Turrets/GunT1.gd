extends "res://Scenes/Turrets/turrets.gd"


func _on_mouse_entered() -> void:
	print_rich("[font_size=15][color=cornsilk]GunT1 _on_mouse_entered Mouse entered GunT1 collision shape")
	print("position = ", position)

func _on_mouse_exited() -> void:
	pass # Replace with function body.
