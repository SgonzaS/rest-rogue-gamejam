extends CharacterBody2D

#Cargamos la escena del proyectil/hechizo

@onready var hechizo_scene = load("res://Nodos/Proyectil.tscn") # Ajustá la ruta a tu tscn real

# Referencia al marcador que creamos en el Paso 1

@onready var hechizo_spawn = $hechizospawn

@onready var health_comp = $HealthComponent # Ajusta la ruta a tu componente

@onready var barra_vida = $inventario/HealthBar # Ajusta la ruta a tu barra

@onready var oro_label = $inventario/HBoxContainer/Orolabel 

func _ready():
	# 1. Configurar Barra de Vida
	if health_comp and barra_vida:
		barra_vida.max_value = health_comp.MAX_HEALTH
		barra_vida.value = health_comp.current_health
		health_comp.health_changed.connect(_actualizar_barra)
	
	# 2. Configurar UI de Oro
	# Asegúrate de tener una referencia a tu Label de oro

	if oro_label: # Solo si el nodo existe, hacemos la conexión
		oro_label.text = str(global.oro)
		global.oro_cambiado.connect(func(nuevo_oro): 
			if oro_label: 
				oro_label.text = str(nuevo_oro)
		)
	else:
		print("⚠️ ERROR: No se encontró OroLabel en la ruta indicada.")

func _process(_delta):
	# Lógica de movimiento que comentaste (asegúrate de descomentarla si la usas)
	var direction = Input.get_vector("Mover_izquierda", "Mover_derecha", "Mover_arriba", "Mover_abajo")
	# velocity = direction * speed
	# move_and_slide()

func _actualizar_barra(actual, maximo):
	# Verificamos que barra_vida siga existiendo antes de actualizar
	if barra_vida:
		barra_vida.value = actual

# Tu función de disparo (puedes completarla cuando quieras)
func multi_shot() -> void:
	print("¡El jugador está ejecutando un Multi-Shot!")

	move_and_slide()

func morir():
	# 1. Pausamos todo
	get_tree().paused = true
	
	# 2. Buscamos el menú dentro del CanvasLayer del jugador
	var menu = $inventario/MenuMuerte 
	if menu:
		menu.show() # Mostramos el Panel que configuraste
	
	# 3. Opcional: Desactivamos el script para que no siga moviéndose
	set_process(false)
	set_physics_process(false)
