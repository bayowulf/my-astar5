extends Node2D

@onready var player: Node2D = $"../player"

func _process(_delta):
	queue_redraw()
	
func draw():
	print("path.ge:_draw()")
	if player.current_point_path.is_empty():
		return
		
	draw_polyline(player.current_point_path, Color.BLUE)
	
