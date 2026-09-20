class_name HudRoot
extends CanvasLayer
## Premium portrait RPG HUD — built for readability and one-hand play.

const ItemDefScript = preload("res://scripts/data/item_def.gd")
const UiThemeScript = preload("res://scripts/ui/ui_theme.gd")
const JoystickScript = preload("res://scripts/ui/mobile_joystick.gd")

var root: Control
var attack_button: Button
var interact_button: Button
var menu_button: Button
var hp_bar: ProgressBar
var xp_bar: ProgressBar
var level_label: Label
var gold_label: Label
var quest_label: Label
var toast_label: Label
var hint_label: Label
var portrait: Panel

var _menu: Control
var _dialogue: Control
var _dialogue_text: Label
var _dialogue_lines: PackedStringArray = []
var _dialogue_index: int = 0
var _page: StringName = &"character"
var _menu_body: VBoxContainer
var _selected_uid: String = ""
var _attack_cooldown_overlay: ColorRect


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
	_refresh_stats()
	_refresh_quest()


func _build_hud() -> void:
	# Clear packed children if present
	for c in get_children():
		c.queue_free()

	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_build_top_left()
	_build_top_right()
	_build_quest_tracker()
	_build_center_joystick()
	_build_attack_cluster()
	_build_toast_and_hint()


func _build_top_left() -> void:
	var frame := PanelContainer.new()
	frame.position = Vector2(24, 28)
	frame.custom_minimum_size = Vector2(420, 138)
	frame.add_theme_stylebox_override("panel", UiThemeScript.panel_dark(24, 0.82))
	root.add_child(frame)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	frame.add_child(row)

	portrait = Panel.new()
	portrait.custom_minimum_size = Vector2(78, 78)
	portrait.add_theme_stylebox_override("panel", UiThemeScript.circle(Color("c9a45c"), Color("f0e0b0"), 40))
	row.add_child(portrait)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 6)
	row.add_child(col)

	var name_row := HBoxContainer.new()
	col.add_child(name_row)
	var name_l := Label.new()
	name_l.text = "Wanderer"
	name_l.add_theme_font_size_override("font_size", 30)
	name_l.add_theme_color_override("font_color", Color("f2ebe0"))
	name_row.add_child(name_l)
	level_label = Label.new()
	level_label.text = "Lv. 1"
	level_label.add_theme_font_size_override("font_size", 22)
	level_label.add_theme_color_override("font_color", Color("d4b56a"))
	level_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	name_row.add_child(level_label)

	hp_bar = _make_bar(UiThemeScript.bar_hp())
	col.add_child(hp_bar)
	xp_bar = _make_bar(UiThemeScript.bar_xp())
	xp_bar.custom_minimum_size = Vector2(0, 10)
	col.add_child(xp_bar)


func _make_bar(fill: StyleBoxFlat) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 16)
	bar.show_percentage = false
	bar.max_value = 100
	bar.value = 100
	bar.add_theme_stylebox_override("background", UiThemeScript.bar_bg())
	bar.add_theme_stylebox_override("fill", fill)
	return bar


func _build_top_right() -> void:
	gold_label = Label.new()
	gold_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	gold_label.offset_left = -280
	gold_label.offset_top = 36
	gold_label.offset_right = -120
	gold_label.offset_bottom = 80
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	gold_label.add_theme_font_size_override("font_size", 28)
	gold_label.add_theme_color_override("font_color", Color("f0d78a"))
	gold_label.text = "0"
	root.add_child(gold_label)

	var gold_tag := Label.new()
	gold_tag.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	gold_tag.offset_left = -280
	gold_tag.offset_top = 18
	gold_tag.offset_right = -120
	gold_tag.offset_bottom = 40
	gold_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	gold_tag.add_theme_font_size_override("font_size", 16)
	gold_tag.add_theme_color_override("font_color", Color(0.85, 0.8, 0.7, 0.7))
	gold_tag.text = "GOLD"
	root.add_child(gold_tag)

	menu_button = Button.new()
	menu_button.text = "☰"
	menu_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	menu_button.offset_left = -108
	menu_button.offset_top = 28
	menu_button.offset_right = -28
	menu_button.offset_bottom = 108
	menu_button.add_theme_font_size_override("font_size", 34)
	_style_button(menu_button)
	menu_button.pressed.connect(_toggle_menu)
	root.add_child(menu_button)


