extends Panel
# Se utiliza para representar un espacio o ranura individual dentro de un inventario,
# como un slot en una mochila o barra de acceso rápido.
@onready var icono_item: TextureRect = $TextureRect
@onready var label: Label = $Label
var item_data = null
# Función para "llenar" el slot con un ítem.
# Este método actualiza la interfaz de usuario del slot para mostrar la información del ítem.
# 'item' es un objeto que contiene los datos del ítem a mostrar (por ejemplo, el icono y la cantidad).
func llenar_espacio(item):
	item_data = item
	label.text = str(item.cantidad)
	icono_item.texture = item.icono
	
# Función para "vaciar" el slot.
# Este método resetea la interfaz de usuario del slot, dejándolo en un estado vacío.
func vaciar_valores():
	item_data = null
	label.text = ""
	icono_item.texture = null


func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return item_data == null
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if not icono_item.texture:
		icono_item.texture = data.icono_item.texture
		label.text = data.label.text
		item_data = data.item_data
		data.vaciar_valores()

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not item_data:
		return null
	var drag_preview = TextureRect.new()
	drag_preview.texture = icono_item.texture
	drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	drag_preview.custom_minimum_size = Vector2(32, 32)
	set_drag_preview(drag_preview)
	return self
