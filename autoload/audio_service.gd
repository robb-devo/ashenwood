extends Node
## Audio hooks for later asset drop-in.
## Gameplay never hard-depends on real audio files.

enum Bus {
	MASTER,
	MUSIC,
	SFX,
	UI,
}

var music_volume: float = 0.8
var sfx_volume: float = 1.0
var vibration_enabled: bool = true

func play_sfx(_clip_id: StringName, _pitch_scale: float = 1.0) -> void:
	# PLACEHOLDER: bind AudioStreamPlayer pool + assets under res://assets/audio/
	pass


func play_ui(_clip_id: StringName = &"ui_click") -> void:
	play_sfx(_clip_id)


func play_music(_track_id: StringName) -> void:
	# PLACEHOLDER: crossfade music players
	pass


func stop_music() -> void:
	pass


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	EventBus.settings_changed.emit()


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	EventBus.settings_changed.emit()


func set_vibration_enabled(enabled: bool) -> void:
	vibration_enabled = enabled
	EventBus.settings_changed.emit()


func pulse_haptic(_strength: float = 0.35) -> void:
	if not vibration_enabled:
		return
	# PLACEHOLDER: Input.vibrate_handheld on Android
	pass
