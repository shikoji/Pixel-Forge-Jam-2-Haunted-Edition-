extends Resource
class_name item_data

@export var item_name: String
@export var icon: Texture2D = preload("res://icon.svg")
@export_file("*.tscn") var mesh_scene_path: String 
