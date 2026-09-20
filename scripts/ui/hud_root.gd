class_name HudRoot
extends CanvasLayer
## Commercial portrait RPG HUD — Ashenwood visual identity.

const ItemDefScript = preload("res://scripts/data/item_def.gd")
const UiThemeScript = preload("res://scripts/ui/ui_theme.gd")
const JoystickScript = preload("res://scripts/ui/mobile_joystick.gd")

var root: Control
var attack_button: Button
var potion_button: Button
var interact_button: Button
var menu_button: Button
var hp_bar: ProgressBar
var xp_bar: ProgressBar
var hp_text: Label
var level_label: Label
var gold_label: Label
var quest_title: Label
var quest_progress: Label
var toast_banner: PanelContainer
var toast_label: Label
var hint_label: Label
var portrait: Panel
var boss_wrap: Control
var boss_bar: ProgressBar
var boss_label: Label
var death_dim: ColorRect
var death_panel: Control
var reward_overlay: Control
var reward_card: PanelContainer
var reward_label: Label
var reward_rarity: Label

var _menu_dim: ColorRect
var _menu: Control
var _menu_sheet: PanelContainer
var _dialogue: Control
var _dialogue_name: Label
var _dialogue_text: Label
var _dialogue_lines: PackedStringArray = []
var _dialogue_index: int = 0
var _dialogue_npc: StringName = &""
var _page: StringName = &"hero"
var _menu_body: VBoxContainer
var _tab_buttons: Dictionary = {}
var _selected_uid: String = ""
var _attack_cooldown_overlay: ColorRect
var _quest_panel: PanelContainer
var _quest_dots: HBoxContainer
var _celebrate: Control
var _celebrate_title: Label
var _celebrate_body: Label
var _gold_chip: PanelContainer
var _displayed_gold: int = 0


func _ready() -> void:
	layer = 20
	add_to_group("hud")
	_build_hud()
	_build_menu()
	_build_dialogue()
	GameState.stats_changed.connect(_refresh_stats)
	EventBus.player_gold_changed.connect(func(_g): _refresh_stats())
	EventBus.player_xp_changed.connect(func(_a, _b): _refresh_stats())
	EventBus.player_leveled_up.connect(_on_level_up)
	EventBus.quest_updated.connect(func(_q): _refresh_quest())
	EventBus.quest_started.connect(func(_q): _refresh_quest())
	EventBus.quest_completed.connect(_on_quest_complete)
	EventBus.dialogue_requested.connect(_show_dialogue)
	EventBus.inventory_changed.connect(func(): if _menu and _menu.visible: _rebuild_menu_page())
	EventBus.player_died.connect(_show_death)
	EventBus.player_respawned.connect(_hide_death)
	EventBus.boss_engaged.connect(_on_boss_engaged)
	EventBus.boss_hp_changed.connect(_on_boss_hp)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.quest_progress_toast.connect(_toast)
	EventBus.rare_loot_found.connect(_show_rare_loot)
	EventBus.loot_collected.connect(_on_loot_collected)
	_refresh_stats()
	_refresh_quest()
	_displayed_gold = GameState.gold


func _build_hud() -> void:
	for c in get_children():
		c.queue_free()

	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_build_top_left()
	_build_top_right()
	_build_quest_tracker()
	_build_joystick()
	_build_attack_cluster()
	_build_toast()
	_build_boss_bar()
	_build_death_panel()
	_build_reward_overlay()
	_build_celebrate()


func _build_top_left() -> void:
	var frame := PanelContainer.new()
	frame.position = Vector2(28, 36)
	frame.custom_minimum_size = Vector2(460, 148)
	frame.add_theme_stylebox_override("panel", UiThemeScript.panel_main(26, 0.9))
	root.add_child(frame)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	frame.add_child(row)

	var portrait_wrap := Control.new()
	portrait_wrap.custom_minimum_size = Vector2(96, 96)
	row.add_child(portrait_wrap)

	portrait = Panel.new()
	portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait.add_theme_stylebox_override("panel", UiThemeScript.circle(Color("c9a45c"), UiThemeScript.BRASS_LIGHT, 50))
	portrait_wrap.add_child(portrait)

	var face := Label.new()
	face.text = "W"
	face.set_anchors_preset(Control.PRESET_FULL_RECT)
	face.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	face.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(face, 42, UiThemeScript.INK)
	portrait.add_child(face)

	var badge := Panel.new()
	badge.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	badge.offset_left = -42
	badge.offset_top = -36
	badge.offset_right = 6
	badge.offset_bottom = 6
	badge.add_theme_stylebox_override("panel", UiThemeScript.circle(UiThemeScript.BRASS, UiThemeScript.BRASS_LIGHT, 20))
	portrait_wrap.add_child(badge)
	level_label = Label.new()
	level_label.text = "1"
	level_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(level_label, 18, UiThemeScript.INK)
	badge.add_child(level_label)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 8)
	row.add_child(col)

	var name_l := Label.new()
	name_l.text = "Wanderer"
	UiThemeScript.style_label(name_l, 30, UiThemeScript.CREAM)
	col.add_child(name_l)

	var hp_row := HBoxContainer.new()
	hp_row.add_theme_constant_override("separation", 8)
	col.add_child(hp_row)
	var hp_tag := Label.new()
	hp_tag.text = "HP"
	hp_tag.custom_minimum_size = Vector2(36, 0)
	UiThemeScript.style_label(hp_tag, 16, UiThemeScript.MUTED)
	hp_row.add_child(hp_tag)
	hp_bar = _make_bar(UiThemeScript.bar_hp(), 22)
	hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_row.add_child(hp_bar)
	hp_text = Label.new()
	hp_text.custom_minimum_size = Vector2(90, 0)
	hp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	UiThemeScript.style_label(hp_text, 16, UiThemeScript.CREAM)
	hp_row.add_child(hp_text)

	var xp_row := HBoxContainer.new()
	xp_row.add_theme_constant_override("separation", 8)
	col.add_child(xp_row)
	var xp_tag := Label.new()
	xp_tag.text = "XP"
	xp_tag.custom_minimum_size = Vector2(36, 0)
	UiThemeScript.style_label(xp_tag, 16, UiThemeScript.MUTED)
	xp_row.add_child(xp_tag)
	xp_bar = _make_bar(UiThemeScript.bar_xp(), 12)
	xp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	xp_row.add_child(xp_bar)


