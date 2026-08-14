extends Resource

class_name skill

var cooldawn : int
var texture : Texture2D
var animation_name : String

func _init(target) -> void:
	target.cooldawn.max_value = cooldawn
	target.texture_normal = texture
	target.timer.wait_time = cooldawn
	
func cast_spell(target):
	print(animation_name + " casted from " + target.name)
