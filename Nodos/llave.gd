extends StaticBody2D

@onready var Interactable: Area2D = $Interactable
@onready var sprite_2D: Sprite2D = $Sprite2D


func _ready() -> void:
	# Asignamos la función de interacción
	Interactable.interact = _alternar_estado_restaurante

func _alternar_estado_restaurante():
	if not global.restaurante_abierto:
		global.abrir_restaurante()
	else:
		print("El restaurante ya está abierto. ¡A trabajar!")
