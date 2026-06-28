
extends RigidBody3D

@export var data: Resource


func interact(player, camera: Camera3D, slot_screen_pos: Vector2):
	if is_queued_for_deletion():
		return

	freeze = true
	$CollisionShape3D.disabled = true
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free.call_deferred)
	
