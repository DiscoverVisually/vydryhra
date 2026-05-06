extends Area2D

enum CollectibleType { FOOD, BONUS }
@export var kind: CollectibleType = CollectibleType.FOOD
@export var speed: float = 180.0

func _process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -100:
		queue_free()
