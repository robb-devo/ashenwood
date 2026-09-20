class_name HudRoot
extends CanvasLayer
## Full portrait RPG HUD + menu overlays.

const ItemDefScript = preload("res://scripts/data/item_def.gd")

@onready var root: Control = $Root
@onready var attack_button: Button = $Root/AttackButton
@onready var interact_button: Button = $Root/InteractButton
@onready var menu_button: Button = $Root/MenuButton
@onready var hp_bar: ProgressBar = $Root/PlayerFrame/PlayerInfo/HPBar
@onready var xp_bar: ProgressBar = $Root/PlayerFrame/PlayerInfo/XPBar
@onready var level_label: Label = $Root/PlayerFrame/PlayerInfo/NameRow/NameLevel/LevelLabel
@onready var gold_label: Label = $Root/GoldLabel
@onready var quest_label: Label = $Root/QuestTracker/QuestText
@onready var toast_label: Label = $Root/Toast
@onready var hint_label: Label = $Root/Hint

var _menu: Control
var _dialogue: Control
var _dialogue_text: Label
var _dialogue_lines: PackedStringArray = []
var _dialogue_index: int = 0
var _page: StringName = &"character"
var _menu_body: VBoxContainer
var _selected_uid: String = ""


func _ready() -> void:
	layer = 20
	add_to_group("hud")
	attack_button.pressed.connect(func():
		InputService.attack_pressed = true
		AudioService.play_ui()
		AudioService.pulse_haptic(0.2)
	)
	interact_button.pressed.connect(func():
		InputService.interact_pressed = true
		AudioService.play_ui()
	)
	interact_button.visible = false
	menu_button.pressed.connect(_toggle_menu)
	GameState.stats_changed.connect(_refresh_stats)
	EventBus.player_gold_changed.connect(func(_g): _refresh_stats())
	EventBus.player_xp_changed.connect(func(_a, _b): _refresh_stats())
	EventBus.player_leveled_up.connect(_on_level_up)
	EventBus.quest_updated.connect(func(_q): _refresh_quest())
	EventBus.quest_started.connect(func(_q): _refresh_quest())
	EventBus.quest_completed.connect(_on_quest_complete)
	EventBus.dialogue_requested.connect(_show_dialogue)
	EventBus.inventory_changed.connect(func(): if _menu and _menu.visible: _rebuild_menu_page())
	_build_menu()
	_build_dialogue()
	_refresh_stats()
	_refresh_quest()


func open_upgrade_from_blacksmith() -> void:
	_menu.visible = true
	_page = &"upgrade"
	_rebuild_menu_page()
	EventBus.ui_menu_opened.emit(&"upgrade")


func set_interact_prompt(show: bool, npc_name: String = "") -> void:
	interact_button.visible = show
	if show:
		interact_button.text = "Talk"
		hint_label.text = "Near %s" % npc_name
	else:
		hint_label.text = "Joystick move · ATK fight · Menu top-right"


func _refresh_stats() -> void:
	hp_bar.max_value = GameState.get_max_hp()
	hp_bar.value = GameState.hp
	xp_bar.max_value = GameState.xp_to_next_level()
	xp_bar.value = GameState.xp
	level_label.text = "Lv. %d" % GameState.level
	gold_label.text = "Gold %d" % GameState.gold


func _refresh_quest() -> void:
	quest_label.text = QuestService.get_tracker_text()


func _on_level_up(level: int) -> void:
	_toast("LEVEL UP! Lv. %d" % level)


func _on_quest_complete(quest_id: StringName) -> void:
	var def = ContentDB.get_quest(quest_id)
	_toast("Quest complete: %s" % (def.title if def else String(quest_id)))
	_refresh_quest()


func _toast(text: String) -> void:
	toast_label.text = text
	toast_label.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(1.6)
	tw.tween_property(toast_label, "modulate:a", 0.0, 0.6)


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
	_dialogue.offset_top = -360
	_dialogue.offset_bottom = -80
	root.add_child(_dialogue)
	var v := VBoxContainer.new()
	_dialogue.add_child(v)
	_dialogue_text = Label.new()
	_dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_text.custom_minimum_size = Vector2(900, 160)
	v.add_child(_dialogue_text)
	var btn := Button.new()
	btn.text = "Continue"
	btn.custom_minimum_size = Vector2(0, 64)
	btn.pressed.connect(_advance_dialogue)
	v.add_child(btn)