func _make_bar(fill: StyleBoxFlat, height: float) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, height)
	bar.show_percentage = false
	bar.max_value = 100
	bar.value = 100
	bar.add_theme_stylebox_override("background", UiThemeScript.bar_bg())
	bar.add_theme_stylebox_override("fill", fill)
	return bar


func _build_top_right() -> void:
	_gold_chip = PanelContainer.new()
	_gold_chip.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_gold_chip.offset_left = -300
	_gold_chip.offset_top = 40
	_gold_chip.offset_right = -124
	_gold_chip.offset_bottom = 108
	_gold_chip.add_theme_stylebox_override("panel", UiThemeScript.panel_pill(UiThemeScript.PANEL_RAISED, UiThemeScript.BRASS))
	root.add_child(_gold_chip)

	var gold_row := HBoxContainer.new()
	gold_row.add_theme_constant_override("separation", 10)
	gold_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_gold_chip.add_child(gold_row)

	var coin := Panel.new()
	coin.custom_minimum_size = Vector2(34, 34)
	coin.add_theme_stylebox_override("panel", UiThemeScript.circle(UiThemeScript.BRASS, UiThemeScript.BRASS_LIGHT, 20))
	gold_row.add_child(coin)
	var coin_l := Label.new()
	coin_l.text = "G"
	coin_l.set_anchors_preset(Control.PRESET_FULL_RECT)
	coin_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coin_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(coin_l, 16, UiThemeScript.INK)
	coin.add_child(coin_l)

	gold_label = Label.new()
	gold_label.text = "0"
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	UiThemeScript.style_label(gold_label, 28, UiThemeScript.BRASS_LIGHT)
	gold_row.add_child(gold_label)

	menu_button = Button.new()
	menu_button.text = "BAG"
	menu_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	menu_button.offset_left = -112
	menu_button.offset_top = 36
	menu_button.offset_right = -28
	menu_button.offset_bottom = 120
	menu_button.add_theme_font_size_override("font_size", 22)
	UiThemeScript.style_primary_button(menu_button)
	menu_button.pressed.connect(func():
		UiThemeScript.pulse_control(menu_button)
		_toggle_menu()
	)
	root.add_child(menu_button)


func _build_quest_tracker() -> void:
	_quest_panel = PanelContainer.new()
	_quest_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_quest_panel.offset_left = -300
	_quest_panel.offset_top = 160
	_quest_panel.offset_right = 300
	_quest_panel.offset_bottom = 300
	_quest_panel.add_theme_stylebox_override("panel", UiThemeScript.panel_glass(22))
	root.add_child(_quest_panel)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	_quest_panel.add_child(v)

	var tag_row := HBoxContainer.new()
	tag_row.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(tag_row)
	var bang := Label.new()
	bang.text = "!"
	UiThemeScript.style_label(bang, 22, UiThemeScript.BRASS)
	tag_row.add_child(bang)
	var tag := Label.new()
	tag.text = "  QUEST"
	UiThemeScript.style_label(tag, 14, UiThemeScript.BRASS)
	tag_row.add_child(tag)

	quest_title = Label.new()
	quest_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quest_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiThemeScript.style_label(quest_title, 24, UiThemeScript.CREAM)
	v.add_child(quest_title)

	quest_progress = Label.new()
	quest_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(quest_progress, 18, UiThemeScript.MUTED)
	v.add_child(quest_progress)

	_quest_dots = HBoxContainer.new()
	_quest_dots.alignment = BoxContainer.ALIGNMENT_CENTER
	_quest_dots.add_theme_constant_override("separation", 8)
	v.add_child(_quest_dots)


func _build_joystick() -> void:
	# Wide bottom pad — Archero-style: stick rests center-bottom, touch anywhere in zone.
	var stick := Control.new()
	stick.set_script(JoystickScript)
	stick.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	stick.offset_left = 0
	stick.offset_top = -460
	stick.offset_right = -240 # leave ATK/HEAL column clearer; buttons still sit above in tree
	stick.offset_bottom = 0
	stick.mouse_filter = Control.MOUSE_FILTER_STOP
	stick.z_index = 0
	root.add_child(stick)


func _build_attack_cluster() -> void:
	attack_button = Button.new()
	attack_button.text = "ATK"
	attack_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	attack_button.offset_left = -220
	attack_button.offset_top = -260
	attack_button.offset_right = -36
	attack_button.offset_bottom = -76
	attack_button.focus_mode = Control.FOCUS_NONE
	attack_button.add_theme_font_size_override("font_size", 36)
	attack_button.add_theme_color_override("font_color", UiThemeScript.INK)
	attack_button.add_theme_stylebox_override("normal", UiThemeScript.circle(UiThemeScript.BRASS, UiThemeScript.BRASS_LIGHT, 100))
	attack_button.add_theme_stylebox_override("pressed", UiThemeScript.circle(UiThemeScript.BRASS_DEEP, UiThemeScript.BRASS, 100))
	attack_button.add_theme_stylebox_override("hover", UiThemeScript.circle(Color("e0b85a"), UiThemeScript.BRASS_LIGHT, 100))
	attack_button.pressed.connect(func():
		InputService.attack_pressed = true
		AudioService.play_ui()
		AudioService.pulse_haptic(0.22)
		_pulse_attack()
	)
	root.add_child(attack_button)

	_attack_cooldown_overlay = ColorRect.new()
	_attack_cooldown_overlay.color = Color(0.04, 0.05, 0.05, 0.5)
	_attack_cooldown_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_attack_cooldown_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_attack_cooldown_overlay.visible = false
	attack_button.add_child(_attack_cooldown_overlay)

	potion_button = Button.new()
	potion_button.text = "HEAL"
	potion_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	potion_button.offset_left = -340
	potion_button.offset_top = -210
	potion_button.offset_right = -230
	potion_button.offset_bottom = -100
	potion_button.focus_mode = Control.FOCUS_NONE
	potion_button.add_theme_font_size_override("font_size", 20)
	potion_button.add_theme_color_override("font_color", Color("ffe8ec"))
	potion_button.add_theme_stylebox_override("normal", UiThemeScript.circle(Color("8a3542"), Color("d07080"), 60))
	potion_button.add_theme_stylebox_override("pressed", UiThemeScript.circle(Color("6a2430"), Color("b05060"), 60))
	potion_button.pressed.connect(func():
		UiThemeScript.pulse_control(potion_button)
		if GameState.use_first_consumable(&"health_vial"):
			_toast("Health restored")
			AudioService.play_sfx(&"loot_pickup")
			VfxService.spawn_level_up()
		else:
			_toast("No Health Vials")
			AudioService.play_ui(&"ui_click")
	)
	root.add_child(potion_button)

	interact_button = Button.new()
	interact_button.text = "TALK"
	interact_button.visible = false
	interact_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	interact_button.offset_left = -220
	interact_button.offset_top = -370
	interact_button.offset_right = -36
	interact_button.offset_bottom = -280
	interact_button.focus_mode = Control.FOCUS_NONE
	interact_button.add_theme_font_size_override("font_size", 28)
	UiThemeScript.style_primary_button(interact_button)
	interact_button.pressed.connect(func():
		InputService.interact_pressed = true
		UiThemeScript.pulse_control(interact_button)
		AudioService.play_ui()
	)
	root.add_child(interact_button)

	hint_label = Label.new()
	hint_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint_label.offset_left = -360
	hint_label.offset_top = -58
	hint_label.offset_right = 360
	hint_label.offset_bottom = -18
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(hint_label, 18, Color(UiThemeScript.MUTED.r, UiThemeScript.MUTED.g, UiThemeScript.MUTED.b, 0.65))
	hint_label.text = "Touch & drag to move"
	root.add_child(hint_label)


