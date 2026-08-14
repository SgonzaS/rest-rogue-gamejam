extends Node2D

@onready var interac_label: Label = $InteractLabel

var current_interaction := []
var can_interact: bool = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact and current_interaction.size() > 0:
		# Ordenamos por cercanía para asegurar que interactuamos con el más próximo
		current_interaction.sort_custom(_sort_by_nearest)
		var objeto = current_interaction[0]
		
		# DEBUG: Mira qué objeto estamos intentando activar
		print("DEBUG: Intentando interactuar con: ", objeto.name)
		
		if objeto.has_method("interact_call"):
			can_interact = false
			await objeto.interact_call()
			can_interact = true
				
func _ready() -> void:
	# ✅ Forzamos a que el cartel empiece invisible al cargar la escena
	if interac_label != null:
		interac_label.hide()

func _process(delta: float) -> void:
	# 1. Limpiamos la lista quitando CUALQUIER cosa que huela a enemigo
	if current_interaction.size() > 0:
		var i = current_interaction.size() - 1
		while i >= 0:
			var area = current_interaction[i]
			# 🚨 Si el área es nula, no es válida, o es la hitbox del enemigo, la borramos de la lista de interacciones
			if area == null or not is_instance_valid(area) or "enemy" in area.name.to_lower():
				current_interaction.remove_at(i)
			i -= 1

	# 2. Ahora procesamos la interacción con lo que quedó en la lista (objetos reales)
	if current_interaction and current_interaction.size() > 0 and can_interact:
		current_interaction.sort_custom(_sort_by_nearest)
		var area_actual = current_interaction[0]
		
		# Verificamos si es un interactuable real con su variable
		if "interaction_name" in area_actual and area_actual.interaction_name != "":
			interac_label.text = area_actual.interaction_name
		else:
			# Si por alguna razón es un área sin nombre, usamos esto de respaldo
			interac_label.text = ""
			
		interac_label.show()
	else:
		# Si la lista quedó vacía tras limpiar los enemigos, ocultamos el cartel
		if interac_label != null:
			interac_label.hide()
		
		
		
func _sort_by_nearest(area1, area2):
	var area1_distance = global_position.distance_to(area1.global_position)
	var area2_distance = global_position.distance_to(area2.global_position)
	return area1_distance < area2_distance

func _on_interact_range_area_entered(area: Area2D) -> void:
	# 1. ¿El área tiene el script 'InteractableArea'?
	if area is InteractableArea:
		current_interaction.push_back(area)
		print("DEBUG: Objeto añadido a la lista: ", area.name)
	else:
		# 2. Si no, busca si un hijo tiene el script (a veces el padre es solo un contenedor)
		var interactable = area.get_node_or_null("Interactable") # O el nombre que tenga
		if interactable and interactable is InteractableArea:
			current_interaction.push_back(interactable)

#func _on_interact_range_area_entered(area: Area2D) -> void:
#	current_interaction.push_back(area)


func _on_interact_range_area_exited(area: Area2D) -> void:
	current_interaction.erase(area)
	
