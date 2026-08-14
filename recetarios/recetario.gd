extends Resource
class_name Receta

@export var nombre_comida: String 

# 💎 Apunta directo a tu recurso .tres del plato terminado
@export var item_resultado: Item 
@export var cantidad_resultado: int = 1

# 💎 Obligamos al diccionario a pedir la clase Item como clave y un entero como valor
#@export var ingredientes: Dictionary[Item, int] = {}
@export var ingrediente: Item
@export var cantidad: int 

#@export var lista_ingredientes: Array[IngredienteReceta] = []
@export var nombre_hechizo: String
@export var cantidad_oro: int
