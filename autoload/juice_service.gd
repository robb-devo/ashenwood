extends Node
## Global juice helpers: hit-stop, time scale pulses.


func hit_stop(duration: float = 0.045, scale: float = 0.08) -> void:
	if duration <= 0.0:
		return
	Engine.time_scale = scale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
