#this is very primitive and dump, I tried more efficient methods, using exceptions instead of a match
#but it just doesn't work with the weird behaviourTree I made for the player, as of now this works just 
#fine, revamping it to use "smarter" coding practices might just break the system or 
#not broken, don't fix it 
extends TextureButton
onready var player = $"../../../.."
var queue_skills:bool = true #this is only for people with disabilities or if the game ever goes online to help with high ping, as of now it can't be used by itself until I revamp the skill cancel system  


func _ready()->void:
	connect("pressed", self , "pressed")

func pressed()->void:
	queue_skills = !queue_skills
	player.switchButtonTextures()


#call this function and write in the string which skill to NOT  be cancelled, all the others 
#will go in cooldown if they are activated  as well as being turned off allowing for smooth skill cancelling 
func skillCancel(string:String)->void:
	if player.skill_cancelling == true:
		match string:
			"none":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.current_race_gender.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.current_race_gender.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.current_race_gender.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.current_race_gender.kickCD()
				if player.overhead_slash_duration == true:
					player.current_race_gender.overheadSlashCD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.current_race_gender.risingSlashCD()
				if player.heart_trust_duration == true:
					player.current_race_gender.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.current_race_gender.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.current_race_gender.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.current_race_gender.tauntCD()
					player.taunt_duration = false
			"throw_rock":
				interruptBackstep()
				interruptBaseAtk()
#				if player.throw_rock_duration == true:
#					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.current_race_gender.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.current_race_gender.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.current_race_gender.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.current_race_gender.kickCD()
				if player.overhead_slash_duration == true:
					player.current_race_gender.overheadSlashCD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.current_race_gender.risingSlashCD()
				if player.heart_trust_duration == true:
					player.current_race_gender.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.current_race_gender.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.current_race_gender.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.current_race_gender.tauntCD()
					player.taunt_duration = false
			"dash":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.current_race_gender.slideCD()
					player.slide_duration = false
#				if player.dash_duration == true:
#					player.current_race_gender.dashCD()
#					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.current_race_gender.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.current_race_gender.kickCD()
				if player.overhead_slash_duration == true:
					player.current_race_gender.overheadSlashCD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.current_race_gender.risingSlashCD()
				if player.heart_trust_duration == true:
					player.current_race_gender.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.current_race_gender.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.current_race_gender.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.current_race_gender.tauntCD()
					player.taunt_duration = false
			"slide":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
#				if player.slide_duration == true:
#					player.current_race_gender.slideCD()
#					player.slide_duration = false
				if player.dash_duration == true:
					player.current_race_gender.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.current_race_gender.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.current_race_gender.kickCD()
				if player.overhead_slash_duration == true:
					player.current_race_gender.overheadSlashCD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.current_race_gender.risingSlashCD()
				if player.heart_trust_duration == true:
					player.current_race_gender.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.current_race_gender.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.current_race_gender.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.current_race_gender.tauntCD()
					player.taunt_duration = false
			"backstep":
	#			interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.current_race_gender.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.current_race_gender.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.current_race_gender.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.current_race_gender.kickCD()
				if player.overhead_slash_duration == true:
					player.current_race_gender.overheadSlashCD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.current_race_gender.risingSlashCD()
				if player.heart_trust_duration == true:
					player.current_race_gender.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.current_race_gender.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.current_race_gender.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.current_race_gender.tauntCD()
					player.taunt_duration = false
			"stomp":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.current_race_gender.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.current_race_gender.dashCD()
					player.dash_duration = false
#				if player.stomp_duration == true:
#					player.stomp_duration = false
#					player.current_race_gender.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.current_race_gender.kickCD()
				if player.overhead_slash_duration == true:
					player.current_race_gender.overheadSlashCD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.current_race_gender.risingSlashCD()
				if player.heart_trust_duration == true:
					player.current_race_gender.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.current_race_gender.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.current_race_gender.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.current_race_gender.tauntCD()
					player.taunt_duration = false
			"sunder":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.current_race_gender.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.current_race_gender.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.current_race_gender.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.current_race_gender.kickCD()
#				if player.overhead_slash_duration == true:
#					player.current_race_gender.overheadSlashCD()
#					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.current_race_gender.risingSlashCD()
				if player.heart_trust_duration == true:
					player.current_race_gender.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.current_race_gender.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.current_race_gender.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.current_race_gender.tauntCD()
					player.taunt_duration = false
			"rising_slash":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.current_race_gender.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.current_race_gender.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.current_race_gender.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.current_race_gender.kickCD()
				if player.overhead_slash_duration == true:
					player.current_race_gender.overheadSlashCD()
					player.overhead_slash_duration = false
#				if player.rising_slash_duration == true:
#					player.rising_slash_duration = false
#					player.current_race_gender.risingSlashCD()
				if player.heart_trust_duration == true:
					player.current_race_gender.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.current_race_gender.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.current_race_gender.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.current_race_gender.tauntCD()
					player.taunt_duration = false
			"cyclone":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.current_race_gender.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.current_race_gender.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.current_race_gender.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.current_race_gender.kickCD()
				if player.overhead_slash_duration == true:
					player.current_race_gender.overheadSlashCD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.current_race_gender.risingSlashCD()
				if player.heart_trust_duration == true:
					player.current_race_gender.HeartTrustCD()
					player.heart_trust_duration = false
