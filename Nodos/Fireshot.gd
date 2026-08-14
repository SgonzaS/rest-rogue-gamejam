extends skill
class_name Fireshot

# 1. Cargamos la escena del proyectil/hechizo desde el recurso
var proyectil_scene = preload("res://Nodos/fireshot.tscn") # <- Asegurate de poner tu ruta real al .tscn del proyectil


func _init() -> void:
	cooldawn = 1.0
	animation_name = "fuego rojo"
	texture = preload("res://Art/FireBalls/3/1.png")
	


func cast_spell(caster) -> void:
	super.cast_spell(caster)
	
	var caster_2d = caster as Node2D
	var spawn_node = caster_2d.get_node_or_null("hechizospawn")
	
	if spawn_node == null:
		print("❌ ERROR: No se encontró el nodo 'hechizospawn' en el jugador.")
		return

	# 1. Calculamos la dirección AL MOUSE (ya lo tenías bien)
	var mouse_position = caster_2d.get_global_mouse_position()
	var direccion_al_mouse = (mouse_position - spawn_node.global_position).normalized()
	
	# 2. Instanciamos el proyectil
	var proyectil_instance = proyectil_scene.instantiate()
	
	# 3. APLICAMOS EL OFFSET DE SEGURIDAD
	# Multiplicamos la dirección por un valor pequeño (ej. 20 píxeles) 
	# para que aparezca alejado del centro del jugador
	proyectil_instance.global_position = spawn_node.global_position + (direccion_al_mouse)
	
	# 4. Asignamos dirección y reproducimos
	proyectil_instance.direction = direccion_al_mouse
	proyectil_instance.play(animation_name)
	
	# 5. Añadimos a la escena raíz (es lo correcto para que no herede rotaciones del jugador)
	caster_2d.get_tree().current_scene.add_child(proyectil_instance)
	

	
	
