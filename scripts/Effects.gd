extends Node


var effects:Dictionary = { #Reminder to add extra_on_hit_resolve_regen to weapons
	"none": {"stats": {}, "applied": false},
	"bleed": {"stats": {"extra_melee_atk_speed": 5.22,}, "applied": false},
	"stun": {"stats": {"extra_melee_atk_speed": 5.22,}, "applied": false},
	}
	
func showStatusIcon(
	icon1: TextureRect, icon2: TextureRect, icon3: TextureRect, icon4: TextureRect, 
	icon5: TextureRect, icon6: TextureRect, icon7: TextureRect, icon8: TextureRect, 
	icon9: TextureRect, icon10: TextureRect, icon11: TextureRect, icon12: TextureRect, 
	icon13: TextureRect, icon14: TextureRect, icon15: TextureRect, icon16: TextureRect, 
	icon17: TextureRect, icon18: TextureRect, icon19: TextureRect, icon20: TextureRect, 
	icon21: TextureRect, icon22: TextureRect, icon23: TextureRect, icon24: TextureRect
)->void:

	# Reset all icons
	var all_icons = [icon1, icon2, icon3, icon4, icon5, icon6, icon7, icon8, icon9, icon10, icon11, icon12, icon13, icon14, icon15, icon16, icon17, icon18, icon19, icon20, icon21, icon22, icon23, icon24]
	for icon in all_icons:
		icon.texture = null
		icon.modulate = Color(1, 1, 1)
	var applied_effects = [
		{"name": "bleed", "texture":Icons.bleed, "modulation_color": Color(1, 1, 1)},
		{"name": "stun", "texture":Icons.stun, "modulation_color": Color(1, 1, 1)}
		]

	for effect in applied_effects:
		if effects.has(effect["name"]) and effects[effect["name"]]["applied"]:
			for icon in all_icons:
				if icon.texture == null:
					icon.texture = effect["texture"]
					icon.modulate = effect["modulation_color"]
					break  # Exit loop after applying status to the first available icon
func applyEffect(effect_name: String, active: bool)->void:
	var stats = get_parent().get_node("Stats")
	if effects.has(effect_name):
		var effect = effects[effect_name]
		if active and not effect["applied"]:
			# Apply effect
			for stat_name in effect["stats"].keys():
				stats[stat_name] += effect["stats"][stat_name]
			effect["applied"] = true
		elif not active and effect["applied"]:
			# Remove effect
			for stat_name in effect["stats"].keys():
				if stat_name in stats:
					stats[stat_name] -= effect["stats"][stat_name]
			effect["applied"] = false
	else:
		print("Effect not found:", effect_name)
