extends RefCounted
class_name SpawnDirector

var spawn_progress: float = 0.0
var spawn_interval: float = 1.45
var use_seed_mode: bool = false
var seed_value: int = 1337

func configure_seed_mode(enabled: bool, seed: int = 1337) -> void:
	use_seed_mode = enabled
	seed_value = seed
	if use_seed_mode:
		seed(seed_value)

func tick_difficulty() -> void:
	spawn_progress += 1.0
	if spawn_progress < 6:
		spawn_interval = max(1.0, spawn_interval - 0.05)
	elif spawn_progress < 14:
		spawn_interval = max(0.72, spawn_interval - 0.07)
	else:
		spawn_interval = max(0.52, spawn_interval - 0.08)

func roll_spawn_kind() -> String:
	var weights := _phase_weights()
	var roll := randi_range(0, 99)
	if roll < weights.enemy:
		return "enemy"
	elif roll < weights.enemy + weights.food:
		return "food"
	return "bonus"

func phase_name() -> String:
	if spawn_progress < 6:
		return "Early"
	if spawn_progress < 14:
		return "Mid"
	return "Late"

func _phase_weights() -> Dictionary:
	if spawn_progress < 6:
		return {"enemy": 45, "food": 38, "bonus": 17}
	if spawn_progress < 14:
		return {"enemy": 56, "food": 31, "bonus": 13}
	return {"enemy": 64, "food": 27, "bonus": 9}