func _build_quest_tracker() -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.offset_left = -250
	panel.offset_top = 176
	panel.offset_right = 250
	panel.offset_bottom = 268
	panel.add_theme_stylebox_override("panel", UiThemeScript.panel_glass(18))
	root.add_child(panel)
	quest_label = Label.new()
	quest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quest_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quest_label.add_theme_font_size_override("font_size", 22)
	quest_label.add_theme_color_override("font_color", Color("efe6d4"))
	panel.add_child(quest_label)


func _build_center_joystick() -> void:
	var stick := Control.new()
	stick.set_script(JoystickScript)
	stick.set_anchors_preset(Control.PRESET_CENTER)
	# Slightly below true center so character stays readable
	stick.offset_left = -170
	stick.offset_top = -40
	stick.offset_right = 170
	stick.offset_bottom = 300
	stick.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(stick)


func _build_attack_cluster() -> void:
	attack_button = Button.new()
	attack_button.text = "⚔"
	attack_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	attack_button.offset_left = -210
	attack_button.offset_top = -250
	attack_button.offset_right = -40
	attack_button.offset_bottom = -80
	attack_button.focus_mode = Control.FOCUS_NONE
	attack_button.add_theme_font_size_override("font_size", 56)
	attack_button.add_theme_color_override("font_color", Color("1a1410"))
	attack_button.add_theme_stylebox_override("normal", UiThemeScript.circle(Color("e0b34a"), Color("fff1c2"), 100))
	attack_button.add_theme_stylebox_override("pressed", UiThemeScript.circle(Color("c49330"), Color("ffe08a"), 100))
	attack_button.add_theme_stylebox_override("hover", UiThemeScript.circle(Color("ecc25a"), Color("fff6d2"), 100))
	attack_button.pressed.connect(func():
		InputService.attack_pressed = true
		AudioService.play_ui()
		AudioService.pulse_haptic(0.22)
		_pulse_attack()
	)
	root.add_child(attack_button)

	var skill := Button.new()
	skill.text = "◆"
	skill.disabled = true
	skill.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	skill.offset_left = -320
	skill.offset_top = -200
	skill.offset_right = -220
	skill.offset_bottom = -100
	skill.add_theme_font_size_override("font_size", 28)
	skill.add_theme_stylebox_override("disabled", UiThemeScript.circle(Color(0.15, 0.16, 0.18, 0.55), Color(0.6, 0.55, 0.4, 0.25), 60))
	root.add_child(skill)

	interact_button = Button.new()
	interact_button.text = "Talk"
	interact_button.visible = false
	interact_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	interact_button.offset_left = -210
	interact_button.offset_top = -360
	interact_button.offset_right = -40
	interact_button.offset_bottom = -275
	interact_button.focus_mode = Control.FOCUS_NONE
	interact_button.add_theme_font_size_override("font_size", 28)
	_style_button(interact_button)
	interact_button.pressed.connect(func():
		InputService.interact_pressed = true
		AudioService.play_ui()
	)
	root.add_child(interact_button)


func _pulse_attack() -> void:
	var tw := create_tween()
	tw.tween_property(attack_button, "scale", Vector2(0.92, 0.92), 0.06)
	tw.tween_property(attack_button, "scale", Vector2.ONE, 0.1)


