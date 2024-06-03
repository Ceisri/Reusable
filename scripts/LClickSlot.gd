extends TextureButton

onready var player: KinematicBody = $"../../../../.."
onready var icon: TextureRect = $Icon
onready var all_skills: Node = $"../../../SkillTrees"
func _ready() -> void:
	switchAttackIcon()
func switchAttackIcon() -> void:
	if all_skills.necro_switch == true:
		icon.texture = autoload.base_attack_necromant
	else:
		match player.weapon_type:
			autoload.weapon_list.fist:
				icon.texture = autoload.punch
			autoload.weapon_list.sword:
				icon.texture = autoload.slash_sword
			autoload.weapon_list.dual_swords:
				icon.texture = autoload.slash_sword
			autoload.weapon_list.bow:
				icon.texture = autoload.quick_shot
