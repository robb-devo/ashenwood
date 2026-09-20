# Architecture — Ashenwood

## Engine
Godot 4.7, GDScript, mobile renderer, portrait 1080×1920.

## Layering
1. **Autoloads** — configuration, events, input aggregation, audio hooks
2. **Scenes** — composition roots (Main, Player, HUD, later Enemies/NPCs)
3. **Scripts by domain** — player, world, combat, ui, systems, save
4. **Data** — future resource/JSON defs for items, enemies, quests, dialogue

## Future MMO posture
- Gameplay mutations should flow through explicit services / EventBus
- Avoid baking progression only into scene-local variables
- Keep combat resolution in a dedicated module (easy to server-author later)
- No networking in the vertical slice

## Milestone 1 ownership
- `VillageBuilder` owns village composition
- `PropFactory` owns placeholder mesh construction
- `PlayerController` owns movement feel
- `PlayerCamera` owns framing
- `MobileJoystick` + `InputService` own touch move intent
- `HUD` owns portrait chrome shell
