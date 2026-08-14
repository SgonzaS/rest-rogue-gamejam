extends CharacterBody2D
# --- Configuración ---
@export var velocidad: float = 100.0
@export var velocidad_persecucion: float = 150.0
@export var tiempo_entre_ataques: float = 1.5

# --- Referencias de Nodos ---
@onready var health_component: HealthComponent = $EnemyHealthComponent
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var timer_ataque: Timer = $DPS # Reutilizamos tu timer
@onready var timer_perdida: Timer = $TimerPerdida
@onready var area_cono: Area2D = $area_cono
@onready var area_latigo: Area2D = $AreaLatigo
@onready var forma_latigo: CollisionShape2D = $AreaLatigo/CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# CORRECCIÓN: Usamos las barras que declaraste
@onready var barra_verde = $Control/Barraverde
@onready var barra_roja = $Control/Barraroja

# --- Variables de Estado ---
var posicion_origen: Vector2
var punto_patrulla_actual: Vector2
var jugador_objetivo: Node2D = null
var esta_patrullando = true
var puede_atacar = true

func _ready() -> void:
	posicion_origen = global_position
	forma_latigo.disabled = true # Aseguramos que el látigo empiece desactivado
	
	# Conexiones
	area_cono.body_entered.connect(_on_area_cono_body_entered)
	area_cono.body_exited.connect(_on_area_cono_body_exited)
	timer_ataque.timeout.connect(func(): puede_atacar = true)
	timer_perdida.timeout.connect(_on_timer_perdida_timeout)
	area_latigo.body_entered.connect(_on_latigo_hit)
	
	call_deferred("_definir_nuevo_punto_patrulla")
	
	barra_verde.max_value = health_component.MAX_HEALTH
	barra_verde.value = health_component.current_health
	barra_roja.max_value = health_component.MAX_HEALTH
	barra_roja.value = health_component.current_health
	
	health_component.health_changed.connect(_on_health_changed)

func _physics_process(_delta: float) -> void:
	rotation = 0 # Evita que todo el cuerpo rote
	
	if jugador_objetivo:
		var distancia = global_position.distance_to(jugador_objetivo.global_position)
		
		# Orientación visual (Flip)
		sprite.flip_h = (jugador_objetivo.global_position.x < global_position.x)
		
		# Estados
		if distancia < 80.0: # Rango de ataque (Melee)
			velocity = Vector2.ZERO
			if puede_atacar:
				ejecutar_ataque_latigo()
		else:
			# Persecución
			nav_agent.target_position = jugador_objetivo.global_position
			var next_pos = nav_agent.get_next_path_position()
			velocity = (next_pos - global_position).normalized() * velocidad_persecucion
			
	elif esta_patrullando:
		nav_agent.target_position = punto_patrulla_actual
		if nav_agent.is_navigation_finished():
			velocity = Vector2.ZERO
			_definir_nuevo_punto_patrulla()
		else:
			var dir = (nav_agent.get_next_path_position() - global_position).normalized()
			velocity = dir * velocidad
			if abs(dir.x) > 0.1: sprite.flip_h = (dir.x < 0)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 5.0)

	move_and_slide()

# --- Lógica de Ataque ---
func ejecutar_ataque_latigo() -> void:
	puede_atacar = false
	sprite.play("atacar")
	
	# Posicionar látigo según dirección
	area_latigo.position.x = -80 if sprite.flip_h else 80
	
	# Activar hitbox temporalmente
	forma_latigo.disabled = false
	await get_tree().create_timer(0.3).timeout
	forma_latigo.disabled = true
	
	timer_ataque.start(tiempo_entre_ataques)

func _on_health_changed(actual, maximo):
	# Actualizamos la barra verde inmediatamente
	barra_verde.value = actual
	
	# El efecto de "retraso" en la barra roja (Tween)
	var tween = create_tween()
	tween.tween_property(barra_roja, "value", float(actual), 0.4)

func _on_latigo_hit(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Accedemos al nodo del componente dentro del cuerpo del jugador
		var player_health = body.get_node_or_null("HealthComponent")
		if player_health and player_health.has_method("damage"):
			player_health.damage(10)
			print("¡Daño aplicado al componente del jugador!: ", player_health.damage)

# --- Lógica de Patrulla y Detección ---
func _definir_nuevo_punto_patrulla() -> void:
	punto_patrulla_actual = posicion_origen + Vector2(randf_range(-50, 50), randf_range(-150, 150))

func _on_area_cono_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		jugador_objetivo = body
		esta_patrullando = false
		timer_perdida.stop()

func _on_area_cono_body_exited(body: Node2D) -> void:
	if body == jugador_objetivo:
		timer_perdida.start()

func _on_timer_perdida_timeout() -> void:
	jugador_objetivo = null
	esta_patrullando = true
