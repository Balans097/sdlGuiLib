# sdlGuiLib - Справочник по API

## Общая информация

**Версия:** 0.3  
**Дата:** 2026-02-14  
**Зависимости:** libSDL.nim (SDL3 wrapper)  
**Автор:** github.com/Balans097

Кроссплатформенная GUI библиотека для Nim, построенная на базе SDL3.

---

## Содержание

1. [Константы и типы](#константы-и-типы)
2. [Темы оформления](#темы-оформления)
3. [Менеджер GUI](#менеджер-gui)
4. [Базовые виджеты](#базовые-виджеты)
5. [Кнопки и элементы управления](#кнопки-и-элементы-управления)
6. [Текстовые поля](#текстовые-поля)
7. [Списки и выбор](#списки-и-выбор)
8. [Контейнеры и панели](#контейнеры-и-панели)
9. [Меню и панели инструментов](#меню-и-панели-инструментов)
10. [Диалоговые окна](#диалоговые-окна)
11. [Вспомогательные функции](#вспомогательные-функции)

---

## Константы и типы

### Клавиши (SdlKeycode)

Дополнительные константы клавиш для SDL3:

```nim
SDLK_DELETE*: SdlKeycode
SDLK_DELETE_CHAR*: SdlKeycode
SDLK_LEFT*: SdlKeycode
SDLK_RIGHT*: SdlKeycode
SDLK_UP*: SdlKeycode
SDLK_DOWN*: SdlKeycode
SDLK_HOME*: SdlKeycode
SDLK_END*: SdlKeycode
SDLK_PAGEUP*: SdlKeycode
SDLK_PAGEDOWN*: SdlKeycode
SDLK_INSERT*: SdlKeycode
SDLK_KP_ENTER*: SdlKeycode
```

### WidgetState (перечисление)

Состояния виджета:

- `wsNormal` - обычное состояние
- `wsHover` - курсор над виджетом
- `wsPressed` - виджет нажат
- `wsActive` - виджет активен
- `wsDisabled` - виджет отключён
- `wsFocused` - виджет в фокусе

### Alignment (перечисление)

Выравнивание элементов:

- `alignLeft` - выравнивание по левому краю
- `alignCenter` - выравнивание по центру
- `alignRight` - выравнивание по правому краю
- `alignTop` - выравнивание по верхнему краю
- `alignMiddle` - выравнивание по середине
- `alignBottom` - выравнивание по нижнему краю

### DialogType (перечисление)

Типы диалоговых окон:

- `dtInfo` - информационное сообщение
- `dtWarning` - предупреждение
- `dtError` - ошибка
- `dtQuestion` - вопрос

### DialogButton (перечисление)

Кнопки диалоговых окон:

- `dbOk` - кнопка "OK"
- `dbCancel` - кнопка "Отмена"
- `dbYes` - кнопка "Да"
- `dbNo` - кнопка "Нет"

---

## Темы оформления

### GuiTheme

Тема оформления GUI.

```nim
type GuiTheme* = ref object
  bgColor*: SdlColor              # цвет фона
  textColor*: SdlColor            # цвет текста
  borderColor*: SdlColor          # цвет границ
  accentColor*: SdlColor          # акцентный цвет
  hoverColor*: SdlColor           # цвет при наведении
  activeColor*: SdlColor          # цвет активного элемента
  disabledColor*: SdlColor        # цвет неактивного элемента
  font*: TTF_Font                 # основной шрифт
  fontSize*: float                # размер шрифта
  padding*: int                   # отступы
  borderWidth*: int               # толщина границ
```

### createDefaultTheme

Создать светлую тему по умолчанию.

```nim
proc createDefaultTheme*(font: TTF_Font, fontSize: float = 16.0): GuiTheme
```

**Параметры:**
- `font` - шрифт для темы
- `fontSize` - размер шрифта (по умолчанию 16.0)

**Возвращает:** новую светлую тему

**Пример:**
```nim
let theme = createDefaultTheme(myFont, 14.0)
```

### createDarkTheme

Создать тёмную тему оформления.

```nim
proc createDarkTheme*(font: TTF_Font, fontSize: float = 16.0): GuiTheme
```

**Параметры:**
- `font` - шрифт для темы
- `fontSize` - размер шрифта (по умолчанию 16.0)

**Возвращает:** новую тёмную тему

**Пример:**
```nim
let darkTheme = createDarkTheme(myFont, 16.0)
```

---

## Менеджер GUI

### GuiManager

Менеджер для управления GUI.

```nim
type GuiManager* = ref object
  renderer*: SdlRenderer
  theme*: GuiTheme
  widgets*: seq[Widget]
  focusedWidget*: Widget
  modalDialog*: Dialog
  radioGroups*: Table[string, seq[RadioButton]]
  cursorX*, cursorY*: cint
  lastBlinkTime*: uint64
  cursorVisible*: bool
  tooltipWidget*: Widget
  tooltipStartTime*: uint64
  tooltipDelay*: uint64
```

### createGuiManager

Создать менеджер GUI.

```nim
proc createGuiManager*(renderer: SdlRenderer, theme: GuiTheme): GuiManager
```

**Параметры:**
- `renderer` - SDL рендерер
- `theme` - тема оформления

**Возвращает:** новый менеджер GUI

**Пример:**
```nim
let gui = createGuiManager(renderer, theme)
```

### addWidget

Добавить виджет в менеджер.

```nim
proc addWidget*(gui: GuiManager, widget: Widget)
```

**Параметры:**
- `gui` - менеджер GUI
- `widget` - добавляемый виджет

**Пример:**
```nim
gui.addWidget(button)
```

### removeWidget

Удалить виджет из менеджера.

```nim
proc removeWidget*(gui: GuiManager, widget: Widget)
```

**Параметры:**
- `gui` - менеджер GUI
- `widget` - удаляемый виджет

### findWidgetById

Найти виджет по ID.

```nim
proc findWidgetById*(gui: GuiManager, id: string): Widget
```

**Параметры:**
- `gui` - менеджер GUI
- `id` - идентификатор виджета

**Возвращает:** виджет или nil, если не найден

### setFocus

Установить фокус на виджет.

```nim
proc setFocus*(gui: GuiManager, widget: Widget)
```

**Параметры:**
- `gui` - менеджер GUI
- `widget` - виджет для фокуса (или nil для снятия фокуса)

### updateCursorBlink

Обновить мигание курсора (вызывать в главном цикле).

```nim
proc updateCursorBlink*(gui: GuiManager)
```

**Параметры:**
- `gui` - менеджер GUI

### renderGui

Отрендерить все виджеты GUI.

```nim
proc renderGui*(gui: GuiManager)
```

**Параметры:**
- `gui` - менеджер GUI

**Пример:**
```nim
# В главном цикле
gui.renderGui()
```

### handleGuiEvent

Обработать событие для всех виджетов.

```nim
proc handleGuiEvent*(gui: GuiManager, event: ptr SdlEvent): bool
```

**Параметры:**
- `gui` - менеджер GUI
- `event` - SDL событие

**Возвращает:** true, если событие было обработано

**Пример:**
```nim
if gui.handleGuiEvent(addr event):
  continue  # Событие обработано GUI
```

---

## Базовые виджеты

### Widget (базовый класс)

Базовый класс для всех виджетов.

```nim
type Widget* = ref object of RootObj
  id*: string                    # уникальный идентификатор
  rect*: SdlRect                 # позиция и размер
  state*: WidgetState            # состояние виджета
  visible*: bool                 # видимость
  enabled*: bool                 # включён/отключён
  parent*: Widget                # родительский виджет
  children*: seq[Widget]         # дочерние виджеты
  tooltip*: string               # всплывающая подсказка
  userData*: pointer             # пользовательские данные
```

---

## Кнопки и элементы управления

### Button

Кнопка для нажатия.

```nim
type Button* = ref object of Widget
  text*: string                  # текст кнопки
  textColor*: SdlColor           # цвет текста
  bgColor*: SdlColor             # цвет фона
  hoverColor*: SdlColor          # цвет при наведении
  activeColor*: SdlColor         # цвет при нажатии
  borderColor*: SdlColor         # цвет границы
  icon*: SdlTexture              # иконка
  iconRect*: SdlRect             # позиция иконки
  onClick*: proc(btn: Button)    # обработчик нажатия
  textAlign*: Alignment          # выравнивание текста
```

### createButton

Создать кнопку.

```nim
proc createButton*(theme: GuiTheme, id: string, text: string, 
                  x, y, w, h: int): Button
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `text` - текст на кнопке
- `x, y` - координаты
- `w, h` - ширина и высота

**Возвращает:** новую кнопку

**Пример:**
```nim
let button = createButton(theme, "btnSave", "Сохранить", 10, 10, 100, 30)
button.onClick = proc(btn: Button) =
  echo "Кнопка нажата!"
gui.addWidget(button)
```

### CheckBox

Флажок (галочка) для включения/выключения.

```nim
type CheckBox* = ref object of Widget
  text*: string                     # текст рядом с флажком
  checked*: bool                    # состояние (включён/выключен)
  textColor*: SdlColor              # цвет текста
  bgColor*: SdlColor                # цвет фона
  checkColor*: SdlColor             # цвет галочки
  borderColor*: SdlColor            # цвет границы
  onChange*: proc(cb: CheckBox, checked: bool)  # обработчик изменения
```

### createCheckBox

Создать флажок.

```nim
proc createCheckBox*(theme: GuiTheme, id: string, text: string, 
                    x, y: int, checked: bool = false): CheckBox
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `text` - текст рядом с флажком
- `x, y` - координаты
- `checked` - начальное состояние

**Возвращает:** новый флажок

**Пример:**
```nim
let checkbox = createCheckBox(theme, "cbRemember", "Запомнить меня", 10, 50)
checkbox.onChange = proc(cb: CheckBox, checked: bool) =
  echo "Флажок: ", checked
gui.addWidget(checkbox)
```

### RadioButton

Радиокнопка для взаимоисключающего выбора.

```nim
type RadioButton* = ref object of Widget
  text*: string                     # текст рядом с кнопкой
  checked*: bool                    # выбрана или нет
  group*: string                    # группа радиокнопок
  textColor*: SdlColor              # цвет текста
  bgColor*: SdlColor                # цвет фона
  checkColor*: SdlColor             # цвет отметки
  borderColor*: SdlColor            # цвет границы
  onChange*: proc(rb: RadioButton, checked: bool)  # обработчик изменения
```

### createRadioButton

Создать радиокнопку.

```nim
proc createRadioButton*(theme: GuiTheme, id: string, text: string, 
                       group: string, x, y: int, 
                       checked: bool = false): RadioButton
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `text` - текст рядом с кнопкой
- `group` - имя группы (кнопки с одинаковой группой взаимоисключающие)
- `x, y` - координаты
- `checked` - начальное состояние

**Возвращает:** новую радиокнопку

**Пример:**
```nim
let rb1 = createRadioButton(theme, "rb1", "Вариант 1", "group1", 10, 80, true)
let rb2 = createRadioButton(theme, "rb2", "Вариант 2", "group1", 10, 110)
gui.registerRadioButton(rb1)
gui.registerRadioButton(rb2)
gui.addWidget(rb1)
gui.addWidget(rb2)
```

### registerRadioButton

Зарегистрировать радиокнопку в группе.

```nim
proc registerRadioButton*(gui: GuiManager, radioButton: RadioButton)
```

**Параметры:**
- `gui` - менеджер GUI
- `radioButton` - регистрируемая радиокнопка

### Slider

Ползунок для выбора значения в диапазоне.

```nim
type Slider* = ref object of Widget
  minValue*: float                # минимальное значение
  maxValue*: float                # максимальное значение
  value*: float                   # текущее значение
  step*: float                    # шаг изменения
  orientation*: Alignment         # ориентация (alignLeft=горизонт, alignTop=вертик)
  trackColor*: SdlColor           # цвет дорожки
  thumbColor*: SdlColor           # цвет ползунка
  fillColor*: SdlColor            # цвет заполнения
  thumbRect*: SdlRect             # прямоугольник ползунка
  onChange*: proc(slider: Slider, value: float)  # обработчик изменения
```

### createSlider

Создать ползунок.

```nim
proc createSlider*(theme: GuiTheme, id: string, x, y, w, h: int,
                  minValue, maxValue, value: float = 0.0,
                  orientation: Alignment = alignLeft): Slider
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `x, y` - координаты
- `w, h` - ширина и высота
- `minValue` - минимальное значение
- `maxValue` - максимальное значение
- `value` - начальное значение
- `orientation` - ориентация (alignLeft - горизонтальный, alignTop - вертикальный)

**Возвращает:** новый ползунок

**Пример:**
```nim
let slider = createSlider(theme, "volume", 10, 140, 200, 20, 0.0, 100.0, 50.0)
slider.onChange = proc(s: Slider, val: float) =
  echo "Значение: ", val
gui.addWidget(slider)
```

### ProgressBar

Индикатор прогресса.

```nim
type ProgressBar* = ref object of Widget
  minValue*: float                # минимальное значение
  maxValue*: float                # максимальное значение
  value*: float                   # текущее значение
  bgColor*: SdlColor              # цвет фона
  fillColor*: SdlColor            # цвет заполнения
  borderColor*: SdlColor          # цвет границы
  showText*: bool                 # показывать текст процентов
  textColor*: SdlColor            # цвет текста
```

### createProgressBar

Создать индикатор прогресса.

```nim
proc createProgressBar*(theme: GuiTheme, id: string, x, y, w, h: int,
                       minValue, maxValue, value: float = 0.0): ProgressBar
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `x, y` - координаты
- `w, h` - ширина и высота
- `minValue` - минимальное значение
- `maxValue` - максимальное значение
- `value` - начальное значение

**Возвращает:** новый индикатор прогресса

**Пример:**
```nim
let progress = createProgressBar(theme, "progress", 10, 170, 200, 25, 0.0, 100.0, 30.0)
progress.showText = true
gui.addWidget(progress)
```

### SpinBox

Поле для ввода числового значения с кнопками увеличения/уменьшения.

```nim
type SpinBox* = ref object of Widget
  value*: float                   # текущее значение
  minValue*: float                # минимальное значение
  maxValue*: float                # максимальное значение
  step*: float                    # шаг изменения
  decimals*: int                  # количество знаков после запятой
  textColor*: SdlColor            # цвет текста
  bgColor*: SdlColor              # цвет фона
  borderColor*: SdlColor          # цвет границы
  buttonColor*: SdlColor          # цвет кнопок
  upButtonRect*: SdlRect          # область кнопки вверх
  downButtonRect*: SdlRect        # область кнопки вниз
  onChange*: proc(spin: SpinBox, value: float)  # обработчик изменения
```

### createSpinBox

Создать числовое поле с кнопками.

```nim
proc createSpinBox*(theme: GuiTheme, id: string, x, y, w, h: int,
                   value: float = 0.0, minValue: float = 0.0, 
                   maxValue: float = 100.0, step: float = 1.0): SpinBox
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `x, y` - координаты
- `w, h` - ширина и высота
- `value` - начальное значение
- `minValue` - минимальное значение
- `maxValue` - максимальное значение
- `step` - шаг изменения

**Возвращает:** новое числовое поле

**Пример:**
```nim
let spinbox = createSpinBox(theme, "spin", 10, 200, 120, 30, 5.0, 0.0, 10.0, 0.5)
spinbox.onChange = proc(sb: SpinBox, val: float) =
  echo "Новое значение: ", val
gui.addWidget(spinbox)
```

---

## Текстовые поля

### TextField

Однострочное текстовое поле для ввода.

```nim
type TextField* = ref object of Widget
  text*: string                   # текст в поле
  placeholder*: string            # текст-заполнитель
  textColor*: SdlColor            # цвет текста
  placeholderColor*: SdlColor     # цвет заполнителя
  bgColor*: SdlColor              # цвет фона
  borderColor*: SdlColor          # цвет границы
  cursorPos*: int                 # позиция курсора
  selectionStart*: int            # начало выделения
  selectionEnd*: int              # конец выделения
  scrollOffset*: int              # смещение прокрутки
  maxLength*: int                 # максимальная длина текста
  passwordChar*: Rune             # символ для пароля
  isPassword*: bool               # режим пароля
  onChange*: proc(field: TextField, newText: string)  # обработчик изменения
  onSubmit*: proc(field: TextField, text: string)     # обработчик отправки (Enter)
```

### createTextField

Создать однострочное текстовое поле.

```nim
proc createTextField*(theme: GuiTheme, id: string, x, y, w, h: int,
                     text: string = "", placeholder: string = ""): TextField
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `x, y` - координаты
- `w, h` - ширина и высота
- `text` - начальный текст
- `placeholder` - текст-заполнитель

**Возвращает:** новое текстовое поле

**Пример:**
```nim
let textField = createTextField(theme, "name", 10, 230, 200, 30, "", "Введите имя")
textField.onChange = proc(tf: TextField, newText: string) =
  echo "Текст изменён: ", newText
textField.onSubmit = proc(tf: TextField, text: string) =
  echo "Отправлено: ", text
gui.addWidget(textField)
```

### TextArea

Многострочное текстовое поле для ввода.

```nim
type TextArea* = ref object of Widget
  lines*: seq[string]             # строки текста
  textColor*: SdlColor            # цвет текста
  bgColor*: SdlColor              # цвет фона
  borderColor*: SdlColor          # цвет границы
  selectionColor*: SdlColor       # цвет выделения
  cursorLine*: int                # строка курсора
  cursorCol*: int                 # столбец курсора
  scrollX*: int                   # горизонтальная прокрутка
  scrollY*: int                   # вертикальная прокрутка
  selectionStartLine*: int        # начало выделения (строка)
  selectionStartCol*: int         # начало выделения (столбец)
  selectionEndLine*: int          # конец выделения (строка)
  selectionEndCol*: int           # конец выделения (столбец)
  hasSelection*: bool             # есть ли выделение
  onChange*: proc(area: TextArea) # обработчик изменения
```

### createTextArea

Создать многострочное текстовое поле.

```nim
proc createTextArea*(theme: GuiTheme, id: string, x, y, w, h: int,
                    text: string = ""): TextArea
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `x, y` - координаты
- `w, h` - ширина и высота
- `text` - начальный текст (может содержать переносы строк)

**Возвращает:** новое многострочное поле

**Пример:**
```nim
let textArea = createTextArea(theme, "editor", 10, 270, 300, 150, "Строка 1\nСтрока 2")
textArea.onChange = proc(ta: TextArea) =
  echo "Текст изменён"
gui.addWidget(textArea)
```

### Label

Текстовая метка для отображения текста.

```nim
type Label* = ref object of Widget
  text*: string                   # текст метки
  textColor*: SdlColor            # цвет текста
  bgColor*: SdlColor              # цвет фона
  textAlign*: Alignment           # выравнивание текста
  wordWrap*: bool                 # перенос слов
```

### createLabel

Создать текстовую метку.

```nim
proc createLabel*(theme: GuiTheme, id: string, text: string, 
                 x, y, w, h: int): Label
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `text` - текст метки
- `x, y` - координаты
- `w, h` - ширина и высота

**Возвращает:** новую метку

**Пример:**
```nim
let label = createLabel(theme, "lblTitle", "Заголовок", 10, 430, 200, 30)
label.textAlign = alignCenter
gui.addWidget(label)
```

---

## Списки и выбор

### ListBox

Список элементов для выбора.

```nim
type ListBox* = ref object of Widget
  items*: seq[string]             # элементы списка
  selectedIndex*: int             # индекс выбранного элемента
  itemHeight*: int                # высота элемента
  scrollOffset*: int              # смещение прокрутки
  textColor*: SdlColor            # цвет текста
  selectedColor*: SdlColor        # цвет выбранного элемента
  hoverColor*: SdlColor           # цвет при наведении
  bgColor*: SdlColor              # цвет фона
  borderColor*: SdlColor          # цвет границы
  onSelect*: proc(list: ListBox, index: int)  # обработчик выбора
```

### createListBox

Создать список элементов.

```nim
proc createListBox*(theme: GuiTheme, id: string, items: seq[string],
                   x, y, w, h: int): ListBox
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `items` - список элементов
- `x, y` - координаты
- `w, h` - ширина и высота

**Возвращает:** новый список

**Пример:**
```nim
let listbox = createListBox(theme, "list", @["Элемент 1", "Элемент 2", "Элемент 3"], 
                           10, 470, 200, 120)
listbox.onSelect = proc(lb: ListBox, idx: int) =
  echo "Выбран элемент ", idx, ": ", lb.items[idx]
gui.addWidget(listbox)
```

### ComboBox

Выпадающий список (комбобокс).

```nim
type ComboBox* = ref object of Widget
  items*: seq[string]             # элементы списка
  selectedIndex*: int             # индекс выбранного элемента
  isOpen*: bool                   # список открыт/закрыт
  textColor*: SdlColor            # цвет текста
  bgColor*: SdlColor              # цвет фона
  borderColor*: SdlColor          # цвет границы
  hoverColor*: SdlColor           # цвет при наведении
  selectedColor*: SdlColor        # цвет выбранного элемента
  dropdownHeight*: int            # высота выпадающего списка
  hoveredIndex*: int              # индекс элемента под курсором
  onSelect*: proc(combo: ComboBox, index: int)  # обработчик выбора
```

### createComboBox

Создать выпадающий список.

```nim
proc createComboBox*(theme: GuiTheme, id: string, items: seq[string],
                    x, y, w, h: int, selectedIndex: int = 0): ComboBox
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `items` - список элементов
- `x, y` - координаты
- `w, h` - ширина и высота
- `selectedIndex` - индекс выбранного элемента (по умолчанию 0)

**Возвращает:** новый выпадающий список

**Пример:**
```nim
let combo = createComboBox(theme, "combo", @["Опция 1", "Опция 2", "Опция 3"], 
                          220, 10, 150, 30)
combo.onSelect = proc(cb: ComboBox, idx: int) =
  echo "Выбрана опция ", idx
gui.addWidget(combo)
```

---

## Контейнеры и панели

### Panel

Контейнер для других виджетов.

```nim
type Panel* = ref object of Widget
  bgColor*: SdlColor              # цвет фона
  borderColor*: SdlColor          # цвет границы
  scrollX*: int                   # горизонтальная прокрутка
  scrollY*: int                   # вертикальная прокрутка
  scrollable*: bool               # включить прокрутку
```

### createPanel

Создать панель-контейнер.

```nim
proc createPanel*(theme: GuiTheme, id: string, x, y, w, h: int): Panel
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `x, y` - координаты
- `w, h` - ширина и высота

**Возвращает:** новую панель

**Пример:**
```nim
let panel = createPanel(theme, "panel", 380, 10, 300, 400)
panel.bgColor = initColor(240, 240, 240, 255)
gui.addWidget(panel)

# Добавление дочернего виджета
let childButton = createButton(theme, "btnChild", "Кнопка в панели", 10, 10, 120, 30)
childButton.parent = panel
panel.children.add(childButton)
```

### TabControl

Элемент управления с вкладками.

```nim
type Tab* = object
  title*: string                  # заголовок вкладки
  content*: Widget                # содержимое вкладки

type TabControl* = ref object of Widget
  tabs*: seq[Tab]                 # вкладки
  activeTab*: int                 # индекс активной вкладки
  tabHeight*: int                 # высота заголовков вкладок
  textColor*: SdlColor            # цвет текста
  bgColor*: SdlColor              # цвет фона
  activeColor*: SdlColor          # цвет активной вкладки
  borderColor*: SdlColor          # цвет границы
  onTabChange*: proc(tc: TabControl, index: int)  # обработчик смены вкладки
```

### createTabControl

Создать элемент управления с вкладками.

```nim
proc createTabControl*(theme: GuiTheme, id: string, x, y, w, h: int): TabControl
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `x, y` - координаты
- `w, h` - ширина и высота

**Возвращает:** новый элемент управления вкладками

### createTab

Создать вкладку для TabControl.

```nim
proc createTab*(title: string, content: Widget): Tab
```

**Параметры:**
- `title` - заголовок вкладки
- `content` - содержимое вкладки (виджет)

**Возвращает:** новую вкладку

### addTab

Добавить вкладку в TabControl.

```nim
proc addTab*(tc: TabControl, tab: Tab)
```

**Параметры:**
- `tc` - элемент управления вкладками
- `tab` - добавляемая вкладка

**Пример:**
```nim
let tabs = createTabControl(theme, "tabs", 10, 600, 400, 300)

let tab1Content = createLabel(theme, "tab1lbl", "Содержимое вкладки 1", 10, 10, 380, 30)
let tab1 = createTab("Вкладка 1", tab1Content)
tabs.addTab(tab1)

let tab2Content = createButton(theme, "tab2btn", "Кнопка на вкладке 2", 10, 10, 150, 30)
let tab2 = createTab("Вкладка 2", tab2Content)
tabs.addTab(tab2)

gui.addWidget(tabs)
```

---

## Меню и панели инструментов

### MenuItem

Элемент меню.

```nim
type MenuItem* = ref object
  id*: string                     # идентификатор
  text*: string                   # текст элемента
  enabled*: bool                  # включён/отключён
  checked*: bool                  # отмечен (для checkable элементов)
  checkable*: bool                # можно ли отмечать
  isSeparator*: bool              # является ли разделителем
  icon*: SdlTexture               # иконка
  shortcut*: string               # горячая клавиша (текст)
  submenu*: seq[MenuItem]         # подменю
  onClick*: proc(item: MenuItem)  # обработчик нажатия
```

### Menu

Выпадающее меню.

```nim
type Menu* = ref object of Widget
  items*: seq[MenuItem]           # элементы меню
  isOpen*: bool                   # меню открыто/закрыто
  hoveredIndex*: int              # индекс элемента под курсором
  textColor*: SdlColor            # цвет текста
  bgColor*: SdlColor              # цвет фона
  hoverColor*: SdlColor           # цвет при наведении
  borderColor*: SdlColor          # цвет границы
  itemHeight*: int                # высота элемента
```

### createMenu

Создать выпадающее меню.

```nim
proc createMenu*(theme: GuiTheme, id: string, x, y: int): Menu
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `x, y` - координаты

**Возвращает:** новое меню

### createMenuItem

Создать элемент меню.

```nim
proc createMenuItem*(id, text: string, onClick: proc(item: MenuItem) = nil): MenuItem
```

**Параметры:**
- `id` - идентификатор элемента
- `text` - текст элемента
- `onClick` - обработчик нажатия (опционально)

**Возвращает:** новый элемент меню

### createMenuSeparator

Создать разделитель в меню.

```nim
proc createMenuSeparator*(): MenuItem
```

**Возвращает:** разделитель меню

### addMenuItem

Добавить элемент в меню.

```nim
proc addMenuItem*(menu: Menu, item: MenuItem)
```

**Параметры:**
- `menu` - меню
- `item` - добавляемый элемент

**Пример:**
```nim
let menu = createMenu(theme, "contextMenu", 100, 100)
menu.addMenuItem(createMenuItem("open", "Открыть", proc(mi: MenuItem) = echo "Открыть"))
menu.addMenuItem(createMenuItem("save", "Сохранить", proc(mi: MenuItem) = echo "Сохранить"))
menu.addMenuItem(createMenuSeparator())
menu.addMenuItem(createMenuItem("exit", "Выход", proc(mi: MenuItem) = echo "Выход"))
gui.addWidget(menu)
```

### MenuBar

Строка меню (обычно вверху окна).

```nim
type MenuBar* = ref object of Widget
  menus*: seq[tuple[title: string, menu: Menu]]  # меню и их заголовки
  openMenu*: int                  # индекс открытого меню (-1 если закрыто)
  hoveredMenu*: int               # индекс меню под курсором
  textColor*: SdlColor            # цвет текста
  bgColor*: SdlColor              # цвет фона
  hoverColor*: SdlColor           # цвет при наведении
  borderColor*: SdlColor          # цвет границы
```

### createMenuBar

Создать строку меню.

```nim
proc createMenuBar*(theme: GuiTheme, id: string, x, y, w, h: int): MenuBar
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `x, y` - координаты
- `w, h` - ширина и высота

**Возвращает:** новую строку меню

### addMenu

Добавить меню в строку меню.

```nim
proc addMenu*(menuBar: MenuBar, title: string, menu: Menu)
```

**Параметры:**
- `menuBar` - строка меню
- `title` - заголовок меню
- `menu` - добавляемое меню

**Пример:**
```nim
let menubar = createMenuBar(theme, "menubar", 0, 0, 800, 30)

# Меню "Файл"
let fileMenu = createMenu(theme, "fileMenu", 0, 30)
fileMenu.addMenuItem(createMenuItem("new", "Новый", proc(mi: MenuItem) = echo "Новый файл"))
fileMenu.addMenuItem(createMenuItem("open", "Открыть...", proc(mi: MenuItem) = echo "Открыть"))
fileMenu.addMenuItem(createMenuSeparator())
fileMenu.addMenuItem(createMenuItem("exit", "Выход", proc(mi: MenuItem) = echo "Выход"))
menubar.addMenu("Файл", fileMenu)

# Меню "Правка"
let editMenu = createMenu(theme, "editMenu", 0, 30)
editMenu.addMenuItem(createMenuItem("undo", "Отменить", proc(mi: MenuItem) = echo "Отменить"))
editMenu.addMenuItem(createMenuItem("redo", "Повторить", proc(mi: MenuItem) = echo "Повторить"))
menubar.addMenu("Правка", editMenu)

gui.addWidget(menubar)
```

### ToolBar

Панель инструментов с кнопками.

```nim
type ToolBar* = ref object of Widget
  buttons*: seq[Button]           # кнопки на панели
  bgColor*: SdlColor              # цвет фона
  borderColor*: SdlColor          # цвет границы
  buttonSpacing*: int             # расстояние между кнопками
```

### createToolBar

Создать панель инструментов.

```nim
proc createToolBar*(theme: GuiTheme, id: string, x, y, w, h: int): ToolBar
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `x, y` - координаты
- `w, h` - ширина и высота

**Возвращает:** новую панель инструментов

### addToolButton

Добавить кнопку на панель инструментов.

```nim
proc addToolButton*(toolbar: ToolBar, button: Button)
```

**Параметры:**
- `toolbar` - панель инструментов
- `button` - добавляемая кнопка

**Пример:**
```nim
let toolbar = createToolBar(theme, "toolbar", 0, 30, 800, 40)

let btnNew = createButton(theme, "toolNew", "Новый", 0, 0, 60, 30)
btnNew.onClick = proc(b: Button) = echo "Создать новый"
toolbar.addToolButton(btnNew)

let btnOpen = createButton(theme, "toolOpen", "Открыть", 0, 0, 70, 30)
btnOpen.onClick = proc(b: Button) = echo "Открыть файл"
toolbar.addToolButton(btnOpen)

gui.addWidget(toolbar)
```

### StatusBar

Строка состояния (обычно внизу окна).

```nim
type StatusBar* = ref object of Widget
  text*: string                   # текст статусной строки
  sections*: seq[string]          # секции статусной строки
  textColor*: SdlColor            # цвет текста
  bgColor*: SdlColor              # цвет фона
  borderColor*: SdlColor          # цвет границы
```

### createStatusBar

Создать строку состояния.

```nim
proc createStatusBar*(theme: GuiTheme, id: string, x, y, w, h: int): StatusBar
```

**Параметры:**
- `theme` - тема оформления
- `id` - уникальный идентификатор
- `x, y` - координаты
- `w, h` - ширина и высота

**Возвращает:** новую строку состояния

### setText (StatusBar)

Установить текст для строки состояния.

```nim
proc setText*(statusbar: StatusBar, text: string)
```

**Параметры:**
- `statusbar` - строка состояния
- `text` - устанавливаемый текст

### setSections

Установить секции для строки состояния.

```nim
proc setSections*(statusbar: StatusBar, sections: seq[string])
```

**Параметры:**
- `statusbar` - строка состояния
- `sections` - список секций

**Пример:**
```nim
let statusbar = createStatusBar(theme, "status", 0, 570, 800, 30)
statusbar.setText("Готово")
# или с секциями:
statusbar.setSections(@["Готово", "Строка: 1", "Колонка: 1"])
gui.addWidget(statusbar)
```

---

## Диалоговые окна

### Dialog

Модальное диалоговое окно.

```nim
type Dialog* = ref object of Widget
  title*: string                  # заголовок диалога
  message*: string                # текст сообщения
  dialogType*: DialogType         # тип диалога
  buttons*: seq[DialogButton]     # кнопки диалога
  titleColor*: SdlColor           # цвет заголовка
  messageColor*: SdlColor         # цвет сообщения
  bgColor*: SdlColor              # цвет фона
  borderColor*: SdlColor          # цвет границы
  iconTexture*: SdlTexture        # иконка диалога
  onClose*: proc(dlg: Dialog, result: DialogButton)  # обработчик закрытия
```

### createDialog

Создать диалоговое окно.

```nim
proc createDialog*(title, message: string, dialogType: DialogType,
                  buttons: seq[DialogButton]): Dialog
```

**Параметры:**
- `title` - заголовок диалога
- `message` - текст сообщения
- `dialogType` - тип диалога (dtInfo, dtWarning, dtError, dtQuestion)
- `buttons` - кнопки диалога (dbOk, dbCancel, dbYes, dbNo)

**Возвращает:** новый диалог

**Пример:**
```nim
let dialog = createDialog("Подтверждение", "Вы уверены?", dtQuestion, @[dbYes, dbNo])
dialog.onClose = proc(dlg: Dialog, result: DialogButton) =
  if result == dbYes:
    echo "Пользователь подтвердил"
  else:
    echo "Пользователь отменил"
gui.modalDialog = dialog
```

### Удобные функции для создания диалогов

#### showInfoDialog

Показать информационный диалог.

```nim
proc showInfoDialog*(gui: GuiManager, title, message: string, 
                    onClose: proc(dlg: Dialog, result: DialogButton) = nil)
```

**Пример:**
```nim
gui.showInfoDialog("Информация", "Операция выполнена успешно")
```

#### showWarningDialog

Показать диалог с предупреждением.

```nim
proc showWarningDialog*(gui: GuiManager, title, message: string,
                       onClose: proc(dlg: Dialog, result: DialogButton) = nil)
```

**Пример:**
```nim
gui.showWarningDialog("Предупреждение", "Это действие необратимо")
```

#### showErrorDialog

Показать диалог с ошибкой.

```nim
proc showErrorDialog*(gui: GuiManager, title, message: string,
                     onClose: proc(dlg: Dialog, result: DialogButton) = nil)
```

**Пример:**
```nim
gui.showErrorDialog("Ошибка", "Не удалось открыть файл")
```

#### showQuestionDialog

Показать диалог с вопросом (кнопки Да/Нет).

```nim
proc showQuestionDialog*(gui: GuiManager, title, message: string,
                        onClose: proc(dlg: Dialog, result: DialogButton))
```

**Пример:**
```nim
gui.showQuestionDialog("Вопрос", "Сохранить изменения?", 
  proc(dlg: Dialog, result: DialogButton) =
    if result == dbYes:
      echo "Сохраняем"
)
```

#### showConfirmDialog

Показать диалог подтверждения (кнопки OK/Отмена).

```nim
proc showConfirmDialog*(gui: GuiManager, title, message: string,
                       onClose: proc(dlg: Dialog, result: DialogButton))
```

**Пример:**
```nim
gui.showConfirmDialog("Подтверждение", "Удалить файл?", 
  proc(dlg: Dialog, result: DialogButton) =
    if result == dbOk:
      echo "Удаляем файл"
)
```

---

## Вспомогательные функции

### ToolTip

Всплывающая подсказка.

```nim
type ToolTip* = object
  text*: string                   # текст подсказки
  x*, y*: int                     # позиция
  visible*: bool                  # видимость
```

### updateTooltip

Обновить состояние всплывающей подсказки.

```nim
proc updateTooltip*(gui: GuiManager)
```

**Параметры:**
- `gui` - менеджер GUI

**Примечание:** Вызывается автоматически в `renderGui`

### checkTooltipHover

Проверить наведение для всплывающей подсказки.

```nim
proc checkTooltipHover*(gui: GuiManager, widget: Widget, mx, my: int)
```

**Параметры:**
- `gui` - менеджер GUI
- `widget` - виджет для проверки
- `mx, my` - координаты курсора мыши

### Вспомогательные функции создания цветов и прямоугольников

#### initColor

Создать цвет SDL.

```nim
proc initColor*(r, g, b, a: uint8): SdlColor
```

**Параметры:**
- `r, g, b` - красный, зелёный, синий компоненты (0-255)
- `a` - прозрачность (0-255)

**Возвращает:** цвет SDL

**Пример:**
```nim
let red = initColor(255, 0, 0, 255)
let semiTransparentBlue = initColor(0, 0, 255, 128)
```

#### initRect

Создать прямоугольник SDL (целочисленный).

```nim
proc initRect*(x, y, w, h: int): SdlRect
```

**Параметры:**
- `x, y` - координаты
- `w, h` - ширина и высота

**Возвращает:** прямоугольник SDL

**Пример:**
```nim
let rect = initRect(10, 20, 100, 50)
```

#### initFRect

Создать прямоугольник SDL с плавающей точкой.

```nim
proc initFRect*(x, y, w, h: float): SdlFRect
```

**Параметры:**
- `x, y` - координаты
- `w, h` - ширина и высота

**Возвращает:** прямоугольник SDL с плавающей точкой

**Пример:**
```nim
let frect = initFRect(10.5, 20.5, 100.5, 50.5)
```

---

## Полный пример использования

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

let checkbox = createCheckBox(theme, "cb1", "Включить опцию", 10, 100)
gui.addWidget(checkbox)

# Главный цикл
var running = true
var event: SdlEvent

while running:
  while SDL_PollEvent(addr event):
    if event.type == SDL_EVENT_QUIT:
      running = false
    
    # Обработка событий GUI
    if gui.handleGuiEvent(addr event):
      continue  # Событие обработано GUI
  
  # Обновление и рендеринг
  gui.updateCursorBlink()
  
  discard SDL_SetRenderDrawColor(renderer, 50, 50, 50, 255)
  discard SDL_RenderClear(renderer)
  
  gui.renderGui()
  
  discard SDL_RenderPresent(renderer)
  SDL_Delay(16)  # ~60 FPS

# Очистка
TTF_CloseFont(font)
TTF_Quit()
SDL_DestroyRenderer(renderer)
SDL_DestroyWindow(window)
SDL_Quit()
```

---

## Примечания

### Обработка событий

Порядок обработки событий важен:

1. Модальные диалоги обрабатываются в первую очередь
2. Открытые MenuBar, ComboBox и Menu обрабатываются приоритетно
3. Остальные виджеты обрабатываются в обратном порядке добавления

### Фокус ввода

Фокус ввода автоматически управляется для текстовых полей. Используйте `gui.setFocus(widget)` для установки фокуса программно.

### Родительские и дочерние виджеты

Дочерние виджеты автоматически рендерятся вместе с родительскими. При добавлении дочернего виджета:

```nim
childWidget.parent = parentWidget
parentWidget.children.add(childWidget)
```

### Производительность

- Виджеты с `visible = false` не рендерятся и не обрабатывают события
- Виджеты с `enabled = false` рендерятся, но не обрабатывают события
- Используйте `Panel` с `scrollable = true` для больших списков дочерних виджетов

---

## Лицензия

См. исходный файл библиотеки для информации о лицензии.
