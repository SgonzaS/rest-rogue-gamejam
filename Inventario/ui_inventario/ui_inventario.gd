extends Control

@onready var grid_container: GridContainer = $PanelContainer/GridContainer
@onready var panel_container: PanelContainer = $PanelContainer

const ICONO_BOLSITA = preload("res://Art/ui (new)/Icono saquito.png")
const ICONO_RESTAURANTE = preload("res://Art/ui (new)/icono cofre.png")

var mochila:Mochila 


func _ready() -> void:
	if global.mochila_guardada == null:
		mochila = Mochila.new()
		global.mochila_guardada = mochila
	else:
		mochila = global.mochila_guardada
		
	actualizar_todas_la_ui()
	actualizar_icono() # <--- Llamada nueva
	panel_container.hide()
	global.inventario_abierto = false
		
func actualizar_icono() -> void:
	# Asumiendo que el botón se llama "BotonMochila"
	# Si se llama distinto, cambia el nombre aquí
	var boton = get_node_or_null("BotonMochila") 
	if boton:
		if global.icono_actual == "restaurante":
			boton.texture_normal = ICONO_RESTAURANTE
		else:
			boton.texture_normal = ICONO_BOLSITA
		
func alternar_inventario():
	if panel_container.visible:
		panel_container.hide()
	else:
		actualizar_todas_la_ui()
		panel_container.show()
# Función para agregar un ítem a la interfaz del inventario.
# Esta lógica primero intenta apilar el ítem en un slot existente. Si no es posible, lo coloca en un slot vacío.
func agregar_item_a_mochila(item_a_agregar: Item) -> void:
	# 1. Le mandamos el ítem a la mochila global para que maneje los datos
	var se_guardo = global.mochila_guardada.agregar_item(item_a_agregar, 1)
	
	# 2. Si la mochila lo aceptó con éxito, actualizamos la interfaz en pantalla
	if se_guardo:
		actualizar_todas_la_ui()
# Creamos una función aparte para actualizar los slots. 

# Esto te va a servir un montón para cuando pases de nivel y quieras volver a dibujar todo.
func actualizar_todas_la_ui() -> void:
	
	for clave in global.mochila_guardada.objetos:
		var item_actual = global.mochila_guardada.objetos[clave]
	# Primero vaciamos visualmente todos los paneles del GridContainer
	for slot in grid_container.get_children():
		slot.vaciar_valores()
	
	# Agarramos todos los slots disponibles de la interfaz
	var slots_ui = grid_container.get_children()
	var index = 0
	
	# Recorremos el diccionario de la mochila y vamos llenando los slots uno por uno
	for clave in mochila.objetos:
		if index < slots_ui.size():
			var datos_item = mochila.objetos[clave]
			slots_ui[index].llenar_espacio(datos_item)
			index += 1

# Función que busca el primer slot vacío en el inventario.
# Retorna la referencia al nodo del slot si lo encuentra, o 'null' si todos están ocupados.
func buscar_slot_vacio() -> Control:
	# Recorre cada slot en el 'GridContainer'.
	for slot in grid_container.get_children():
		# Si el slot no tiene datos de ítem (es decir, 'item_data' es 'null'), lo retorna.
		if not slot.item_data:
			return slot
	# Si el bucle termina y no se encontró un slot vacío, retorna 'null'.
	return null


func _on_boton_mochila_pressed() -> void:
	alternar_inventario()
	
func _input(event: InputEvent) -> void:
	# Si presionan la tecla que configuramos en el proyecto
	if event.is_action_pressed("inventario"):
		alternar_inventario()
