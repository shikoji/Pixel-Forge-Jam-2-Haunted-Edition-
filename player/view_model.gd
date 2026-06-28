extends Node3D

var current_item_instance: Node3D = null

func _ready():
	inventory.slot_selected.connect(_update_held_item)



func clear_item():
	if current_item_instance:
		remove_child(current_item_instance)
		current_item_instance.queue_free()  
		current_item_instance = null

func _physics_process(_delta):
	var camera_node = get_node_or_null("../head/camera")
	if camera_node:
		global_transform = camera_node.global_transform	
		
func show_item(item_dat: item_data):
	clear_item()
	if item_dat and item_dat.mesh_scene_path:
		var loaded_scene = load(item_dat.mesh_scene_path)
		if loaded_scene:
			var new_instance = loaded_scene.instantiate()
			
			if new_instance.get_parent():
				new_instance.get_parent().remove_child(new_instance)
				
			current_item_instance = new_instance
			current_item_instance.position = Vector3(0.3, -0.2, -0.5)
			current_item_instance.rotation = Vector3.ZERO
			
			add_child(current_item_instance)
		
func _update_held_item(slot_index: int):
	var item = inventory.hotbar[slot_index]
	if item:
		show_item(item)
	else:
		clear_item() 
