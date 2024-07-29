extends Node

var apothecary_list = {
	"empty_potion": {
		"price": 3,
		"icon": preload("res://Game/Interface/Assets/Icons/Alchemy/Alchemy_09_test_tube.png"),
		"rarity": 10.0
	},
	"red_potion": {
		"price": 100,
		"icon": preload("res://Game/Interface/Assets/Icons/Alchemy/Alchemy_13_heal_potion.png"),
		"rarity": 30.0
	},
	"blue_potion": {
		"price": 50,
		"icon": preload("res://Game/Interface/Assets/Icons/Alchemy/Alchemy_17_blue_potion.png"),
		"rarity": 25.0
	},
	"magic_mixture": {
		"price": 200,
		"icon": preload("res://Game/Interface/Assets/Icons/Alchemy/Alchemy_18_magic_mixture.png"),
		"rarity": 50.0
	},
	"magical flask": {
		"price": 500,
		"icon": preload("res://Game/Interface/Assets/Icons/Alchemy/Alchemy_47_middlemagical_flask.png"),
		"rarity": 80.0
	}
}


var costermonger_list = {
	"broccoli": {
		"price": 5,
		"icon": preload("res://Game/Interface/Assets/Icons/Cooking_fishing/Broccoli.png"),
		"rarity": 10.0
	},
	"cabbage": {
		"price": 4,
		"icon": preload("res://Game/Interface/Assets/Icons/Cooking_fishing/Cabbage.png"),
		"rarity": 10.0
	},
	"carrot": {
		"price": 3,
		"icon": preload("res://Game/Interface/Assets/Icons/Cooking_fishing/Carrot.png"),
		"rarity": 10.0
	},
	"pear": {
		"price": 6,
		"icon": preload("res://Game/Interface/Assets/Icons/Cooking_fishing/Cooking_03_pear.png"),
		"rarity": 30.0
	},
	"apple": {
		"price": 4,
		"icon": preload("res://Game/Interface/Assets/Icons/Cooking_fishing/Cooking_04_apple.png"),
		"rarity": 30.0
	},
	"red_grapes": {
		"price": 7,
		"icon": preload("res://Game/Interface/Assets/Icons/Cooking_fishing/Cooking_05_redgrapes.png"),
		"rarity": 50.0
	},
	"green_grapes": {
		"price": 7,
		"icon": preload("res://Game/Interface/Assets/Icons/Cooking_fishing/Cooking_06_greengrapes.png"),
		"rarity": 50.0
	},
	"blue_grapes": {
		"price": 7,
		"icon": preload("res://Game/Interface/Assets/Icons/Cooking_fishing/Cooking_07_bluegrapes.png"),
		"rarity": 50.0
	},
	"onion": {
		"price": 3,
		"icon": preload("res://Game/Interface/Assets/Icons/Cooking_fishing/Cooking_09_onion.png"),
		"rarity": 10.0
	},
	"tomatoes": {
		"price": 5,
		"icon": preload("res://Game/Interface/Assets/Icons/Cooking_fishing/Cooking_15_tomatos.png"),
		"rarity": 10.0
	},
	"pepper_1": {
		"price": 6,
		"icon": preload("res://Game/Interface/Assets/Icons/Cooking_fishing/Cooking_14_pepper.png"),
		"rarity": 30.0
	},
	"pepper_2": {
		"price": 6,
		"icon": preload("res://Game/Interface/Assets/Icons/Cooking_fishing/Cooking_13_pepper.png"),
		"rarity": 30.0
	},
	"carrot_2": {
		"price": 3,
		"icon": preload("res://Game/Interface/Assets/Icons/Cooking_fishing/Cooking_12_carrot.png"),
		"rarity": 10.0
	}
}



var herbalist_list = {
	"blue_tip_grass": {
		"price": 1,
		"icon": preload("res://Game/Interface/Assets/Icons/Herbalism/Herbalism_15_herb.png"),
		"rarity": 10.0
	},
	"dill": {
		"price": 2,
		"icon": preload("res://Game/Interface/Assets/Icons/Herbalism/Herbalism_01_Dill.png"),
		"rarity": 10.0
	},
	"rucola": {
		"price": 3,
		"icon": preload("res://Game/Interface/Assets/Icons/Herbalism/Herbalism_02_rucola.png"),
		"rarity": 30.0
	},
	"basilicum": {
		"price": 4,
		"icon": preload("res://Game/Interface/Assets/Icons/Herbalism/Herbalism_03_basilicum.png"),
		"rarity": 30.0
	},
	"manaflower": {
		"price": 5,
		"icon": preload("res://Game/Interface/Assets/Icons/Herbalism/Herbalism_04_manaflower.png"),
		"rarity": 50.0
	},
	"fireflower": {
		"price": 6,
		"icon": preload("res://Game/Interface/Assets/Icons/Herbalism/Herbalism_05_fireflower.png"),
		"rarity": 50.0
	},
	"parsley": {
		"price": 2,
		"icon": preload("res://Game/Interface/Assets/Icons/Herbalism/Herbalism_06_parsley.png"),
		"rarity": 10.0
	},
	"oilplant": {
		"price": 3,
		"icon": preload("res://Game/Interface/Assets/Icons/Herbalism/Herbalism_07_oilplant.png"),
		"rarity": 30.0
	},
	"dragonherb": {
		"price": 7,
		"icon": preload("res://Game/Interface/Assets/Icons/Herbalism/Herbalism_10_dragonherb.png"),
		"rarity": 70.0
	},
	"shadowflower": {
		"price": 8,
		"icon": preload("res://Game/Interface/Assets/Icons/Herbalism/Herbalism_11_shadowflower.png"),
		"rarity": 70.0
	},
	"purpleflower": {
		"price": 9,
		"icon": preload("res://Game/Interface/Assets/Icons/Herbalism/Herbalism_14_purpleflower.png"),
		"rarity": 90.0
	},
	"seakale": {
		"price": 10,
		"icon": preload("res://Game/Interface/Assets/Icons/Herbalism/Herbalism_49_seakale.png"),
		"rarity": 90.0
	}
}



