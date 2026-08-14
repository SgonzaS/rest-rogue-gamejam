extends TextureButton

@onready var cooldawn = $Cooldawn
@onready var key = $tecla
@onready var time = $time
@onready var timer = $Timer


var skill = null

var change_key = "":
	set(value):
		change_key = value
		key.text = value
		
		
		shortcut = Shortcut.new()
		var input_key = InputEventKey.new()
		input_key.keycode = value.unicode_at(0)
		
		shortcut.events = [input_key]

func _ready() -> void:
	change_key = "1"
	cooldawn.max_value = timer.wait_time
	set_process(false)
	
	
func _process(delta: float) -> void:
	time.text = "%3.1f" % timer.time_left
	cooldawn.value = timer.time_left
	

func _on_pressed() -> void:
	if skill != null:
		# Buscamos al Player directamente en la escena activa por su nombre
		var jugador_real = get_tree().current_scene.get_node_or_null("Player")
		
		# Si tu escena raíz se llama "Game" y el Player está colgado ahí, esto no falla:
		if jugador_real == null:
			jugador_real = get_node_or_null("/root/Game/Player")

		if jugador_real != null:
			skill.cast_spell(jugador_real)
		else:
			print("❌ Error Crítico: No se encontró ningún nodo llamado 'Player' en la escena.")
		
		timer.start()
		disabled = true
		set_process(true)

func _on_timer_timeout() -> void:
	disabled = false
	time.text = ""
	cooldawn.value = 0
	set_process(false)
	
	
func setup_button(new_skill) -> void:
	skill = new_skill
	
	# Si el hechizo tiene una textura asignada, se la aplicamos al botón visible
	if skill != null and "texture" in skill:
		if skill.texture != null:
			texture_normal = skill.texture
		
