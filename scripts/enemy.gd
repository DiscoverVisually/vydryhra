extends Area2D

@export var speed: float = 220.0
@export var can_change_depth: bool = false
var vertical_velocity: float = 0.0

func _ready() -> void:
	if can_change_depth:
		vertical_velocity = randf_range(-40.0, 40.0)

func _process(delta: float) -> void:
	position.x -= speed * delta
	if can_change_depth:
		position.y += vertical_velocity * delta
		if position.y < 170 or position.y > 680:
			vertical_velocity *= -1.0
	if position.x < -100:
		queue_free()