func _build_toast_and_hint() -> void:
	toast_label = Label.new()
	toast_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	toast_label.offset_left = -320
	toast_label.offset_top = 290
	toast_label.offset_right = 320
	toast_label.offset_bottom = 340
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_font_size_override("font_size", 30)
	toast_label.add_theme_color_override("font_color", Color("ffe6a0"))
	toast_label.modulate.a = 0.0
	root.add_child(toast_label)

	hint_label = Label.new()
	hint_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint_label.offset_left = -360
	hint_label.offset_top = -70
	hint_label.offset_right = 360
	hint_label.offset_bottom = -28
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 18)
	hint_label.add_theme_color_override("font_color", Color(0.9, 0.86, 0.75, 0.55))
	hint_label.text = "Drag center stick to move"
	root.add_child(hint_label)


func _style_button(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal", UiThemeScript.button_quiet())
	btn.add_theme_stylebox_override("pressed", UiThemeScript.button_quiet())
	btn.add_theme_stylebox_override("hover", UiThemeScript.button_quiet())
	btn.add_theme_color_override("font_color", Color("efe6d4"))


func open_upgrade_from_blacksmith() -> void:
	_menu.visible = true
	_page = &"upgrade"
	_rebuild_menu_page()
	EventBus.ui_menu_opened.emit(&"upgrade")


func set_interact_prompt(show: bool, npc_name: String = "") -> void:
	interact_button.visible = show
	if show:
		interact_button.text = "Talk"
		hint_label.text = "Near %s — tap Talk" % npc_name
	else:
		hint_label.text = "Drag center stick to move"


func _refresh_stats() -> void:
	hp_bar.max_value = GameState.get_max_hp()
	hp_bar.value = GameState.hp
	xp_bar.max_value = GameState.xp_to_next_level()
	xp_bar.value = GameState.xp
	level_label.text = "Lv. %d" % GameState.level
	gold_label.text = str(GameState.gold)


func _refresh_quest() -> void:
	quest_label.text = QuestService.get_tracker_text()


func _on_level_up(level: int) -> void:
	_toast("LEVEL UP  ·  Lv. %d" % level)


func _on_quest_complete(quest_id: StringName) -> void:
	var def = ContentDB.get_quest(quest_id)
	_toast("Quest Complete  ·  %s" % (def.title if def else String(quest_id)))
	_refresh_quest()


func _toast(text: String) -> void:
	toast_label.text = text
	toast_label.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(1.7)
	tw.tween_property(toast_label, "modulate:a", 0.0, 0.55)


func _toggle_menu() -> void:
	if _dialogue.visible:
		return
	_menu.visible = not _menu.visible
	if _menu.visible:
		_page = &"character"
		_rebuild_menu_page()
		EventBus.ui_menu_opened.emit(_page)
		AudioService.play_ui()
	else:
		EventBus.ui_menu_closed.emit()


func _build_dialogue() -> void:
	_dialogue = PanelContainer.new()
	_dialogue.visible = false
	_dialogue.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_dialogue.offset_left = -480
	_dialogue.offset_right = 480
	_dialogue.offset_top = -380
	_dialogue.offset_bottom = -90
	_dialogue.add_theme_stylebox_override("panel", UiThemeScript.panel_dark(24, 0.92))
	root.add_child(_dialogue)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	_dialogue.add_child(v)
	_dialogue_text = Label.new()
	_dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_text.custom_minimum_size = Vector2(900, 150)
	_dialogue_text.add_theme_font_size_override("font_size", 28)
	_dialogue_text.add_theme_color_override("font_color", Color("f2ebe0"))
	v.add_child(_dialogue_text)
	var btn := Button.new()
	btn.text = "Continue"
	btn.custom_minimum_size = Vector2(0, 70)
	btn.add_theme_font_size_override("font_size", 26)
	_style_button(btn)
	btn.pressed.connect(_advance_dialogue)
	v.add_child(btn)


func _show_dialogue(_npc_id: StringName, lines: PackedStringArray) -> void:
	_dialogue_lines = lines
	_dialogue_index = 0
	_dialogue.visible = true
	_menu.visible = false
	_update_dialogue_line()


func _update_dialogue_line() -> void:
	if _dialogue_index >= _dialogue_lines.size():
		_dialogue.visible = false
		return
	_dialogue_text.text = _dialogue_lines[_dialogue_index]


func _advance_dialogue() -> void:
	_dialogue_index += 1
	AudioService.play_ui()
	if _dialogue_index >= _dialogue_lines.size():
		_dialogue.visible = false
	else:
		_update_dialogue_line()


func _build_menu() -> void:
	_menu = PanelContainer.new()
	_menu.visible = false
	_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu.offset_left = 20
	_menu.offset_top = 160
	_menu.offset_right = -20
	_menu.offset_bottom = -24
	_menu.add_theme_stylebox_override("panel", UiThemeScript.panel_dark(26, 0.94))
	root.add_child(_menu)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 12)
	_menu.add_child(outer)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	outer.add_child(tabs)
	for page in [&"character", &"inventory", &"equipment", &"quests", &"upgrade", &"settings"]:
		var b := Button.new()
		b.text = String(page).capitalize()
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 56)
		_style_button(b)
		b.pressed.connect(_open_page.bind(page))
		tabs.add_child(b)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(scroll)
	_menu_body = VBoxContainer.new()
	_menu_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_menu_body.add_theme_constant_override("separation", 10)
	scroll.add_child(_menu_body)
	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(0, 68)
	close_btn.add_theme_font_size_override("font_size", 26)
	_style_button(close_btn)
	close_btn.pressed.connect(_toggle_menu)
	outer.add_child(close_btn)


