class_name HealthComponent extends Node

const ITEM_SUELO_SCENE = preload("res://Nodos/item_suelo.tscn")
# Mantenemos tus señales y variables existentes
signal Muerte
signal health_changed(current_health, max_health) # ✅ NUEVA SEÑAL PARA LA BARRA

@export var MAX_HEALTH : int
@export var Resistance : int

@export_group("Loot Recompensa")
@export var item_a_soltar: Item
@export_range(0.0, 100.0) var probabilidad_drop: float = 50.0

var current_health : int : 
	set(value):
		current_health = clamp(value, 0, MAX_HEALTH)
		
		# ✅ Emitimos la señal cada vez que cambia la vida
		health_changed.emit(current_health, MAX_HEALTH)
		
		if current_health <= 0:
			var cuerpo_padre = get_parent()
			var posicion_muerte: Vector2 = cuerpo_padre.global_position
	
			if cuerpo_padre.name == "Player":
		# ✅ NUEVA LÓGICA PARA EL JUGADOR
				cuerpo_padre.morir() 
			else:
		# Lógica para enemigos (se destruyen)
				soltar_recompensa(posicion_muerte)
				cuerpo_padre.queue_free()

func _ready() -> void:
	if get_parent().name == "Player":
		current_health = global.vida_guardada if global.vida_guardada != -1 else MAX_HEALTH
	else:
		current_health = MAX_HEALTH
	
	# ✅ Emitimos el valor inicial para que la barra sepa qué dibujar al empezar
	health_changed.emit(current_health, MAX_HEALTH)
			

# Añadir vida
func heal(value: int) -> void:
	current_health += value
	# ¡Importante! Limitamos para que no pase de la vida máxima
	current_health = min(current_health, MAX_HEALTH)
	# Emitimos la señal para que la barra de vida se actualice visualmente
	health_changed.emit(current_health, MAX_HEALTH)
	print("¡Curado! Vida actual: ", current_health)

# Restar vida
func damage(value : int) -> void:
	# ✅ CORREGIDO: Cambiado *= por -= para que realmente reste vida al recibir daño
	current_health -= value

# --- FUNCIÓN PARA INSTANCIAR EL ITEM ---
func soltar_recompensa(posicion_real: Vector2) -> void:
	if item_a_soltar == null:
		# Modificamos esta línea para que nos diga de quién es este componente:
		print("❌ ERROR: El nodo '", get_parent().name, "' tiene su variable 'item_a_soltar' VACÍA en el Inspector.")
		return
		
	var numero_azar = randf_range(0.0, 100.0)
	if numero_azar <= probabilidad_drop:
		var nuevo_item = ITEM_SUELO_SCENE.instantiate()
		
		# Le pasamos los datos del recurso al objeto del suelo
		nuevo_item.item_data = item_a_soltar
		
		# ✅ CLAVE: Usamos la posición real exacta que le mandamos por parámetro
		nuevo_item.global_position = posicion_real
		
		# Lo agregamos al mapa
		get_tree().current_scene.add_child(nuevo_item)
		print("¡Ítem dropeado en la posición: ", posicion_real)	
