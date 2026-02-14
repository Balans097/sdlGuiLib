# sdlGuiLib - Кроссплатформенная GUI библиотека для Nim

Полнофункциональная библиотека для создания графических интерфейсов на основе SDL3.

## Возможности

### Виджеты

- ✅ **Button** - Кнопки с поддержкой иконок, разных стилей и выравнивания текста
- ✅ **TextField** - Однострочные текстовые поля с поддержкой placeholder, пароли, ограничение длины
- ✅ **TextArea** - Многострочные текстовые поля (базовая структура)
- ✅ **CheckBox** - Флажки с текстовыми метками
- ✅ **RadioButton** - Радиокнопки с группировкой
- ✅ **Slider** - Ползунки (горизонтальные и вертикальные)
- ✅ **ProgressBar** - Индикаторы прогресса с текстом процентов
- ✅ **Label** - Текстовые метки с выравниванием
- ✅ **Panel** - Контейнеры для группировки виджетов
- ✅ **ListBox** - Списки с прокруткой и выбором элементов
- ✅ **Dialog** - Модальные диалоговые окна (Info, Warning, Error, Question)
- 🔧 **ComboBox** - Выпадающие списки (структура определена)
- 🔧 **SpinBox** - Числовые поля со стрелками (структура определена)
- 🔧 **TabControl** - Вкладки (структура определена)
- 🔧 **Menu** - Меню (структура определена)
- 🔧 **ToolBar** - Панель инструментов (структура определена)

### Система тем

- Светлая тема по умолчанию
- Тёмная тема
- Легко настраиваемые цвета и стили

### Обработка событий

- Полная поддержка мыши (клики, наведение, перетаскивание)
- Поддержка клавиатуры (фокус, текстовый ввод, горячие клавиши)
- Система фокуса виджетов
- Модальные диалоги

## Установка

1. Убедитесь, что у вас установлены:
   - SDL3
   - SDL3_ttf
   - Nim компилятор

2. Скопируйте файлы в ваш проект:
   - `libSDL.nim` - обёртка SDL3
   - `sdlGuiLib.nim` - GUI библиотека

## Быстрый старт

```nim
import libSDL
import sdlGuiLib

# Инициализация SDL и TTF
discard SDL_Init(SDL_INIT_VIDEO)
discard TTF_Init()

# Создание окна и рендерера
let window = SDL_CreateWindow("My App", 800, 600, 0)
let renderer = SDL_CreateRenderer(window, nil)
let font = TTF_OpenFont("font.ttf", 14.0)

# Создание GUI менеджера
var gui = createGuiManager(renderer, font)

# Создание кнопки
let btn = createButton("btn1", 20, 20, 150, 40, "Нажми меня!")
btn.onClick = proc(b: Button) =
  echo "Кнопка нажата!"
gui.addWidget(btn)

# Главный цикл
var running = true
var event: SdlEvent

while running:
  while SDL_PollEvent(addr event) == SDL_TRUE:
    if event.type == SDL_EVENT_QUIT:
      running = false
    discard gui.handleGuiEvent(addr event)
  
  discard SDL_RenderClear(renderer)
  gui.renderGui()
  discard SDL_RenderPresent(renderer)

# Очистка
SDL_Quit()
```

## Примеры использования

### Кнопка

```nim
let button = createButton("myBtn", x, y, width, height, "Текст")
button.onClick = proc(btn: Button) =
  echo "Клик!"
button.textAlign = alignCenter  # или alignLeft, alignRight
button.bgColor = initColor(0, 120, 215)
button.textColor = initColor(255, 255, 255)
gui.addWidget(button)
```

### Текстовое поле

```nim
let field = createTextField("myField", x, y, width, height, "Placeholder...")
field.onChange = proc(f: TextField, newText: string) =
  echo "Новый текст: ", newText
field.onSubmit = proc(f: TextField, text: string) =
  echo "Отправлено: ", text
field.maxLength = 50  # Ограничение длины

# Поле для пароля
field.isPassword = true
field.passwordChar = "*".runeAt(0)

gui.addWidget(field)
```

### Чекбокс

