extends skill
class_name Meteorito

# Cargamos la escena física del meteorito
var proyectil_scene = preload("res://Nodos/meteorito.tscn") 

# 📐 NUEVAS CONFIGURACIONES DE ÁREA
@export var rango_maximo_casteo: float = 100.0 # Radio de alcance máximo desde el jugador
@export var radio_dispersion: float = 30.0     # Qué tanto se puede desviar del centro (0 = precisión perfecta)

func _init() -> void:
	cooldawn = 5.0
	animation_name = "fuego morado"
	texture = preload("res://Art/FireBalls/4/1.png")

func cast_spell(caster) -> void:
	# Lógica base (cooldown)
	super.cast_spell(caster)
	
	# 1. Filtro de Seguridad: Obligamos a que el caster sea un Node2D (el jugador)
	var caster_2d = caster as Node2D
	if caster_2d == null:
		print("❌ Cast_spell abortado: El caster no es un Node2D.")
		return
		
	# 📍 POSICIONES BASE
	var posicion_jugador = caster_2d.global_position
	var posicion_mouse = caster_2d.get_global_mouse_position()
	var posicion_objetivo = posicion_mouse
	
	# 🗺️ VALIDADOR DE RANGO MÁXIMO
	# Si el mouse supera la distancia permitida, recalculamos el punto en el límite del círculo
	if posicion_jugador.distance_to(posicion_mouse) > rango_maximo_casteo:
		var direccion = (posicion_mouse - posicion_jugador).normalized()
		posicion_objetivo = posicion_jugador + (direccion * rango_maximo_casteo)
		print("📏 Objetivo limitado al rango máximo de casteo.")
	
	# 🎲 APLICAMOS DISPERSIÓN EN ÁREA
	# Calculamos el desvío aleatorio final tomando como centro la posición permitida
	var posicion_final = _calcular_posicion_en_radio(posicion_objetivo, radio_dispersion)
	
	# 2. Instanciamos el proyectil meteorito
	var meteorito_instance = proyectil_scene.instantiate()
	
	# 3. Blindaje de tipo: Nos aseguramos de que sea el script correcto
	if meteorito_instance is MeteoritoProyectil:
		# Le decimos al meteorito DÓNDE tiene que caer (su destino real con área aplicada)
		meteorito_instance.target_position = posicion_final
		
		# 🌟 SOLUCIÓN SEGURA: Lo agregamos de forma diferida a la escena principal
		# ✅ Usamos el 'caster_2d' para acceder al árbol de forma segura
		caster_2d.get_tree().current_scene.call_deferred("add_child", meteorito_instance)
		
		# 🔥 INICIAMOS LA CAÍDA enviándole la posición final calculada
		meteorito_instance.start_fall(posicion_final)
		
		#print("☄️ Meteorito enviado con éxito hacia: ", posicion_final)
		
	else:
		print("❌ Error: La escena meteorito.tscn no tiene el script MeteoritoProyectil.")
		meteorito_instance.queue_free()

# 🧮 Función matemática para dispersar el impacto dentro del radio
func _calcular_posicion_en_radio(centro: Vector2, radio: float) -> Vector2:
	if radio <= 0.0:
		return centro # Si la dispersión es 0, cae exacto en el mouse
		
	var angulo = randf() * TAU
	var distancia = randf() * radio
	return centro + Vector2(cos(angulo), sin(angulo)) * distancia
