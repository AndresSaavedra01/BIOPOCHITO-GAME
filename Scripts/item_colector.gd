extends Area3D

@export var player : Player

var body_global: Physical_object
var current_collected_body : Physical_object

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pickup") and body_global != null:
		if current_collected_body != null:
			current_collected_body.be_launch(-player.skin.basis.z)
		body_global.be_collect(player.mark_item_position)
		current_collected_body = body_global
	elif Input.is_action_just_pressed("pickup") and current_collected_body != null:
		current_collected_body.be_launch(-player.skin.basis.z)
		current_collected_body = null

func _on_body_entered(body: Node3D) -> void:
	if body is Physical_object:
		body_global = body


func _on_body_exited(body: Node3D) -> void:
	if body_global == body:
		body_global = null
