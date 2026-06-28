extends CharacterBody3D

var SPEED = global_manager.player_speed
const JUMP_VELOCITY = global_manager.player_jump_vel
var MOUSE_SENSITIVITY = global_manager.mouse_sense

const ACCELERATION = 8.0
const DECELERATION = 10.0


const bob_feq = global_manager.player_bob_feq
const bob_amp = global_manager.player_bob_amp
var t_bob = 0.0
const BOB_CENTER_SPEED = 5.0 

const LEAN_ANGLE = 1.0
const LEAN_SPEED = 4.0 


var footstep_can_play := true
var footstep_landed := true

var is_sprinting := false

var target_rotation_y: float = 0.0
var target_rotation_x: float = 0.0
var target_lean_z: float = 0.0 
const CAMERA_SMOOTHING = 10.0  

@onready var head = $head
@onready var camera = $head/camera

func _ready() -> void:
	dialogue_manager.display_text("hey there ", "erik", 1.5)
	dialogue_manager.display_text("watcha in here for? ", "erik", 1.5)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	inventory.item_drop.connect(drop_from_player)
	
	target_rotation_y = head.rotation.y
	target_rotation_x = camera.rotation.x

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		target_rotation_y -= event.relative.x * MOUSE_SENSITIVITY
		target_rotation_x -= event.relative.y * MOUSE_SENSITIVITY
		target_rotation_x = clamp(target_rotation_x, deg_to_rad(-40), deg_to_rad(60))

func target_tween(modulate:float):
	var tween: Tween = create_tween()
	tween.tween_property($head/camera/interact_sprite, "modulate:a", modulate, 0.3)

func _physics_process(delta: float) -> void:
	if $head/camera/interact_ray.is_colliding():
		var target = $head/camera/interact_ray.get_collider()
		
		if target and target.has_method("interact"):
			$head/camera/interact_sprite.global_position = target.global_position + Vector3(0, 1, 0)
			$head/camera/interact_sprite.show()
			$head/camera/interact_sprite.modulate.a = 0
			target_tween(1)
			
			if Input.is_action_just_pressed("interact"):
				target.interact()
	else:
		target_tween(0)
				
	head.rotation.y = lerp_angle(head.rotation.y, target_rotation_y, CAMERA_SMOOTHING * delta)
	
	camera.rotation.x = lerp_angle(camera.rotation.x, target_rotation_x, CAMERA_SMOOTHING * delta)
	camera.rotation.z = lerp_angle(camera.rotation.z, target_lean_z, LEAN_SPEED * delta)

	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
		else:
			velocity.y = -0.1
	else:
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	

	if input_dir.x != 0 and is_on_floor():
		target_lean_z = deg_to_rad(-input_dir.x * LEAN_ANGLE)
	else:
		target_lean_z = 0.0
	
	if Input.is_action_pressed("sprint"):
		is_sprinting = true
		SPEED = global_manager.player_speed * 1.4
		camera.fov = lerp(camera.fov, 95.0, 10.0 * delta)
	else:
		is_sprinting = false
		SPEED = global_manager.player_speed
		camera.fov = lerp(camera.fov, 75.0, 10.0 * delta)
	
	var target_cam_pos = Vector3.ZERO
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION * delta)
		velocity.z = lerp(velocity.z, direction.z * SPEED, ACCELERATION * delta)
		
		t_bob += delta * SPEED * float(is_on_floor())
		
		target_cam_pos = _headbob(t_bob, is_sprinting)
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0.0, SPEED * DECELERATION * delta)
		
		t_bob = 0.0
		target_cam_pos = Vector3.ZERO
	
	camera.transform.origin = camera.transform.origin.lerp(target_cam_pos, BOB_CENTER_SPEED * delta)
	
	move_and_slide()
	
	if is_on_floor() and not footstep_landed:
		$landing_audio.play()
	footstep_landed = is_on_floor()

func _headbob(time, is_sprinting: bool) -> Vector3:
	var pos = Vector3.ZERO
	var current_amp = bob_amp
	var current_feq = bob_feq
	
	if is_sprinting:
		current_amp = bob_amp * 1.5 
		current_feq = bob_feq * 1.3 
	
	pos.y = sin(time * current_feq) * current_amp
	
	var side_sway_multiplier = 1.8 if is_sprinting else 1.0
	pos.x = sin(time * (current_feq / 2.0)) * current_amp * side_sway_multiplier
	

	var footstep_threshold = -current_amp + 0.01
	if pos.y > footstep_threshold:
		footstep_can_play = true
	elif pos.y <= footstep_threshold and footstep_can_play:
		footstep_can_play = false
		$footstep_audio.play()
		
	return pos


func drop_from_player(item):
	var look_node: Node3D = camera
	if not look_node:
		look_node = get_viewport().get_camera_3d()
	
	var forward: Vector3
	if look_node:
		forward = -look_node.global_transform.basis.z.normalized()
	else:
		forward = -global_transform.basis.z.normalized()
	
	forward.y = 0
	forward = forward.normalized()
	
	var drop_pos = global_position + (forward * 2.5)
	
	item.global_position = drop_pos
	

	if item is RigidBody3D:
		item.linear_velocity = Vector3.ZERO
		item.angular_velocity = Vector3.ZERO
		
		var toss = (forward * 4.0) + (Vector3.UP * 1.5)
		item.apply_central_impulse(toss)
