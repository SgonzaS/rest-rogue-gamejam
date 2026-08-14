extends Area2D

@export var npc_hechizo_scene: PackedScene
@export var npc_oro_scene: PackedScene
@onready var random = RandomNumberGenerator.new()

# Ahora hacen referencia a los nodos Area2D que creamos
@onready var punto_a: Area2D = $"../Punto A"
@onready var punto_b: Area2D = $"../Punto B"
@onready var punto_c: Area2D = $"../Punto C"

func _ready() -> void:
	random.randomize()
	# Usaremos tu Cooldown_spawn solo para revisar los puntos cada x segundos
	# Así el juego no se satura revisando 60 veces por segundo.
	if has_node("cooldown_spawn"):
		$"cooldown_spawn".start()

func _on_cooldown_spawn_timeout() -> void:
	# 1. Bloqueo total si el restaurante está cerrado
	if not global.restaurante_abierto:
		return
	
	# 2. ELIMINAMOS EL BLOQUEO: if cantidad_npcs >= 1: return
	# Ahora el script seguirá ejecutándose aunque ya haya un NPC en el mapa.

	# 3. Solo si hay puntos vacíos, buscamos un punto disponible
	var puntos = [punto_a, punto_b, punto_c]
	var puntos_libres = []
	
	for punto in puntos:
		var ocupado = false
		for cuerpo in punto.get_overlapping_bodies():
			if cuerpo.is_in_group("NPCs"):
				ocupado = true
				break
		if not ocupado:
			puntos_libres.append(punto)
			
	# 4. Si hay puntos libres, spawnear
	if puntos_libres.size() > 0:
		var punto_elegido = puntos_libres.pick_random()
		spawnear_npc_hacia(punto_elegido.global_position)
		
		# Ajustamos el tiempo para que el siguiente intento no sea tan inmediato
		$cooldown_spawn.wait_time = randf_range(2.0, 4.0)

func spawnear_npc_hacia(destino: Vector2) -> void:
	var probabilidad = randf()
	var npc_instancia = null
	
	if probabilidad <= 0.5:
		# Instanciamos la escena del NPC de oro
		npc_instancia = npc_oro_scene.instantiate()
		npc_instancia.tipo_recompensa = "oro"
	else:
		# Instanciamos la escena del NPC de hechizos
		npc_instancia = npc_hechizo_scene.instantiate()
		npc_instancia.tipo_recompensa = "hechizo"
		
	# 1. POSICIÓN INICIAL: Aquí le decimos al NPC cuál es su "casa"
	npc_instancia.posicion_inicial = destino 
	
	# 2. POSICIÓN DE SPAWN: Donde aparece realmente el NPC en el mapa
	var x_aleatorio = random.randi_range(int(global_position.x + 210), int(global_position.x + 250))
	npc_instancia.global_position = Vector2(x_aleatorio, 260)
	
	npc_instancia.target_position = destino
	# 3. AÑADIR AL MUNDO: Ahora sí, lo soltamos en la escena
	get_parent().add_child(npc_instancia)
	
	print("Spawneando NPC hacia el marcador: ", destino)
