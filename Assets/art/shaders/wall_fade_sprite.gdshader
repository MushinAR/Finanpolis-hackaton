shader_type canvas_item;
// Lo mismo que wall_fade.gdshader, pero para paredes armadas con Sprites sueltos
// (un Sprite por tramo) en vez de tiles: vuelve translucido SOLO el tramo que tapa al jugador.
//
// El origen de cada Sprite es el punto medio de la linea donde el tramo apoya en el piso.
// Un tramo tapa al jugador cuando se cumplen las tres cosas a la vez:
//   1. Se dibuja delante de el: los pies quedan mas arriba que la linea de apoyo.
//   2. Esta en su misma columna de pantalla: el tramo y el cuerpo se pisan en X.
//   3. Es lo bastante alto para llegarle: el borde de arriba queda por encima de los pies.
// Todo se calcula con el origen del Sprite, que es igual para todos sus pixeles, asi el
// tramo entero se desvanece de una y no por la mitad.

// Posicion de los pies del jugador en el mundo. La escribe wall_fade_sprites.gd cada frame.
uniform vec2 target = vec2(-100000.0);
// Medio ancho del cuerpo del jugador, en pixeles (el dibujo mide ~22 de ancho).
uniform float target_half_width : hint_range(0.0, 64.0) = 11.0;
// Cuantos pixeles de solapamiento hacen falta para llegar al maximo de transparencia.
uniform float edge : hint_range(1.0, 32.0) = 8.0;
// Que tan transparente queda el tramo que tapa. 0 = invisible, 1 = sin efecto.
uniform float min_alpha : hint_range(0.0, 1.0) = 0.22;
// Transparencia de base, cuando no tapa a nadie. 1 = opaco.
uniform float max_alpha : hint_range(0.0, 1.0) = 1.0;
// Medio ancho del tramo en pantalla (un tramo de 72 px -> 36).
uniform float half_width = 36.0;
// Alto de la pared, del piso al borde de arriba.
uniform float height = 98.0;
// Pendiente de la linea de apoyo: 0.5 si baja hacia la derecha, -0.5 si baja hacia la izquierda.
uniform float slope = 0.5;

varying vec2 base;

void vertex() {
	base = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// Altura de la linea de apoyo en la columna del jugador (sin salirse del tramo).
	float dx = clamp(target.x - base.x, -half_width, half_width);
	float line_y = base.y + slope * dx;

	// 1. Solo tapan los tramos que se dibujan delante del jugador.
	float in_front = step(target.y, line_y);

	// 2. Distancia horizontal entre el tramo y el borde del cuerpo.
	float u = max(abs(target.x - base.x) - target_half_width, 0.0);
	float overlap_x = half_width - u;

	// 3. El borde de arriba tiene que quedar por encima de los pies.
	float overlap_y = target.y - (line_y - height);

	// Cuanto se pisan de verdad: manda el menor de los dos solapamientos.
	float covers = smoothstep(0.0, edge, min(overlap_x, overlap_y));

	COLOR = vec4(tex.rgb, tex.a * mix(max_alpha, min(min_alpha, max_alpha), covers * in_front));
}
