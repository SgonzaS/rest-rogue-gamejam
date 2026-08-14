extends Node

var player_current_attack = false

var hechizos_guardados: Array = []
var vida_guardada: int = -1

var mochila_guardada: Mochila = Mochila.new()

var inventario_abierto: bool = false

signal oro_cambiado(nueva_cantidad)
var oro : int = 0 :
	set(value):
		oro = value
		emit_signal("oro_cambiado", oro)

var restaurante_abierto: bool = false

var duracion_turno: float = 30 #cambiar el tiempo del turno aca
var tiempo_restante: float = 0

var icono_actual: String = "restaurante"

func _ready():
	# Detectamos cambios de escena cada vez que se añade un nuevo nodo raíz
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node):
	# 1. Filtramos por nombre. 
	# Solo nos importa si el nodo que entra es el "nodo raíz" de una de tus escenas.
	match node.name:
		"level":
			icono_actual = "restaurante"
		"Bosque", "Granja", "Cultivo":
			icono_actual = "bolsita"
		_:
			# Si el nodo no es una de nuestras escenas principales, salimos.
			return 
			
	# 2. Si llegamos aquí, es porque detectamos una escena válida.
	print("DEBUG: Escena detectada: ", node.name, " | Ícono: ", icono_actual)
	
	# 3. Llamamos a la actualización de la UI
	actualizar_ui_global()

func actualizar_ui_global():
	# Buscamos la UI en la raíz del árbol
	var ui = get_tree().root.find_child("Control", true, false)
	
	# Verificamos si existe y si tiene el método necesario para no causar errores
	if ui and ui.has_method("actualizar_icono"):
		ui.actualizar_icono()
	else:
		print("⚠️ [GLOBAL] No se encontró UI o el método 'actualizar_icono' no existe.")

func agregar_hechizo(nombre_hechizo: String):
	if not hechizos_guardados.has(nombre_hechizo):
		hechizos_guardados.append(nombre_hechizo)
		print("Guardado en Global: ", hechizos_guardados)

signal tiempo_actualizado(porcentaje)

func abrir_restaurante():
	restaurante_abierto = true
	tiempo_restante = duracion_turno
	
	# Bucle que descuenta tiempo
	while tiempo_restante > 0:
		await get_tree().create_timer(0.1).timeout # Actualizamos cada 100ms
		tiempo_restante -= 0.1
		
		# Calculamos el porcentaje para la barra (0 a 100)
		var porcentaje = (tiempo_restante / duracion_turno) * 100
		tiempo_actualizado.emit(porcentaje)
		
	cerrar_restaurante()

func cerrar_restaurante():
	restaurante_abierto = false
	tiempo_actualizado.emit(0) # Aseguramos que la barra quede en 0