```nim
let checkbox = createCheckBox("myCheck", x, y, "Включить опцию", false)
checkbox.onChange = proc(cb: CheckBox, checked: bool) =
  echo "Состояние: ", checked
gui.addWidget(checkbox)
```

### Радиокнопки

```nim
let radio1 = createRadioButton("r1", x, y, "Опция 1", "group1")
let radio2 = createRadioButton("r2", x, y+30, "Опция 2", "group1")
let radio3 = createRadioButton("r3", x, y+60, "Опция 3", "group1")

radio1.checked = true  # По умолчанию выбрана
radio1.onChange = proc(rb: RadioButton, checked: bool) =
  if checked: echo "Выбрана опция 1"

# Обязательно зарегистрировать в группе
gui.registerRadioButton(radio1)
gui.registerRadioButton(radio2)
gui.registerRadioButton(radio3)

gui.addWidget(radio1)
gui.addWidget(radio2)
gui.addWidget(radio3)
```

### Слайдер

```nim
# Горизонтальный слайдер
let slider = createSlider("mySlider", x, y, width, height, 
                         minValue=0.0, maxValue=100.0, 
                         orientation=alignLeft)
slider.value = 50.0
slider.step = 1.0  # Шаг изменения
slider.onChange = proc(s: Slider, value: float) =
  echo "Значение: ", value

# Вертикальный слайдер
let vSlider = createSlider("vSlider", x, y, width, height, 
                          0.0, 100.0, alignTop)

gui.addWidget(slider)
gui.addWidget(vSlider)
```

### Прогресс-бар

```nim
let progress = createProgressBar("myProgress", x, y, width, height, 0.0, 100.0)
progress.value = 75.0
progress.showText = true  # Показывать проценты
progress.fillColor = initColor(6, 176, 37)  # Зелёный
gui.addWidget(progress)

# Обновление значения
progress.value = 90.0
```

### Список

```nim
let list = createListBox("myList", x, y, width, height)
list.items = @["Элемент 1", "Элемент 2", "Элемент 3", "Элемент 4"]
list.itemHeight = 24
list.onSelect = proc(l: ListBox, index: int) =
  echo "Выбран: ", l.items[index]
gui.addWidget(list)
```

### Диалоговые окна

```nim
# Информационный диалог
gui.showInfoDialog("Заголовок", "Сообщение")

# Диалог с предупреждением
gui.showWarningDialog("Внимание!", "Это важно")

# Диалог с ошибкой
gui.showErrorDialog("Ошибка", "Что-то пошло не так")

# Диалог с вопросом
gui.showQuestionDialog("Вопрос", "Продолжить?") do (dlg: Dialog, result: DialogButton):
  if result == dbYes:
    echo "Пользователь согласился"
  else:
    echo "Пользователь отказался"

# Диалог подтверждения
gui.showConfirmDialog("Подтверждение", "Сохранить изменения?") do (dlg: Dialog, result: DialogButton):
  if result == dbOk:
    # Сохранить
    echo "Сохранено"
  else:
    # Отменить
    echo "Отменено"
```

### Метки

```nim
let label = createLabel("myLabel", x, y, width, height, "Текст метки")
label.textAlign = alignCenter  # или alignLeft, alignRight
label.textColor = initColor(0, 0, 0)
label.bgColor = initColor(240, 240, 240, 0)  # Прозрачный фон
gui.addWidget(label)
```

### Панель

```nim
let panel = createPanel("myPanel", x, y, width, height)
panel.bgColor = initColor(250, 250, 250)
panel.borderColor = initColor(180, 180, 180)
gui.addWidget(panel)

# Можно добавлять виджеты на панель (через parent)
# Но в текущей версии они обрабатываются независимо
```

## Темы оформления

```nim
# Создание светлой темы (по умолчанию)
gui.theme = createDefaultTheme(font)

# Создание тёмной темы
gui.theme = createDarkTheme(font)

# Кастомная тема
var customTheme = createDefaultTheme(font)
customTheme.bgColor = initColor(30, 30, 30)
customTheme.textColor = initColor(220, 220, 220)
customTheme.accentColor = initColor(255, 100, 0)
gui.theme = customTheme
```

## Система событий

