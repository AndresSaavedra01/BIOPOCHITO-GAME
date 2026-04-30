extends Camera3D

var disired_offset: Vector2
var min_offset = -200
var max_offset = 200

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	disired_offset = clamp()
