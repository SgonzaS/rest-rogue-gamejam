extends skill
class_name Curacion

# Cargamos la escena visual del rayo de luz
var rayo_scene = preload("res://Nodos/Curacion.tscn")
@export var cantidad_curacion: int = 20

func _init() -> void:
	cooldawn = 10.0 # Tiempo de espera mayor para curación
	animation_name = "curacion"
	texture = preload("res://Art/FireBalls/5/10.png")

func cast_spell(caster) -> void:
	# 1. Ejecutamos la lógica base de cooldown
	super.cast_spell(caster)
	
	var caster_2d = caster as Node2D
	if caster_2d == null: return

	# 2. Instanciamos el efecto visual
	var rayo_instance = rayo_scene.instantiate()
	
	# 3. Lo ponemos sobre el jugador
	rayo_instance.global_position = caster_2d.global_position
	
	# 4. Inyectamos la cantidad de curación al efecto
	rayo_instance.cantidad = cantidad_curacion
	
	# 5. Agregamos al árbol de forma segura
	caster_2d.get_tree().current_scene.call_deferred("add_child", rayo_instance)
	
	print("✨ Rayo de curación invocado sobre el jugador.")