func _pulse_attack() -> void:
	attack_button.pivot_offset = attack_button.size * 0.5
	var tw := create_tween()
	tw.tween_property(attack_button, "scale", Vector2(0.9, 0.9), 0.05)
	tw.tween_property(attack_button, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func set_attack_cooldown(ratio: float) -> void:
	if _attack_cooldown_overlay == null:
		return
	var r := clampf(ratio, 0.0, 1.0)
	_attack_cooldown_overlay.visible = r > 0.02
	_attack_cooldown_overlay.anchor_top = 1.0 - r


func _build_toast() -> void:
	toast_banner = PanelContainer.new()
	toast_banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	toast_banner.offset_left = -340
	toast_banner.offset_top = 300
	toast_banner.offset_right = 340
	toast_banner.offset_bottom = 380
	toast_banner.modulate.a = 0.0
	toast_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_banner.add_theme_stylebox_override("panel", UiThemeScript.panel_pill(Color(0.12, 0.15, 0.13, 0.94), UiThemeScript.BRASS))
	root.add_child(toast_banner)
	toast_label = Label.new()
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiThemeScript.style_label(toast_label, 26, UiThemeScript.BRASS_LIGHT)
	toast_banner.add_child(toast_label)


func _build_boss_bar() -> void:
	boss_wrap = PanelContainer.new()
	boss_wrap.set_anchors_preset(Control.PRESET_CENTER_TOP)
	boss_wrap.offset_left = -340
	boss_wrap.offset_top = 320
	boss_wrap.offset_right = 340
	boss_wrap.offset_bottom = 430
	boss_wrap.visible = false
	boss_wrap.name = "BossWrap"
	boss_wrap.add_theme_stylebox_override("panel", UiThemeScript.panel_main(20, 0.94))
	root.add_child(boss_wrap)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	boss_wrap.add_child(v)
	var tag := Label.new()
	tag.text = "BOSS"
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(tag, 14, UiThemeScript.DANGER)
	v.add_child(tag)
	boss_label = Label.new()
	boss_label.text = "GRAVEKEEPER"
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(boss_label, 28, UiThemeScript.BRASS_LIGHT)
	v.add_child(boss_label)
	boss_bar = _make_bar(UiThemeScript.bar_boss(), 26)
	v.add_child(boss_bar)


func _build_death_panel() -> void:
	death_dim = ColorRect.new()
	death_dim.visible = false
	death_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	death_dim.color = Color(0.02, 0.03, 0.03, 0.72)
	death_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(death_dim)

	death_panel = PanelContainer.new()
	death_panel.visible = false
	death_panel.set_anchors_preset(Control.PRESET_CENTER)
	death_panel.offset_left = -320
	death_panel.offset_top = -200
	death_panel.offset_right = 320
	death_panel.offset_bottom = 200
	death_panel.add_theme_stylebox_override("panel", UiThemeScript.panel_main(30, 0.97))
	root.add_child(death_panel)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 18)
	death_panel.add_child(v)

	var t := Label.new()
	t.text = "YOU FELL"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(t, 48, UiThemeScript.BRASS_LIGHT)
	v.add_child(t)

	var s := Label.new()
	s.text = "Your progress is safe.\nReturn to Ashenwood Village."
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	s.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiThemeScript.style_label(s, 24, UiThemeScript.MUTED)
	v.add_child(s)

	var btn := Button.new()
	btn.text = "RETURN TO VILLAGE"
	btn.custom_minimum_size = Vector2(0, 80)
	btn.add_theme_font_size_override("font_size", 28)
	UiThemeScript.style_primary_button(btn)
	btn.pressed.connect(func():
		var p := get_tree().get_first_node_in_group("player")
		if p and p.has_method("return_to_village"):
			p.return_to_village()
		AudioService.play_ui(&"ui_confirm")
	)
	v.add_child(btn)


