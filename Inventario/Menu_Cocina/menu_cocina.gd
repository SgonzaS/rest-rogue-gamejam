# menu_cocina.gd
extends CanvasLayer

# Arrastrá acá tu escena 'boton_receta.tscn' desde el sistema de archivos
@export var boton_receta_escena: PackedScene

# Ruta al nodo VBoxContainer donde se van a enlistar los botones
@onready var lista_comidas: VBoxContainer = $Panel/ScrollContainer/VBoxContainer

# 🎒 NOTA: Cambiá esto por la forma en que accedas a tu mochila global en tu juego
# (Por ejemplo, si la tenés en un Autoload/Singleton global como 'Global.mochila')
var mochila_jugador: Mochila

func _ready() -> void:
	# Apuntamos directo a tu script Autoload global y a tu variable real
	if global and global.mochila_guardada != null:
		mochila_jugador = global.mochila_guardada
	else:
		print("🚨 [MENU] No se pudo conectar con la mochila_guardada en Global")

# 🔄 Esta función la va a llamar el Horno al abrir el menú
func cargar_recetas(recetas_horno: Array[Receta]) -> void:
	# 1. Limpiamos los botones viejos para que no se dupliquen
	for hijo in lista_comidas.get_children():
		hijo.queue_free()
		
	# 2. Creamos un botón nuevo por cada receta que tenga este horno
	for receta in recetas_horno:
		var nuevo_boton = boton_receta_escena.instantiate()
		
		# Configuramos el texto del botón (Nombre de la comida + lo que pide)
		nuevo_boton.text = receta.nombre_comida + " (Cocinar)"
		nuevo_boton.receta_asignada = receta
		
		# Conectamos la señal del botón a la lógica de este menú
		nuevo_boton.receta_seleccionada.connect(_on_receta_clickeada)
		
		# Lo metemos adentro de la lista visual
		lista_comidas.add_child(nuevo_boton)

# 🍳 Se ejecuta cuando el jugador hace clic en cualquier comida de la lista
func _on_receta_clickeada(receta: Receta) -> void:
	# 1. Verificamos que la mochila esté conectada al menú
	if mochila_jugador == null:
		print("❌ Error: No se encontró la Mochila del jugador conectada al menú.")
		return
		
	print("🖱️ [MENU] Se hizo clic en la receta: ", receta.nombre_comida)
	
	# 2. Le preguntamos a las funciones actualizadas de tu mochila
	if mochila_jugador.tiene_ingredientes_necesarios(receta):
		mochila_jugador.cocinar_receta(receta)
		print("✨ ¡Comida lista!")
		
		# 3. Forzamos a que tu inventario visual se redibuje en pantalla
		var ui_inv = get_tree().current_scene.find_child("UI_Inventario", true, false)
		if ui_inv == null:
			ui_inv = get_tree().current_scene.find_child("inventario", true, false)
			
		if ui_inv != null and ui_inv.has_method("actualizar_todas_la_ui"):
			ui_inv.actualizar_todas_la_ui()
	else:
		print("❌ No tenés los materiales suficientes para hacer: ", receta.nombre_comida)
		
# menu_cocina.gd
#extends Control

# ... (tus otras variables y funciones como cargar_recetas) ...

func _input(event: InputEvent) -> void:
	# IMPORTANTE: Solo procesar si el menú está visible
	if not visible:
		return
		
	if event.is_action_pressed("interact"):
		# Esto previene que la tecla se propague a otros nodos
		get_viewport().set_input_as_handled() 
		cerrar_menu()



func cerrar_menu() -> void:
	hide()
	get_tree().paused = false
	
	# 💥 IMPORTANTE: Cambiamos a MOUSE_MODE_VISIBLE para el menú
	# y devolvemos al jugador a MOUSE_MODE _CAPTURED
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	get_tree().call_group("Interactuables", "desbloquear_interaccion")
