# boton_receta.gd
extends Button

# Guardamos la receta asignada a este botón específico
var receta_asignada: Receta

# Señal para avisarle al menú principal qué receta se clickeó
signal receta_seleccionada(receta: Receta)

func _ready() -> void:
	# Conectamos el click del propio botón a nuestra función
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# Emitimos la señal pasando la receta como argumento
	receta_seleccionada.emit(receta_asignada)
