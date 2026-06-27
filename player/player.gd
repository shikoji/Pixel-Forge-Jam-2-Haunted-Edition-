extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var MOUSE_SENSITIVITY = 0.003

const bob_feq = 2.0
const bob_amp = 0.06
var t_bob = 0.0

var footstep_can_play := true
var footstep_landed

@onready var head=$head
@onready var camera=$head/camera

func _ready() -> void:
	dialogue_manager.display_text("Son", "Father", 1.5)
	dialogue_manager.display_text("Tell me, how was school today?", "Father", 1.5)
	dialogue_manager.display_text("It was alright dad", "Timmy", 2)
	dialogue_manager.display_text("Good to hear Timmy", "Father", 1.5)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	move_and_slide()
	
	#if not footstep_landed and is_on_floor():
		#$footstep_audio.play()
	#elif footstep_landed and not is_on_floor():
		#$footstep_audio.play()
	#footstep_landed = is_on_floor()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_feq) * bob_amp
	pos.x = cos(time * bob_feq /2) * bob_amp
	
	var footstep_threshold = -bob_amp + 0.002
	if pos.y > footstep_threshold:
		footstep_can_play = true
	elif pos.y < footstep_threshold and footstep_can_play:
		footstep_can_play = false
		$footstep_audio.play()
	
	return pos
	
