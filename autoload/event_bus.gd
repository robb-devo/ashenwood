extends Node
## Lightweight signal hub.

signal player_spawned(player: Node3D)
signal player_died
signal player_respawned
signal player_leveled_up(new_level: int)
signal player_gold_changed(amount: int)
signal player_xp_changed(current: int, required: int)

signal damage_dealt(amount: int, is_critical: bool, world_position: Vector3)
signal enemy_died(enemy_id: StringName, world_position: Vector3)

signal loot_collected(item_id: StringName, quantity: int)
signal rare_loot_found(item_id: StringName)
signal inventory_changed
signal equipment_changed

signal quest_started(quest_id: StringName)
signal quest_updated(quest_id: StringName)
signal quest_completed(quest_id: StringName)
signal quest_progress_toast(text: String)

signal npc_interact_requested(npc_id: StringName)
signal dialogue_requested(npc_id: StringName, lines: PackedStringArray)

signal boss_engaged(enemy_id: StringName, hp: int, max_hp: int)
signal boss_hp_changed(enemy_id: StringName, hp: int, max_hp: int)
signal boss_defeated(enemy_id: StringName)

signal ui_menu_opened(page: StringName)
signal ui_menu_closed
signal settings_changed

signal save_requested
signal load_requested
signal save_completed(success: bool)
