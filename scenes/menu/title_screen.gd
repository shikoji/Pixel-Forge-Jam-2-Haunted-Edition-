extends Node3D

const PRISON_SCENE := "res://scenes/prison/prison.tscn"

@onready var camera: Camera3D = $Camera3D
@onready var start_button: Button = $MenuLayer/Root/Menu/StartButton
@onready var quit_button: Button = $MenuLayer/Root/Menu/QuitButton

var _time := 0.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	camera.current = true
	start_button.pressed.connect(_start_game)
	quit_button.pressed.connect(_quit_game)
	start_button.grab_focus()


func _process(delta: float) -> void:
	_time += delta
	camera.position.x = sin(_time * 0.25) * 0.12
	camera.rotation.y = sin(_time * 0.18) * 0.018


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_start_game()


func _start_game() -> void:
	get_tree().change_scene_to_file(PRISON_SCENE)


func _quit_game() -> void:
	get_tree().quit()
