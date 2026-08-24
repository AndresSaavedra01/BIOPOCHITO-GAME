extends Marker3D
class_name WeaponComponent

@export var bullet_scene: PackedScene
@export var default_bullet_speed: float = 25.0

func shoot(default_direction: Vector3, target_enemy: Node3D = null) -> void:
	if not bullet_scene:
		push_warning("WeaponComponent: Faltan referencias de bullet_scene")
		return
		
	var new_bullet: Bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(new_bullet)
	
	var final_direction := default_direction
	
	# Si hay un enemigo apuntado, recalculamos la dirección hacia él
	if target_enemy:
		final_direction = (target_enemy.global_position - global_position).normalized()
		
	new_bullet.initialize(global_position, final_direction, default_bullet_speed)
