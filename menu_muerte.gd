extends Panel

func _ready() -> void:
	hide() # Aseguramos que inicie invisible

func _on_reiniciar_pressed() -> void:
	get_tree().paused = false
	global.mochila_guardada = Mochila.new()
	get_tree().change_scene_to_file("res://game.tscn")

func _on_menu_principal_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://escenas/MenuPrincipal.tscn")
