extends CharacterBody3D

@onready var camera_controller := $CameraController
@onready var skin := $Skin

const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	var input_dir := Input.get_vector("left", "right", "up", "down")	
	var move_direction =  get_move_direction(input_dir);
	
	if move_direction:
		velocity.x = move_direction.x * SPEED
		velocity.z = move_direction.z * SPEED
		rotate_skin(delta, move_direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	

func get_move_direction(input: Vector2) -> Vector3:
	var forward = camera_controller.get_forward_direction()
	var right = camera_controller.get_right_direction()
	
	return (forward * -input.y + right * input.x).normalized()

func rotate_skin(delta: float, move_direction: Vector3):
	var target_rotation = atan2(-move_direction.x, -move_direction.z)
	var new_direction = lerp_angle(skin.rotation.y, target_rotation, 10 * delta)
	skin.rotation.y = new_direction
