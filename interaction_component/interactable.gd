extends Area2D
class_name InteractableArea

@export var interaction_name: String = ""
@export var is_interactable: bool = true
# Adentro de interactable.gd
@export var recetas_disponibles: Array[Receta] = []

var interact: Callable = func():
	pass
	
func _ready():
	# Conexión forzada por código (ignora si está conectado en el editor)
	body_entered.connect(_on_test_entered)

func _on_test_entered(body):
	print("¡COLISIÓN DETECTADA! El cuerpo que entró es: ", body.name)
	# Si esto NO imprime nada en consola, es 100% un problema de Layer/Mask o CollisionShape

func interact_call():
	print("DEBUG: Se llamó a interact_call en ", name)
	if interact.is_valid():
		print("DEBUG: El Callable es válido, ejecutando...")
		interact.call()
	else:
		print("❌ ERROR: El Callable en ", name, " es inválido.")
