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
) -> void:
	var all_icons = [icon1, icon2, icon3, icon4, icon5, icon6, icon7, icon8, icon9, icon10, icon11, icon12, icon13, icon14, icon15, icon16, icon17, icon18, icon19, icon20, icon21, icon22, icon23, icon24]
	for icon in all_icons:
		icon.texture = null
		icon.modulate = Color(1, 1, 1)
		var label = icon.get_node("Label")
		if label == null: 
			if get_parent().has_node("Debug"):
				get_parent().get_node("Debug").effect_error = "label missing at" + str(icon.name)
		else: 
			label.text = " "  # Set text to " " for all icons initially
	
	var applied_effects = [
		{"name": "bleed", "texture": Icons.bleed, "modulation_color": Color(1, 1, 1)},
		{"name": "stun", "texture": Icons.stun, "modulation_color": Color(1, 1, 1)}
	]

	for effect in applied_effects:
		if effects.has(effect["name"]) and effects[effect["name"]]["applied"]:
			for icon in all_icons:
				if icon.texture == null:
					icon.texture = effect["texture"]
					icon.modulate = effect["modulation_color"]
					var label = icon.get_node("Label")
					if effect["name"] == "bleed":
						label.text = str(bleed_duration)
					elif effect["name"] == "stun":
						label.text = str(stun_duration)
					break
					
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
		if get_parent().has_node("Debug"):
			get_parent().get_node("Debug").effect_error = "Effect not found:" + effect_name
		else:
			print("Effect not found:", effect_name)
				
var bleed_duration:int = 1
var stun_duration:int = 1
#put on a 1 second timer or every 60,30 or whatever your max physics frame is to mimic a second,
#you could use -= delta but, but then again why refersh something like 60 times a second if you need it 1 times per second? 
func effectManager() -> void: 
	if bleed_duration > 0 : 
		bleed_duration -= 1
		applyEffect("bleed",true)
	else:
		applyEffect("bleed",false)
		
	if stun_duration > 0 : 
		stun_duration -= 1
		applyEffect("stun",true)
	else:
		applyEffect("stun",false)
