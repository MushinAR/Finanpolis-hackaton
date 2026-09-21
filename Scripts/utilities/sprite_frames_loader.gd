class_name SpriteFramesLoader
extends RefCounted
## Arma un SpriteFrames a partir de tiras de PNG, así el artista solo reemplaza archivos.
##
## Convención: <carpeta>/<prefijo>_<animación>_<dirección>.png
## Cada PNG es una tira horizontal de celdas de `frame_size` (la cantidad de cuadros
## sale sola del ancho de la imagen). Lo que falte se saltea sin problema.


static func build(config: PlayerConfig, prefix: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var directions := CoordinateUtils.DIRECTIONS_8 if config.direction_count == 8 else CoordinateUtils.DIRECTIONS_4
	for anim in config.animations:
		for dir in directions:
			var path := "%s/%s_%s_%s.png" % [config.sprites_path, prefix, anim, dir]
			if not ResourceLoader.exists(path):
				continue
			var texture: Texture2D = load(path)
			var anim_name := StringName("%s_%s" % [anim, dir])
			frames.add_animation(anim_name)
			frames.set_animation_speed(anim_name, config.animations[anim])
			frames.set_animation_loop(anim_name, true)
			for i in texture.get_width() / config.frame_size.x:
				var atlas := AtlasTexture.new()
				atlas.atlas = texture
				atlas.region = Rect2(Vector2(config.frame_size.x * i, 0), Vector2(config.frame_size))
				frames.add_frame(anim_name, atlas)
	return frames
