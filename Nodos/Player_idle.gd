extends State

var input_component : InputComponent

func enter(args := {}):
	input_component = target.get_node("Input_Component")

	anim.play("idle")

func state_process(delta : float) -> void:
	if input_component.input_motion:
		emit_signal("transitioned", self, "Walk", {})
	
	if input_component.input_attack:
		emit_signal("transitioned", self, "Move_attack", {})
	