func _open_page(page: StringName) -> void:
	_page = page
	AudioService.play_ui()
	_rebuild_menu_page()


func _rebuild_menu_page() -> void:
	for c in _menu_body.get_children():
		c.queue_free()
	match _page:
		&"character":
			_add_menu_label("Wanderer of Ashenwood")
			_add_menu_label("Level %d" % GameState.level)
			_add_menu_label("HP %d / %d" % [GameState.hp, GameState.get_max_hp()])
			_add_menu_label("Attack %d" % GameState.get_attack())
			_add_menu_label("Defense %d" % GameState.get_defense())
			_add_menu_label("Crit %.0f%%   Crit Damage +%.0f%%" % [GameState.get_crit_chance() * 100.0, GameState.get_crit_damage() * 100.0])
			_add_menu_label("Gold %d" % GameState.gold)
		&"inventory":
			_populate_inventory(false)
		&"equipment":
			_populate_equipment()
		&"quests":
			_populate_quests()
		&"upgrade":
			_populate_upgrade()
		&"settings":
			_populate_settings()


func _add_menu_label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", 24)
	l.add_theme_color_override("font_color", Color("efe6d4"))
	_menu_body.add_child(l)
	return l


func _populate_inventory(upgrade_mode: bool) -> void:
	for item in GameState.inventory:
		var def = ContentDB.get_item(item.item_id)
		if def == null:
			continue
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		_menu_body.add_child(row)
		var info := Label.new()
		info.text = "%s  ·  %s  ·  x%d  +%d" % [def.name, ItemDefScript.rarity_name(def.rarity), item.quantity, item.upgrade_level]
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_theme_font_size_override("font_size", 22)
		info.add_theme_color_override("font_color", ItemDefScript.rarity_color(def.rarity))
		row.add_child(info)
		if def.kind == ItemDefScript.Kind.EQUIPMENT:
			var eq := Button.new()
			eq.text = "Equip"
			_style_button(eq)
			eq.pressed.connect(func():
				GameState.equip_uid(item.uid)
				AudioService.play_ui()
				_rebuild_menu_page()
			)
			row.add_child(eq)
			if upgrade_mode:
				var up := Button.new()
				up.text = "Select"
				_style_button(up)
				up.pressed.connect(func():
					_selected_uid = item.uid
					_rebuild_menu_page()
				)
				row.add_child(up)
		elif def.kind == ItemDefScript.Kind.CONSUMABLE:
			var use := Button.new()
			use.text = "Use"
			_style_button(use)
			use.pressed.connect(func():
				GameState.use_consumable_uid(item.uid)
				_rebuild_menu_page()
			)
			row.add_child(use)


