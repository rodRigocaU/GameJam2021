extends Node

#this script is singleton, DON'T forget it!!!

var Stat_max_life := 200;
var Stat_strength := 2.0;
var Stat_armor := 1.25;
var Stat_cold_down_less := 0.0;
var Stat_MAX_ENERGY_SHIELD_HP := 100;

#Habilities benefits
var HB_life_recovery_per_second := 1;
var HB_seismic_skill_damage := 20;
var HB_energy_shield_hp : int;
var HB_

#Player reference
var player = null;

var Collectable_gold : int;
var life_value : int;

#Seismic Landing, Explosive Punch, Energy Shield, Healing Aura
var Habilities_unlocked = [false, false, false, false];

func _ready() -> void:
	life_value = Stat_max_life;
	Collectable_gold = 0;
	
func upgrade_stats():
	Stat_max_life += int(float(Stat_max_life) * 0.05);
	Stat_strength += float(Stat_strength) * 0.02;
	Stat_armor += float(Stat_armor) * 0.03;
	Stat_cold_down_less += 0.1;
	
func execute_active_hability(hab_idx : int, _delta : float) -> void:
	if Habilities_unlocked[hab_idx]:
		if hab_idx == 0 and player.is_on_floor():#Seismic Landing
			for enemy in player.get_node("Seismic_Skill_Area").get_overlapping_bodies():
				#enemy.life -= HB_seismic_skill_damage;
				print("Stun and Damage!!!");
		elif hab_idx == 1:#Explosive Punch
			pass;
		elif hab_idx == 2:#Energy Shield
			HB_energy_shield_hp = Stat_MAX_ENERGY_SHIELD_HP;
			print(HB_energy_shield_hp);
		
#Healing
func execute_pasive_hability(_delta : float) -> void:
	if Habilities_unlocked[3]:
		if life_value < Stat_max_life:
			life_value += int(HB_life_recovery_per_second * _delta);
			life_value = int(clamp(life_value, 0, Stat_max_life));

func this_hability_handler(_delta : float) -> void:
	if Input.is_action_just_pressed("ui_key_q"):
		execute_active_hability(0, _delta);
	elif Input.is_action_just_pressed("ui_key_f"):
		execute_active_hability(1, _delta);
	elif Input.is_action_just_pressed("ui_key_e"):
		execute_active_hability(2, _delta);
	execute_pasive_hability(_delta);
