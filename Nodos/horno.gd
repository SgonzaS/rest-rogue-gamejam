extends StaticBody2D

# 1. Referencia al nodo de interacción dentro del horno
@onready var interactable = $Interactable 

func _ready() -> void:
	# Nos aseguramos de que este objeto asigne SU PROPIA función
	# y no la de otro objeto.
	add_to_group("Interactuables") # Esto registra al horno en el grupo
	
	if interactable:
		interactable.interact = _on_interact
	

func desbloquear_interaccion() -> void:
	# Esto garantiza que este horno específico se vuelva a activar
	$Interactable.is_interactable = true

# 2. Función específica para este horno
func _on_interact() -> void:
	print("🔥 [HORNO] Iniciando interacción...")

	# 1. Buscamos el menú en el árbol de nodos de forma global y segura
	# Buscamos en el grupo "Menu" en lugar de buscar por nombre en el árbol
	var menu_cocina = get_tree().get_first_node_in_group("Menu")
	
	if menu_cocina == null:
		print("❌ [HORNO] ERROR CRÍTICO: No se encontró 'MenuCocina'.")
		print("👉 Asegúrate de que el nodo se llame exactamente 'MenuCocina'.")
		return

	# 2. Verificamos que el menú tenga la función necesaria antes de llamarla
	if menu_cocina.has_method("cargar_recetas"):
		# Usamos un acceso seguro a la propiedad 'recetas_disponibles'
		if "recetas_disponibles" in interactable:
			menu_cocina.cargar_recetas(interactable.recetas_disponibles)
			print("✅ [HORNO] Recetas enviadas al menú.")
		else:
			print("⚠️ [HORNO] Advertencia: 'recetas_disponibles' no existe en Interactable.")
			menu_cocina.cargar_recetas([]) # Enviamos vacío para evitar crashes
	else:
		print("❌ [HORNO] ERROR: El nodo 'MenuCocina' no tiene la función 'cargar_recetas'.")
		return

	# 3. Mostramos el menú
	menu_cocina.show()
	
	# Opcional: Si quieres que el juego se pause al cocinar, descomenta la siguiente línea:
	# get_tree().paused = true
	
	print("✨ [HORNO] Menú mostrado con éxito.")

# 3. Función auxiliar por si el componente de interacción la necesita
func interact_call() -> void:
	_on_interact()