```nim
# В главном цикле
while SDL_PollEvent(addr event) == SDL_TRUE:
  # Сначала обработка системных событий
  if event.type == SDL_EVENT_QUIT:
    running = false
  
  # Затем передача в GUI
  # Возвращает true если событие обработано
  if gui.handleGuiEvent(addr event):
    continue  # Событие обработано, не обрабатывать дальше
  
  # Ваша дополнительная обработка событий
```

## Работа с фокусом

```nim
# Установить фокус на виджет
gui.setFocus(textField)

# Получить виджет в фокусе
if gui.focusedWidget != nil:
  echo "Фокус на: ", gui.focusedWidget.id

# Снять фокус
gui.setFocus(nil)
```

## Поиск виджетов

```nim
# Найти виджет по ID
let widget = gui.findWidgetById("myButton")
if widget != nil:
  # Приведение к конкретному типу
  if widget of Button:
    let btn = Button(widget)
    btn.text = "Новый текст"
```

## Управление видимостью и активностью

```nim
# Показать/скрыть виджет
widget.visible = false

# Включить/отключить виджет
widget.enabled = false

# Состояние виджета
widget.state = wsDisabled  # или wsNormal, wsHover, wsPressed, wsActive, wsFocused
```

## Цвета

```nim
# Создание цвета RGB
let red = initColor(255, 0, 0)

# Создание цвета RGBA (с прозрачностью)
let semiTransparent = initColor(0, 0, 0, 128)

# Предопределённые цвета из темы
let accentColor = gui.theme.accentColor
let bgColor = gui.theme.bgColor
```

## Прямоугольники

```nim
# Создание прямоугольника
let rect = initRect(x, y, width, height)

# Float прямоугольник
let frect = initFRect(x.float, y.float, width.float, height.float)

# Проверка попадания точки
if pointInRect(mouseX, mouseY, widget.rect):
  echo "Курсор над виджетом"
```

## Рендеринг текста

```nim
# Прямой рендеринг текста
let textRect = renderText(gui.renderer, gui.theme.font, 
                         "Мой текст", x, y, textColor)

# Получение размера текста
let (width, height) = getTextSize(gui.theme.font, "Мой текст")
```

## Полный пример приложения

См. файл `gui_demo.nim` для полного рабочего примера со всеми виджетами.

## Требования

- Nim 2.0+
- SDL3
- SDL3_ttf
- TrueType шрифт (.ttf файл)

## Компиляция

```bash
nim c -r gui_demo.nim
```

Для релизной сборки:
```bash
nim c -d:release --opt:speed gui_demo.nim
```

## Архитектура

### Иерархия виджетов

```
Widget (базовый класс)
├── Button
├── TextField
├── TextArea
├── CheckBox
├── RadioButton
├── Slider
├── ProgressBar
├── Label
├── Panel
├── ListBox
├── ComboBox
├── SpinBox
├── Dialog
├── TabControl
├── Menu
└── ToolBar
```

### GuiManager

Центральный менеджер для управления всеми виджетами:
- Хранение списка виджетов
- Управление темой
- Обработка событий
- Управление фокусом
- Рендеринг всех виджетов

### Система событий

События обрабатываются в порядке "сверху вниз" (последние добавленные виджеты обрабатываются первыми). Когда виджет обрабатывает событие, оно не передаётся дальше.

## Планы развития

- [ ] Поддержка иконок в кнопках
- [ ] Реализация ComboBox
- [ ] Реализация SpinBox
- [ ] Реализация TabControl
- [ ] Реализация Menu и MenuItem
- [ ] Реализация ToolBar
- [ ] Drag & Drop
- [ ] Resize виджетов
- [ ] Layout менеджеры (Grid, Flow, etc.)
- [ ] Анимации
- [ ] Tooltips (структура есть, нужна реализация)
- [ ] Контекстные меню
- [ ] Улучшенная поддержка клавиатуры
- [ ] Поддержка тач-интерфейсов

## Лицензия

Свободное использование. Библиотека создана для демонстрации возможностей SDL3 в Nim.

## Автор

Разработано на основе libSDL.nim обёртки SDL3.

## Поддержка

Для вопросов и предложений создавайте issues в репозитории проекта.
