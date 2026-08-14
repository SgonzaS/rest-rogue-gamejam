extends State


func enter(_args := {}):
	# 2. Detener al personaje físicamente
	if target.has_method("velocity"):
		target.velocity = Vector2.ZERO

	# Opción B: Si prefieres usar el AnimationPlayer directamente
	target.get_node("AnimationPlayer").play("muerte")

	# 4. (Opcional) Esperar a que la animación termine para borrar al personaje
	# var anim_player = target.get_node("AnimationPlayer")
	await anim.animation_finished
	self.queue_free()

func update(_delta):
	# Dejamos el update vacío para que no pueda moverse ni atacar
	pass
