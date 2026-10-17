# mushin.ar en Finanpolis

Módulo de inversión con interés compuesto que se abre desde la pestaña **Invertir** de la compu. El jugador recibe tokens FNP de práctica por día, los invierte en tokens y acciones tokenizadas (Stellar, por ahora simulado) y con lo que gana compra ítems.

## Archivos

| Archivo | Qué es |
|---|---|
| `Web/mushin/` | El módulo (HTML/CSS/JS). `Web/.gdignore` evita que Godot lo importe. |
| `Scripts/core/mushin.gd` | Autoload `Mushin`: abre el módulo como iframe y emite señales. |
| `Scripts/ui/computer_ui/invertir_computer_view.gd` | Pestaña "Invertir" de la compu. |

## Demo en la PC (editor de Godot)

1. Correr `Web/demo.ps1` (clic derecho → *Ejecutar con PowerShell*) y dejar la ventana abierta.
2. Abrir el proyecto en Godot y darle play (F5).
3. Usar la compu y tocar la pestaña **Invertir**: mushin.ar se abre en el navegador.

En escritorio el módulo funciona solo: no le avisa al juego de compras ni de tokens.

## Versión web (módulo dentro del juego)

El preset "Web" ya está en `export_presets.cfg`, con Thread Support desactivado para que funcione en GitHub Pages sin encabezados especiales. Hacen falta las plantillas de exportación 4.7.2.

1. Exportar y copiar mushin.ar en un paso:
   `powershell -ExecutionPolicy Bypass -File Web/build_web.ps1 -Godot "C:\ruta\Godot_v4.7.2-stable_win64.exe"`
2. Probar: `Web/demo.ps1 -Root build/web` y abrir `http://localhost:8080/`.
3. Publicar: subir el contenido de `build/web` a la rama `gh-pages` (GitHub Pages).

En la versión web, el calendario de mushin.ar lo avanza el `TimeManager` del juego.

## Señales del autoload

```gdscript
Mushin.item_bought.connect(func(id, price): print("compró ", id))
Mushin.tokens_changed.connect(func(tokens): print(tokens))
Mushin.closed.connect(func(data): print("apagó la PC"))
Mushin.add_tokens(50, "Trabajo freelance")   # premiar al jugador
```

Si hay un `TimeManager` en la escena, cada día del juego el módulo avanza un día de inversiones.