func _show_dialogue(npc_id: StringName, lines: PackedStringArray) -> void:
	_dialogue_lines = lines
	_dialogue_index = 0
	_dialogue.visible = true
	_menu.visible = false
	_update_dialogue_line()
	# Ensure talk objectives resolve even if opened from merchant/blacksmith later
	if npc_id != &"":
		pass


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
	_menu.offset_left = 24
	_menu.offset_top = 170
	_menu.offset_right = -24
	_menu.offset_bottom = -24
	root.add_child(_menu)
	var outer := VBoxContainer.new()
	_menu.add_child(outer)
	var tabs := HBoxContainer.new()
	outer.add_child(tabs)
	for page in [&"character", &"inventory", &"equipment", &"quests", &"upgrade", &"settings"]:
		var b := Button.new()
		b.text = String(page).capitalize()
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(_open_page.bind(page))
		tabs.add_child(b)
	_menu_body = VBoxContainer.new()
	_menu_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(_menu_body)
	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(0, 64)
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
			_add_menu_label("Wanderer")
			_add_menu_label("Level %d" % GameState.level)
			_add_menu_label("HP %d / %d" % [GameState.hp, GameState.get_max_hp()])
			_add_menu_label("Attack %d" % GameState.get_attack())
			_add_menu_label("Defense %d" % GameState.get_defense())
			_add_menu_label("Crit %.0f%%  CritDMG +%.0f%%" % [GameState.get_crit_chance() * 100.0, GameState.get_crit_damage() * 100.0])
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
	_menu_body.add_child(l)
	return l


func _populate_inventory(upgrade_mode: bool) -> void:
	for item in GameState.inventory:
		var def = ContentDB.get_item(item.item_id)
		if def == null:
			continue
		var row := HBoxContainer.new()
		_menu_body.add_child(row)
		var info := Label.new()
		var rare := ItemDefScript.rarity_name(def.rarity)
		info.text = "%s  [%s]  x%d  +%d" % [def.name, rare, item.quantity, item.upgrade_level]
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.modulate = ItemDefScript.rarity_color(def.rarity)
		row.add_child(info)
		if def.kind == ItemDefScript.Kind.EQUIPMENT:
			var eq := Button.new()
			eq.text = "Equip"
			eq.pressed.connect(func():
				GameState.equip_uid(item.uid)
				AudioService.play_ui()
				_rebuild_menu_page()
			)
			row.add_child(eq)
			if upgrade_mode:
				var up := Button.new()
				up.text = "Upgrade"
				up.pressed.connect(func():
					_selected_uid = item.uid
					_page = &"upgrade"
					_rebuild_menu_page()
				)
				row.add_child(up)
		elif def.kind == ItemDefScript.Kind.CONSUMABLE:
			var use := Button.new()
			use.text = "Use"
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
		var text := "%s: Empty" % names[slot]
		if inv:
			var def = ContentDB.get_item(inv.item_id)
			text = "%s: %s +%d" % [names[slot], def.name if def else "?", inv.upgrade_level]
		var row := HBoxContainer.new()
		_menu_body.add_child(row)
		var l := Label.new()
		l.text = text
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		if inv:
			var u := Button.new()
			u.text = "Unequip"
			u.pressed.connect(func():
				GameState.unequip_slot(slot)
				_rebuild_menu_page()
			)
			row.add_child(u)
	_add_menu_label("")
	_add_menu_label("Tap Inventory to equip gear.")


func _populate_quests() -> void:
	_add_menu_label(QuestService.get_tracker_text())
	_add_menu_label("")
	for qid in ContentDB.quests.keys():
		var def = ContentDB.get_quest(qid)
		var status := "Done" if QuestService.completed.has(qid) else ("Active" if QuestService.active_quest_id == qid else "Locked")
		_add_menu_label("%s — %s" % [def.title, status])


func _populate_upgrade() -> void:
	_add_menu_label("Blacksmith Upgrade")
	_add_menu_label("Select equipment, then Upgrade.")
	_populate_inventory(true)
	if _selected_uid != "":
		var preview := GameState.upgrade_preview(_selected_uid)
		if not preview.is_empty():
			_add_menu_label("")
			_add_menu_label("%s +%d → +%d" % [preview.name, preview.level, preview.next_level])
			_add_menu_label("ATK %d → %d" % [preview.attack, preview.attack_next])
			_add_menu_label("DEF %d → %d" % [preview.defense, preview.defense_next])
			_add_menu_label("Cost: %d gold" % preview.cost)
			var btn := Button.new()
			btn.text = "UPGRADE"
			btn.custom_minimum_size = Vector2(0, 70)
			btn.pressed.connect(func():
				if GameState.upgrade_uid(_selected_uid):
					_toast("Upgraded!")
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
	save_btn.pressed.connect(func():
		SaveService.save_game()
		_toast("Saved")
	)
	_menu_body.add_child(save_btn)
