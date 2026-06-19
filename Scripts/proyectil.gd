extends Node3D
class_name  Bullet

@onready var raycast := $RayCast3D
@export var lifetime := 1.0
var speed := 8.0
var bullet_velocity := Vector3.ZERO
var age := 0.0
var shoot_direction := Vector3.ZERO
var gravity : Vector3

func _ready() -> void:
	gravity = Vector3(0, -5, 0)
	

func initialize(start_position: Vector3, direction: Vector3, init_speed: float ) -> void:
	global_position = start_position
	shoot_direction = direction
	bullet_velocity = shoot_direction * init_speed
	speed = init_speed


func _physics_process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
		return
	
	bullet_velocity += gravity * delta
	var mov_distance = bullet_velocity.length() * delta
	raycast.target_position = bullet_velocity.normalized() * mov_distance
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		global_position = raycast.get_collision_point()
		queue_free()
		return
	
	global_position += bullet_velocity * delta
	
