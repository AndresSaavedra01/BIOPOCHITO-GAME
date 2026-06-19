extends CharacterBody3D

@onready var skin := $Skin
@onready var camera_controller := $"../CameraController"
@onready var start_point_projectils := $Skin/Marker3D
const BULLET_SCENE = preload("res://Escenas/proyectil.tscn")

@export var SPEED := 10.0
@export var ACCELERATION := 20.0
@export var DECELERATION := 28.0
@export var JUMP_VELOCITY := 9.5
enum states {WALK, ROLL}
var current_state = states.WALK

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		if velocity.y < 0:
			velocity.y = 0

	match current_state:
		states.WALK:
			handle_walking(delta)
		states.ROLL:
			handle_rolling(delta)
	
	if Input.is_action_just_pressed("shoot"):
		if camera_controller.currentAimEnemy == null:
			launch_projectil(-skin.global_transform.basis.z, 25.0)
		else: 
			print(camera_controller.currentAimEnemy)
			launch_projectil(-start_point_projectils.global_position + camera_controller.currentAimEnemy.global_position, 25.0)
	
	move_and_slide()


func handle_walking(delta: float):
	var input_dir := Input.get_vector("left", "right", "up", "down").normalized()
	var move_dir := get_move_direction(input_dir)
	
	if move_dir != Vector3.ZERO:
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED

		rotate_skin(delta, move_dir)
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0.0, DECELERATION * delta)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("roll"):
			current_state = states.ROLL



func handle_rolling(delta):
	if is_on_floor():
		$Skin/GPUParticles3D.emitting = true
		var dash_direction = -skin.global_transform.basis.z
		velocity = dash_direction * 20
		await get_tree().create_timer(.2).timeout
		velocity.x = move_toward(velocity.x, 0.0, 100 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 100 * delta)
		
	current_state = states.WALK
	

func launch_projectil(direction: Vector3, speed: float):
	var new_proyectil :Bullet = BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(new_proyectil)
	new_proyectil.initialize(start_point_projectils.global_position, direction.normalized(), speed)

func get_move_direction(input: Vector2) -> Vector3:
	var forward: Vector3 = camera_controller.get_forward_direction()
	var right: Vector3 = camera_controller.get_right_direction()

	var direction: Vector3 = forward * -input.y + right * input.x
	direction.y = 0.0

	return direction.normalized()

func rotate_skin(delta: float, move_direction: Vector3) -> void:
	var target_rotation := atan2(-move_direction.x, -move_direction.z)
	skin.rotation.y = lerp_angle(
		skin.rotation.y,
		target_rotation,
		20.0 * delta
	)
