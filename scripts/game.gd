extends Node2D

const MAX_HEALTH := 3
const MAX_OXYGEN := 100.0
const BASE_OXYGEN_DRAIN_RATE := 8.0
const OXYGEN_REFILL_RATE := 24.0
const GROUND_Y := 220.0
const SURFACE_Y := 280.0
const SKY_Y := 110.0
const WATER_BOTTOM_Y := 690.0

const LAYERS := {
	"sky": Vector2(0, 100),
	"ground": Vector2(100, 220),
	"water_1": Vector2(220, 300),
	"water_2": Vector2(300, 380),
	"water_3": Vector2(380, 460),
	"water_4": Vector2(460, 540),
	"water_5": Vector2(540, 720)
}

@onready var otter := $Otter
@onready var hud := $CanvasLayer/HUD
@onready var spawn_timer := $SpawnTimer
@onready var difficulty_timer := $DifficultyTimer
@onready var layers := $Layers

var health := GameBalance.MAX_HEALTH
var oxygen := GameBalance.MAX_OXYGEN
var score := 0
var speed := GameBalance.PLAYER_SPEED
var throw_cooldown := GameBalance.THROW_COOLDOWN
var throw_timer := 0.0
var max_pebbles := GameBalance.MAX_PEBBLES
var active_pebbles := 0
var game_over := false
var spawn_interval := GameBalance.START_SPAWN_INTERVAL
var bg_scroll_x := 0.0
var shield_hits := 0
var slow_time_seconds := 0.0
var spawn_progress := 0.0
var director := SpawnDirector.new()
var paused := false
var run_time := 0.0
var max_depth := 0.0
var hits_taken := 0
var player_runtime := PlayerRuntime.new()
var hud_runtime := HudRuntime.new()

func _ready() -> void:
	randomize()
	director.configure_seed_mode(true, 1337)
	otter.get_node("Visual").color = GameState.get_selected_color()
	otter.collision_layer = 1
	otter.collision_mask = 4 | 16
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()
	difficulty_timer.start()
	_update_hud()

func _process(delta: float) -> void:
	_scroll_background(delta)
	if game_over:
		if Input.is_action_just_pressed("confirm"):
			get_tree().reload_current_scene()
		return

	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_pause()
	if paused:
		return

	throw_timer = max(throw_timer - delta, 0.0)
	slow_time_seconds = max(0.0, slow_time_seconds - delta)
	player_runtime.move_player(otter, delta, speed, GROUND_Y, SKY_Y, WATER_BOTTOM_Y)
	_update_oxygen(delta)
	run_time += delta
	max_depth = max(max_depth, otter.position.y)
	score += int((12 + spawn_progress) * delta)
	_update_hud()

func _scroll_background(delta: float) -> void:
	bg_scroll_x += 35.0 * delta
	if bg_scroll_x > 1280.0:
		bg_scroll_x = 0.0
	layers.position.x = -bg_scroll_x * 0.08

func _update_oxygen(delta: float) -> void:
	var drain := GameBalance.OXYGEN_DRAIN_BASE + (spawn_progress * 0.18)
	oxygen -= drain * delta
	if otter.position.y <= SURFACE_Y:
		oxygen += OXYGEN_REFILL_RATE * delta
	oxygen = clamp(oxygen, 0.0, GameBalance.MAX_OXYGEN)
	if oxygen <= 0.0:
		_end_game("Došiel kyslík")

func _spawn_pebble() -> void:
	var pebble := Area2D.new()
	pebble.collision_layer = 8
	pebble.collision_mask = 4
	pebble.set_script(load("res://scripts/pebble.gd"))
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8
	shape.shape = circle
	var visual := ColorRect.new()
	visual.color = Color(0.75, 0.75, 0.78)
	visual.size = Vector2(12, 12)
	visual.position = Vector2(-6, -6)
	pebble.add_child(shape)
	pebble.add_child(visual)
	pebble.position = otter.position + Vector2(24, 0)
	$Projectiles.add_child(pebble)
	active_pebbles += 1
	pebble.tree_exited.connect(func(): active_pebbles = max(active_pebbles - 1, 0))
	pebble.area_entered.connect(_on_pebble_hit)

