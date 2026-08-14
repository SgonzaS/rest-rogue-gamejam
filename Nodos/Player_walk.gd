extends State

var input_component : InputComponent
var velocity_component : VelocityComponent


func enter(args := {}):
	input_component = target.get_node("Input_Component")
	velocity_component = target.get_node("Velocity_Component")
	
	anim.play("run")

func state_process(delta : float) -> void:
	if input_component.input_motion == Vector2.ZERO:
		emit_signal("transitioned", self, "Idle", {})
	
	if input_component.input_motion.x != 0:
		target.get_node("AnimatedSprite2D").scale.x = roundi(input_component.input_motion.x)
		target.get_node("Pivote_arma").scale.x = roundi(input_component.input_motion.x)
	
	velocity_component.move(delta, input_component.input_motion)
	
	
	if input_component.input_attack:
		emit_signal("transitioned", self, "Move_attack", {
			"direction": input_component.input_motion,
			"velocity_component": velocity_component,
			"force": 10,
		})
		

	
	
