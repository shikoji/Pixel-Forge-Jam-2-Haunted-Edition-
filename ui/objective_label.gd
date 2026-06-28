extends Label

func _ready() -> void:
	global_manager.update_objective.connect(upd_objective)

var current_obj = global_manager.current_objective

func _process(delta: float) -> void:
	if current_obj < global_manager.player_objectives.size():
		self.text = str(global_manager.player_objectives[current_obj])
	else:
		self.text = "all obj finished"

func upd_objective():
	current_obj = current_obj + 1
