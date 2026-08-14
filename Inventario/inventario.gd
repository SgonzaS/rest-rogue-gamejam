# Clase de Inventario
# Esta clase extiende 'Resource' para crear un objeto de datos de inventario.
# Sirve para gestionar y almacenar los objetos de un jugador.
extends Resource

# nombre de la clase del inventario
class_name Mochila

#variable para guardar los items
@export var objetos:Dictionary = {}

# funcion para agregar los items a la variable objetos
# Retorna 'true' si el ítem se agregó con éxito.
func agregar_item(item: Item, cantidad_adicional: int):
	# Aquí sumas el ítem y le agregas la cantidad extra
	item.cantidad += cantidad_adicional
	var clave = item.nombre 
	
	# 1. Si es apilable, buscamos si YA existe en el diccionario
	if item.apilable:
		for clave_existente in objetos:
			var item_en_mochila = objetos[clave_existente]
			# Si coincide el nombre y no se pasó del límite máximo
			if item_en_mochila.nombre == item.nombre and item_en_mochila.cantidad < item_en_mochila.max_cantidad:
				item_en_mochila.cantidad += 1
				return true # Se apiló con éxito en los datos
	
	# 2. Si no es apilable o no encontró espacio para apilarse, creamos uno nuevo
	var nueva_instancia_item = item.duplicate()
	# Nos aseguramos de que si es nuevo arranque en cantidad 1
	if nueva_instancia_item.cantidad <= 0:
		nueva_instancia_item.cantidad = 1
		
	var clave_nueva = clave
	if not nueva_instancia_item.apilable or objetos.has(clave_nueva):
		clave_nueva += "_" + str(randi())
	
	objetos[clave_nueva] = nueva_instancia_item
	# Cambiá temporalmente la línea 37 por esto para espiar las rutas de tu mochila:
	print("🎒 [CONTENIDO MOCHILA]: ", objetos.keys())
	return true
	
# 🧐 FUNCIÓN 1: Cuenta cuántas unidades totales tenés de un recurso de ítem específico
# 🧐 FUNCIÓN 1: Cuenta cuánto tenés comparando nombres de forma segura
# 🧐 FUNCIÓN 1: El escáner de la mochila
func obtener_cantidad_de_item(item_buscado: Item) -> int:
	if item_buscado == null: 
		print("❌ [ERROR] El item buscado por la receta es NULL.")
		return 0
	
	var total = 0
	var nombre_a_buscar = item_buscado.nombre
	
	print("🔍 [INVENTARIO] Buscando el string exacto: '", nombre_a_buscar, "'")
	
	for clave in objetos:
		var item_en_mochila = objetos[clave]
		if item_en_mochila == null: 
			continue
			
		var nombre_en_slot = item_en_mochila.nombre
		print("   📦 Revisando slot '", clave, "' -> Su variable nombre dice: '", nombre_en_slot, "' (Cantidad: ", item_en_mochila.cantidad, ")")
		
		# Comparamos sin to_lower ni nada, el texto crudo
		if nombre_en_slot == nombre_a_buscar:
			total += item_en_mochila.cantidad
			print("   ✅ ¡MATCH PERFECTO en slot '", clave, "'!")
			
	print("📊 [RESULTADO] Total encontrado de '", nombre_a_buscar, "': ", total)
	return total

# 🧐 FUNCIÓN 2: El escáner de la receta
func tiene_ingredientes_necesarios(receta: Receta) -> bool:
	print("--------------------------------------------------")
	print("🍳 [COCINA] Chequeando receta: ", receta.nombre_comida)
	
	if receta.ingrediente == null:
		print("❌ [ERROR] La receta no tiene ningún ingrediente cargado en el Inspector.")
		return false
		
	print("📝 [RECETA] Exige cantidad: ", receta.cantidad, " del ítem: '", receta.ingrediente.nombre, "'")
	
	var cantidad_que_tengo = obtener_cantidad_de_item(receta.ingrediente)
	
	if cantidad_que_tengo >= receta.cantidad:
		print("✅ [ÉXITO] Tenés materiales de sobra o exactos.")
		return true
	else:
		print("❌ [FRACASO] Te faltan materiales. Tenés ", cantidad_que_tengo, " y pide ", receta.cantidad)
		return false

