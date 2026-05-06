extends RefCounted
class_name PlayerRuntime

func move_player(otter: Area2D, delta: float, speed: float, ground_y: float, sky_y: float, water_bottom_y: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		dir.y -= 1.0
	if Input.is_action_pressed("move_down"):
		dir.y += 1.0
	if Input.is_action_pressed("move_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		dir.x += 1.0

	if otter.position.y <= ground_y + 15.0 and Input.is_action_just_pressed("move_up"):
		otter.position.y = max(sky_y, otter.position.y - 85.0)

	if dir != Vector2.ZERO:
		dir = dir.normalized()
	otter.position += dir * speed * delta
	otter.position.x = clamp(otter.position.x, 120.0, 780.0)
	otter.position.y = clamp(otter.position.y, sky_y, water_bottom_y)
