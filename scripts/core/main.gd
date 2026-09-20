extends Node3D
## Main entry for Ashenwood vertical slice.


func _ready() -> void:
	DisplayServer.window_set_title("%s" % GameConfig.APP_DISPLAY_NAME)
	AudioService.play_music(&"village_ambient")
