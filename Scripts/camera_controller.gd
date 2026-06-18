extends Node3D

@export var suavizado_horizontal: float = 0.1
@export var suavizado_vertical: float = 0.05
@export var mouse_sensibility := 0.003 # Ajustado para mouse
@export var joystick_sensibility := .05  # Ajustado para joystick (es un multiplicador de rotación)
@export var player : CharacterBody3D
@onready var spring_arm := $SpringArm3D
@onready var camera := $SpringArm3D/Camera3D

var h_rotation := 0.0
var v_rotation := 0.0
var manual_mov = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		manual_mov = true
		apply_rotation(event.relative, mouse_sensibility)

	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	if player:
		var target_pos = player.global_position
		global_position.x = lerp(global_position.x, target_pos.x, suavizado_horizontal)
		global_position.z = lerp(global_position.z, target_pos.z, suavizado_horizontal)
		global_position.y = lerp(global_position.y, target_pos.y, suavizado_vertical)
	var stick := Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	
	if stick.length() > 0.05:
		manual_mov = true
		apply_rotation(stick * joystick_sensibility, 1.0) 
	else:
		manual_mov = false

	if !manual_mov:
		if Input.is_action_pressed("left"): apply_rotation(Vector2(-10, 0), 0.001)
		if Input.is_action_pressed("right"): apply_rotation(Vector2(10, 0), 0.001)

func apply_rotation(input_vector: Vector2, sensitivity: float) -> void:
	h_rotation -= input_vector.x * sensitivity
	rotation.y = h_rotation

	v_rotation -= input_vector.y * sensitivity
	spring_arm.rotation.x = clamp(v_rotation, deg_to_rad(-45), deg_to_rad(55))
	

func get_forward_direction() -> Vector3:
	return -camera.global_transform.basis.z


func get_right_direction() -> Vector3:
	return camera.global_transform.basis.x 
