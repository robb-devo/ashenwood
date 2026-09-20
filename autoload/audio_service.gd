extends Node
## Lightweight procedural SFX + volume settings for mobile feel.

enum Bus {
	MASTER,
	MUSIC,
	SFX,
	UI,
}

var music_volume: float = 0.8
var sfx_volume: float = 1.0
var vibration_enabled: bool = true

var _players: Array[AudioStreamPlayer] = []
var _clip_cache: Dictionary = {}
var _player_index: int = 0
var _current_music: StringName = &""


func _ready() -> void:
	for i in 6:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)


func play_sfx(clip_id: StringName, pitch_scale: float = 1.0) -> void:
	if sfx_volume <= 0.01:
		return
	var stream := _get_clip(clip_id)
	if stream == null:
		return
	var p: AudioStreamPlayer = _players[_player_index]
	_player_index = (_player_index + 1) % _players.size()
	p.stream = stream
	p.volume_db = linear_to_db(sfx_volume)
	p.pitch_scale = clampf(pitch_scale, 0.7, 1.4)
	p.play()


func play_ui(clip_id: StringName = &"ui_click") -> void:
	play_sfx(clip_id, 1.05)


func play_music(track_id: StringName) -> void:
	if track_id == _current_music:
		return
	_current_music = track_id
	# Soft zone sting until real music assets are added.
	match String(track_id):
		"forest_ambient":
			play_sfx(&"ui_click", 0.55)
		"cemetery_ambient":
			play_sfx(&"boss", 0.7)
		_:
			play_sfx(&"ui_confirm", 0.6)


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


func pulse_haptic(strength: float = 0.35) -> void:
	if not vibration_enabled:
		return
	if OS.has_feature("mobile") or OS.get_name() == "Android":
		Input.vibrate_handheld(int(lerpf(20.0, 55.0, clampf(strength, 0.0, 1.0))))


func _get_clip(clip_id: StringName) -> AudioStream:
	if _clip_cache.has(clip_id):
		return _clip_cache[clip_id]
	var stream := _synthesize(clip_id)
	_clip_cache[clip_id] = stream
	return stream


func _synthesize(clip_id: StringName) -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 0.12
	var freq := 440.0
	var wave := 0 # 0 sine, 1 noise, 2 square
	match String(clip_id):
		"ui_click":
			freq = 880.0
			duration = 0.05
		"ui_confirm":
			freq = 660.0
			duration = 0.1
		"player_attack":
			freq = 220.0
			duration = 0.09
			wave = 2
		"weapon_hit":
			freq = 180.0
			duration = 0.08
			wave = 1
		"enemy_hit":
			freq = 140.0
			duration = 0.1
			wave = 1
		"enemy_death":
			freq = 110.0
			duration = 0.22
			wave = 1
		"critical":
			freq = 920.0
			duration = 0.14
		"loot_pickup":
			freq = 740.0
			duration = 0.12
		"level_up", "quest_complete":
			freq = 523.25
			duration = 0.28
		"player_death":
			freq = 90.0
			duration = 0.35
			wave = 1
		"upgrade":
			freq = 600.0
			duration = 0.18
		"boss":
			freq = 80.0
			duration = 0.3
			wave = 1
		_:
			freq = 400.0
			duration = 0.08

	var frames := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(frames * 2)
	for i in frames:
		var t := float(i) / float(sample_rate)
		var env := 1.0 - (float(i) / float(frames))
		env = env * env
		var sample := 0.0
		match wave:
			1:
				sample = (randf() * 2.0 - 1.0) * 0.35 * env
			2:
				sample = (1.0 if sin(TAU * freq * t) >= 0.0 else -1.0) * 0.28 * env
			_:
				sample = sin(TAU * freq * t) * 0.4 * env
				if String(clip_id) in ["level_up", "quest_complete", "loot_pickup"]:
					sample += sin(TAU * freq * 1.5 * t) * 0.2 * env
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = s16 & 0xFF
		data[i * 2 + 1] = (s16 >> 8) & 0xFF

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream
