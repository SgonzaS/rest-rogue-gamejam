extends CharacterBody2D

# Configuración
@export var speed: float = 100.0
@export var rango_ataque: float = 60.0
@export var tiempo_ataque: float = 1.0

# Nodos
@onready var nav_agent = $NavigationAgent2D
@onready var sprite = $chanchoSprite
@onready var timer_ataque = $Timer
@onready var hitbox = $enemy_hitbox/CollisionShape2D
@onready var health_comp = $EnemyHealthComponent
# CORRECCIÓN: Usamos las barras que declaraste
@onready var barra_verde = $Control/Barraverde
@onready var barra_roja = $Control/Barraroja

var esta_persiguiendo = false
var puntos_patrulla = [] # O define una posición de origen
var destino_patrulla = Vector2.ZERO

var player = null
var puede_atacar = true

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	hitbox.disabled = true
	$enemy_hitbox.body_entered.connect(_on_hitbox_body_entered)
	
	# CORRECCIÓN: Inicializamos ambas barras
	barra_verde.max_value = health_comp.MAX_HEALTH
	barra_verde.value = health_comp.current_health
	barra_roja.max_value = health_comp.MAX_HEALTH
	barra_roja.value = health_comp.current_health
	
	health_comp.health_changed.connect(_on_health_changed)
	
	destino_patrulla = global_position

func _physics_process(_delta):
	if player and esta_persiguiendo:
		# LÓGICA DE PERSECUCIÓN
		var dist = global_position.distance_to(player.global_position)
		sprite.flip_h = (player.global_position.x < global_position.x)
		
		if dist <= rango_ataque:
			velocity = Vector2.ZERO
			if puede_atacar: ejecutar_ataque()
		else:
			nav_agent.target_position = player.global_position
			var next_pos = nav_agent.get_next_path_position()
			velocity = (next_pos - global_position).normalized() * speed
	else:
		# LÓGICA DE PATRULLA
		patrullar()
	
	move_and_slide()

func _on_health_changed(actual, maximo):
	# Actualizamos la barra verde inmediatamente
	barra_verde.value = actual
	
	# El efecto de "retraso" en la barra roja (Tween)
	var tween = create_tween()
	tween.tween_property(barra_roja, "value", float(actual), 0.4)

func patrullar():
	# El enemigo se mueve suavemente hacia su punto de origen o patrulla
	if global_position.distance_to(destino_patrulla) > 5.0:
		var dir = (destino_patrulla - global_position).normalized()
		velocity = dir * (speed * 0.5) # Patrulla a la mitad de velocidad
	else:
		velocity = Vector2.ZERO # Se queda quieto si llega al punto

func ejecutar_ataque():
	puede_atacar = false
	sprite.play("atacar")
	hitbox.disabled = false
	await get_tree().create_timer(0.3).timeout
	hitbox.disabled = true
	await get_tree().create_timer(tiempo_ataque).timeout
	puede_atacar = true

func _on_hitbox_body_entered(body):
	# Si el objeto que entra es el jugador, aplicamos daño
	if body.is_in_group("Player"):
		var comp_vida = body.get_node_or_null("HealthComponent")
		if comp_vida:
			comp_vida.damage(10)


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		esta_persiguiendo = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		esta_persiguiendo = false
