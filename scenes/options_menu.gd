extends Control

var main_menu_scene: PackedScene = load("res://scenes/main_menu.tscn")

func _ready() -> void:
	set_values()

func set_values() -> void:
	%MasterHSlider.value = Globals.master_volume
	%MusicHSlider.value = Globals.music_volume
	%SoundHSlider.value = Globals.sfx_volume
	%VSyncCheckBox.button_pressed = Globals.vsync
	%FullscreenCheckButton.button_pressed = Globals.fullscreen

func _on_back_button_pressed() -> void:
	Globals.save_settings()
	get_tree().change_scene_to_packed(main_menu_scene)

func _on_restore_button_pressed() -> void:
	Globals.restore_settings()
	set_values()

func _on_v_sync_check_box_toggled(toggled_on: bool) -> void:
	Globals.vsync = toggled_on
	Globals.set_vsync()

func _on_fullscreen_check_button_toggled(toggled_on: bool) -> void:
	Globals.fullscreen = toggled_on
	Globals.set_window_mode()

func _on_sound_h_slider_value_changed(value: float) -> void:
	Globals.sfx_volume = value
	Globals.set_volume(Globals.SFX_VOLUME_BUS, Globals.sfx_volume)

func _on_music_h_slider_value_changed(value: float) -> void:
	Globals.music_volume = value
	Globals.set_volume(Globals.MUSIC_VOLUME_BUS, Globals.music_volume)

func _on_master_h_slider_value_changed(value: float) -> void:
	Globals.master_volume = value
	Globals.set_volume(Globals.MASTER_VOLUME_BUS, Globals.master_volume)
