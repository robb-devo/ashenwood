extends Node
## Central gameplay / mobile configuration.
## Keep tunable values here instead of scattering magic numbers.

const APP_ID := "com.ashenwood.game"
const APP_DISPLAY_NAME := "Ashenwood"
const SAVE_VERSION := 1

## Portrait design reference (9:16).
const DESIGN_WIDTH := 1080
const DESIGN_HEIGHT := 1920

## Player movement (Milestone 1 baseline).
const PLAYER_MOVE_SPEED := 6.5
const PLAYER_ACCELERATION := 28.0
const PLAYER_FRICTION := 32.0
const PLAYER_ROTATION_SPEED := 14.0

## Camera.
const CAMERA_DISTANCE := 14.0
const CAMERA_HEIGHT := 16.0
const CAMERA_PITCH_DEG := -55.0
const CAMERA_FOLLOW_SMOOTHING := 8.0
const CAMERA_LOOK_AHEAD := 1.25

## Joystick.
const JOYSTICK_DEADZONE := 0.12
const JOYSTICK_MAX_RADIUS := 110.0

## World.
const VILLAGE_SPAWN := Vector3(0.0, 0.0, 4.0)
const WORLD_BOUNDS := Rect2(-30.0, -68.0, 92.0, 92.0)

## Visual identity (stylized dark fantasy).
const COLOR_GROUND_VILLAGE := Color("3d4f3a")
const COLOR_PATH := Color("5a4a38")
const COLOR_BUILDING := Color("6b5a48")
const COLOR_ROOF := Color("4a3530")
const COLOR_WOOD := Color("7a6248")
const COLOR_FOLIAGE := Color("2f4a35")
const COLOR_PLAYER := Color("c9a45c")
const COLOR_PLAYER_ACCENT := Color("2a3d4a")
const COLOR_FIRE := Color("e0893a")
const COLOR_FOG := Color(0.12, 0.14, 0.16, 1.0)
