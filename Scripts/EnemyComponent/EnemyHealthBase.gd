extends CharacterBody2D
class_name EnemyBase # Esto permite que otros scripts reconozcan esta clase

@onready var health_comp = $EnemyHealthComponent
@onready var barra_verde = $HealthBarUI/Barraverde
@onready var barra_roja = $HealthBarUI/Barraroja

func _ready():
	# Inicialización estándar
	barra_verde.max_value = health_comp.MAX_HEALTH
	barra_verde.value = health_comp.current_health
	barra_roja.max_value = health_comp.MAX_HEALTH
	barra_roja.value = health_comp.current_health
	
	health_comp.health_changed.connect(_on_health_changed)

func _on_health_changed(actual, maximo):
	barra_verde.value = actual
	var tween = create_tween()
	tween.tween_property(barra_roja, "value", float(actual), 0.4)
