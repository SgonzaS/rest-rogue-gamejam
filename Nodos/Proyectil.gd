extends Area2D

var speed : float = 120
var enemy_hit = false
var enemy_heal = HealthComponentEnemy

var direction : Vector2 = Vector2.RIGHT:
	set(value):
		direction = value
		if $AnimatedSprite2D.animation != "fuego morado":
			rotation = direction.angle()
			
func _ready() -> void:
	#body_entered.connect(_on_body_entered)
	pass
func _physics_process(delta: float) -> void:
	global_position += speed * direction * delta
	
func play(animation_name = "fuego rojo"):
	$AnimatedSprite2D.play(animation_name)


func _on_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemigos"):
		# 2. Buscamos el componente de vida dentro de ese cuerpo específico
		# Ajusta "EnemyHealthComponent" al nombre exacto de tu nodo componente
		var health_comp = body.get_node_or_null("EnemyHealthComponent")
		
		if health_comp and health_comp.has_method("damage"):
			# 3. Aplicamos el daño de 20
			health_comp.damage(20)
			
			# 4. Eliminamos el proyectil tras el impacto
			queue_free()
		
	
	
	
	
			
		
	queue_free()
		