#				if player.cyclone_duration == true:
#					player.current_race_gender.cycloneCD()
#					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.current_race_gender.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.current_race_gender.tauntCD()
					player.taunt_duration = false
			"whirlwind":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.current_race_gender.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.current_race_gender.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.current_race_gender.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.current_race_gender.kickCD()
				if player.overhead_slash_duration == true:
					player.current_race_gender.overheadSlashCD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.current_race_gender.risingSlashCD()
				if player.heart_trust_duration == true:
					player.current_race_gender.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.current_race_gender.cycloneCD()
					player.cyclone_duration = false
#				if player.whirlwind_duration == true:
#					player.current_race_gender.whirlwindCD()
#					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.current_race_gender.tauntCD()
					player.taunt_duration = false
			"heart_trust":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.current_race_gender.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.current_race_gender.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.current_race_gender.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.current_race_gender.kickCD()
				if player.overhead_slash_duration == true:
					player.current_race_gender.overheadSlashCD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.current_race_gender.risingSlashCD()
#				if player.heart_trust_duration == true:
#					player.current_race_gender.HeartTrustCD()
#					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.current_race_gender.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.current_race_gender.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.current_race_gender.tauntCD()
					player.taunt_duration = false
			"taunt":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.current_race_gender.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.current_race_gender.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.current_race_gender.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.current_race_gender.kickCD()
				if player.overhead_slash_duration == true:
					player.current_race_gender.overheadSlashCD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.current_race_gender.risingSlashCD()
				if player.heart_trust_duration == true:
					player.current_race_gender.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.current_race_gender.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.current_race_gender.whirlwindCD()
					player.whirlwind_duration = false
#				if player.taunt_duration == true:
#					player.current_race_gender.tauntCD()
#					player.taunt_duration = false
			"kick":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.current_race_gender.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.current_race_gender.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.current_race_gender.stompCD()
#				if player.kick_duration == true:
#					player.kick_duration = false
#					player.current_race_gender.kickCD()
				if player.overhead_slash_duration == true:
					player.current_race_gender.overheadSlashCD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.current_race_gender.risingSlashCD()
				if player.heart_trust_duration == true:
					player.current_race_gender.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.current_race_gender.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.current_race_gender.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.current_race_gender.tauntCD()
					player.taunt_duration = false
			"none":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.current_race_gender.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.current_race_gender.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.current_race_gender.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.current_race_gender.kickCD()
				if player.overhead_slash_duration == true:
					player.current_race_gender.overheadSlashCD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.current_race_gender.risingSlashCD()
				if player.heart_trust_duration == true:
					player.current_race_gender.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.current_race_gender.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.current_race_gender.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.current_race_gender.tauntCD()
					player.taunt_duration = false

func interruptBaseAtk():
	player.base_atk_duration = false
	player.base_atk2_duration = false
	
func interruptBackstep()->void:
	if player.leftstep_duration == true:
		player.all_skills.backstepCD()
		player.backstep_duration = false
		player.frontstep_duration = false
		player.leftstep_duration = false
		player.rightstep_duration = false
	if player.backstep_duration == true:
		player.all_skills.backstepCD()
		player.backstep_duration = false
		player.frontstep_duration = false
		player.leftstep_duration = false
		player.rightstep_duration = false
	if player.frontstep_duration == true :
		player.all_skills.backstepCD()
		player.backstep_duration = false
		player.frontstep_duration = false
		player.leftstep_duration = false
		player.rightstep_duration = false
	if player.rightstep_duration == true:
		player.all_skills.backstepCD()
		player.backstep_duration = false
		player.frontstep_duration = false
		player.leftstep_duration = false
		player.rightstep_duration = false
	if player.leftstep_duration == true:
		player.all_skills.backstepCD()
		player.backstep_duration = false
		player.frontstep_duration = false
		player.leftstep_duration = false
		player.rightstep_duration = false
		
func getInterrupted()->void:#Universal stop, call this when I'm stunned, staggered, dead, knocked down and so on 
	player.overhead_slash_combo = false
	player.whirlwind_combo = false
	player.cyclone_combo = false
	player.base_atk_duration = false
	player.base_atk2_duration = false
	player.throw_rock_duration = false
	
	interruptBackstep()
	interruptBaseAtk()
	if player.throw_rock_duration == true:
		player.throw_rock_duration = false
	if player.slide_duration == true:
		player.current_race_gender.slideCD()
		player.slide_duration = false
	if player.dash_duration == true:
		player.current_race_gender.dashCD()
		player.dash_duration = false
	if player.stomp_duration == true:
		player.stomp_duration = false
		player.current_race_gender.stompCD()
	if player.kick_duration == true:
		player.kick_duration = false
		player.current_race_gender.kickCD()
	if player.overhead_slash_duration == true:
		player.current_race_gender.overheadSlashCD()
		player.overhead_slash_duration = false
	if player.rising_slash_duration == true:
		player.rising_slash_duration = false
		player.current_race_gender.risingSlashCD()
	if player.heart_trust_duration == true:
		player.current_race_gender.HeartTrustCD()
		player.heart_trust_duration = false
	if player.cyclone_duration == true:
		player.current_race_gender.cycloneCD()
		player.cyclone_duration = false
	if player.whirlwind_duration == true:
		player.current_race_gender.whirlwindCD()
		player.whirlwind_duration = false
	if player.taunt_duration == true:
		player.current_race_gender.tauntCD()
		player.taunt_duration = false
