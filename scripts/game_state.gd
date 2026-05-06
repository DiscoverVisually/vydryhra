extends Node

const OTTER_COLORS := [
	Color("8c6b48"), Color("7c5b3f"), Color("a67f58"), Color("5f4a33"),
	Color("8a5634"), Color("9f7547"), Color("6f5337"), Color("b0875f")
]

var selected_otter: int = 0
var best_score: int = 0
var last_run_summary: String = ""

func _ready() -> void:
	SaveManager.load_data()

func get_selected_color() -> Color:
	return OTTER_COLORS[selected_otter % OTTER_COLORS.size()]

func register_score(score: int) -> void:
	best_score = max(best_score, score)
	SaveManager.save_data()
