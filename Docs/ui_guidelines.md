# Guía de UI (resumen de trabajo)

El documento que manda es `Docs/Finanpolis_UI_Guidelines.pdf`, de diseño. Este archivo es el
resumen para el que programa: qué dice la norma y dónde está aplicada en el proyecto.
**Toda interfaz nueva del juego sale de acá.**

## Paleta semántica

Ningún color se escribe suelto en una escena: todos viven en `Scripts/ui/palette.gd`.
Ninguno se usa fuera de su categoría; el rojo nunca es decorativo ni indica selección.

| Token | Hex | Para qué |
|---|---|---|
| Verde-Estabilidad | `#4CAF6D` | Estabilidad, dinero positivo, crecimiento |
| Azul-Info | `#3B82C4` | Banco, calma, información y selección |
| Amarillo-Aviso | `#E8B84B` | Oportunidad, aviso, energía |
| Rojo-Riesgo | `#D9534F` | Deuda, riesgo, urgencia (peligro real) |
| Gris-Neutro | `#8A8A8A` | Cansancio, rutina, crisis no urgente |
| Naranja-Hogar | `#E58A4E` | Hogar, calidez, vida cotidiana |
| Texto-Oscuro | `#1E1E1E` | Texto principal |
| Fondo-Calido | `#F7F5F2` | Fondo del HUD y de los paneles |

## Tipografía

Poppins es la única fuente de la interfaz. Está puesta como fuente por defecto del proyecto
(`project.godot`, `gui/theme/custom_font`), así nada se cuela con otra.

| Token | Peso | Tamaño | Uso |
|---|---|---|---|
| Titulo-Evento | SemiBold 600 | 24 px | Título de evento o decisión |
| Texto-Opcion | Medium 500 | 16 px | Texto de botón |
| Numero-Stat | Bold 700 | 20 px (24 el dinero) | Números de dinero y stats |
| Label-Stat | Regular 400 | 12 px | Etiquetas y fecha |

## HUD superior

Una sola franja anclada al borde de arriba, de ancho completo (`Scenes/ui/hud.tscn`), con
fondo `#F7F5F2` sólido y una única línea abajo de 1 px `#8A8A8A` al 40 %. Tres grupos sobre
la misma línea base, separados por divisorias finas: **dinero**, **bienestar**, **tiempo y fecha**.

- **Bienestar** (`Scenes/ui/stat_bar.tscn`): ícono + barra, nunca el número. La barra lleva
  contenedor con borde, relleno sólido de 12 px de alto y esquinas tipo cápsula.
  El color sale del nivel y se actualiza con cada cambio: arriba de 60 % verde, entre 30 y 60
  amarillo, abajo de 30 rojo. El **estrés va al revés** (poco estrés = verde), por su marca
  `inverted` en `Data/stats/estres.tres`.
- **Dinero** (`Scenes/ui/money_display.tscn`): contenedor propio destacado, fondo sutil
  Verde-Estabilidad, ícono en círculo relleno y número a 24 px. Nunca se agrupa igual que el
  bienestar: es la variable central y se lee con más peso.
- **Tiempo** (`Scenes/ui/time_controls.tscn`): x1 / x2 / x4 / x8, los cuatro pegados en un
  solo grupo. **No hay pausa.** El juego puede forzar x1 ante un evento importante con
  `force_speed()`, y el selector lo muestra aunque el jugador no lo haya tocado.

## Botón seleccionable

Mismo componente para el selector de velocidad y para las opciones de decisión.

- Normal: fondo `#F7F5F2`, borde 1 px `#8A8A8A`, texto `#1E1E1E`.
- Elegido: fondo `#3B82C4`, sin borde, texto blanco.
- Nunca rojo para indicar selección. Ninguna opción de decisión lleva marca de "correcta"
  o "incorrecta": el juego no dice cuál elegir.

## Qué va en el HUD y qué no

| Siempre visible | Bajo demanda (nunca en el HUD) |
|---|---|
| Dinero, energía, felicidad, salud, estrés, velocidad del tiempo, semana / mes / año / edad | Banco, inversiones, deudas detalladas, patrimonio, calendario completo |

## Tono visual

Cálido, no corporativo, no oscuro. Íconos con contorno marcado y algo de volumen, no flat-UI
de app fintech. Bordes redondeados suaves, sin gradientes ni sombras duras. El gris y lo
oscuro quedan reservados para comunicar crisis.
