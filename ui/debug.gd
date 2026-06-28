extends CanvasLayer

@onready var fps_label: Label = $fps
func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
