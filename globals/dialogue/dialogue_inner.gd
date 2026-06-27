# DialogueBox.gd
extends Control

@onready var text_label: RichTextLabel = %text
@onready var name_label: Label = $dialogue_canvas/person
@onready var canvas_layer: CanvasLayer = %dialogue_canvas

@export var characters_per_second: float = 30.0
@export var wait_time_after_typing: float = 2.0

var typing_tween: Tween
var dialogue_queue: Array = []
var is_playing: bool = false


func display_text(text_to_display: String, person: String, pitch: float) -> void:
	dialogue_queue.append({"text": text_to_display, "person": person, "pitch": pitch})
	
	if not is_playing:
		_play_next_in_queue()

func _play_next_in_queue() -> void:
	if dialogue_queue.is_empty():
		is_playing = false
		canvas_layer.hide()
		return
		
	is_playing = true
	canvas_layer.show()
	
	var current_line = dialogue_queue.pop_front()
	var text_to_display = current_line["text"]
	var pitch = current_line["pitch"]
	
	text_label.text = text_to_display
	name_label.text = "[" + current_line["person"] + "]"
	text_label.visible_characters = 0
	
	if typing_tween:
		typing_tween.kill()
		
	var total_characters = text_to_display.length()
	var duration = total_characters / characters_per_second
		
	var typing_tween = create_tween()
	typing_tween.tween_property(text_label, "visible_characters", total_characters, duration)


	var time_per_char = duration / total_characters
	$dialogue_canvas/dialogue_sound.pitch_scale = pitch
	for i in range(total_characters):
		typing_tween.parallel().tween_callback($dialogue_canvas/dialogue_sound.play).set_delay(i * time_per_char)


	typing_tween.tween_interval(wait_time_after_typing)
	typing_tween.tween_callback(_play_next_in_queue)