func _build_reward_overlay() -> void:
	reward_overlay = ColorRect.new()
	reward_overlay.visible = false
	reward_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	reward_overlay.color = Color(0.02, 0.03, 0.04, 0.78)
	reward_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(reward_overlay)

	reward_card = PanelContainer.new()
	reward_card.set_anchors_preset(Control.PRESET_CENTER)
	reward_card.offset_left = -300
	reward_card.offset_top = -260
	reward_card.offset_right = 300
	reward_card.offset_bottom = 260
	reward_card.add_theme_stylebox_override("panel", UiThemeScript.panel_main(28, 0.98))
	reward_overlay.add_child(reward_card)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	reward_card.add_child(v)

	var headline := Label.new()
	headline.text = "NEW ITEM"
	headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(headline, 22, UiThemeScript.BRASS)
	v.add_child(headline)

	var icon := Panel.new()
	icon.custom_minimum_size = Vector2(120, 120)
	icon.add_theme_stylebox_override("panel", UiThemeScript.circle(UiThemeScript.PANEL_RAISED, UiThemeScript.BRASS, 60))
	v.add_child(icon)
	var icon_l := Label.new()
	icon_l.text = "★"
	icon_l.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(icon_l, 48, UiThemeScript.BRASS_LIGHT)
	icon.add_child(icon_l)

	reward_label = Label.new()
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiThemeScript.style_label(reward_label, 36, UiThemeScript.CREAM)
	v.add_child(reward_label)

	reward_rarity = Label.new()
	reward_rarity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(reward_rarity, 24, UiThemeScript.BRASS_LIGHT)
	v.add_child(reward_rarity)

	var tap := Label.new()
	tap.text = "Tap to continue"
	tap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(tap, 18, UiThemeScript.MUTED)
	v.add_child(tap)

	reward_overlay.gui_input.connect(func(ev):
		if (ev is InputEventMouseButton and ev.pressed) or (ev is InputEventScreenTouch and ev.pressed):
			UiThemeScript.animate_close(reward_overlay)
	)


func _show_death() -> void:
	death_dim.visible = true
	death_dim.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(death_dim, "modulate:a", 1.0, 0.25)
	UiThemeScript.animate_open(death_panel)


func _hide_death() -> void:
	death_dim.visible = false
	death_panel.visible = false


func _on_boss_engaged(_id: StringName, hp: int, max_hp: int) -> void:
	if boss_wrap:
		UiThemeScript.animate_open(boss_wrap)
	if boss_bar:
		boss_bar.max_value = max_hp
		boss_bar.value = hp


func _on_boss_hp(_id: StringName, hp: int, max_hp: int) -> void:
	if boss_bar:
		boss_bar.max_value = max_hp
		var tw := create_tween()
		tw.tween_property(boss_bar, "value", hp, 0.15)


func _on_boss_defeated(_id: StringName) -> void:
	if boss_wrap:
		UiThemeScript.animate_close(boss_wrap)
	_toast("Gravekeeper Defeated")


func _show_rare_loot(item_id: StringName) -> void:
	var def = ContentDB.get_item(item_id)
	if def == null or reward_overlay == null:
		return
	reward_label.text = def.name
	reward_rarity.text = ItemDefScript.rarity_name(def.rarity)
	reward_rarity.add_theme_color_override("font_color", ItemDefScript.rarity_color(def.rarity))
	reward_overlay.visible = true
	reward_overlay.modulate.a = 0.0
	reward_card.scale = Vector2(0.7, 0.7)
	reward_card.pivot_offset = reward_card.size * 0.5
	var tw := create_tween()
	tw.tween_property(reward_overlay, "modulate:a", 1.0, 0.2)
	tw.parallel().tween_property(reward_card, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	AudioService.play_sfx(&"loot_pickup")
	AudioService.play_sfx(&"quest_complete")


func open_upgrade_from_blacksmith() -> void:
	_open_menu_to(&"forge")


func open_merchant_shop() -> void:
	_open_menu_to(&"shop")


func set_interact_prompt(show: bool, npc_name: String = "") -> void:
	interact_button.visible = show
	if show:
		interact_button.text = "TALK"
		hint_label.text = "Near %s" % npc_name
		UiThemeScript.pulse_control(interact_button, 1.04)
	else:
		hint_label.text = "Touch & drag to move"


func _refresh_stats() -> void:
	var max_hp := GameState.get_max_hp()
	hp_bar.max_value = max_hp
	# Snap first paint so bar never looks empty while text says full
	if absf(hp_bar.value - float(GameState.hp)) > 8.0 or hp_bar.value <= 0.01:
		hp_bar.value = GameState.hp
	else:
		var tw := create_tween()
		tw.tween_property(hp_bar, "value", float(GameState.hp), 0.18)
	xp_bar.max_value = maxf(1, GameState.xp_to_next_level())
	if absf(xp_bar.value - float(GameState.xp)) > 12.0:
		xp_bar.value = GameState.xp
	else:
		var tw2 := create_tween()
		tw2.tween_property(xp_bar, "value", float(GameState.xp), 0.22)
	level_label.text = str(GameState.level)
	if hp_text:
		hp_text.text = "%d/%d" % [GameState.hp, max_hp]
	_animate_gold_to(GameState.gold)


func _animate_gold_to(target: int) -> void:
	if gold_label == null:
		return
	if target == _displayed_gold:
		gold_label.text = str(target)
		return
	var from := _displayed_gold
	_displayed_gold = target
	var tw := create_tween()
	tw.tween_method(func(v: float):
		gold_label.text = str(int(round(v)))
	, float(from), float(target), 0.35)
	if _gold_chip:
		UiThemeScript.pulse_control(_gold_chip, 1.08)


func _on_loot_collected(item_id: StringName, _qty: int) -> void:
	if item_id == &"gold" and _gold_chip:
		UiThemeScript.pulse_control(_gold_chip, 1.12)
	if xp_bar:
		var tw := create_tween()
		tw.tween_property(xp_bar, "modulate", UiThemeScript.BRASS_LIGHT, 0.08)
		tw.tween_property(xp_bar, "modulate", Color.WHITE, 0.25)


func _refresh_quest() -> void:
	var def = ContentDB.get_quest(QuestService.active_quest_id)
	if def == null:
		quest_title.text = "All quests complete"
		quest_progress.text = "Explore freely"
		_rebuild_quest_dots(0, 0)
		return
	quest_title.text = def.title
	if def.objective_type == def.ObjectiveType.TALK:
		quest_progress.text = "Talk to the Village Elder"
		_rebuild_quest_dots(0, 0)
	else:
		quest_progress.text = "%d / %d" % [QuestService.progress, def.target_count]
		_rebuild_quest_dots(QuestService.progress, def.target_count)
	if _quest_panel:
		UiThemeScript.pulse_control(_quest_panel, 1.03)


func _rebuild_quest_dots(done: int, total: int) -> void:
	if _quest_dots == null:
		return
	for c in _quest_dots.get_children():
		c.queue_free()
	if total <= 0 or total > 10:
		return
	for i in total:
		var d := Panel.new()
		d.custom_minimum_size = Vector2(18, 18)
		var filled := i < done
		d.add_theme_stylebox_override("panel", UiThemeScript.circle(
			UiThemeScript.BRASS if filled else Color(0.2, 0.24, 0.2, 0.9),
			UiThemeScript.BRASS_LIGHT if filled else Color(0.4, 0.42, 0.36, 0.5),
			10
		))
		_quest_dots.add_child(d)


func _build_celebrate() -> void:
	_celebrate = ColorRect.new()
	_celebrate.visible = false
	_celebrate.set_anchors_preset(Control.PRESET_FULL_RECT)
	_celebrate.color = Color(0.02, 0.03, 0.03, 0.55)
	_celebrate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_celebrate)
	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left = -320
	card.offset_top = -180
	card.offset_right = 320
	card.offset_bottom = 180
	card.add_theme_stylebox_override("panel", UiThemeScript.panel_main(28, 0.97))
	_celebrate.add_child(card)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	card.add_child(v)
	_celebrate_title = Label.new()
	_celebrate_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(_celebrate_title, 42, UiThemeScript.BRASS_LIGHT)
	v.add_child(_celebrate_title)
	_celebrate_body = Label.new()
	_celebrate_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_celebrate_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiThemeScript.style_label(_celebrate_body, 26, UiThemeScript.CREAM)
	v.add_child(_celebrate_body)


