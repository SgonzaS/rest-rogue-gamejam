class_name InputComponent
extends Node

# Input para movimientos
var input_motion : Vector2:
	get:
		input_motion = Input.get_vector("Mover_izquierda","Mover_derecha","Mover_arriba","Mover_abajo")
		return input_motion

# Input para interactuar
var input_action:
	get:
		input_action = Input.is_action_just_pressed("ui_accept")
		return input_action

# Input para atacar
var input_attack:
	get:
		# 1. Buscamos el Panel del inventario en toda la escena activa.
		# Cambiá "PanelContainer" por el nombre exacto de tu nodo de inventario si lo renombraste.
		var panel_inventario = get_tree().root.find_child("PanelContainer", true, false)
		
		# 2. Si el panel existe y se está mostrando en pantalla, bloqueamos el ataque devolviendo false
		if panel_inventario and panel_inventario.visible:
			return false
			
		# 3. Si el inventario está cerrado, el ataque funciona de manera normal
		#var input_attack = Input.is_action_just_pressed("attack")
		#return input_attack
