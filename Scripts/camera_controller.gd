extends Node3D

@export var aim_speed := 4
@export var suavizado_horizontal: float = 0.1
@export var suavizado_vertical: float = 0.05
@export var mouse_sensibility := 0.003 
@export var joystick_sensibility := .05 
@export var player : CharacterBody3D
@onready var spring_arm := $SpringArm3D
@onready var camera := $SpringArm3D/Camera3D
@onready var aimSprite := $"../../Control/AimEyeBurn3"

var h_rotation := 0.0
var v_rotation := 0.0
var manual_mov = false
var currentAimEnemy = null
var is_aim = false

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
	
	if stick.length() > 0.05 :
		manual_mov = true
		apply_rotation(stick * joystick_sensibility, 1.0) 
	else:
		manual_mov = false

	if !manual_mov and !is_aim:
		if Input.is_action_pressed("left"): apply_rotation(Vector2(-15, 0), 0.001)
		if Input.is_action_pressed("right"): apply_rotation(Vector2(15, 0), 0.001)
	
	aimAtEnemy(delta)
	


func aimAtEnemy(delta: float):
	is_aim = Input.is_action_pressed("aim")
	if is_aim:
		if currentAimEnemy == null:
			currentAimEnemy = findBestEnemyToAim()
		if currentAimEnemy != null:
			
			look_at_enemy(currentAimEnemy, delta)
			aimSprite.visible = true
			aimSprite.global_position = camera.unproject_position(currentAimEnemy.global_position)
	else:
		aimSprite.visible = false
		currentAimEnemy = null
		return

func look_at_enemy(enemy: CharacterBody3D, delta: float):
	# 1. calcular angulo horizontal hacia el enemigo
	var dirToEnemy = enemy.global_position - global_position
	var target_h = atan2(-dirToEnemy.x, -dirToEnemy.z)
	
	# 2. calcular angulo vertical desde el SpringArm
	var diff_to_spring_arm = enemy.global_position - spring_arm.global_position
	var flat_distance = Vector2(diff_to_spring_arm.x, diff_to_spring_arm.z).length()
	var target_v = -atan2(diff_to_spring_arm.y, flat_distance)
	
	h_rotation = lerp_angle(h_rotation, target_h, aim_speed * delta)
	v_rotation = lerp(v_rotation, -target_v, aim_speed * delta)
	
	rotation.y = h_rotation
	spring_arm.rotation.x = clamp(v_rotation, deg_to_rad(-45), deg_to_rad(55))


func findBestEnemyToAim() -> CharacterBody3D:
	var enemies =  get_tree().get_nodes_in_group("Enemies")
	if enemies.is_empty():
		return null
	var bestEnemy = null
	var bestScore = -1.0
	var cam_forward = -camera.global_transform.basis.z
	var cam_pos = camera.global_position
	
	for e in enemies:
		var dirToEnemy = (e.global_position - cam_pos)
		if dirToEnemy.length() > 30.0:
			continue
		var alig = cam_forward.dot(dirToEnemy.normalized())
		
		if alig > 0.5:
			var distScore = 1.0 / cam_pos.distance_to(e.global_position)
			print(distScore)
			var score =  alig + distScore
			if score > bestScore:
				bestScore = score
				bestEnemy = e
	
	return bestEnemy

func apply_rotation(input_vector: Vector2, sensitivity: float) -> void:
		h_rotation -= input_vector.x * sensitivity
		rotation.y = h_rotation
		v_rotation -= input_vector.y * sensitivity
		spring_arm.rotation.x = clamp(v_rotation, deg_to_rad(-45), deg_to_rad(55))
	

func get_forward_direction() -> Vector3:
	return -camera.global_transform.basis.z


func get_right_direction() -> Vector3:
	return camera.global_transform.basis.x 
