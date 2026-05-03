extends Node3D

@export var sensibility := 0.002
@onready var spring_arm :=  $SpringArm3D
@onready var camera := $SpringArm3D/Camera3D

var h_rotation := 0.0
var v_rotation := 0.0

func _ready() -> void:
	Input.mouse_mode =  Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_camera(event.relative)
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func rotate_camera(mouse_delta):
	h_rotation -= mouse_delta.x * sensibility
	rotation.y =  h_rotation
	
	v_rotation -= mouse_delta.y * sensibility
	spring_arm.rotation.x = clamp(v_rotation, -1, 1)
	

func get_forward_direction() -> Vector3:
	return -camera.global_transform.basis.z

func get_right_direction() -> Vector3:
	return camera.global_transform.basis.x
