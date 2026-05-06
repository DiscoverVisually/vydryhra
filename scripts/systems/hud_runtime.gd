extends RefCounted
class_name HudRuntime

func update_hud(hud: Control, score: int, health: int, oxygen: float, zone_name: String, shield_hits: int, slow_time_seconds: float, phase_name: String, spawn_interval: float, entity_count: int, debug_enabled: bool) -> void:
	hud.get_node("Score").text = "Skóre: %d" % score
	hud.get_node("Lives").text = "Životy: %d" % health
	hud.get_node("Oxygen").text = "Kyslík: %d%%" % int(oxygen)
	hud.get_node("Depth").text = "Zóna: %s" % zone_name
	hud.get_node("Shield").text = "Štít: %d" % shield_hits
	hud.get_node("TimeFx").text = "Spomalenie: %.1fs" % slow_time_seconds
	hud.get_node("Debug").visible = debug_enabled
	hud.get_node("Debug").text = "DEBUG | Phase: %s | Spawn: %.2f | Entít: %d" % [phase_name, spawn_interval, entity_count]
