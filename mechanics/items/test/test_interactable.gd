extends RigidBody3D

@export var data: item_data

func interact():
	if inventory.add_item(data):
		call_deferred("queue_free")
	else:
		print("full inv")
