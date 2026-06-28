extends Node


signal inventory_changed
signal slot_selected(slot_index: int)
signal item_drop(item)

const hotbar_size := 5
var hotbar: Array[item_data]
var selected_slot: int = 0

func _init() -> void:
	for i in hotbar_size:
		hotbar.append( null )
		
func add_item(item: item_data) -> int:
	for i in hotbar_size:
		if hotbar[i] == null:
			hotbar[i] = item
			inventory_changed.emit()
			slot_selected.emit(i)
			return i
	return -1 
	
func select_slot(index:int):
	print(index)
	selected_slot = clamp(index, 0, hotbar_size - 1)
	slot_selected.emit(selected_slot)
	
func spawn_item(item: Resource):
	var interactable = load(item.mesh_scene_path).instantiate()
	
	interactable.set_meta("item_data", item)
	
	get_tree().current_scene.add_child(interactable)
	item_drop.emit(interactable)
		

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_BACKSPACE:
			drop_item(selected_slot)

func drop_item(slot_index: int):
	if hotbar[slot_index]:
		var dropped_item = hotbar[slot_index]
		spawn_item(dropped_item)
		hotbar[slot_index] = null
		inventory_changed.emit()
		if slot_index == selected_slot:
			slot_selected.emit(selected_slot)
