extends Control

func _on_boton_jugar_pressed() -> void:
	# Cambia "bosque" por el nombre del archivo de tu primer nivel
	get_tree().change_scene_to_file("res://game.tscn")
