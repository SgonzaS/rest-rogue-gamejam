extends CharacterBody2D

# Configuración del Enemigo
@export var velocidad: float = 100.0
@export var velocidad_persecucion: float = 150.0
@onready var health_component: HealthComponent = $EnemyHealthComponent
@export var tiempo_entre_disparos: float = 1.5
@export var proyectil_escena: PackedScene

# Definición de la Zona de Patrulla
@export var zona_patrulla_ancho: float = 100.0
@export var zona_patrulla_alto: float = 300.0
@export var distancia_minima: float = 80.0  # Distancia que quiere mantener
@export var zona_tolerancia: float = 20.0    # Margen de error para que no vibre
@onready var timer_perdida: Timer = $TimerPerdida

@onready var barra_verde = $Control/Barraverde
@onready var barra_roja = $Control/Barraroja

# Nodos y Estados
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var timer_disparo: Timer = $DPS
@onready var area_cono: Area2D = $area_cono


var posicion_origen: Vector2
var punto_patrulla_actual: Vector2
var jugador_objetivo: Node2D = null
var esta_patrullando = true
var puede_disparar = true

func _ready() -> void:
	posicion_origen = global_position
	call_deferred("_definir_nuevo_punto_patrulla")
	timer_disparo.wait_time = tiempo_entre_disparos
	
	# Conexión automática de señales de Area2D
	area_cono.body_entered.connect(_on_area_cono_body_entered)
	area_cono.body_exited.connect(_on_area_cono_body_exited)
	timer_disparo.timeout.connect(_on_timer_disparo_timeout)
	
	barra_verde.max_value = health_component.MAX_HEALTH
	barra_verde.value = health_component.current_health
	barra_roja.max_value = health_component.MAX_HEALTH
	barra_roja.value = health_component.current_health
	
	timer_perdida.timeout.connect(_on_timer_perdida_timeout)
	# Conectamos la señal de muerte del componente (opcional)
	#health_component.Muerte.connect(_on_muerte)
	health_component.health_changed.connect(_on_health_changed)


func _physics_process(_delta: float) -> void:
	# Aseguramos que el cuerpo no rote, solo el sprite se voltee
	rotation = 0 
	
	if jugador_objetivo:
		var distancia = global_position.distance_to(jugador_objetivo.global_position)
		
		# 1. Lógica de orientación (SOLO EJE X)
		$AnimatedSprite2D.flip_h = (jugador_objetivo.global_position.x < global_position.x)
		
		# 2. Lógica de estados de combate
		if distancia < 100.0:
			# HUIR
			var direccion_huida = (global_position - jugador_objetivo.global_position).normalized()
			velocity = direccion_huida * (velocidad_persecucion * 0.5)
			
		elif distancia >= 100.0 and distancia <= 150.0:
			# ATACAR
			velocity = Vector2.ZERO 
			if puede_disparar:
				disparar()
			
		else:
			# PERSEGUIR
			nav_agent.target_position = jugador_objetivo.global_position
			var next_pos = nav_agent.get_next_path_position()
			velocity = (next_pos - global_position).normalized() * velocidad_persecucion
			
	elif esta_patrullando:
		nav_agent.target_position = punto_patrulla_actual
		
		if nav_agent.is_navigation_finished():
			velocity = Vector2.ZERO
			_definir_nuevo_punto_patrulla()
		else:
			var direccion_patrulla = (nav_agent.get_next_path_position() - global_position).normalized()
			velocity = direccion_patrulla * velocidad
			
			# Orientación en patrulla
			if abs(direccion_patrulla.x) > 0.1: # Evita parpadeos si se mueve solo vertical
				$AnimatedSprite2D.flip_h = (direccion_patrulla.x < 0)

	else:
		velocity = velocity.move_toward(Vector2.ZERO, 5.0)

	move_and_slide()

func _definir_nuevo_punto_patrulla() -> void:
	var dx = randf_range(-zona_patrulla_ancho / 2, zona_patrulla_ancho / 2)
	var dy = randf_range(-zona_patrulla_alto / 2, zona_patrulla_alto / 2)
	punto_patrulla_actual = posicion_origen + Vector2(dx, dy)
	print("Nuevo punto de patrulla definido.")

func _on_health_changed(actual, maximo):
	# Actualizamos la barra verde inmediatamente
	barra_verde.value = actual
	
	# El efecto de "retraso" en la barra roja (Tween)
	var tween = create_tween()
	tween.tween_property(barra_roja, "value", float(actual), 0.4)

# Lógica de Combate
func disparar() -> void:
	if proyectil_escena and jugador_objetivo:
		puede_disparar = false
		var proy = proyectil_escena.instantiate()
		proy.global_position = global_position
		# Dispara directamente al objetivo, ignorando la rotación del enemigo
		proy.rotation = global_position.angle_to_point(jugador_objetivo.global_position)
		proy.dueño = self
		get_tree().current_scene.add_child(proy)
		timer_disparo.start()

func _on_timer_disparo_timeout() -> void:
	puede_disparar = true
	
func mover_hacia_objetivo():
	var current_pos = global_position
	var next_pos = nav_agent.get_next_path_position()
	velocity = (next_pos - current_pos).normalized() * velocidad_persecucion
	move_and_slide()
	
func _on_muerte() -> void:
	# Aquí puedes poner efectos de sonido o partículas antes de morir
	print("El enemigo ha muerto.")
	# El componente ya se encarga de llamar al queue_free() del padre

func _on_area_cono_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		jugador_objetivo = body
		esta_patrullando = false
		timer_perdida.stop() # Si te vuelvo a ver, cancelo el olvido

func _on_area_cono_body_exited(body: Node2D) -> void:
	if body == jugador_objetivo:
		# Empieza la cuenta atrás para olvidarte
		timer_perdida.start()
		
func recibir_dano(cantidad: int) -> void:
	if health_component:
		health_component.damage(cantidad)
		print(health_component.current_health)
	else:
		# Si no tiene componente, hacemos un daño básico o ignoramos
		queue_free()


func _on_timer_perdida_timeout() -> void:
	# Pasaron los 2 segundos, ya no te persigo
	jugador_objetivo = null
	esta_patrullando = true
	_definir_nuevo_punto_patrulla()
