extends HBoxContainer

var slots: Array

func _ready():
	get_slots()
	inventory.inventory_changed.connect(_update_hotbar)
	inventory.slot_selected.connect(_highlight_slot)
	_update_hotbar()

func get_slots():
	slots = get_children()
	for slot : TextureButton in slots:
		slot.pressed.connect(inventory.select_slot.bind(slot.get_index()))
		
func _update_hotbar():
	for node in slots:
		var slot = node as TextureButton
		if not slot: 
			continue
			
		slot.ignore_texture_size = true
		slot.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			
		var index = slot.get_index()
		if index < inventory.hotbar.size():
			var item = inventory.hotbar[index]
			slot.texture_normal = item.icon if item else null
		else:
			slot.texture_normal = null
		
func _highlight_slot(slot_index:int):
	for i in range(5):
		slots[i].modulate = Color(1,1,1)
	slots[slot_index].modulate = Color(1.5,1.5,1.5)
