# mushin.ar en Finanpolis

Módulo de inversión con interés compuesto que se abre desde la pestaña **Invertir** de la compu. El jugador recibe tokens FNP de práctica por día, los invierte en tokens y acciones tokenizadas (Stellar, por ahora simulado) y con lo que gana compra ítems.

## Archivos

| Archivo | Qué es |
|---|---|
| `Web/mushin/` | El módulo (HTML/CSS/JS). `Web/.gdignore` evita que Godot lo importe. |
| `Scripts/core/mushin.gd` | Autoload `Mushin`: abre el módulo como iframe y emite señales. |
| `Scripts/ui/computer_ui/invertir_computer_view.gd` | Pestaña "Invertir" de la compu. |

## Probarlo (solo en la versión web)

1. *Proyecto → Exportar → Añadir → Web*. En las opciones, dejar **Thread Support desactivado** (Codeberg Pages no permite los encabezados que pide).
2. Exportar a una carpeta, por ejemplo `build/web/index.html`.
3. Copiar `Web/mushin` dentro de esa carpeta: queda `build/web/mushin/index.html`.
4. Servir `build/web` por HTTP (no funciona abriendo el archivo) o subirlo a Codeberg Pages.

En el editor, la pestaña muestra un aviso en lugar del módulo.

## Señales del autoload

```gdscript
Mushin.item_bought.connect(func(id, price): print("compró ", id))
Mushin.tokens_changed.connect(func(tokens): print(tokens))
Mushin.closed.connect(func(data): print("apagó la PC"))
Mushin.add_tokens(50, "Trabajo freelance")   # premiar al jugador
```

Si hay un `TimeManager` en la escena, cada día del juego el módulo avanza un día de inversiones.