func _show_celebrate(title: String, body: String, duration: float = 1.8) -> void:
	_celebrate_title.text = title
	_celebrate_body.text = body
	_celebrate.visible = true
	_celebrate.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_celebrate, "modulate:a", 1.0, 0.15)
	tw.tween_interval(duration)
	tw.tween_property(_celebrate, "modulate:a", 0.0, 0.25)
	tw.tween_callback(func(): _celebrate.visible = false)


func _on_level_up(level: int) -> void:
	_show_celebrate("LEVEL UP", "You reached Level %d" % level, 1.7)
	AudioService.play_sfx(&"level_up")
	if portrait:
		var tw := create_tween()
		tw.tween_property(portrait, "modulate", UiThemeScript.BRASS_LIGHT, 0.1)
		tw.tween_property(portrait, "modulate", Color.WHITE, 0.55)


func _on_quest_complete(quest_id: StringName) -> void:
	var def = ContentDB.get_quest(quest_id)
	var title: String = def.title if def else String(quest_id)
	var xp: int = def.xp_reward if def else 0
	var gold: int = def.gold_reward if def else 0
	_show_celebrate("QUEST COMPLETE", "%s\n+%d XP   +%d Gold" % [title, xp, gold], 2.0)
	_refresh_quest()
	if _quest_panel:
		UiThemeScript.pulse_control(_quest_panel, 1.06)


func _toast(text: String) -> void:
	toast_label.text = text
	toast_banner.modulate.a = 0.0
	toast_banner.scale = Vector2(0.9, 0.9)
	toast_banner.pivot_offset = toast_banner.size * 0.5
	var tw := create_tween()
	tw.tween_property(toast_banner, "modulate:a", 1.0, 0.12)
	tw.parallel().tween_property(toast_banner, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(1.6)
	tw.tween_property(toast_banner, "modulate:a", 0.0, 0.4)


func _toggle_menu() -> void:
	if _dialogue.visible:
		return
	if _menu.visible:
		_close_menu()
	else:
		_open_menu_to(&"hero")


func _open_menu_to(page: StringName) -> void:
	_page = page
	_menu.visible = true
	_menu_dim.visible = true
	_menu_dim.modulate.a = 0.0
	_rebuild_menu_page()
	_update_tabs()
	var tw := create_tween()
	tw.tween_property(_menu_dim, "modulate:a", 1.0, 0.15)
	UiThemeScript.animate_open(_menu_sheet)
	EventBus.ui_menu_opened.emit(_page)
	AudioService.play_ui(&"ui_confirm")


func _close_menu() -> void:
	UiThemeScript.animate_close(_menu_sheet, func():
		_menu.visible = false
		_menu_dim.visible = false
	)
	EventBus.ui_menu_closed.emit()
	AudioService.play_ui()


func _build_dialogue() -> void:
	_dialogue = PanelContainer.new()
	_dialogue.visible = false
	_dialogue.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_dialogue.offset_left = 24
	_dialogue.offset_right = -24
	_dialogue.offset_top = -420
	_dialogue.offset_bottom = -40
	_dialogue.add_theme_stylebox_override("panel", UiThemeScript.panel_main(28, 0.96))
	root.add_child(_dialogue)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	_dialogue.add_child(v)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 14)
	v.add_child(header)

	var avatar := Panel.new()
	avatar.custom_minimum_size = Vector2(72, 72)
	avatar.add_theme_stylebox_override("panel", UiThemeScript.circle(UiThemeScript.MOSS, UiThemeScript.BRASS, 40))
	header.add_child(avatar)

	_dialogue_name = Label.new()
	_dialogue_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dialogue_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(_dialogue_name, 30, UiThemeScript.BRASS_LIGHT)
	header.add_child(_dialogue_name)

	_dialogue_text = Label.new()
	_dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_text.custom_minimum_size = Vector2(0, 140)
	UiThemeScript.style_label(_dialogue_text, 28, UiThemeScript.CREAM)
	v.add_child(_dialogue_text)

	var btn := Button.new()
	btn.text = "CONTINUE"
	btn.custom_minimum_size = Vector2(0, 76)
	btn.add_theme_font_size_override("font_size", 28)
	UiThemeScript.style_primary_button(btn)
	btn.pressed.connect(_advance_dialogue)
	v.add_child(btn)


func _show_dialogue(npc_id: StringName, lines: PackedStringArray) -> void:
	_dialogue_npc = npc_id
	_dialogue_lines = lines
	_dialogue_index = 0
	_dialogue_name.text = _npc_display_name(npc_id)
	_close_menu_instant()
	UiThemeScript.animate_open(_dialogue)
	_update_dialogue_line()


func _npc_display_name(npc_id: StringName) -> String:
	match String(npc_id):
		"elder": return "Village Elder"
		"blacksmith": return "Blacksmith"
		"merchant": return "Merchant"
		_: return "Villager"


