# sdlGuiLib

**Кроссплатформенная GUI-библиотека на базе SDL3 для языка Nim**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)  
**Версия:** 0.3  
**Дата последнего обновления:** 2026-02-15  
**Автор:** [github.com/Balans097](https://github.com/Balans097)  
**Зависимости:** [libSDL.nim](https://github.com/planetis-m/nim-sdl2) (обёртка над SDL3)

## Описание

`sdlGuiLib` — это лёгкая, кроссплатформенная библиотека для создания графического пользовательского интерфейса на языке Nim с использованием **SDL3** в качестве бэкенда рендеринга.

Библиотека ориентирована на:

- простоту интеграции в существующие SDL3-приложения
- минимальные зависимости
- приемлемый внешний вид «из коробки»
- поддержку светлой и тёмной тем оформления
- полный набор часто используемых виджетов

На момент версии 0.3 библиотека **не использует** сложные layout-системы (Flexbox, Grid и т.п.), позиционирование виджетов — абсолютное.

## Основные возможности

- Светлая и тёмная темы оформления «из коробки»
- Мигающий текстовый курсор
- Поддержка UTF-8 (включая emoji в большинстве случаев)
- Поддержка выделения текста (Shift+стрелки, мышь, Ctrl+A/C/V/X)
- Модальные диалоговые окна
- Базовые события мыши и клавиатуры
- Поддержка пароля в текстовых полях
- Простая система фокуса и ховера

## Поддерживаемые виджеты

| Виджет          | Описание                              | Состояния               | Основные события               | Готовность |
|-----------------|----------------------------------------|--------------------------|----------------------------------|------------|
| `Button`        | Обычная кнопка                        | normal, hover, pressed   | `onClick`                        | ✓          |
| `TextField`     | Однострочное текстовое поле           | normal, focused          | `onChange`, `onSubmit`           | ✓          |
| `TextArea`      | Многострочное текстовое поле          | normal, focused          | `onChange`                       | ✓          |
| `CheckBox`      | Флажок (чекбокс)                      | normal, hover            | `onChange`                       | ✓          |
| `RadioButton`   | Радиокнопка (группы)                  | normal, hover            | `onChange`                       | ✓          |
| `Slider`        | Горизонтальный / вертикальный слайдер | normal, pressed          | `onChange`                       | ✓          |
| `ProgressBar`   | Индикатор прогресса                   | —                        | —                                | ✓          |
| `Label`         | Текстовая метка                       | —                        | —                                | ✓          |
| `Panel`         | Контейнер для группировки             | —                        | —                                | ✓          |
| `ListBox`       | Простой список элементов              | normal                   | `onSelect`                       | ✓          |
| `ComboBox`      | Выпадающий список                     | normal, open             | `onSelect`                       | ✓          |
| `SpinBox`       | Числовой спиннер                      | normal, focused          | `onChange`                       | ✓          |
| `TabControl`    | Вкладки                               | —                        | `onTabChange`                    | ✓          |
| `Menu`          | Контекстное / выпадающее меню         | normal, open             | `onClick` (для элемента)         | ✓          |
| `MenuBar`       | Строка меню (вверху окна)             | —                        | —                                | ✓          |
| `ToolBar`       | Панель инструментов                   | —                        | —                                | ✓          |
| `StatusBar`     | Строка состояния (внизу окна)         | —                        | —                                | ✓          |
| `Dialog`        | Модальное диалоговое окно             | —                        | `onClose`                        | ✓          |
| `ToolTip`       | Всплывающие подсказки                 | —                        | —                                | ✓          |

## Установка

```bash
# Предполагается, что у вас уже есть SDL3 и обёртка libSDL.nim

nimble install https://github.com/Balans097/sdlGuiLib
# или
git clone https://github.com/Balans097/sdlGuiLib
cd sdlGuiLib
nimble develop
```

## Быстрый старт

```nim
import sdlGuiLib
import libSDL

# Инициализация SDL
if not SDL_Init(SDL_INIT_VIDEO):
  quit "Не удалось инициализировать SDL"

# Создание окна и рендерера
let window = SDL_CreateWindow("GUI Demo", 800, 600, SDL_WINDOW_RESIZABLE)
let renderer = SDL_CreateRenderer(window, nil)

# Инициализация SDL_ttf
if not TTF_Init():
  quit "Не удалось инициализировать SDL_ttf"

# Загрузка шрифта
let font = TTF_OpenFont("font.ttf", 16)
if font.isNil:
  quit "Не удалось загрузить шрифт"

# Создание темы и менеджера GUI
let theme = createDefaultTheme(font, 16.0)
let gui = createGuiManager(renderer, theme)

# Создание виджетов
let button = createButton(theme, "btn1", "Нажми меня", 10, 10, 120, 40)
button.onClick = proc(btn: Button) =
  echo "Кнопка нажата!"
gui.addWidget(button)

let textField = createTextField(theme, "input", 10, 60, 200, 30, "", "Введите текст")
gui.addWidget(textField)

# Главный цикл
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

# Очистка
TTF_CloseFont(font)
TTF_Quit()
SDL_DestroyRenderer(renderer)
SDL_DestroyWindow(window)
SDL_Quit()
```

## Документация

Полный справочник по API доступен в файлах [API Reference](API_Reference.md) (английский) или [API Reference RU](API_Reference_RU.md) (русский).

## Примеры

Смотрите директорию `examples/` для более полных примеров, демонстрирующих различные виджеты и возможности.




