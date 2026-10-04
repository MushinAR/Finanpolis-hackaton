shader_type canvas_item;
// Vuelve translucidas SOLO las paredes que tapan de verdad al jugador.
//
// Un tile de pared es un cubo de 64x64 cuya BASE (el centro del rombo de abajo) esta
// en el pixel (32,48) de la imagen. Una pared tapa al jugador cuando se cumplen las
// tres cosas a la vez:
//   1. Se dibuja delante de el: su base esta mas abajo que los pies del jugador.
//   2. Esta en su misma columna de pantalla: el cubo y el cuerpo se pisan en X.
//   3. Es lo bastante alta para llegarle: el techo del cubo queda por encima de los pies.
// Todo se calcula con la base del tile, que es igual para todos sus pixeles, asi el
// cubo entero se desvanece de una y no por la mitad.

// Posicion de los pies del jugador en el mundo. La escribe wall_fade.gd cada frame.
uniform vec2 target = vec2(-100000.0);
// Medio ancho del cuerpo del jugador, en pixeles (el dibujo mide ~22 de ancho).
uniform float target_half_width : hint_range(0.0, 64.0) = 11.0;
// Cuantos pixeles de solapamiento hacen falta para llegar al maximo de transparencia.
// Mas alto = aparece mas de a poco al acercarse; 1 = corte seco.
uniform float edge : hint_range(1.0, 32.0) = 8.0;
// Que tan transparente queda la pared que tapa. 0 = invisible, 1 = sin efecto.
uniform float min_alpha : hint_range(0.0, 1.0) = 0.22;
// Tamaño de la celda del atlas, en pixeles.
uniform float cell_size = 64.0;
// Donde apoya el dibujo dentro de la celda (32,48 de 64 -> 0.5, 0.75).
uniform vec2 cell_pivot = vec2(0.5, 0.75);
// Proporcion del tile isometrico (64x32 -> 2.0). Da la pendiente del borde del cubo.
uniform float iso_ratio = 2.0;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// UV dentro de la celda del atlas (0..1), sirva el atlas que sirva.
	vec2 tex_size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 cell_uv = fract(UV * tex_size / cell_size);
	// Donde apoya ESTE tile en el mundo. Da lo mismo para todos sus pixeles.
	vec2 base = world_pos + (cell_pivot - cell_uv) * cell_size;

	// 1. Solo tapan las paredes que se dibujan delante del jugador.
	float in_front = step(target.y, base.y);

	// 2. Distancia horizontal entre el cubo y el borde del cuerpo. 0 = el cuerpo
	//    pasa justo por el medio del cubo; cell_size/2 = ya no se tocan.
	float u = max(abs(base.x - target.x) - target_half_width, 0.0);
	float overlap_x = cell_size * 0.5 - u;

	// 3. Altura del techo del cubo en esa columna (el cubo es un hexagono: el techo
	//    baja hacia los costados). Tiene que quedar por encima de los pies.
	float top = base.y - cell_size * cell_pivot.y + u / iso_ratio;
	float overlap_y = target.y - top;

	// Cuanto se pisan de verdad: manda el menor de los dos solapamientos.
	float covers = smoothstep(0.0, edge, min(overlap_x, overlap_y));

	COLOR = vec4(tex.rgb, tex.a * mix(1.0, min_alpha, covers * in_front));
}
