class_name CombatMath
extends RefCounted


static func roll_player_damage() -> Dictionary:
	var atk := GameState.get_attack()
	var is_crit := randf() < GameState.get_crit_chance()
	var dmg := atk
	if is_crit:
		dmg = int(round(float(atk) * (1.0 + GameState.get_crit_damage())))
	dmg = maxi(1, dmg + randi_range(-1, 1))
	return {"damage": dmg, "critical": is_crit}
