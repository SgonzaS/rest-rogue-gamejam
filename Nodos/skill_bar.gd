extends HBoxContainer

var slots : Array
var hechizos_desbloqueados : Array = [Fireshot] # Hechizo inicial

# Diccionario para convertir el nombre del hechizo (String) en la clase real
var catalogo_hechizos = {
	"Fireshot": Fireshot,
	"Meteorito": Meteorito,
	"Curacion": Curacion 
}

func _ready() -> void:
	if global.hechizos_guardados.size() > 0:
		hechizos_desbloqueados = global.hechizos_guardados.duplicate()
	
	slots = get_children()
	actualizar_barra()

func actualizar_barra() -> void:
	# Limpiamos los slots
	for slot in slots:
		if slot:
			slot.skill = null
			slot.texture_normal = null
	
	# Asignamos las teclas
	for i in range(slots.size()):
		slots[i].change_key = str(i + 1)
		
	# Dibujamos los hechizos desbloqueados
	for i in range(hechizos_desbloqueados.size()):
		if i >= slots.size(): break
		
		var clase_hechizo = hechizos_desbloqueados[i]
		if slots[i] and clase_hechizo:
			var nuevo_hechizo = clase_hechizo.new()
			slots[i].setup_button(nuevo_hechizo)

func desbloquear_nuevo_hechizo(nombre_hechizo: String):
	if global.hechizos_guardados.has(catalogo_hechizos[nombre_hechizo]):
		print("Ya tienes este hechizo.")
		return
	if catalogo_hechizos.has(nombre_hechizo):
		var clase = catalogo_hechizos[nombre_hechizo]
		
		# 1. Agregamos la clase al array local
		hechizos_desbloqueados.append(clase)
		
		# 2. Actualizamos la variable global para que persista
		global.hechizos_guardados = hechizos_desbloqueados.duplicate()
		
		print("🎉 ¡Nuevo hechizo '", nombre_hechizo, "' desbloqueado!")
		
		# 3. Refrescamos la UI
		actualizar_barra()
	else:
		print("❌ Error: El hechizo '", nombre_hechizo, "' no existe en el catálogo.")
