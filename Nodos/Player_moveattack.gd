extends State

var health_component : HealthComponent
# Conseguimos la referencia a la forma de colisión del arma
@onready var weapon_collision_shape = $"../../Pivote_arma/weapon_colision/CollisionShape2D"

func enter(args := {}):
	health_component = target.get_node("HealthComponent")
	
	if args.has("direction"):
		args["velocity_component"].move(0, args["direction"] * args["force"])
	
	# 1. Nos conectamos al cambio de fotograma del sprite
	anim.frame_changed.connect(_on_attack_frame_changed)
	
	# Aseguramos que empiece desactivada antes de reproducir
	weapon_collision_shape.set_deferred("disabled", true)
	
	# Reproducir animación
	anim.play("attack")
	
	# 2. Esperamos a que la animación termine por completo
	await anim.animation_finished
	
	# 3. Limpieza: Desconectamos la señal y aseguramos dejar el arma apagada al salir
	if anim.frame_changed.is_connected(_on_attack_frame_changed):
		anim.frame_changed.disconnect(_on_attack_frame_changed)
	weapon_collision_shape.set_deferred("disabled", true)
	
	# Volver a Idle
	emit_signal("transitioned", self, "Idle", {})

# 4. Esta función se ejecuta en CADA fotograma de la animación de ataque
func _on_attack_frame_changed():
	if anim.animation == "attack":
		# Supongamos que tu espada se extiende visualmente en el fotograma 2:
		if anim.frame == 2:
			weapon_collision_shape.set_deferred("disabled", false) # ACTIVA EL DAÑO
		
		# En el fotograma 3 (cuando la espada ya bajó), la volvemos a apagar:
		elif anim.frame == 3:
			weapon_collision_shape.set_deferred("disabled", true) # DESACTIVA EL DAÑO
			
# Suponiendo que tu máquina de estados te da una referencia al personaje como 'owner' o 'player'
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("atacar"): # Tu acción de input para lanzar hechizos
		lanzar_hechizo()

func lanzar_hechizo() -> void:
	# 1. Instanciamos el proyectil usando la escena guardada en el player
	var hechizo = owner.hechizo_scene.instantiate()
	
	# 2. Le damos la posición global del Marker2D de salida
	hechizo.global_position = owner.hechizo_spawn.global_position
	
	# 3. OPCIONAL: Definir dirección del hechizo (por ejemplo, hacia donde mira el Player)
	# Si tu player tiene una variable para la dirección (ej: Vector2.RIGHT o Vector2.LEFT)
	hechizo.direction = owner.look_direction 
	
	# 4. Lo agregamos a la escena principal del juego para que se mueva independiente del jugador
	owner.get_parent().add_child(hechizo)
