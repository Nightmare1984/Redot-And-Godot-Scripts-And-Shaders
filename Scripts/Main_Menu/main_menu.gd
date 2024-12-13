extends Control

@onready var settings = $Settings
@onready var ResolutionOption = $Settings/OptionButton
@onready var FullscreenToggle = $Settings/CheckBox
@onready var VSyncToggle = $Settings/CheckBox2
@onready var buttons = $VBoxContainer

func _play() -> void:
	get_tree().change_scene_to_file("")
func _Settings() -> void:
	settings.show()
	buttons.hide()
func _Quit() -> void:
	self.get_tree().quit()
func _ready():
	ResolutionOption.add_item("1280x720")
	ResolutionOption.add_item("1920x1080")
	ResolutionOption.add_item("2560x1440")
	ResolutionOption.add_item("3840x2160")
	for i in range(4):
		var text = ResolutionOption.get_item_text(i)
		var r = SettingsHandler._get_resolution_as_str()
		if text == r:
			ResolutionOption.selected = i
			break
	FullscreenToggle.button_pressed = SettingsHandler.SettingsDict["fullscreen"]
	VSyncToggle.button_pressed = SettingsHandler.SettingsDict["vsync"]
func _on_apply_settings() -> void:
	var resolution = ResolutionOption.get_item_text(ResolutionOption.selected)
	var fullscreen = FullscreenToggle.button_pressed
	var vsync = VSyncToggle.button_pressed
	resolution = resolution.split("x")
	resolution = [int(resolution[0]), int(resolution[1])]
	SettingsHandler.SettingsDict = {"resolution": resolution, "vsync": vsync, "fullscreen": fullscreen}
	
	SettingsHandler._apply_settings()
	SettingsHandler._save_settings()
func _on_close_button() -> void:
	settings.hide()
	buttons.show()
