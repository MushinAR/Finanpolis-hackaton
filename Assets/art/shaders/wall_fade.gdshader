shader_type canvas_item;
// Vuelve translucidas las paredes que tapan al jugador, al estilo Project Zomboid.
//
// La clave: un tile de pared es un cubo de 64x64 cuya BASE esta en el pixel (32,48)
// de la imagen. Lo que te tapa es la parte de arriba del cubo, que en pantalla queda
// MAS ARRIBA que su base. Por eso no alcanza con mirar la altura de cada pixel:
// hay que calcular donde apoya el tile y decidir con eso, asi el cubo entero
// se desvanece de una y no por la mitad.

// Posicion del jugador en el mundo. La escribe wall_fade.gd cada frame.
uniform vec2 target = vec2(-100000.0);
// Radio del agujero, en pixeles.
uniform float radius : hint_range(0.0, 200.0) = 40.0;
// Cuanto tarda en volver a ser solido (borde suave).
uniform float softness : hint_range(1.0, 200.0) = 56.0;
// Que tan transparente queda en el centro. 0 = invisible, 1 = sin efecto.
uniform float min_alpha : hint_range(0.0, 1.0) = 0.22;
// Tamaño de la celda del atlas, en pixeles.
uniform float cell_size = 64.0;
// Donde apoya el dibujo dentro de la celda (32,48 de 64 -> 0.5, 0.75).
uniform vec2 cell_pivot = vec2(0.5, 0.75);
// Proporcion del tile isometrico (64x32 -> 2.0). Hace que el agujero se vea redondo.
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
	// Donde apoya ESTE tile en el mundo. Da lo mismo para todos sus pixeles,
	// asi que el cubo se atenua entero.
	vec2 base = world_pos + (cell_pivot - cell_uv) * cell_size;

	// Solo tapan las paredes que apoyan mas abajo que el jugador.
	float in_front = step(target.y, base.y);
	vec2 d = base - target;
	d.y *= iso_ratio;
	float fade = 1.0 - smoothstep(radius, radius + softness, length(d));

	COLOR = vec4(tex.rgb, tex.a * mix(1.0, min_alpha, fade * in_front));
}
