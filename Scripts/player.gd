extends CharacterBody3D

@onready var camera_controller := $CameraController
@onready var skin := $Skin

@export var SPEED := 8.0
@export var ACCELERATION := 20.0
@export var DECELERATION := 28.0
@export var JUMP_VELOCITY := 4.5

# cuánto afecta la pendiente
@export var UPHILL_SLOWDOWN := 0.35
@export var DOWNHILL_BOOST := 0.45


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var move_direction := get_move_direction(input_dir)

	if move_direction != Vector3.ZERO:
		var current_speed := get_slope_speed(move_direction)
		var target_velocity := move_direction * current_speed

		velocity.x = move_toward(
			velocity.x,
			target_velocity.x,
			ACCELERATION * delta
		)

		velocity.z = move_toward(
			velocity.z,
			target_velocity.z,
			ACCELERATION * delta
		)

		rotate_skin(delta, move_direction)
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0.0, DECELERATION * delta)

	move_and_slide()


func get_move_direction(input: Vector2) -> Vector3:
	var forward: Vector3 = camera_controller.get_forward_direction()
	var right: Vector3 = camera_controller.get_right_direction()

	var direction: Vector3 = forward * -input.y + right * input.x
	direction.y = 0.0

	return direction.normalized()


func get_slope_speed(move_direction: Vector3) -> float:
	var current_speed := SPEED

	if not is_on_floor():
		return current_speed

	var floor_normal := get_floor_normal()

	# dirección cuesta abajo
	var downhill := Vector3.DOWN.slide(floor_normal).normalized()

	# +1 bajando, -1 subiendo
	var slope_dir := move_direction.dot(downhill)

	if slope_dir > 0.0:
		current_speed *= 1.0 + slope_dir * DOWNHILL_BOOST
	else:
		current_speed *= 1.0 + slope_dir * UPHILL_SLOWDOWN

	return current_speed


func rotate_skin(delta: float, move_direction: Vector3) -> void:
	var target_rotation := atan2(-move_direction.x, -move_direction.z)
	skin.rotation.y = lerp_angle(
		skin.rotation.y,
		target_rotation,
		10.0 * delta
	)
