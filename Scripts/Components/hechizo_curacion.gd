extends Node2D
class_name RayoCurativo

var cantidad: int = 0

func _ready() -> void:
	# 1. Reproducir animación de destello/rayo
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default")
		
	# 2. Aplicar la curación al jugador inmediatamente
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_node("HealthComponent"):
		var health_comp = player.get_node("HealthComponent")
		if health_comp.has_method("heal"):
			health_comp.heal(cantidad)
			
	# 3. Auto-destrucción al terminar la animación
	if has_node("AnimatedSprite2D"):
		await $AnimatedSprite2D.animation_finished
	queue_free()