# 🧼 FUNCIÓN 3: Gasta los recursos de ingredientes y te añade el plato terminado
func cocinar_receta(receta: Receta) -> void:
	if not tiene_ingredientes_necesarios(receta):
		print("❌ No tenés los materiales suficientes en la mochila.")
		return
		
	print("🍳 [MOCHILA] Comenzando proceso de cocina para: ", receta.nombre_comida)
	
	# 1. Consumimos el ingrediente único usando tu función por nombre
	_eliminar_cantidad_por_nombre(receta.ingrediente.nombre, receta.cantidad)
		
	# 2. Te damos el plato terminado (item_resultado)
	for i in range(receta.cantidad_resultado):
		agregar_item(receta.item_resultado, 0)
		
	print("🍳 ¡Cocinaste con éxito: ", receta.nombre_comida, "!")


# 🧹 FUNCIÓN INTERNA: Busca los ítems en el diccionario y les resta la cantidad real
func _eliminar_cantidad_por_nombre(nombre_item_a_borrar: String, cantidad_total_a_sacar: int) -> void:
	var cantidad_restante = cantidad_total_a_sacar
	var claves_a_eliminar: Array[String] = []
	
	
	print("🧼 [MOCHILA] Intentando gastar ", cantidad_total_a_sacar, " unidades de: ", nombre_item_a_borrar)
	
	# Recorremos todas las claves lógicas del diccionario de objetos
	for clave in objetos:
		if cantidad_restante <= 0:
			break
			
		var item_en_mochila = objetos[clave]
		
		# 🎯 COMPROBACIÓN: Comparamos el nombre real del recurso dentro del slot
		if item_en_mochila != null and item_en_mochila.nombre == nombre_item_a_borrar:
			if item_en_mochila.cantidad <= cantidad_restante:
				# Caso A: El slot tiene menos o lo mismo de lo que necesito. Se vacía completo.
				cantidad_restante -= item_en_mochila.cantidad
				claves_a_eliminar.append(clave)
				print("   -> Slot '", clave, "' anotado para eliminar por completo.")
			else:
				# Caso B: El slot tiene más cantidad de la que necesito. Solo le restamos la diferencia.
				item_en_mochila.cantidad -= cantidad_restante
				cantidad_restante = 0
				print("   -> Reducida cantidad en slot '", clave, "'. Quedan: ", item_en_mochila.cantidad)
				
	# Borramos físicamente del diccionario los slots que quedaron en 0
	for clave in claves_a_eliminar:
		objetos.erase(clave)
		print("   ❌ Slot '", clave, "' borrado físicamente del diccionario objetos.")
		
	if cantidad_restante > 0:
		print("⚠️ [MOCHILA] Error inesperado: Faltaron borrar ", cantidad_restante, " unidades de ", nombre_item_a_borrar)
func tiene_item_con_nombre(nombre_item: String) -> int:
	var total = 0
	# Recorremos el diccionario de objetos
	for clave in objetos:
		var item_en_mochila = objetos[clave]
		if item_en_mochila != null and item_en_mochila.nombre == nombre_item:
			total += item_en_mochila.cantidad
	return total
	
# 🧐 FUNCIÓN: El escáner específico para RECETAS
func obtener_cantidad_de_receta(receta_buscada: Receta) -> int:
	var total = 0
	for clave in objetos:
		var obj = objetos[clave]
		# Comparamos nombres (asegúrate de que sean idénticos, incluyendo mayúsculas)
		if obj != null and obj.nombre == receta_buscada.nombre_comida:
			total += obj.cantidad
	return total
