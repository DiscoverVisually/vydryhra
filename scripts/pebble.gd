extends Area2D

@export var speed: float = 650.0

func _process(delta: float) -> void:
	position.x += speed * delta
	if position.x > 1400:
		queue_free()
