extends CharacterBody2D

enum TipoNPC { COMERCIANTE_ORO, MAESTRO_HECHIZOS }
@export var tipo_npc: TipoNPC = TipoNPC.COMERCIANTE_ORO

@export var ofertas: Array[Receta] = []
#@export var es_hechizo_desbloqueo: String = ""
@export var speed: float   
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export var interaction_name: String = "Hablar"
@export var is_interactable: bool = true
@onready var interaction_area: Area2D = $Chatdetectionarea
#@export var item_requerido: Item
#@export var cantidad_requerida: int 
# Si dejamos esto vacío, el NPC entiende que no da un item, sino un hechizo o dinero
@export var item_recompensa: Item 
@export var es_hechizo: PackedScene 
@export var cantidad_oro: int = 0
# Dejamos la variable vacía o con un valor por defecto. 
# El Spawner se va a encargar de cambiar este valor al instanciarlo.
var posicion_inicial: Vector2
var target_position = null
var tipo_recompensa: String = ""
var ya_llego = false
var is_chatting = false
var player_in_chat_zone = false
var player
var debe_retirarse = false
var menu_actual: CanvasLayer = null

func _ready() -> void:
	print("Nacio un NPC y la recompensa es: ", tipo_recompensa)
	posicion_inicial = global_position
	call_deferred("configurar_interaccion")
	
	await get_tree().physics_frame
	if target_position != null:
		nav_agent.target_position = target_position
	
func retirarse():
	# 1. Nos quitamos del grupo para que el Spawner no nos cuente como ocupantes
	remove_from_group("NPCs")
	
	# 2. Creamos el Tween
	var tween = create_tween()
	
	# 3. Lo movemos a la posición inicial (o a una puerta de salida)
	tween.tween_property(self, "global_position", posicion_inicial, 2.0)
	
	# 4. Eliminamos al terminar
	tween.tween_callback(queue_free)
	
func configurar_interaccion():
	var area = get_node_or_null("Chatdetectionarea")
	if area is InteractableArea:
		# Asegúrate de que apunte a _on_interact (que ahora solo abre el menú)
		area.interact = _on_interact
		
func _physics_process(delta: float) -> void:
	if is_chatting: # <--- AGREGA ESTO
		return
	# 1. Chequeo constante de cierre
	if not global.restaurante_abierto and not debe_retirarse:
		# Solo entra aquí una vez
		debe_retirarse = true
		retirarse()
		return # Ya no ejecutamos la lógica de movimiento normal
	# Si no tenemos destino, no hacemos nada
	if target_position == null:
		return

	# 1. Asignamos destino SOLO si cambió o es necesario
	if nav_agent.target_position != target_position:
		nav_agent.target_position = target_position
	
	# 2. Si ya llegamos, paramos
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	# 3. Calculamos la dirección y velocidad DESEADA
	var next_path_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	
	# 4. PASAMOS AL AGENTE LA VELOCIDAD DESEADA (Él calculará la segura)
	nav_agent.set_velocity(direction * speed)

# ESTA FUNCIÓN ES LA ÚNICA QUE MUEVE AL PERSONAJE
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
	
func _on_chatdetectionarea_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		player_in_chat_zone = true
		print("¡Jugador detectado por método!")
	else:
		print("Entró algo que no es el jugador. Se llama: ", body.name)

func _on_chatdetectionarea_body_exited(body: Node2D) -> void:
	if body.name == ("Player"):
		player = body
		player_in_chat_zone = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_chat_zone:
		iniciar_interaccion()

func iniciar_interaccion():
	if is_chatting: return
	is_chatting = true
	set_physics_process(false) # ¡Detiene el movimiento!
	velocity = Vector2.ZERO
	crear_menu_seleccion()
	
func terminar_interaccion():
	is_chatting = false
	set_physics_process(true) # ¡Reactiva el movimiento!
	#retirarse()

func _on_interact():
	# Ya no hace nada de intercambio aquí.
	# Solo inicia la interacción para abrir el menú.
	iniciar_interaccion()

func desbloquear_hechizo(nombre_hechizo: String):
	# 1. Avisamos a la SkillBar
	var skill_bar = get_tree().root.find_child("SkillBar", true, false)
	if skill_bar and skill_bar.has_method('desbloquear_nuevo_hechizo'):
		skill_bar.desbloquear_nuevo_hechizo(nombre_hechizo)
		print("✨ ¡Hechizo '", nombre_hechizo, "' entregado correctamente!")
		
func crear_menu_seleccion():
	menu_actual = CanvasLayer.new()
	add_child(menu_actual)
	
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(250, 200)
	panel.position = get_viewport_rect().size / 2 - panel.custom_minimum_size / 2
	menu_actual.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT) # Esto alinea bien los botones
	panel.add_child(vbox)
	
	for receta in ofertas:
		var btn = Button.new()
		# Usa el mismo nombre que usaste en el obtener_cantidad_de_receta
		btn.text = "Canjear " + receta.nombre_comida 
		btn.pressed.connect(_on_opcion_seleccionada.bind(receta))
		vbox.add_child(btn)
	
	# AGREGA ESTO: Botón para salir sin hacer nada
	var btn_salir = Button.new()
	btn_salir.text = "Cancelar"
	btn_salir.pressed.connect(cerrar_menu) # Debes crear la función cerrar_menu abajo
	vbox.add_child(btn_salir)
		
func cerrar_menu():
	if menu_actual:
		menu_actual.queue_free()
		menu_actual = null
	terminar_interaccion()
		
func _on_opcion_seleccionada(receta: Receta):
	var mochila = global.mochila_guardada
	
	# 1. Validación: ¿Tiene el jugador la receta?
	if mochila.obtener_cantidad_de_receta(receta) >= 1:
		# 2. Consumo: Borramos 1 unidad de la mochila
		mochila._eliminar_cantidad_por_nombre(receta.nombre_comida, 1)
		
		# 3. Recompensa
		if tipo_npc == TipoNPC.MAESTRO_HECHIZOS:
			desbloquear_hechizo(receta.nombre_hechizo)
		else:
			global.oro += receta.cantidad_oro
			print("Oro actual:", global.oro)
	else:
		print("❌ No tienes esa receta.")
		
	# 4. Limpieza: Cerramos el menú y volvemos al estado normal
	if menu_actual:
		menu_actual.queue_free()
	terminar_interaccion()
	retirarse()
func interact_call():
	# Esta es la función que tu Player llama desde el script que me pasaste
	iniciar_interaccion()
