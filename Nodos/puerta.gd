extends Area2D


@export var new_escene_path: String



func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("estas por salir ", body.name)
		
		if body.has_node("HealthComponent"):
			var componente_salud = body.get_node("HealthComponent")
			
			# Guardamos el valor actual de su variable en el script global
			global.vida_guardada = componente_salud.current_health
			
		var skill_bar = get_tree().root.find_child("SkillBar", true, false)
		if skill_bar != null:
			# Guardamos una copia limpia de tus hechizos desbloqueados en el script global
			global.hechizos_guardados = skill_bar.hechizos_desbloqueados.duplicate()
			
		change_scene()
		
func change_scene():
	get_tree().change_scene_to_file(new_escene_path)
	
		