func _update_dialogue_line() -> void:
	if _dialogue_index >= _dialogue_lines.size():
		_dialogue.visible = false
		return
	_dialogue_text.text = _dialogue_lines[_dialogue_index]


func _advance_dialogue() -> void:
	_dialogue_index += 1
	AudioService.play_ui()
	if _dialogue_index >= _dialogue_lines.size():
		UiThemeScript.animate_close(_dialogue)
	else:
		_dialogue_text.modulate.a = 0.0
		_update_dialogue_line()
		var tw := create_tween()
		tw.tween_property(_dialogue_text, "modulate:a", 1.0, 0.12)


func _close_menu_instant() -> void:
	_menu.visible = false
	_menu_dim.visible = false


func _build_menu() -> void:
	_menu = Control.new()
	_menu.visible = false
	_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(_menu)

	_menu_dim = ColorRect.new()
	_menu_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu_dim.color = Color(0.02, 0.03, 0.03, 0.7)
	_menu_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_menu_dim.gui_input.connect(func(ev):
		if (ev is InputEventMouseButton and ev.pressed) or (ev is InputEventScreenTouch and ev.pressed):
			_close_menu()
	)
	_menu.add_child(_menu_dim)

	_menu_sheet = PanelContainer.new()
	_menu_sheet.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu_sheet.offset_left = 20
	_menu_sheet.offset_top = 140
	_menu_sheet.offset_right = -20
	_menu_sheet.offset_bottom = -24
	_menu_sheet.add_theme_stylebox_override("panel", UiThemeScript.panel_main(30, 0.97))
	_menu_sheet.mouse_filter = Control.MOUSE_FILTER_STOP
	_menu.add_child(_menu_sheet)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 14)
	_menu_sheet.add_child(outer)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	outer.add_child(header)
	var title := Label.new()
	title.text = "ASHENWOOD"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiThemeScript.style_label(title, 28, UiThemeScript.BRASS_LIGHT)
	header.add_child(title)
	var close_x := Button.new()
	close_x.text = "CLOSE"
	close_x.custom_minimum_size = Vector2(140, 56)
	close_x.add_theme_font_size_override("font_size", 22)
	UiThemeScript.style_secondary_button(close_x)
	close_x.pressed.connect(_close_menu)
	header.add_child(close_x)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	outer.add_child(tabs)
	_tab_buttons.clear()
	for page in [
		[&"hero", "Hero"],
		[&"bag", "Bag"],
		[&"gear", "Gear"],
		[&"quests", "Quests"],
		[&"more", "More"],
	]:
		var b := Button.new()
		b.text = page[1]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 64)
		b.add_theme_font_size_override("font_size", 20)
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(_open_page.bind(page[0]))
		tabs.add_child(b)
		_tab_buttons[page[0]] = b

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	_menu_body = VBoxContainer.new()
	_menu_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_menu_body.add_theme_constant_override("separation", 12)
	scroll.add_child(_menu_body)


func _update_tabs() -> void:
	var map := {
		&"hero": &"hero",
		&"bag": &"bag",
		&"gear": &"gear",
		&"quests": &"quests",
		&"forge": &"more",
		&"shop": &"more",
		&"more": &"more",
		&"settings": &"more",
	}
	var active: StringName = map.get(_page, &"hero")
	for id in _tab_buttons.keys():
		var btn: Button = _tab_buttons[id]
		var is_on: bool = id == active
		btn.add_theme_stylebox_override("normal", UiThemeScript.button_tab(is_on))
		btn.add_theme_stylebox_override("pressed", UiThemeScript.button_tab(true))
		btn.add_theme_stylebox_override("hover", UiThemeScript.button_tab(is_on))
		btn.add_theme_color_override("font_color", UiThemeScript.BRASS_LIGHT if is_on else UiThemeScript.MUTED)


func _open_page(page: StringName) -> void:
	_page = page
	AudioService.play_ui()
	_rebuild_menu_page()
	_update_tabs()


func _rebuild_menu_page() -> void:
	for c in _menu_body.get_children():
		c.queue_free()
	match _page:
		&"hero", &"character":
			_populate_hero()
		&"bag", &"inventory":
			_populate_inventory(false)
		&"gear", &"equipment":
			_populate_equipment()
		&"quests":
			_populate_quests()
		&"forge", &"upgrade":
			_populate_upgrade()
		&"shop":
			_populate_shop()
		&"more", &"settings":
			_populate_more()


func _section_title(text: String) -> void:
	var l := Label.new()
	l.text = text
	UiThemeScript.style_label(l, 22, UiThemeScript.BRASS)
	_menu_body.add_child(l)


func _body_label(text: String, size: int = 24, color: Color = UiThemeScript.CREAM) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiThemeScript.style_label(l, size, color)
	_menu_body.add_child(l)
	return l


func _stat_card(title: String, value: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", UiThemeScript.panel_card(18))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	card.add_child(v)
	var t := Label.new()
	t.text = title
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(t, 16, UiThemeScript.MUTED)
	v.add_child(t)
	var val := Label.new()
	val.text = value
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiThemeScript.style_label(val, 30, UiThemeScript.CREAM)
	v.add_child(val)
	return card


func _populate_hero() -> void:
	_section_title("Hero")
	_body_label("Wanderer of Ashenwood", 28)
	_body_label("Level %d" % GameState.level, 22, UiThemeScript.BRASS_LIGHT)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	_menu_body.add_child(grid)
	grid.add_child(_stat_card("HP", "%d / %d" % [GameState.hp, GameState.get_max_hp()]))
	grid.add_child(_stat_card("Attack", str(GameState.get_attack())))
	grid.add_child(_stat_card("Defense", str(GameState.get_defense())))
	grid.add_child(_stat_card("Gold", str(GameState.gold)))
	grid.add_child(_stat_card("Crit", "%.0f%%" % (GameState.get_crit_chance() * 100.0)))
	grid.add_child(_stat_card("Crit DMG", "+%.0f%%" % (GameState.get_crit_damage() * 100.0)))


func _populate_shop() -> void:
	_section_title("Merchant")
	_body_label("Your gold: %d" % GameState.gold, 22, UiThemeScript.BRASS_LIGHT)

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiThemeScript.panel_card(20))
	_menu_body.add_child(card)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	card.add_child(row)

	var icon := Panel.new()
	icon.custom_minimum_size = Vector2(88, 88)
	icon.add_theme_stylebox_override("panel", UiThemeScript.circle(Color("8a3542"), Color("d07080"), 44))
	row.add_child(icon)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	var n := Label.new()
	n.text = "Health Vial"
	UiThemeScript.style_label(n, 26, UiThemeScript.CREAM)
	info.add_child(n)
	var d := Label.new()
	d.text = "Restores HP  ·  15 Gold"
	UiThemeScript.style_label(d, 20, UiThemeScript.MUTED)
	info.add_child(d)

	var buy := Button.new()
	buy.text = "BUY"
	buy.custom_minimum_size = Vector2(140, 80)
	buy.add_theme_font_size_override("font_size", 26)
	UiThemeScript.style_primary_button(buy)
	buy.pressed.connect(func():
		if GameState.spend_gold(15):
			GameState.add_item_by_id(&"health_vial", 1)
			AudioService.play_sfx(&"loot_pickup")
			_toast("Bought Health Vial")
			_rebuild_menu_page()
		else:
			_toast("Not enough gold")
			AudioService.play_ui(&"ui_click")
	)
	row.add_child(buy)


