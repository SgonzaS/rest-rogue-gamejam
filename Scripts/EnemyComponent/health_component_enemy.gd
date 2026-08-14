class_name HealthComponentEnemy 
extends Node

signal Muerte
# Vida maxima
@export var MAX_HEALTH : int
@export var resistence : int

# Vida actual con la cual se interactuara
@onready var current_health := MAX_HEALTH:
	set(value):
		current_health = value
		current_health = clampi(current_health, 0, MAX_HEALTH)
		if current_health <= 0:
			Muerte.emit()
		
		

# Añadir vida
func heal(value : int) -> void:
	current_health += value
	
# Restar vida
func damage(value : int) -> void:
	current_health -= value


func _on_timer_timeout() -> void:
	current_health = MAX_HEALTH
