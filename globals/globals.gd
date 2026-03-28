extends Node

@export_category("Player settings")
@export var master_volume_default := 100.0
@export var music_volume_default := 100.0
@export var sfx_volume_default := 100.0
@export var vsync_default := false
@export var fullscreen_default := false

var master_volume := master_volume_default
var music_volume := music_volume_default
var sfx_volume := sfx_volume_default
var vsync := vsync_default
var fullscreen := fullscreen_default

const CONFIG_FILEPATH := "user://settings.cfg"
const MASTER_VOLUME_BUS := 0
const MUSIC_VOLUME_BUS := 1
const SFX_VOLUME_BUS := 2

func _ready() -> void:
	if FileAccess.file_exists(CONFIG_FILEPATH):
		load_config()

func load_config() -> void:
	var config := ConfigFile.new()
	var error := config.load(CONFIG_FILEPATH)
	
	if error != OK:
		print("Config file not found")
		return
		
	master_volume = config.get_value("audio", "master_volume", master_volume_default)
	music_volume = config.get_value("audio", "music_volume", music_volume_default)
	sfx_volume = config.get_value("audio", "sfx_volume", sfx_volume_default)
	vsync = config.get_value("video", "vsync", vsync_default)
	fullscreen = config.get_value("video", "fullscreen", fullscreen_default)
	
	apply_settings()
	
func apply_settings() -> void:
	set_volume(MASTER_VOLUME_BUS, master_volume)
	set_volume(MUSIC_VOLUME_BUS, music_volume)
	set_volume(SFX_VOLUME_BUS, sfx_volume)
	set_vsync()
	set_window_mode()

func set_volume(volume_bus: int, volume_linear: float) -> void:
	AudioServer.set_bus_volume_db(volume_bus, linear_to_db(volume_linear/100.0))
	
func set_window_mode() -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func set_vsync() -> void:
	if vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	
	
func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("video", "vsync", vsync_default)
	config.set_value("video", "fullscreen", fullscreen)
	config.save(CONFIG_FILEPATH)
	print("Config saved")

func restore_settings() -> void:
	master_volume = master_volume_default
	music_volume = music_volume_default
	sfx_volume = sfx_volume_default
	vsync = vsync_default
	fullscreen = fullscreen_default
	apply_settings()
		
	