func _populate_equipment() -> void:
	var names := {
		ItemDefScript.Slot.WEAPON: "Weapon",
		ItemDefScript.Slot.HELMET: "Helmet",
		ItemDefScript.Slot.CHEST: "Chest",
		ItemDefScript.Slot.GLOVES: "Gloves",
		ItemDefScript.Slot.BOOTS: "Boots",
	}
	for slot in names.keys():
		var inv = GameState.equipment[slot]
		var text := "%s — Empty" % names[slot]
		if inv:
			var def = ContentDB.get_item(inv.item_id)
			text = "%s — %s +%d" % [names[slot], def.name if def else "?", inv.upgrade_level]
		var row := HBoxContainer.new()
		_menu_body.add_child(row)
		var l := Label.new()
		l.text = text
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.add_theme_font_size_override("font_size", 24)
		l.add_theme_color_override("font_color", Color("efe6d4"))
		row.add_child(l)
		if inv:
			var u := Button.new()
			u.text = "Unequip"
			_style_button(u)
			u.pressed.connect(func():
				GameState.unequip_slot(slot)
				_rebuild_menu_page()
			)
			row.add_child(u)


func _populate_quests() -> void:
	_add_menu_label(QuestService.get_tracker_text())
	_add_menu_label("")
	for qid in ContentDB.quests.keys():
		var def = ContentDB.get_quest(qid)
		var status := "Done" if QuestService.completed.has(qid) else ("Active" if QuestService.active_quest_id == qid else "Locked")
		_add_menu_label("%s — %s" % [def.title, status])


func _populate_upgrade() -> void:
	_add_menu_label("Blacksmith Forge")
	_add_menu_label("Select gear, then Upgrade.")
	_populate_inventory(true)
	if _selected_uid != "":
		var preview := GameState.upgrade_preview(_selected_uid)
		if not preview.is_empty():
			_add_menu_label("")
			_add_menu_label("%s  +%d → +%d" % [preview.name, preview.level, preview.next_level])
			_add_menu_label("ATK %d → %d" % [preview.attack, preview.attack_next])
			_add_menu_label("DEF %d → %d" % [preview.defense, preview.defense_next])
			_add_menu_label("Cost: %d gold" % preview.cost)
			var btn := Button.new()
			btn.text = "UPGRADE"
			btn.custom_minimum_size = Vector2(0, 74)
			btn.add_theme_font_size_override("font_size", 28)
			_style_button(btn)
			btn.pressed.connect(func():
				if GameState.upgrade_uid(_selected_uid):
					_toast("Equipment upgraded")
				else:
					_toast("Not enough gold")
				_rebuild_menu_page()
			)
			_menu_body.add_child(btn)


func _populate_settings() -> void:
	_add_menu_label("Music")
	var music := HSlider.new()
	music.min_value = 0
	music.max_value = 1
	music.step = 0.05
	music.value = AudioService.music_volume
	music.value_changed.connect(func(v): AudioService.set_music_volume(v))
	_menu_body.add_child(music)
	_add_menu_label("SFX")
	var sfx := HSlider.new()
	sfx.min_value = 0
	sfx.max_value = 1
	sfx.step = 0.05
	sfx.value = AudioService.sfx_volume
	sfx.value_changed.connect(func(v): AudioService.set_sfx_volume(v))
	_menu_body.add_child(sfx)
	var vib := CheckButton.new()
	vib.text = "Vibration"
	vib.button_pressed = AudioService.vibration_enabled
	vib.toggled.connect(func(on): AudioService.set_vibration_enabled(on))
	_menu_body.add_child(vib)
	var save_btn := Button.new()
	save_btn.text = "Save Now"
	_style_button(save_btn)
	save_btn.pressed.connect(func():
		SaveService.save_game()
		_toast("Progress saved")
	)
	_menu_body.add_child(save_btn)
