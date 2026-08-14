extends ProgressBar

func _ready():
	# Nos conectamos a la señal del Global
	global.tiempo_actualizado.connect(_actualizar_barra)
	hide() # La ocultamos al empezar

func _actualizar_barra(porcentaje):
	value = porcentaje
	if porcentaje > 0:
		show()
	else:
		hide() # La ocultamos cuando el tiempo se agota
