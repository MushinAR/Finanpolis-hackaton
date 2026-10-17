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

1. *Proyecto → Exportar → Añadir → Web*. En las opciones, dejar **Thread Support desactivado**, así no hacen falta encabezados especiales en el servidor.
2. Exportar a una carpeta, por ejemplo `build/web/index.html`.
3. Copiar `Web/mushin` dentro de esa carpeta: queda `build/web/mushin/index.html`.
4. Servir esa carpeta por HTTP: `Web/demo.ps1 -Root build/web`, o subirla a GitHub Pages / itch.io.

## Señales del autoload

```gdscript
Mushin.item_bought.connect(func(id, price): print("compró ", id))
Mushin.tokens_changed.connect(func(tokens): print(tokens))
Mushin.closed.connect(func(data): print("apagó la PC"))
Mushin.add_tokens(50, "Trabajo freelance")   # premiar al jugador
```

Si hay un `TimeManager` en la escena, cada día del juego el módulo avanza un día de inversiones.
