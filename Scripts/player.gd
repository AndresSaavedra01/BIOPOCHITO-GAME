class_name Player extends CharacterBody3D

# --- ENUMS ---
enum State { WALK, ROLL }

# --- DEPENDENCIAS (Inyectadas desde el Inspector) ---
@export_group("Nodes")
@export var skin: Node3D
@export var dash_particles: GPUParticles3D
@export var camera_controller: Node3D
@export var weapon: WeaponComponent # Referencia al nuevo script/nodo
@export var mark_item_position:  Marker3D

# --- ATRIBUTOS EXPORTADOS ---
@export_group("Movement Stats")
@export var speed: float = 10.0
@export var acceleration: float = 30.0
@export var deceleration: float = 28.0
@export var jump_velocity: float = 9.5
@export var roll_speed: float = 20.0
@export var roll_duration: float = 0.2
@export var push_force: float = 20.0

# --- VARIABLES PRIVADAS (Encapsulamiento) ---
var _current_state: State = State.WALK
var _roll_timer: float = 0.0
var _gravity: float = 20.0

# --- MÉTODOS NATIVOS ---
func _physics_process(delta: float) -> void:
	_apply_gravity(delta)

	match _current_state:
		State.WALK:
			_handle_walking(delta)
		State.ROLL:
			_handle_rolling(delta)
	
	_handle_combat()
	move_and_slide()
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			print(-c.get_normal())
			var push = push_force + velocity.length()
			print(push)
			c.get_collider().apply_central_impulse(-c.get_normal() * push)
			
	

# --- MÉTODOS DE ESTADO ---
func _handle_walking(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down").normalized()
	var move_dir := _get_move_direction(input_dir)
	
	if move_dir != Vector3.ZERO:
		# Calculamos a qué velocidad queremos llegar (velocidad objetivo)
		var target_vel_x := move_dir.x * speed
		var target_vel_z := move_dir.z * speed
		
		# Aceleramos progresivamente desde la velocidad actual hacia la objetivo
		velocity.x = move_toward(velocity.x, target_vel_x, acceleration * delta)
		velocity.z = move_toward(velocity.z, target_vel_z, acceleration * delta)
		print(target_vel_x)
		_rotate_skin(delta, move_dir)
	else:
		# Desaceleramos progresivamente hasta 0 cuando soltamos los controles
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, deceleration * delta)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
			
	if Input.is_action_just_pressed("roll") and is_on_floor():
		_start_roll()

func _start_roll() -> void:
	_current_state = State.ROLL
	_roll_timer = roll_duration # Usamos un temporizador en lugar de 'await'
	
	if dash_particles:
		dash_particles.emitting = true
		
	var dash_direction := -skin.global_transform.basis.z
	velocity = dash_direction * roll_speed

func _handle_rolling(delta: float) -> void:
	# Restamos el tiempo en cada frame de físicas
	_roll_timer -= delta
	
	if _roll_timer <= 0.0:
		velocity.x = move_toward(velocity.x, 0.0, 100 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 100 * delta)
		_current_state = State.WALK

# --- MÉTODOS DE ACCIÓN ---
func _handle_combat() -> void:
	if Input.is_action_just_pressed("shoot") and weapon:
		var target = null
		# Evitamos errores verificando si el nodo tiene la propiedad
		if camera_controller and "currentAimEnemy" in camera_controller:
			target = camera_controller.currentAimEnemy
			
		var default_dir := -skin.global_transform.basis.z
		weapon.shoot(default_dir, target)

# --- MÉTODOS AUXILIARES (Lógica extraída) ---
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	elif velocity.y < 0:
		velocity.y = 0.0

func _get_move_direction(input: Vector2) -> Vector3:
	if not camera_controller:
		return Vector3.ZERO
		
	var forward: Vector3 = camera_controller.get_forward_direction()
	var right: Vector3 = camera_controller.get_right_direction()

	var direction: Vector3 = forward * -input.y + right * input.x
	direction.y = 0.0

	return direction.normalized()

func _rotate_skin(delta: float, move_direction: Vector3) -> void:
	if not skin: return
	var target_rotation := atan2(-move_direction.x, -move_direction.z)
	skin.rotation.y = lerp_angle(skin.rotation.y, target_rotation, 20.0 * delta)
