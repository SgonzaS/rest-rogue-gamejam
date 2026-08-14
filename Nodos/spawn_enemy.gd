extends Area2D

@export var enemy_scene: PackedScene

# ✅ NUEVO: El ítem que querés que tiren los enemigos que nazcan de este Spawner
@export_group("Configuración de Botín")
@export var item_para_clones: Item
@export_range(0.0, 100.0) var probabilidad_drop: float = 100.0

@onready var respawn_timer: Timer = $respawntimer
@onready var collision_shape: CollisionShape2D = $spawn_enemy_area 

func _ready() -> void:
	if not respawn_timer.timeout.is_connected(_spawn_enemy):
		respawn_timer.timeout.connect(_spawn_enemy)
	_spawn_enemy()

func _spawn_enemy() -> void:
	if enemy_scene == null:
		return
		
	var enemigo_instancia = enemy_scene.instantiate()
	
	# 🎯 NUEVO: Buscamos el componente de vida del clon antes de meterlo a la escena
	var health_comp = enemigo_instancia.find_child("EnemyHealthComponent", true, false)
	if health_comp != null:
		# Le pasamos los datos que configuramos en este Spawner
		health_comp.item_a_soltar = item_para_clones
		health_comp.probabilidad_drop = probabilidad_drop
	else:
		print("⚠️ [SPAWNER] Advertencia: El clon no tiene un nodo llamado 'EnemyHealthComponent'.")
	
	# 🎲 CALCULAMOS LA POSICIÓN ALEATORIA DENTRO DEL ÁREA
	enemigo_instancia.global_position = _get_random_position_in_area()
	enemigo_instancia.z_index = 3
	
	enemigo_instancia.tree_exited.connect(_on_enemy_died)
	
	# Lo agregamos de forma diferida (segura)
	get_tree().current_scene.call_deferred("add_child", enemigo_instancia)

func _on_enemy_died() -> void:
	print("⏳ [SPAWNER] Enemigo eliminado. Iniciando respawn...")
	respawn_timer.start(2.0)

# 🧮 FUNCIÓN MATEMÁTICA PARA EL ÁREA
func _get_random_position_in_area() -> Vector2:
	if collision_shape != null and collision_shape.shape != null:
		if collision_shape.shape is RectangleShape2D:
			var rect = collision_shape.shape as RectangleShape2D
			var size = rect.size
			
			var random_x = randf_range(-size.x / 2, size.x / 2)
			var random_y = randf_range(-size.y / 2, size.y / 2)
			
			return collision_shape.global_position + Vector2(random_x, random_y)
	
	return global_position
