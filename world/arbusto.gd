extends Area2D

@onready var Interactable: Area2D = $Interactable # Asegúrate de que el nodo se llame "Interactable"
@export var item_a_soltar: Item

func _ready() -> void:
	# IMPORTANTE: No llames a la función con (), solo pásala como referencia.
	# Esto asigna la lógica al objeto para que el sistema de interacciones la encuentre.
	if Interactable.has_method("interact_call"):
		# Asignamos el "Callable" directamente a la variable interact que ya tienes
		Interactable.interact = Callable(self, "agarrar_objeto")
		print("La interacción se conectó")
	# Asignamos la función de interacción
#	Interactable.interact=agarrar_objeto()

func agarrar_objeto():
	print("DEBUG: Ejecutando agarrar_objeto")
	var cantidad_aleatoria = randi_range(1, 5)
	
	if global.mochila_guardada:
		print("DEBUG: Mochila encontrada, intentando agregar item...")
		global.mochila_guardada.agregar_item(item_a_soltar, cantidad_aleatoria)
		
		print("DEBUG: Ítem agregado, borrando arbusto...")
		queue_free()
	else:
		print("ERROR: ¡global.mochila_guardada es NULL!")
		
