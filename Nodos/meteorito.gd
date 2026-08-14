extends Area2D
class_name MeteoritoProyectil

# Configuraciones del hechizo
var speed : float = 200.0   # Qué tan rápido cae
var damage : int = 40       # Daño que hace
var aoe_radius : float = 50 # Radio de la explosión (área de efecto)

# Variables internas que configurará el hechizo principal
var target_position : Vector2

func _ready() -> void:
	# 🔌 Conectamos la señal de colisión por seguridad (aunque la explosión principal será al llegar)
	#body_entered.connect(_on_body_entered)
	
	# Aseguramos que empiece la animación
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("fuego morado") # O el nombre de tu animación

# Función principal para iniciar la caída (llamada desde el hechizo)
func start_fall(target_pos: Vector2) -> void:
	target_position = target_pos
	
	# Calculamos el punto de inicio (arriba del objetivo, fuera de pantalla)
	# Puedes ajustar el 800 para que caiga desde más o menos alto
	global_position = target_position + Vector2(0, -100) 
	
	# Usamos un Tween para moverlo. Es mucho más limpio para un destino fijo.
	var tween = create_tween()
	
	# Interpolamos global_position desde su inicio hasta target_position
	# La duración se calcula por la distancia/velocidad para que sea constante
	var duration = global_position.distance_to(target_position) / speed
	
	tween.tween_property(self, "global_position", target_position, duration)
	
	# Cuando el movimiento termina, llamamos a la función de explosión
	tween.finished.connect(_on_fall_finished)

func _on_fall_finished() -> void:
	# ¡Llegamos al destino! Hora de explotar y hacer daño.
	explode()

func explode() -> void:
	
	var tree = get_tree()
	if tree:
		var player = tree.get_first_node_in_group("Player")
		
		# Radio de explosión en píxeles
		var radio_explosion: float = 40.0 
		
		# Buscamos a todos los enemigos en el grupo
		for enemy in tree.get_nodes_in_group("Enemigos"):
			if enemy is Node2D and enemy != player:
				
				# Calculamos la distancia del impacto al enemigo
				var distance = global_position.distance_to(enemy.global_position)
				
				if distance <= radio_explosion:
					#print("🎯 Enemigo en rango: ", enemy.name)
					
					# 🛡️ BUSCAMOS TU COMPONENTE ESPECÍFICO (Respetando las mayúsculas/minúsculas exactas)
					if enemy.has_node("EnemyHealthComponent"):
						var health_comp = enemy.get_node("EnemyHealthComponent")
						
						# Llamamos a tu función 'damage()' que vimos en tu captura de salud
						if health_comp.has_method("damage"):
							health_comp.damage(damage)
							#print("⚔️ Daño de meteorito aplicado con éxito al EnemyHealthComponent.")
						#else:
							#print("⚠️ Alerta: El EnemyHealthComponent no tiene la función 'damage'.")
					
	# Eliminamos el meteorito del mapa al terminar de procesar
	queue_free()

# Por si choca contra algo antes de llegar (una pared alta), explota ahí
func _on_body_entered(body: Node) -> void:
	# 🛑 FILTRO CRÍTICO: Ignoramos por completo las colisiones con el TileMap/Paredes
	# El meteorito SOLO explotará en el aire si choca de frente contra un Enemigo
	if body.is_in_group("Enemigos"):
		print("💥 Impacto directo en el aire contra enemigo: ", body.name)
		
		# Frenamos el Tween inmediatamente para que no siga bajando
		var tween = get_tree().create_tween()
		tween.kill() 
		
		# Ejecutamos la explosión en el lugar del impacto
		explode()
	# Detenemos cualquier Tween que estuviera corriendo para que no siga moviéndose
	var tween = get_tree().create_tween() # Esto es un truco para matar tweens activos en el nodo
	tween.kill() 
	
	
	
