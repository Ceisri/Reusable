extends StaticBody

onready var mesh = $Mesh
var damage_type:String = ""
var weapon_damage:float = 3


var item_type: String 
func _ready():
	print(str(item_type))
	if mesh.is_in_group("sword"):
		item_type = "sword"
		damage_type = "slash"
	elif mesh.is_in_group("bow"):
		item_type = "bow"
		damage_type = "pierce"
	elif mesh.is_in_group("heavy"):
		item_type = "heavy"
		damage_type = "toxic"
	else:
		print("YOU FORGOT TO THE MESH OF THE WEAPON TO A GROUP, therefore weapon type can't be defined")
