extends RigidBody3D
class_name  Physical_object

var mark: Marker3D = null


func _process(delta: float) -> void:
	if mark != null:
		freeze = true
		global_position = mark.global_position
		global_rotation = mark.global_rotation

func be_collect(_mark: Marker3D):
	mark = _mark

func be_launch(direction: Vector3):
	mark = null
	freeze = false
	direction.y = 1 
	apply_central_impulse(direction * 10)
	apply_torque_impulse(Vector3(3 , 3, 0))
