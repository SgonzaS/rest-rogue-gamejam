extends State

var health_component : HealthComponent
var input_component : InputComponent

func enter(args := {}):
	health_component = target.get_node("HealthComponent")
	input_component = target.get_node("Input_Component")
	
	anim.play("attack")
	
	#health_component.damage(25)
	#dprint(health_component.current_health)
	
	await anim.animation_finished
	#await get_tree().create_timer(0.5).timeout
	emit_signal("transitioned", self, "idle", {})
