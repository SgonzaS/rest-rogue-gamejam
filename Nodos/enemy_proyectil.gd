extends Area2D

@export var velocidad: float = 400.0
@export var dano: int = 20
var direccion: Vector2 = Vector2.RIGHT
var dueño: Node2D = null

func _ready() -> void:
	direccion = Vector2.RIGHT.rotated(rotation)
	# Conectamos la señal para detectar colisiones
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	# Mover el proyectil hacia adelante
	position += direccion * velocidad * _delta

func _on_body_entered(body: Node2D) -> void:
	# 1. Evitar que el proyectil se autodestruya al salir del enemigo
	if body == dueño:
		return 
		
	# 2. Verificar si el cuerpo tocado tiene un componente de salud
	# Usamos find_child para buscar el nodo hijo llamado "HealthComponent"
	var health_comp = body.find_child("HealthComponent")
	
	if health_comp != null:
		# Aplicamos el daño directamente al componente
		health_comp.damage(dano)
		print("¡Daño recibido! Vida actual: ", health_comp.current_health)
		
		# Destruir proyectil al impactar
		queue_free()
	
	# 3. Si choca contra algo que no tiene vida (paredes), también se destruye
	elif not body.is_in_group("Enemigos"):
		queue_free()
	# Lógica de rebote (opcional, si quieres usarla)
	# var rebote = velocity.bounce(colision.get_normal())
	# velocity = rebote