func _populate_inventory(upgrade_mode: bool) -> void:
	_section_title("Forge" if upgrade_mode else "Inventory")
	if upgrade_mode:
		_body_label("Tap an item to select, then upgrade.", 20, UiThemeScript.MUTED)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	_menu_body.add_child(grid)

	for item in GameState.inventory:
		var def = ContentDB.get_item(item.item_id)
		if def == null:
			continue
		var cell := PanelContainer.new()
		cell.custom_minimum_size = Vector2(280, 240)
		cell.add_theme_stylebox_override("panel", UiThemeScript.rarity_frame(def.rarity))
		grid.add_child(cell)

		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 8)
		cell.add_child(v)

		var icon := Panel.new()
		icon.custom_minimum_size = Vector2(0, 88)
		icon.add_theme_stylebox_override("panel", UiThemeScript.circle(def.icon_color, ItemDefScript.rarity_color(def.rarity), 18))
		v.add_child(icon)
		var glyph := Label.new()
		glyph.text = def.name.substr(0, 1).to_upper()
		glyph.set_anchors_preset(Control.PRESET_FULL_RECT)
		glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		glyph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		UiThemeScript.style_label(glyph, 36, UiThemeScript.INK)
		icon.add_child(glyph)
		var title := Label.new()
		title.text = def.name
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		UiThemeScript.style_label(title, 18, ItemDefScript.rarity_color(def.rarity))
		v.add_child(title)

		var meta := Label.new()
		meta.text = "x%d" % item.quantity if def.stackable or item.quantity > 1 else ("+%d" % item.upgrade_level)
		meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		UiThemeScript.style_label(meta, 16, UiThemeScript.MUTED)
		v.add_child(meta)

		var actions := HBoxContainer.new()
		actions.add_theme_constant_override("separation", 6)
		v.add_child(actions)

		var captured_uid: String = String(item.uid)
		var info_btn := Button.new()
		info_btn.text = "Info"
		info_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_btn.add_theme_font_size_override("font_size", 18)
		UiThemeScript.style_secondary_button(info_btn)
		info_btn.pressed.connect(func(): _inspect_item(captured_uid))
		actions.add_child(info_btn)

		if def.kind == ItemDefScript.Kind.EQUIPMENT:
			var eq := Button.new()
			eq.text = "Pick" if upgrade_mode else "Equip"
			eq.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			eq.add_theme_font_size_override("font_size", 18)
			UiThemeScript.style_primary_button(eq)
			var eq_uid: String = captured_uid
			eq.pressed.connect(func():
				if upgrade_mode:
					_selected_uid = eq_uid
					_rebuild_menu_page()
				else:
					GameState.equip_uid(eq_uid)
					AudioService.play_ui(&"ui_confirm")
					_toast("Equipped")
					_rebuild_menu_page()
			)
			actions.add_child(eq)
		elif def.kind == ItemDefScript.Kind.CONSUMABLE:
			var use := Button.new()
			use.text = "Use"
			use.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			use.add_theme_font_size_override("font_size", 18)
			UiThemeScript.style_primary_button(use)
			var use_uid: String = captured_uid
			use.pressed.connect(func():
				GameState.use_consumable_uid(use_uid)
				_toast("Used item")
				_rebuild_menu_page()
			)
			actions.add_child(use)


func _inspect_item(uid: String) -> void:
	var item = GameState.find_item_by_uid(uid)
	if item == null:
		return
	var def = ContentDB.get_item(item.item_id)
	if def == null:
		return
	_toast("%s · %s · ATK %d · DEF %d" % [
		def.name,
		ItemDefScript.rarity_name(def.rarity),
		def.attack + item.upgrade_level * 2,
		def.defense + item.upgrade_level,
	])


func _populate_equipment() -> void:
	_section_title("Equipment")
	var names := {
		ItemDefScript.Slot.WEAPON: "Weapon",
		ItemDefScript.Slot.HELMET: "Head",
		ItemDefScript.Slot.CHEST: "Chest",
		ItemDefScript.Slot.GLOVES: "Gloves",
		ItemDefScript.Slot.BOOTS: "Boots",
	}
	for slot in names.keys():
		var inv = GameState.equipment[slot]
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", UiThemeScript.panel_card(18))
		_menu_body.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		card.add_child(row)

		var slot_tag := Label.new()
		slot_tag.text = names[slot]
		slot_tag.custom_minimum_size = Vector2(120, 0)
		slot_tag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		UiThemeScript.style_label(slot_tag, 20, UiThemeScript.BRASS)
		row.add_child(slot_tag)

		var text := "Empty"
		var color := UiThemeScript.MUTED
		if inv:
			var def = ContentDB.get_item(inv.item_id)
			text = "%s +%d" % [def.name if def else "?", inv.upgrade_level]
			color = ItemDefScript.rarity_color(def.rarity) if def else UiThemeScript.CREAM
		var l := Label.new()
		l.text = text
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		UiThemeScript.style_label(l, 22, color)
		row.add_child(l)

		if inv:
			var u := Button.new()
			u.text = "Unequip"
			u.custom_minimum_size = Vector2(140, 56)
			u.add_theme_font_size_override("font_size", 18)
			UiThemeScript.style_secondary_button(u)
			u.pressed.connect(func():
				GameState.unequip_slot(slot)
				_rebuild_menu_page()
			)
			row.add_child(u)

	_body_label("")
	var stats := HBoxContainer.new()
	stats.add_theme_constant_override("separation", 12)
	_menu_body.add_child(stats)
	stats.add_child(_stat_card("ATK", str(GameState.get_attack())))
	stats.add_child(_stat_card("DEF", str(GameState.get_defense())))
	stats.add_child(_stat_card("HP", str(GameState.get_max_hp())))