func _on_pebble_hit(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		area.queue_free()
		score += 30

func _on_spawn_timer_timeout() -> void:
	var kind := director.roll_spawn_kind()
	if kind == "enemy":
		_spawn_enemy()
	elif kind == "food":
		_spawn_food()
	else:
		_spawn_bonus()

func _spawn_enemy() -> void:
	var y := _pick_enemy_y()
	var enemy := Area2D.new()
	enemy.collision_layer = 4
	enemy.collision_mask = 1
	enemy.set_script(load("res://scripts/enemy.gd"))
	enemy.add_to_group("enemy")
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(42, 24)
	shape.shape = rect
	var visual := ColorRect.new()
	visual.color = _enemy_color_for_height(y)
	visual.size = rect.size
	visual.position = -rect.size / 2.0
	enemy.add_child(shape)
	enemy.add_child(visual)
	enemy.position = Vector2(1360, y)
	enemy.can_change_depth = y > LAYERS.water_2.x and randf() < 0.35
	if slow_time_seconds > 0.0:
		enemy.speed *= 0.6
	$Entities.add_child(enemy)
	enemy.area_entered.connect(_on_entity_entered.bind(enemy))

func _spawn_food() -> void:
	var y := randf_range(LAYERS.water_1.x + 8, LAYERS.water_5.y - 20)
	_spawn_collectible(Color(0.25, 0.8, 0.35), "food", y)

func _spawn_bonus() -> void:
	var y := randf_range(LAYERS.water_2.x + 8, LAYERS.water_5.y - 30)
	_spawn_collectible(Color(0.7, 0.35, 0.9), "bonus", y)

func _spawn_collectible(color: Color, kind: String, y: float) -> void:
	var item := Area2D.new()
	item.collision_layer = 16
	item.collision_mask = 1
	item.set_script(load("res://scripts/collectible.gd"))
	item.add_to_group(kind)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 11
	shape.shape = circle
	var visual := ColorRect.new()
	visual.color = color
	visual.size = Vector2(18, 18)
	visual.position = Vector2(-9, -9)
	item.add_child(shape)
	item.add_child(visual)
	item.position = Vector2(1360, y)
	if slow_time_seconds > 0.0:
		item.speed *= 0.7
	$Entities.add_child(item)
	item.area_entered.connect(_on_entity_entered.bind(item))

func _pick_enemy_y() -> float:
	if randf() < 0.35:
		return randf_range(LAYERS.ground.x + 6, LAYERS.ground.y - 6)
	return randf_range(LAYERS.water_1.x + 10, LAYERS.water_5.y - 20)

func _enemy_color_for_height(y: float) -> Color:
	if y < LAYERS.ground.y:
		return Color(0.75, 0.25, 0.2)
	return Color(0.85, 0.15, 0.3)

func _on_entity_entered(area: Area2D, entity: Area2D) -> void:
	if area != otter:
		return
	if entity.is_in_group("enemy"):
		if shield_hits > 0:
			shield_hits -= 1
		else:
			health -= 1
			hits_taken += 1
		entity.queue_free()
		if health <= 0:
			_end_game("Vydra prehrala")
	elif entity.is_in_group("food"):
		score += 18
		oxygen = min(oxygen + GameBalance.FOOD_OXYGEN_GAIN, GameBalance.MAX_OXYGEN)
		entity.queue_free()
	elif entity.is_in_group("bonus"):
		_apply_random_bonus()
		score += 45
		entity.queue_free()

func _apply_random_bonus() -> void:
	if randf() < 0.5:
		shield_hits = min(shield_hits + 2, GameBalance.SHIELD_MAX)
	else:
		slow_time_seconds = 8.0

func _on_difficulty_timer_timeout() -> void:
	director.tick_difficulty()
	spawn_progress = director.spawn_progress
	spawn_interval = max(GameBalance.MIN_SPAWN_INTERVAL, director.spawn_interval)
	spawn_timer.wait_time = spawn_interval

func _end_game(reason: String) -> void:
	game_over = true
	spawn_timer.stop()
	difficulty_timer.stop()
	GameState.register_score(score)
	GameState.last_run_summary = "Dôvod: %s\nSkóre: %d\nNajlepšie: %d\nČas: %.1fs\nMax hĺbka: %.0f\nZásahy: %d" % [reason, score, GameState.best_score, run_time, max_depth, hits_taken]
	get_tree().change_scene_to_file("res://scenes/results_screen.tscn")

func _update_hud() -> void:
	hud_runtime.update_hud(hud, score, health, oxygen, _zone_name(otter.position.y), shield_hits, slow_time_seconds, director.phase_name(), spawn_interval, $Entities.get_child_count(), SaveManager.debug_enabled)

func _zone_name(y: float) -> String:
	if y < LAYERS.ground.x:
		return "Nebo"
	if y < LAYERS.ground.y:
		return "Súš"
	if y < LAYERS.water_2.x:
		return "Plytčina"
	if y < LAYERS.water_3.x:
		return "Vrstva 2"
	if y < LAYERS.water_4.x:
		return "Vrstva 3"
	if y < LAYERS.water_5.x:
		return "Vrstva 4"
	return "Hlbina"


func _toggle_pause() -> void:
	paused = !paused
	get_tree().paused = paused
	hud.get_node("Pause").visible = paused
