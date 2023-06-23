@icon("icon.svg")

class_name AcrylicGlass
extends TextureRect

# A TextureRect that imitates Microsoft's Acrylic and Mica effects


const blur = preload("blur.gd")

const blur_amount := 50
@export var tint_color := Color("1f1f1f66") :
	set(value):
			if value == tint_color:
				return
			
			tint_color = value
			material.set_shader_parameter("tint", tint_color)
@export var opaque_on_lost_focus := true
@export_range(0, 2, 0.05) var fade_in_duration := 0.1
@export_range(0, 2, 0.05) var fade_out_duration := 0.1

var cache := {"wallpaper_checksum": "", "wallpaper_blur": -1}
var config := ConfigFile.new()


func _init():
	if not material:
		material = preload("acrylic_material.tres").duplicate()
	stretch_mode = STRETCH_TILE


func _ready() -> void:
	setup_config()
	
	if not texture:
		var wallpaper_info := get_wallpaper()
		var cache_blurred_path: String = "user://acrylic_cache/%s.res" % wallpaper_info.checksum
		
		if (
				wallpaper_info.checksum == cache.wallpaper_checksum
				and cache.wallpaper_blur == blur_amount
				and FileAccess.file_exists(cache_blurred_path)
		):
			texture = load(cache_blurred_path)
		else:
			DirAccess.remove_absolute(cache_blurred_path)
			wallpaper_info.texture.update(blur.fast_blur(wallpaper_info.texture.get_image(), blur_amount))
			texture = wallpaper_info.texture
			ResourceSaver.save(texture, "user://acrylic_cache/%s.res" % wallpaper_info.checksum)
			
			cache.wallpaper_checksum = wallpaper_info.checksum
			cache.wallpaper_blur = blur_amount
			save_config()
	
	material.set_shader_parameter(&"screen_size", DisplayServer.screen_get_size())
	material.set_shader_parameter(&"texture_size", texture.get_size())


func _process(_delta: float) -> void:
	material.set_shader_parameter(
		&"pos_on_screen",
		get_window().position + Vector2i(global_position)
	)


func get_wallpaper() -> Dictionary:
	var wallpaper_info := {"texture": null, "checksum": ""}
	var image := Image.new()
	var err := -1
	
	match OS.get_name():
		"Windows":
			var locations := [
				"%s/Microsoft/Windows/Themes/CachedFiles/CachedImage_%s_%s_POS4.jpg" % \
						[OS.get_environment("AppData"), DisplayServer.screen_get_size().x, DisplayServer.screen_get_size().y],
				"%s/Microsoft/Windows/Themes/CachedFiles/CachedImage_1128_634_POS4.jpg" % \
						OS.get_environment("AppData"),
				"%s/Web/Wallpaper/Windows/img0.jpg" % OS.get_environment("SystemRoot"),
			]
			for i in locations:
				err = image.load(i)
				if err == OK:
					wallpaper_info.checksum = FileAccess.get_md5(i)
					break
		"Linux":
			var output := []
			OS.execute("gsettings", ["get", "org.gnome.desktop.background", "picture-uri"], output)
			var filepath: String = output[0]
			filepath = filepath.replace("file://", "").replace("'", "").strip_edges()
			err = image.load(filepath)
			wallpaper_info.checksum = FileAccess.get_md5(filepath)
	
	if err == OK:
		wallpaper_info.texture = ImageTexture.create_from_image(image)
	else:
		wallpaper_info.texture = ImageTexture.new()
		printerr("Couldn't get wallpaper. Error code %s" % err)
	
	return wallpaper_info


func setup_config() -> void:
	DirAccess.make_dir_absolute("user://acrylic_cache")
	var err := config.load("user://acrylic_cache/config.cfg")
	
	if err:
		save_config()
		return
	
	cache.wallpaper_checksum = config.get_value("cache", "wallpaper_checksum", "")
	cache.wallpaper_blur = config.get_value("cache", "wallpaper_blur", -1)


func save_config() -> void:
	config.set_value("cache", "wallpaper_checksum", cache.wallpaper_checksum)
	config.set_value("cache", "wallpaper_blur", cache.wallpaper_blur)
	config.save("user://acrylic_cache/config.cfg")


func _notification(what: int) -> void:
	if not opaque_on_lost_focus:
		return
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		create_tween().tween_property(material, ^"shader_parameter/tint:a", tint_color.a, fade_in_duration)
	elif what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		create_tween().tween_property(material, ^"shader_parameter/tint:a", 1, fade_out_duration)