func _populate_quests() -> void:
	_section_title("Quests")
	var active := PanelContainer.new()
	active.add_theme_stylebox_override("panel", UiThemeScript.panel_card(18))
	_menu_body.add_child(active)
	var av := VBoxContainer.new()
	av.add_theme_constant_override("separation", 6)
	active.add_child(av)
	var at := Label.new()
	at.text = "Active"
	UiThemeScript.style_label(at, 16, UiThemeScript.BRASS)
	av.add_child(at)
	var ad := Label.new()
	ad.text = QuestService.get_tracker_text()
	ad.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiThemeScript.style_label(ad, 24, UiThemeScript.CREAM)
	av.add_child(ad)

	for qid in ContentDB.quests.keys():
		var def = ContentDB.get_quest(qid)
		var status := "Complete" if QuestService.completed.has(qid) else ("In Progress" if QuestService.active_quest_id == qid else "Locked")
		var status_color := UiThemeScript.SUCCESS if status == "Complete" else (UiThemeScript.BRASS_LIGHT if status == "In Progress" else UiThemeScript.MUTED)
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", UiThemeScript.panel_card(16))
		_menu_body.add_child(card)
		var row := HBoxContainer.new()
		card.add_child(row)
		var name_l := Label.new()
		name_l.text = def.title
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UiThemeScript.style_label(name_l, 22, UiThemeScript.CREAM)
		row.add_child(name_l)
		var st := Label.new()
		st.text = status
		UiThemeScript.style_label(st, 18, status_color)
		row.add_child(st)


func _populate_upgrade() -> void:
	_populate_inventory(true)
	if _selected_uid != "":
		var preview := GameState.upgrade_preview(_selected_uid)
		if not preview.is_empty():
			var card := PanelContainer.new()
			card.add_theme_stylebox_override("panel", UiThemeScript.panel_card(20))
			_menu_body.add_child(card)
			var v := VBoxContainer.new()
			v.add_theme_constant_override("separation", 8)
			card.add_child(v)
			var t := Label.new()
			t.text = "%s  +%d → +%d" % [preview.name, preview.level, preview.next_level]
			UiThemeScript.style_label(t, 26, UiThemeScript.BRASS_LIGHT)
			v.add_child(t)
			var a := Label.new()
			a.text = "Attack  %d  →  %d" % [preview.attack, preview.attack_next]
			UiThemeScript.style_label(a, 22, UiThemeScript.CREAM)
			v.add_child(a)
			var d := Label.new()
			d.text = "Defense  %d  →  %d" % [preview.defense, preview.defense_next]
			UiThemeScript.style_label(d, 22, UiThemeScript.CREAM)
			v.add_child(d)
			var c := Label.new()
			c.text = "Cost: %d gold" % preview.cost
			UiThemeScript.style_label(c, 22, UiThemeScript.BRASS)
			v.add_child(c)
			var btn := Button.new()
			btn.text = "UPGRADE"
			btn.custom_minimum_size = Vector2(0, 80)
			btn.add_theme_font_size_override("font_size", 30)
			UiThemeScript.style_primary_button(btn)
			btn.pressed.connect(func():
				if GameState.upgrade_uid(_selected_uid):
					_toast("Upgraded!")
					UiThemeScript.pulse_control(btn)
				else:
					_toast("Not enough gold")
				_rebuild_menu_page()
			)
			v.add_child(btn)


func _populate_more() -> void:
	_section_title("More")
	var forge := Button.new()
	forge.text = "Blacksmith Forge"
	forge.custom_minimum_size = Vector2(0, 72)
	forge.add_theme_font_size_override("font_size", 24)
	UiThemeScript.style_secondary_button(forge)
	forge.pressed.connect(func(): _open_page(&"forge"))
	_menu_body.add_child(forge)

	var shop := Button.new()
	shop.text = "Merchant Shop"
	shop.custom_minimum_size = Vector2(0, 72)
	shop.add_theme_font_size_override("font_size", 24)
	UiThemeScript.style_secondary_button(shop)
	shop.pressed.connect(func(): _open_page(&"shop"))
	_menu_body.add_child(shop)

	_section_title("Settings")
	_body_label("Music", 20, UiThemeScript.MUTED)
	var music := HSlider.new()
	music.min_value = 0
	music.max_value = 1
	music.step = 0.05
	music.value = AudioService.music_volume
	music.custom_minimum_size = Vector2(0, 40)
	music.value_changed.connect(func(v): AudioService.set_music_volume(v))
	_menu_body.add_child(music)

	_body_label("SFX", 20, UiThemeScript.MUTED)
	var sfx := HSlider.new()
	sfx.min_value = 0
	sfx.max_value = 1
	sfx.step = 0.05
	sfx.value = AudioService.sfx_volume
	sfx.custom_minimum_size = Vector2(0, 40)
	sfx.value_changed.connect(func(v): AudioService.set_sfx_volume(v))
	_menu_body.add_child(sfx)

	var vib := CheckButton.new()
	vib.text = "Vibration"
	vib.button_pressed = AudioService.vibration_enabled
	vib.add_theme_font_size_override("font_size", 24)
	vib.add_theme_color_override("font_color", UiThemeScript.CREAM)
	vib.toggled.connect(func(on): AudioService.set_vibration_enabled(on))
	_menu_body.add_child(vib)

	var save_btn := Button.new()
	save_btn.text = "Save Now"
	save_btn.custom_minimum_size = Vector2(0, 72)
	save_btn.add_theme_font_size_override("font_size", 24)
	UiThemeScript.style_primary_button(save_btn)
	save_btn.pressed.connect(func():
		SaveService.save_game()
		_toast("Progress saved")
	)
	_menu_body.add_child(save_btn)
