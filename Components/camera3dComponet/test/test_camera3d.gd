extends GutTest

var world_scene = preload("res://Escenas/world.tscn")
var runner = null
var player = null

func before_each():
	# Instanciar e introducir la escena al SceneTree
	runner = autoqfree(world_scene.instantiate())
	add_child(runner)
	
	# Buscar al jugador dentro de la escena instanciada
	player = runner.find_child("Pepe")

func test_player():
	# Verificar que el nodo exista antes de correr la lógica
	assert_not_null(player, "El nodo 'Pepe' debe existir en la escena")
	
	var start_posi: Vector3 = player.global_position
	
	# Simular presionar la tecla D
	Input.action_press("ui_right") # O usar la tecla directa: Input.parse_input_event(...)
	
	# Esperar 2000 ms (2 segundos) procesando físicas y frames
	await wait_seconds(2.0)
	
	# Soltar la tecla D tras los 2 segundos
	Input.action_release("ui_right")
	
	var end_posi: Vector3 = player.global_position
	var move: Vector3 = start_posi.direction_to(end_posi)
	
	# Comparación de vectores en GUT con tolerancia de aproximación
	assert_true(
		move.is_equal_approx(Vector3.RIGHT), 
		"El jugador debió moverse hacia la derecha. Posición esperada aprox: %s, obtenida: %s" % [Vector3.RIGHT, move]
	)
