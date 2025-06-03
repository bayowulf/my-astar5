extends AnimatedSprite2D
##ProjectileImpact scene/projectile_impact.gd
##Plays Impact animation

## Called when the node enters the scene tree for the first time.
##Play the AnimatedSprite2D animation named 'Impact'
##select the 'ProjectileImpact scene.  The SpriteFrames animation is
##managed via the Inspector 
func _ready() -> void:
	play("Impact")

##SIGNAL 
##Function called when Signal emitted when THE AnimationSprite2D  animation is finished 
func _on_animation_finished() -> void:
	queue_free()
