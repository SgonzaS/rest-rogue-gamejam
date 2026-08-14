extends Area2D

# Le pasamos el recurso del ítem que va a representar
@export var item_data: Item

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	# Si le asignamos datos, hacemos que el sprite cambie automáticamente al de su ícono
	if item_data and item_data.icono:
		sprite_2d.texture = item_data.icono

# Conectamos la señal body_entered de la propia Area2D
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if global.mochila_guardada != null:
			# Añadimos el recurso directamente a la base de datos de la mochila
			global.mochila_guardada.agregar_item(item_data, 1)
			
			# 2. Buscamos la UI para avisarle que tiene que redibujarse
			# Cambiamos "Control" por "Panel" que es el nombre real de tu nodo de inventario
			var inventario_ui = get_tree().root.find_child("Panel", true, false)
			if inventario_ui and inventario_ui.has_method("actualizar_todas_la_ui"):
				inventario_ui.actualizar_todas_la_ui()
			
			# 3. Hacemos que el objeto desaparezca del suelo visualmente
			queue_free()
