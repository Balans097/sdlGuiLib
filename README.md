# sdlGuiLib

**Cross-platform GUI library based on SDL3 for the Nim language**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)  
**Version:** 0.3  
**Last updated:** 2026-02-15  
**Author:** [github.com/Balans097](https://github.com/Balans097)  
**Dependencies:** [libSDL.nim](https://github.com/planetis-m/nim-sdl2) (SDL3 wrapper)

## Overview

`sdlGuiLib` is a lightweight, cross-platform graphical user interface library for Nim that uses **SDL3** as the rendering backend.



## How it looks on Fedora Linux
Light theme:
![How it looks on Fedora Linux](./screenshots/LightTheme.png)
Dark theme:
![How it looks on Fedora Linux](./screenshots/DarkTheme.png)


Main goals:

- Easy integration into existing SDL3 applications
- Minimal external dependencies
- Reasonable out-of-the-box appearance
- Built-in light & dark themes
- Complete set of commonly used widgets

As of version 0.3 the library uses **absolute positioning** only — there is no built-in layout system (Flexbox, Grid, anchors, etc.).

## Features

- Light and dark themes included by default
- Blinking text cursor
- UTF-8 support (including emoji in most cases)
- Text selection (Shift+arrows, mouse drag, Ctrl+A/C/V/X)
- Modal dialog windows
- Basic mouse & keyboard event handling
- Password mode for text fields
- Simple focus & hover system

## Supported Widgets

| Widget          | Description                           | States                   | Main callbacks             | Status     |
|-----------------|---------------------------------------|--------------------------|----------------------------|------------|
| `Button`        | Standard push button                  | normal, hover, pressed   | `onClick`                  | ✓          |
| `TextField`     | Single-line text input                | normal, focused          | `onChange`, `onSubmit`     | ✓          |
| `TextArea`      | Multi-line text editor                | normal, focused          | `onChange`                 | ✓          |
| `CheckBox`      | Checkbox                              | normal, hover            | `onChange`                 | ✓          |
| `RadioButton`   | Radio button (grouped)                | normal, hover            | `onChange`                 | ✓          |
| `Slider`        | Horizontal / vertical slider          | normal, pressed          | `onChange`                 | ✓          |
| `ProgressBar`   | Progress indicator                    | —                        | —                          | ✓          |
| `Label`         | Static text label                     | —                        | —                          | ✓          |
| `Panel`         | Container / grouping widget           | —                        | —                          | ✓          |
| `ListBox`       | Simple item list                      | normal                   | `onSelect`                 | ✓          |
| `ComboBox`      | Drop-down list                        | normal, open             | `onSelect`                 | ✓          |
| `SpinBox`       | Numeric spinner                       | normal, focused          | `onChange`                 | ✓          |
| `TabControl`    | Tabbed interface                      | —                        | `onTabChange`              | ✓          |
| `Menu`          | Context / dropdown menu               | normal, open             | `onClick` (per item)       | ✓          |
| `MenuBar`       | Top menu bar                          | —                        | —                          | ✓          |
| `ToolBar`       | Toolbar with buttons                  | —                        | —                          | ✓          |
| `StatusBar`     | Bottom status bar                     | —                        | —                          | ✓          |
| `Dialog`        | Modal dialog window                   | —                        | `onClose`                  | ✓          |
| `ToolTip`       | Hover tooltips                        | —                        | —                          | ✓          |

## Installation

```bash
# Assuming you already have SDL3 + libSDL.nim wrapper

nimble install https://github.com/Balans097/sdlGuiLib
# or
git clone https://github.com/Balans097/sdlGuiLib
cd sdlGuiLib
nimble develop
```

## Quick Start

```nim
import sdlGuiLib
import libSDL

# Initialize SDL
if not SDL_Init(SDL_INIT_VIDEO):
  quit "Failed to initialize SDL"

# Create window and renderer
let window = SDL_CreateWindow("GUI Demo", 800, 600, SDL_WINDOW_RESIZABLE)
let renderer = SDL_CreateRenderer(window, nil)

# Initialize SDL_ttf
if not TTF_Init():
  quit "Failed to initialize SDL_ttf"

# Load font
let font = TTF_OpenFont("font.ttf", 16)
if font.isNil:
  quit "Failed to load font"

# Create theme and GUI manager
let theme = createDefaultTheme(font, 16.0)
let gui = createGuiManager(renderer, theme)

# Create widgets
let button = createButton(theme, "btn1", "Click me", 10, 10, 120, 40)
button.onClick = proc(btn: Button) =
  echo "Button clicked!"
gui.addWidget(button)

let textField = createTextField(theme, "input", 10, 60, 200, 30, "", "Enter text")
gui.addWidget(textField)

# Main loop
var running = true
var event: SdlEvent

while running:
  while SDL_PollEvent(addr event):
    if event.type == SDL_EVENT_QUIT:
      running = false
    
    if gui.handleGuiEvent(addr event):
      continue
  
  gui.updateCursorBlink()
  
  discard SDL_SetRenderDrawColor(renderer, 50, 50, 50, 255)
  discard SDL_RenderClear(renderer)
  
  gui.renderGui()
  
  discard SDL_RenderPresent(renderer)
  SDL_Delay(16)

# Cleanup
TTF_CloseFont(font)
TTF_Quit()
SDL_DestroyRenderer(renderer)
SDL_DestroyWindow(window)
SDL_Quit()
```

## Documentation

For complete API reference, see [API Reference](docs/sdlGuiLib_API_reference_EN.md) (English) or [API Reference RU](docs/sdlGuiLib_API_reference_RU.md) (Russian).

## Examples

Check the `examples/` directory for more complete examples demonstrating various widgets and features.
