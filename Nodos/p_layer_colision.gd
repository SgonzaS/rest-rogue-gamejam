extends State

var enemy_inattack_range = false
var enemy_attack_cooldawn = true
@export var health_component : HealthComponent


func enter(args : Dictionary):
	health_component = target.get_node("HealthComponent")
	
func _physics_process(delta: float) -> void:
	enemy_attack()
	
	
func Player1():
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("enemy1"):
		enemy_inattack_range = true	
		


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("enemy1"):
		enemy_inattack_range = false
		
func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldawn == true:
		health_component.damage(20)
		enemy_attack_cooldawn = false
		$"../attack_cooldown".start()
		print(health_component.current_health)
		#print("me pego")
func _on_weapon_colision_body_entered(body: Node2D) -> void:
	# 1. Este mensaje sale sí o sí si el área choca con ALGO.
	print("El arma tocó a: ", body.name) 
	# 2. Vemos si pasa la prueba de reconocer al enemigo
	if body.has_method("enemy1"):
		print("¡Reconoció que es el enemigo!")
		
		var health_comp_enemy = body.find_child("EnemyHealthComponent")
		
		# 3. Vemos si encuentra el componente
		if health_comp_enemy != null:
			print("¡Encontró el componente de vida!")
			health_comp_enemy.damage(20)
			print("Vida restante: ", health_comp_enemy.current_health)
			
	
func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldawn = true


	



	pass # Replace with function body.
