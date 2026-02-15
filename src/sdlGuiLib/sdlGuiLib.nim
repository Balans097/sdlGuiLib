################################################################
##                    sdlGuiLib
##        КРОССПЛАТФОРМЕННАЯ GUI БИБЛИОТЕКА НА SDL3
##              SDL3 GUI Library for Nim
## 
## Версия:   0.3
## Дата:     2026-02-14
## Зависит:  libSDL.nim (SDL3 wrapper)
## Автор:	 github.com/Balans097
################################################################



import libSDL
import tables, strutils, unicode, math




# =============================================================================
# Дополнительные константы клавиш для SDL3
# =============================================================================

# В SDL3 клавиши создаются из scancode с использованием маски
const
  SDLK_DELETE* = SdlKeycode(SDL_SCANCODE_DELETE.uint32 or SDLK_SCANCODE_MASK)
  SDLK_DELETE_CHAR* = SdlKeycode(127)  # ASCII DEL - реальный код Delete в SDL3
  SDLK_LEFT* = SdlKeycode(SDL_SCANCODE_LEFT.uint32 or SDLK_SCANCODE_MASK)
  SDLK_RIGHT* = SdlKeycode(SDL_SCANCODE_RIGHT.uint32 or SDLK_SCANCODE_MASK)
  SDLK_UP* = SdlKeycode(SDL_SCANCODE_UP.uint32 or SDLK_SCANCODE_MASK)
  SDLK_DOWN* = SdlKeycode(SDL_SCANCODE_DOWN.uint32 or SDLK_SCANCODE_MASK)
  SDLK_HOME* = SdlKeycode(SDL_SCANCODE_HOME.uint32 or SDLK_SCANCODE_MASK)
  SDLK_END* = SdlKeycode(SDL_SCANCODE_END.uint32 or SDLK_SCANCODE_MASK)
  SDLK_PAGEUP* = SdlKeycode(SDL_SCANCODE_PAGEUP.uint32 or SDLK_SCANCODE_MASK)
  SDLK_PAGEDOWN* = SdlKeycode(SDL_SCANCODE_PAGEDOWN.uint32 or SDLK_SCANCODE_MASK)
  SDLK_INSERT* = SdlKeycode(SDL_SCANCODE_INSERT.uint32 or SDLK_SCANCODE_MASK)
  SDLK_KP_ENTER* = SdlKeycode(SDL_SCANCODE_KP_ENTER.uint32 or SDLK_SCANCODE_MASK)

# Оператор сравнения для SdlKeycode (т.к. это distinct type)
proc `==`*(a, b: SdlKeycode): bool {.borrow.}


# =============================================================================
# Типы и константы
# =============================================================================

type
  # Базовые типы
  GuiTheme* = ref object
    ## Тема оформления GUI
    bgColor*: SdlColor              # цвет ФОНА
    textColor*: SdlColor            # цвет ТЕКСТА
    borderColor*: SdlColor          # цвет ГРАНИЦ
    accentColor*: SdlColor          # акцентный цвет
    hoverColor*: SdlColor           # цвет при наведении
    activeColor*: SdlColor          # цвет активного элемента
    disabledColor*: SdlColor        # цвет неактивного элемента
    font*: TTF_Font                 # основной шрифт
    fontSize*: float                # РАЗМЕР шрифта
    padding*: int                   # отступы
    borderWidth*: int               # ТОЛЩИНА границ

  WidgetState* = enum
    ## Состояние виджета
    wsNormal      # обычное состояние
    wsHover       # КУРСОР над виджетом
    wsPressed     # виджет НАЖАТ
    wsActive      # виджет АКТИВЕН
    wsDisabled    # виджет ОТКЛЮЧЁН
    wsFocused     # виджет В ФОКУСЕ

  Alignment* = enum
    ## Выравнивание
    alignLeft
    alignCenter
    alignRight
    alignTop
    alignMiddle
    alignBottom

  # Базовый виджет
  Widget* = ref object of RootObj
    ## Базовый класс для всех виджетов
    id*: string
    rect*: SdlRect
    state*: WidgetState
    visible*: bool
    enabled*: bool
    parent*: Widget
    children*: seq[Widget]
    tooltip*: string
    userData*: pointer

  # Кнопка
  Button* = ref object of Widget
    ## Кнопка
    text*: string
    textColor*: SdlColor
    bgColor*: SdlColor
    hoverColor*: SdlColor
    activeColor*: SdlColor
    borderColor*: SdlColor
    icon*: SdlTexture
    iconRect*: SdlRect
    onClick*: proc(btn: Button)
    textAlign*: Alignment

  # Текстовое поле
  TextField* = ref object of Widget
    ## Однострочное текстовое поле
    text*: string
    placeholder*: string
    textColor*: SdlColor
    placeholderColor*: SdlColor
    bgColor*: SdlColor
    borderColor*: SdlColor
    cursorPos*: int
    selectionStart*: int
    selectionEnd*: int
    scrollOffset*: int
    maxLength*: int
    passwordChar*: Rune
    isPassword*: bool
    onChange*: proc(field: TextField, newText: string)
    onSubmit*: proc(field: TextField, text: string)

  # Многострочное текстовое поле
  TextArea* = ref object of Widget
    ## Многострочное текстовое поле
    lines*: seq[string]
    textColor*: SdlColor
    bgColor*: SdlColor
    borderColor*: SdlColor
    selectionColor*: SdlColor  # Цвет выделения
    cursorLine*: int
    cursorCol*: int
    scrollX*: int
    scrollY*: int
    # Выделение текста
    selectionStartLine*: int
    selectionStartCol*: int
    selectionEndLine*: int
    selectionEndCol*: int
    hasSelection*: bool
    onChange*: proc(area: TextArea)

  # Чекбокс
  CheckBox* = ref object of Widget
    ## Флажок (галочка)
    text*: string
    checked*: bool
    textColor*: SdlColor
    bgColor*: SdlColor
    checkColor*: SdlColor
    borderColor*: SdlColor
    onChange*: proc(cb: CheckBox, checked: bool)

  # Радиокнопка
  RadioButton* = ref object of Widget
    ## Радиокнопка (взаимоисключающий выбор)
    text*: string
    checked*: bool
    group*: string
    textColor*: SdlColor
    bgColor*: SdlColor
    checkColor*: SdlColor
    borderColor*: SdlColor
    onChange*: proc(rb: RadioButton, checked: bool)

  # Слайдер
  Slider* = ref object of Widget
    ## Ползунок для выбора значения
    minValue*: float
    maxValue*: float
    value*: float
    step*: float
    orientation*: Alignment  # alignLeft = horizontal, alignTop = vertical
    trackColor*: SdlColor
    thumbColor*: SdlColor
    fillColor*: SdlColor
    thumbRect*: SdlRect
    onChange*: proc(slider: Slider, value: float)

  # Прогресс-бар
  ProgressBar* = ref object of Widget
    ## Индикатор прогресса
    minValue*: float
    maxValue*: float
    value*: float
    bgColor*: SdlColor
    fillColor*: SdlColor
    borderColor*: SdlColor
    showText*: bool
    textColor*: SdlColor

  # Метка
  Label* = ref object of Widget
    ## Текстовая метка
    text*: string
    textColor*: SdlColor
    bgColor*: SdlColor
    textAlign*: Alignment
    wordWrap*: bool

  # Панель
  Panel* = ref object of Widget
    ## Контейнер для других виджетов
    bgColor*: SdlColor
    borderColor*: SdlColor
    scrollX*: int
    scrollY*: int
    scrollable*: bool

  # Список
  ListBox* = ref object of Widget
    ## Список элементов
    items*: seq[string]
    selectedIndex*: int
    itemHeight*: int
    scrollOffset*: int
    textColor*: SdlColor
    selectedColor*: SdlColor
    hoverColor*: SdlColor
    bgColor*: SdlColor
    borderColor*: SdlColor
    onSelect*: proc(list: ListBox, index: int)

  # Выпадающий список
  ComboBox* = ref object of Widget
    ## Выпадающий список
    items*: seq[string]
    selectedIndex*: int
    isOpen*: bool
    textColor*: SdlColor
    bgColor*: SdlColor
    borderColor*: SdlColor
    hoverColor*: SdlColor
    selectedColor*: SdlColor
    dropdownHeight*: int
    hoveredIndex*: int
    onSelect*: proc(combo: ComboBox, index: int)

  # Спиннер (числовое поле со стрелками)
  SpinBox* = ref object of Widget
    ## Числовое поле со стрелками
    value*: float
    minValue*: float
    maxValue*: float
    step*: float
    decimals*: int
    textColor*: SdlColor
    bgColor*: SdlColor
    borderColor*: SdlColor
    buttonColor*: SdlColor
    upPressed*: bool
    downPressed*: bool
    onChange*: proc(spin: SpinBox, value: float)

  # Диалоговое окно
  DialogType* = enum
    dtInfo      # Информационное
    dtWarning   # Предупреждение
    dtError     # Ошибка
    dtQuestion  # Вопрос
    dtCustom    # Пользовательское

  DialogButton* = enum
    dbOk
    dbCancel
    dbYes
    dbNo
    dbRetry
    dbAbort
    dbIgnore

  Dialog* = ref object of Widget
    ## Модальное диалоговое окно
    title*: string
    message*: string
    dialogType*: DialogType
    buttons*: seq[DialogButton]
    result*: DialogButton
    isModal*: bool
    onClose*: proc(dlg: Dialog, result: DialogButton)

  # Вкладки
  Tab* = ref object
    title*: string
    content*: seq[Widget]
    enabled*: bool

  TabControl* = ref object of Widget
    ## Элемент управления вкладками
    tabs*: seq[Tab]
    activeTab*: int
    tabHeight*: int
    tabColor*: SdlColor
    activeTabColor*: SdlColor
    textColor*: SdlColor
    borderColor*: SdlColor
    hoveredTab*: int
    onTabChange*: proc(tc: TabControl, index: int)

  # Меню
  MenuItem* = ref object
    text*: string
    shortcut*: string
    enabled*: bool
    checkable*: bool
    checked*: bool
    separator*: bool
    submenu*: seq[MenuItem]
    onClick*: proc(item: MenuItem)

  Menu* = ref object of Widget
    ## Меню
    items*: seq[MenuItem]
    isOpen*: bool
    selectedIndex*: int
    itemHeight*: int
    bgColor*: SdlColor
    hoverColor*: SdlColor
    textColor*: SdlColor
    borderColor*: SdlColor
    openSubmenu*: int

  # MenuBar (горизонтальное меню с выпадающими подменю)
  MenuBar* = ref object of Widget
    ## Горизонтальное меню с выпадающими подменю
    menus*: seq[Menu]  # Список меню (Файл, Правка и т.д.)
    hoveredMenu*: int  # Индекс меню под курсором
    openMenu*: int     # Индекс открытого меню (-1 если нет)
    itemWidth*: int    # Ширина пунктов меню
    bgColor*: SdlColor
    textColor*: SdlColor
    hoverColor*: SdlColor
    borderColor*: SdlColor
  
  # Тулбар
  ToolBar* = ref object of Widget
    ## Панель инструментов
    buttons*: seq[Button]
    buttonSize*: int
    spacing*: int
    bgColor*: SdlColor
    borderColor*: SdlColor

  # Tooltip
  ToolTip* = ref object
    ## Всплывающая подсказка
    text*: string
    widget*: Widget
    visible*: bool
    rect*: SdlRect
    bgColor*: SdlColor
    textColor*: SdlColor
    borderColor*: SdlColor
    delay*: int
    timer*: int

  # StatusBar
  StatusBar* = ref object of Widget
    ## Строка состояния внизу окна
    text*: string
    textColor*: SdlColor
    bgColor*: SdlColor
    borderColor*: SdlColor
    sections*: seq[string]  # Несколько секций текста

  # GUI менеджер
  GuiManager* = ref object
    ## Менеджер GUI
    renderer*: SdlRenderer
    theme*: GuiTheme
    widgets*: seq[Widget]
    focusedWidget*: Widget
    hoveredWidget*: Widget
    modalDialog*: Dialog
    tooltip*: ToolTip
    font*: TTF_Font
    cursorX*: float
    cursorY*: float
    radioGroups*: Table[string, seq[RadioButton]]
    # Мигающий курсор
    cursorVisible*: bool
    cursorBlinkTime*: uint64
    cursorBlinkInterval*: uint64  # Интервал мигания в миллисекундах



# =============================================================================
# Вспомогательные функции
# =============================================================================

proc initColor*(r, g, b: uint8, a: uint8 = 255): SdlColor =
  ## Создать цвет
  result.r = r
  result.g = g
  result.b = b
  result.a = a

proc initRect*(x, y, w, h: int): SdlRect =
  ## Создать прямоугольник
  result.x = x.cint
  result.y = y.cint
  result.w = w.cint
  result.h = h.cint

proc initFRect*(x, y, w, h: float): SdlFRect =
  ## Создать прямоугольник с float
  result.x = x.cfloat
  result.y = y.cfloat
  result.w = w.cfloat
  result.h = h.cfloat

proc pointInRect*(x, y: float, rect: SdlRect): bool =
  ## Проверить, находится ли точка внутри прямоугольника
  x >= rect.x.float and x <= (rect.x + rect.w).float and
  y >= rect.y.float and y <= (rect.y + rect.h).float

proc setRenderColor*(renderer: SdlRenderer, color: SdlColor) =
  ## Установить цвет рендеринга
  discard SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)

proc renderFillRect*(renderer: SdlRenderer, rect: SdlRect, color: SdlColor) =
  ## Нарисовать закрашенный прямоугольник
  # Если есть прозрачность, включаем blend mode
  if color.a < 255:
    discard SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND)
  
  setRenderColor(renderer, color)
  var frect = initFRect(rect.x.float, rect.y.float, rect.w.float, rect.h.float)
  discard SDL_RenderFillRect(renderer, addr frect)
  
  # Восстанавливаем blend mode
  if color.a < 255:
    discard SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)

proc renderRect*(renderer: SdlRenderer, rect: SdlRect, color: SdlColor, width: int = 1) =
  ## Нарисовать контур прямоугольника
  setRenderColor(renderer, color)
  var frect = initFRect(rect.x.float, rect.y.float, rect.w.float, rect.h.float)
  for i in 0..<width:
    var r = initFRect(
      frect.x + i.float, 
      frect.y + i.float,
      frect.w - i.float * 2, 
      frect.h - i.float * 2
    )
    discard SDL_RenderRect(renderer, addr r)

proc renderText*(renderer: SdlRenderer, font: TTF_Font, text: string, 
                x, y: int, color: SdlColor): SdlRect =
  ## Отрендерить текст и вернуть его размеры
  if text.len == 0:
    return initRect(x, y, 0, 0)
  
  let surface = TTF_RenderText_Blended(font, text.cstring, text.len.csize_t, color)
  if surface.isNil:
    return initRect(x, y, 0, 0)
  
  let texture = SDL_CreateTextureFromSurface(renderer, surface)
  var w, h: cfloat
  discard SDL_GetTextureSize(texture, addr w, addr h)
  
  var srcRect = initFRect(0, 0, w, h)
  var dstRect = initFRect(x.float, y.float, w, h)
  
  discard SDL_RenderTexture(renderer, texture, addr srcRect, addr dstRect)
  
  SDL_DestroySurface(surface)
  SDL_DestroyTexture(texture)
  
  result = initRect(x, y, w.int, h.int)

proc getTextSize*(font: TTF_Font, text: string): tuple[w, h: int] =
  ## Получить размер текста
  if text.len == 0:
    return (0, 0)
  var w: cint
  var len: csize_t
  if TTF_MeasureString(font, text.cstring, text.len.csize_t, 0, addr w, addr len):
    let h = TTF_GetFontHeight(font)
    result = (w.int, h.int)
  else:
    result = (0, 0)

# =============================================================================
# Темы оформления
# =============================================================================

proc createDefaultTheme*(font: TTF_Font): GuiTheme =
  ## Создать тему по умолчанию (светлая)
  result = GuiTheme(
    bgColor: initColor(240, 240, 240),
    textColor: initColor(0, 0, 0),
    borderColor: initColor(180, 180, 180),
    accentColor: initColor(0, 120, 215),
    hoverColor: initColor(229, 243, 255),
    activeColor: initColor(204, 228, 247),
    disabledColor: initColor(200, 200, 200),
    font: font,
    fontSize: 14.0,
    padding: 8,
    borderWidth: 1
  )

proc createDarkTheme*(font: TTF_Font): GuiTheme =
  ## Создать тёмную тему
  result = GuiTheme(
    bgColor: initColor(45, 45, 48),
    textColor: initColor(241, 241, 241),
    borderColor: initColor(63, 63, 70),
    accentColor: initColor(0, 122, 204),
    hoverColor: initColor(62, 62, 64),
    activeColor: initColor(51, 51, 55),
    disabledColor: initColor(100, 100, 100),
    font: font,
    fontSize: 14.0,
    padding: 8,
    borderWidth: 1
  )

# =============================================================================
# GUI Manager
# =============================================================================

proc createGuiManager*(renderer: SdlRenderer, font: TTF_Font): GuiManager =
  ## Создать менеджер GUI
  result = GuiManager(
    renderer: renderer,
    theme: createDefaultTheme(font),
    widgets: @[],
    font: font,
    radioGroups: initTable[string, seq[RadioButton]](),
    tooltip: ToolTip(
      visible: false,
      bgColor: initColor(255, 255, 225),
      textColor: initColor(0, 0, 0),
      borderColor: initColor(118, 118, 118),
      delay: 500
    ),
    # Инициализация мигающего курсора
    cursorVisible: true,
    cursorBlinkTime: SDL_GetTicks(),
    cursorBlinkInterval: 530  # Мигание каждые 530мс (стандарт Windows)
  )

proc addWidget*(gui: GuiManager, widget: Widget) =
  ## Добавить виджет
  gui.widgets.add(widget)

proc removeWidget*(gui: GuiManager, widget: Widget) =
  ## Удалить виджет
  let idx: int = find(gui.widgets, widget)
  if idx >= 0:
    gui.widgets.delete(idx)

proc findWidgetById*(gui: GuiManager, id: string): Widget =
  ## Найти виджет по ID
  for w in gui.widgets:
    if w.id == id:
      return w
  return nil

proc setFocus*(gui: GuiManager, widget: Widget) =
  ## Установить фокус на виджет
  # ИСПРАВЛЕНИЕ: Очищаем выделение текста при потере фокуса
  if gui.focusedWidget != nil:
    if gui.focusedWidget of TextArea:
      let area = TextArea(gui.focusedWidget)
      area.hasSelection = false
    elif gui.focusedWidget of TextField:
      let field = TextField(gui.focusedWidget)
      field.selectionStart = 0
      field.selectionEnd = 0
    gui.focusedWidget.state = wsNormal
  
  gui.focusedWidget = widget
  if widget != nil:
    widget.state = wsFocused
  # Сбрасываем мигание курсора при смене фокуса
  gui.cursorVisible = true
  gui.cursorBlinkTime = SDL_GetTicks()

proc updateCursorBlink*(gui: GuiManager) =
  ## Обновить состояние мигающего курсора
  let currentTime: uint64 = SDL_GetTicks()
  if currentTime - gui.cursorBlinkTime >= gui.cursorBlinkInterval:
    gui.cursorVisible = not gui.cursorVisible
    gui.cursorBlinkTime = currentTime


# =============================================================================
# Кнопка
# =============================================================================

proc createButton*(id: string, x, y, w, h: int, text: string): Button =
  ## Создать кнопку
  result = Button(
    id: id,
    rect: initRect(x, y, w, h),
    text: text,
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    textColor: initColor(0, 0, 0),
    bgColor: initColor(225, 225, 225),
    hoverColor: initColor(229, 241, 251),
    activeColor: initColor(204, 228, 247),
    borderColor: initColor(173, 173, 173),
    textAlign: alignCenter
  )

proc renderButton*(gui: GuiManager, btn: Button) =
  ## Отрендерить кнопку
  if not btn.visible:
    return
  
  var bgColor = btn.bgColor
  case btn.state:
  of wsHover:
    bgColor = btn.hoverColor
  of wsPressed, wsActive:
    bgColor = btn.activeColor
  of wsDisabled:
    bgColor = gui.theme.disabledColor
  else:
    discard
  
  # Фон
  renderFillRect(gui.renderer, btn.rect, bgColor)
  
  # Граница
  renderRect(gui.renderer, btn.rect, btn.borderColor, gui.theme.borderWidth)
  
  # Иконка (если есть)
  var iconWidth = 0
  if not btn.icon.isNil:
    let iconX = btn.rect.x.int + btn.iconRect.x.int
    let iconY = btn.rect.y.int + btn.iconRect.y.int
    
    # Получаем реальный размер текстуры
    var texW, texH: cfloat
    discard SDL_GetTextureSize(btn.icon, addr texW, addr texH)
    
    # srcRect - вся текстура, dstRect - масштабированный размер из iconRect
    var srcRect = initFRect(0, 0, texW, texH)
    var dstRect = initFRect(iconX.cfloat, iconY.cfloat, btn.iconRect.w.cfloat, btn.iconRect.h.cfloat)
    discard SDL_RenderTexture(gui.renderer, btn.icon, addr srcRect, addr dstRect)
    iconWidth = btn.iconRect.w.int + 8  # Ширина иконки + отступ
  
  # Текст
  if btn.text.len > 0:
    let textSize = getTextSize(gui.theme.font, btn.text)
    var textX = btn.rect.x.int
    let textY = btn.rect.y.int + (btn.rect.h.int - textSize.h) div 2
    
    case btn.textAlign:
    of alignCenter:
      # Если есть иконка, центрируем текст с учётом иконки
      if iconWidth > 0:
        let totalWidth = iconWidth + textSize.w
        let startX = btn.rect.x.int + (btn.rect.w.int - totalWidth) div 2
        textX = startX + iconWidth
      else:
        textX = btn.rect.x.int + (btn.rect.w.int - textSize.w) div 2
    of alignRight:
      textX = btn.rect.x.int + btn.rect.w.int - textSize.w - gui.theme.padding
    else:
      # alignLeft - если есть иконка, текст справа от неё
      if iconWidth > 0:
        textX = btn.rect.x.int + iconWidth + gui.theme.padding
      else:
        textX = btn.rect.x.int + gui.theme.padding
    
    discard renderText(gui.renderer, gui.theme.font, btn.text, textX, textY, btn.textColor)

proc handleButtonEvent*(btn: Button, event: ptr SdlEvent): bool =
  ## Обработать событие для кнопки
  if not btn.enabled or not btn.visible:
    return false
  
  case event.type:
  of SDL_EVENT_MOUSE_MOTION:
    let x = event.motion.x
    let y = event.motion.y
    if pointInRect(x, y, btn.rect):
      if btn.state != wsPressed:
        btn.state = wsHover
      return true
    else:
      if btn.state == wsHover:
        btn.state = wsNormal
  
  of SDL_EVENT_MOUSE_BUTTON_DOWN:
    let x = event.button.x
    let y = event.button.y
    if pointInRect(x, y, btn.rect):
      btn.state = wsPressed
      return true
  
  of SDL_EVENT_MOUSE_BUTTON_UP:
    let x = event.button.x
    let y = event.button.y
    if btn.state == wsPressed:
      btn.state = wsHover
      if pointInRect(x, y, btn.rect):
        if btn.onClick != nil:
          btn.onClick(btn)
        return true
  
  else:
    discard
  
  return false

# =============================================================================
# Текстовое поле
# =============================================================================

proc createTextField*(id: string, x, y, w, h: int, placeholder: string = ""): TextField =
  ## Создать текстовое поле
  result = TextField(
    id: id,
    rect: initRect(x, y, w, h),
    text: "",
    placeholder: placeholder,
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    textColor: initColor(0, 0, 0),
    placeholderColor: initColor(150, 150, 150),
    bgColor: initColor(255, 255, 255),
    borderColor: initColor(122, 122, 122),
    cursorPos: 0,
    selectionStart: -1,
    selectionEnd: -1,
    scrollOffset: 0,
    maxLength: -1,
    isPassword: false
  )

proc renderTextField*(gui: GuiManager, field: TextField) =
  ## Отрендерить текстовое поле
  if not field.visible:
    return
  
  # Фон
  renderFillRect(gui.renderer, field.rect, field.bgColor)
  
  # Граница
  var borderColor = field.borderColor
  if field.state == wsFocused:
    borderColor = gui.theme.accentColor
  renderRect(gui.renderer, field.rect, borderColor, gui.theme.borderWidth)
  
  # Текст или placeholder
  let padding = gui.theme.padding
  let textX = field.rect.x.int + padding
  let textY = field.rect.y.int + padding
  
  if field.text.len > 0:
    var displayText = field.text
    if field.isPassword and field.passwordChar.int != 0:
      displayText = $field.passwordChar.repeat(field.text.runeLen)
    
    # Установить область отсечения
    var clipRect = SdlRect(
      x: (field.rect.x + padding).cint,
      y: field.rect.y,
      w: (field.rect.w - padding * 2).cint,
      h: field.rect.h
    )
    discard SDL_SetRenderClipRect(gui.renderer, addr clipRect)
    
    discard renderText(gui.renderer, gui.theme.font, displayText, 
                      textX - field.scrollOffset, textY, field.textColor)
    
    discard SDL_SetRenderClipRect(gui.renderer, nil)
  
  elif field.placeholder.len > 0:
    discard renderText(gui.renderer, gui.theme.font, field.placeholder, 
                      textX, textY, field.placeholderColor)
  
  # Курсор (мигающий) - рисуется всегда когда поле в фокусе
  if field.state == wsFocused and gui.cursorVisible:
    # Получаем текст до курсора используя руны
    var cursorX = textX - field.scrollOffset
    
    if field.text.len > 0:
      var displayText = field.text
      if field.isPassword and field.passwordChar.int != 0:
        displayText = $field.passwordChar.repeat(field.text.runeLen)
      
      let runes = displayText.toRunes
      let cursorText = if field.cursorPos <= runes.len:
                         $runes[0..<field.cursorPos]
                       else:
                         displayText
      cursorX += getTextSize(gui.theme.font, cursorText).w
    
    # Курсор чуть выше и ниже текста (на 2 пикселя)
    let cursorY1 = field.rect.y.int + padding - 2
    let cursorY2 = field.rect.y.int + field.rect.h.int - padding + 2
    
    setRenderColor(gui.renderer, field.textColor)
    discard SDL_RenderLine(gui.renderer, cursorX.cfloat, cursorY1.cfloat, 
                          cursorX.cfloat, cursorY2.cfloat)


proc insertTextInField*(field: TextField, text: string) =
  ## Вставить текст в поле
  # Работаем с рунами для корректной обработки UTF-8
  var runes = toRunes(field.text)
  let newRunes = toRunes(text)

  # Проверка maxLength по количеству символов, а не байтов
  if field.maxLength >= 0 and runes.len + newRunes.len > field.maxLength:
    return

  # Вставляем руны
  for i in 0..<len(newRunes):
    insert(runes, newRunes[i], field.cursorPos + i)

  field.text = $runes
  field.cursorPos += newRunes.len

  if field.onChange != nil:
    field.onChange(field, field.text)


proc deleteCharInField*(field: TextField, forward: bool = false) =
  ## Удалить символ
  var runes = toRunes(field.text)
  
  if forward:
    if field.cursorPos < len(runes):
      delete(runes, field.cursorPos)
  else:
    if field.cursorPos > 0:
      delete(runes, field.cursorPos - 1)
      field.cursorPos -= 1
  
  field.text = $runes
  
  if field.onChange != nil:
    field.onChange(field, field.text)


proc handleTextFieldEvent*(gui: GuiManager, field: TextField, event: ptr SdlEvent): bool =
  ## Обработать событие для текстового поля
  if not field.enabled or not field.visible:
    return false

  case event.type:
  of SDL_EVENT_MOUSE_BUTTON_DOWN:
    let x = event.button.x
    let y = event.button.y
    if pointInRect(x, y, field.rect):
      gui.setFocus(field)
      
      # Установка позиции курсора по клику
      let padding = gui.theme.padding
      let textX = field.rect.x.int + padding
      let localX = x.int - textX + field.scrollOffset
      
      # Получаем отображаемый текст
      var displayText = field.text
      if field.isPassword and field.passwordChar.int != 0:
        displayText = $field.passwordChar.repeat(field.text.runeLen)
      
      let runes = displayText.toRunes
      var accumulatedWidth = 0
      field.cursorPos = 0
      
      for i in 0..<runes.len:
        let charText = $runes[i]
        let charWidth = getTextSize(gui.theme.font, charText).w
        if accumulatedWidth + charWidth div 2 > localX:
          break
        accumulatedWidth += charWidth
        field.cursorPos += 1
      
      # Сбрасываем мигание курсора
      gui.cursorVisible = true
      gui.cursorBlinkTime = SDL_GetTicks()
      
      return true
    elif field.state == wsFocused:
      field.state = wsNormal
  
  of SDL_EVENT_TEXT_INPUT:
    if field.state == wsFocused:
      # В SDL3 поле text - это cstring, а не массив
      let inputText = $event.text.text
      insertTextInField(field, inputText)
      # Сбрасываем мигание курсора при вводе
      gui.cursorVisible = true
      gui.cursorBlinkTime = SDL_GetTicks()
      return true
  
  of SDL_EVENT_KEY_DOWN:
    if field.state == wsFocused:
      # Сбрасываем мигание курсора при любом нажатии клавиши
      gui.cursorVisible = true
      gui.cursorBlinkTime = SDL_GetTicks()
      
      case event.key.key:
      of SDLK_BACKSPACE:
        deleteCharInField(field, false)
        return true
      of SDLK_DELETE, SDLK_DELETE_CHAR:  # Обрабатываем оба варианта
        deleteCharInField(field, true)
        return true
      of SDLK_LEFT:
        if field.cursorPos > 0:
          field.cursorPos -= 1
        return true
      of SDLK_RIGHT:
        let runeLen = field.text.runeLen
        if field.cursorPos < runeLen:
          field.cursorPos += 1
        return true
      of SDLK_HOME:
        field.cursorPos = 0
        return true
      of SDLK_END:
        field.cursorPos = field.text.runeLen
        return true
      of SDLK_RETURN, SDLK_KP_ENTER:
        if field.onSubmit != nil:
          field.onSubmit(field, field.text)
        return true
      else:
        discard
  
  else:
    discard
  
  return false


# =============================================================================
# TextArea (Многострочное текстовое поле)
# =============================================================================

proc createTextArea*(id: string, x, y, w, h: int): TextArea =
  ## Создать многострочное текстовое поле
  result = TextArea(
    id: id,
    rect: initRect(x, y, w, h),
    lines: @[""],
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    textColor: initColor(0, 0, 0),
    bgColor: initColor(255, 255, 255),
    borderColor: initColor(122, 122, 122),
    selectionColor: initColor(0, 120, 215, 100),  # Полупрозрачный синий
    cursorLine: 0,
    cursorCol: 0,
    scrollX: 0,
    scrollY: 0,
    # Инициализация выделения
    selectionStartLine: -1,
    selectionStartCol: -1,
    selectionEndLine: -1,
    selectionEndCol: -1,
    hasSelection: false
  )

proc clearSelection*(area: TextArea) =
  ## Снять выделение
  area.hasSelection = false
  area.selectionStartLine = -1
  area.selectionStartCol = -1
  area.selectionEndLine = -1
  area.selectionEndCol = -1

proc startSelection*(area: TextArea, line, col: int) =
  ## Начать выделение
  area.hasSelection = true
  area.selectionStartLine = line
  area.selectionStartCol = col
  area.selectionEndLine = line
  area.selectionEndCol = col

proc updateSelection*(area: TextArea, line, col: int) =
  ## Обновить конец выделения
  if area.hasSelection:
    area.selectionEndLine = line
    area.selectionEndCol = col

proc getSelectedText*(area: TextArea): string =
  ## Получить выделенный текст
  if not area.hasSelection:
    return ""
  
  var startLine = area.selectionStartLine
  var startCol = area.selectionStartCol
  var endLine = area.selectionEndLine
  var endCol = area.selectionEndCol
  
  # Нормализуем выделение (начало всегда раньше конца)
  if startLine > endLine or (startLine == endLine and startCol > endCol):
    swap(startLine, endLine)
    swap(startCol, endCol)
  
  result = ""
  if startLine == endLine:
    # Однострочное выделение
    let runes = area.lines[startLine].toRunes
    if startCol < runes.len and endCol <= runes.len:
      result = $runes[startCol..<endCol]
  else:
    # Многострочное выделение
    for line in startLine..endLine:
      if line < area.lines.len:
        if line == startLine:
          # Первая строка - от startCol до конца
          let runes = area.lines[line].toRunes
          if startCol < runes.len:
            result &= $runes[startCol..^1] & "\n"
          else:
            result &= "\n"
        elif line == endLine:
          # Последняя строка - от начала до endCol
          let runes = area.lines[line].toRunes
          if endCol > 0 and endCol <= runes.len:
            result &= $runes[0..<endCol]
        else:
          # Средние строки - целиком
          result &= area.lines[line] & "\n"
  
  return result

proc deleteSelectedText*(area: TextArea) =
  ## Удалить выделенный текст
  if not area.hasSelection:
    return
  
  var startLine = area.selectionStartLine
  var startCol = area.selectionStartCol
  var endLine = area.selectionEndLine
  var endCol = area.selectionEndCol
  
  # Нормализуем выделение
  if startLine > endLine or (startLine == endLine and startCol > endCol):
    swap(startLine, endLine)
    swap(startCol, endCol)
  
  if startLine == endLine:
    # Однострочное удаление
    var runes = area.lines[startLine].toRunes
    if startCol < runes.len and endCol <= runes.len:
      for i in countdown(endCol - 1, startCol):
        if i >= 0 and i < runes.len:
          runes.delete(i)
      area.lines[startLine] = $runes
  else:
    # Многострочное удаление
    # Объединяем первую и последнюю строку
    var firstRunes = area.lines[startLine].toRunes
    var lastRunes = area.lines[endLine].toRunes
    
    # Берём начало первой строки и конец последней
    var newLine: seq[Rune] = @[]
    for i in 0..<startCol:
      if i < firstRunes.len:
        newLine.add(firstRunes[i])
    for i in endCol..<lastRunes.len:
      newLine.add(lastRunes[i])
    
    area.lines[startLine] = $newLine
    
    # Удаляем промежуточные строки
    for i in countdown(endLine, startLine + 1):
      if i < area.lines.len:
        area.lines.delete(i)
  
  # Устанавливаем курсор в начало выделения
  area.cursorLine = startLine
  area.cursorCol = startCol
  clearSelection(area)

proc renderTextArea*(gui: GuiManager, area: TextArea) =
  ## Отрендерить многострочное текстовое поле
  if not area.visible:
    return
  
  # Фон
  renderFillRect(gui.renderer, area.rect, area.bgColor)
  
  # Граница
  var borderColor = area.borderColor
  if area.state == wsFocused:
    borderColor = gui.theme.accentColor
  renderRect(gui.renderer, area.rect, borderColor, gui.theme.borderWidth)
  
  # Область отсечения
  let padding = gui.theme.padding
  var clipRect = SdlRect(
    x: (area.rect.x + padding).cint,
    y: (area.rect.y + padding).cint,
    w: (area.rect.w - padding * 2).cint,
    h: (area.rect.h - padding * 2).cint
  )
  discard SDL_SetRenderClipRect(gui.renderer, addr clipRect)
  
  # Рендеринг текста и выделения
  let lineHeight = getTextSize(gui.theme.font, "Ag").h + 2
  var y = area.rect.y.int + padding - area.scrollY
  
  # Нормализуем выделение для рендеринга
  var selStart = (line: area.selectionStartLine, col: area.selectionStartCol)
  var selEnd = (line: area.selectionEndLine, col: area.selectionEndCol)
  if area.hasSelection:
    if selStart.line > selEnd.line or (selStart.line == selEnd.line and selStart.col > selEnd.col):
      swap(selStart, selEnd)
  
  for i, line in area.lines:
    if y > area.rect.y.int + area.rect.h.int:
      break
    if y + lineHeight >= area.rect.y.int + padding:
      let x = area.rect.x.int + padding - area.scrollX
      
      # Рендеринг выделения для этой строки
      if area.hasSelection and i >= selStart.line and i <= selEnd.line:
        let runes = line.toRunes
        var selStartCol = 0
        var selEndCol = runes.len
        
        if i == selStart.line:
          selStartCol = selStart.col
        if i == selEnd.line:
          selEndCol = selEnd.col
        
        # Рисуем фон выделения
        if selStartCol < selEndCol:
          let beforeText = if selStartCol > 0 and selStartCol <= runes.len:
                             $runes[0..<selStartCol]
                           else:
                             ""
          let selectedText = if selEndCol <= runes.len:
                               $runes[selStartCol..<selEndCol]
                             else:
                               $runes[selStartCol..^1]
          
          let selX = x + getTextSize(gui.theme.font, beforeText).w
          let selW = getTextSize(gui.theme.font, selectedText).w
          
          let selRect = initRect(selX, y, selW, lineHeight)
          renderFillRect(gui.renderer, selRect, area.selectionColor)
      
      # Рендеринг текста
      discard renderText(gui.renderer, gui.theme.font, line, x, y, area.textColor)
      
      # Курсор (мигающий)
      if area.state == wsFocused and i == area.cursorLine and gui.cursorVisible:
        let runes = line.toRunes
        let cursorText = if area.cursorCol <= runes.len:
                           $runes[0..<area.cursorCol]
                         else:
                           line
        let cursorX = x + getTextSize(gui.theme.font, cursorText).w
        setRenderColor(gui.renderer, area.textColor)
        discard SDL_RenderLine(gui.renderer, cursorX.cfloat, y.cfloat,
                              cursorX.cfloat, (y + lineHeight).cfloat)
    y += lineHeight

  discard SDL_SetRenderClipRect(gui.renderer, nil)

proc handleTextAreaEvent*(gui: GuiManager, area: TextArea, event: ptr SdlEvent): bool =
  ## Обработать событие для многострочного текстового поля
  if not area.enabled or not area.visible:
    return false

  case event.type:
  of SDL_EVENT_MOUSE_BUTTON_DOWN:
    let x = event.button.x
    let y = event.button.y
    if pointInRect(x, y, area.rect):
      # ИСПРАВЛЕНИЕ: устанавливаем фокус на TextArea
      gui.setFocus(area)
      
      # Сбрасываем мигание курсора
      gui.cursorVisible = true
      gui.cursorBlinkTime = SDL_GetTicks()
      
      # НОВАЯ ФУНКЦИЯ: установка курсора по клику мыши
      let padding = gui.theme.padding
      let lineHeight = getTextSize(gui.theme.font, "Ag").h + 2
      let localY = y.int - area.rect.y.int - padding + area.scrollY
      let clickedLine = localY div lineHeight
      
      if clickedLine >= 0 and clickedLine < area.lines.len:
        area.cursorLine = clickedLine
        
        # Определяем позицию курсора в строке
        let localX = x.int - area.rect.x.int - padding + area.scrollX
        var accumulatedWidth = 0
        let line = area.lines[area.cursorLine]
        let runes = line.toRunes
        
        area.cursorCol = 0
        for i in 0..<runes.len:
          let charText = $runes[i]
          let charWidth = getTextSize(gui.theme.font, charText).w
          if accumulatedWidth + charWidth div 2 > localX:
            break
          accumulatedWidth += charWidth
          area.cursorCol += 1
        
        # НОВОЕ: начать выделение при Shift-клике, иначе снять выделение
        let modState = SDL_GetModState()
        if (uint32(modState) and uint32(SDL_KMOD_SHIFT)) != 0'u32:
          # Shift-клик - расширяем выделение
          if not area.hasSelection:
            startSelection(area, area.cursorLine, area.cursorCol)
          else:
            updateSelection(area, area.cursorLine, area.cursorCol)
        else:
          # Обычный клик - начинаем новое выделение (будет расширяться при перетаскивании)
          clearSelection(area)
          startSelection(area, area.cursorLine, area.cursorCol)

      return true
    # ИСПРАВЛЕНИЕ: НЕ снимаем фокус здесь, это сделает handleGuiEvent
    return false

  of SDL_EVENT_MOUSE_MOTION:
    # НОВОЕ: выделение при перетаскивании мыши
    if area.state == wsFocused and uint32(event.motion.state) != 0'u32:      # хотя бы одна кнопка нажата → обрабатываем drag
      let x = event.motion.x
      let y = event.motion.y
      if area.hasSelection:
        let padding = gui.theme.padding
        let lineHeight = getTextSize(gui.theme.font, "Ag").h + 2
        let localY = y.int - area.rect.y.int - padding + area.scrollY
        let dragLine = max(0, min(area.lines.len - 1, localY div lineHeight))

        if dragLine >= 0 and dragLine < area.lines.len:
          let localX = x.int - area.rect.x.int - padding + area.scrollX
          var accumulatedWidth = 0
          let line = area.lines[dragLine]
          let runes = line.toRunes
          
          var dragCol = 0
          for i in 0..<runes.len:
            let charText = $runes[i]
            let charWidth = getTextSize(gui.theme.font, charText).w
            if accumulatedWidth + charWidth div 2 > localX:
              break
            accumulatedWidth += charWidth
            dragCol += 1
          
          area.cursorLine = dragLine
          area.cursorCol = dragCol
          updateSelection(area, dragLine, dragCol)
      return true

  of SDL_EVENT_TEXT_INPUT:
    # ИСПРАВЛЕНИЕ: проверяем состояние фокуса
    if area.state == wsFocused:
      # Сбрасываем мигание курсора при вводе
      gui.cursorVisible = true
      gui.cursorBlinkTime = SDL_GetTicks()
      
      # ИСПРАВЛЕНИЕ: проверка на пустой массив строк
      if area.lines.len == 0:
        area.lines.add("")
        area.cursorLine = 0
        area.cursorCol = 0
      
      # Убедимся что cursorLine в пределах массива
      if area.cursorLine >= area.lines.len:
        area.cursorLine = area.lines.len - 1
      
      # НОВОЕ: удаляем выделенный текст перед вводом
      if area.hasSelection:
        deleteSelectedText(area)
      
      let inputText = $event.text.text
      var runes = area.lines[area.cursorLine].toRunes
      let newRunes = inputText.toRunes
      
      # Вставляем новые символы в позицию курсора
      for i in 0..<newRunes.len:
        runes.insert(newRunes[i], area.cursorCol + i)
      
      area.lines[area.cursorLine] = $runes
      area.cursorCol += newRunes.len
      
      if area.onChange != nil:
        area.onChange(area)
      return true
  
  of SDL_EVENT_KEY_DOWN:
    # ИСПРАВЛЕНИЕ: проверяем состояние фокуса
    if area.state == wsFocused:
      # Сбрасываем мигание курсора при любом нажатии клавиши
      gui.cursorVisible = true
      gui.cursorBlinkTime = SDL_GetTicks()
      
      # ИСПРАВЛЕНИЕ: проверка на пустой массив
      if area.lines.len == 0:
        area.lines.add("")
        area.cursorLine = 0
        area.cursorCol = 0
      
      # Получаем состояние модификаторов
      let modState = SDL_GetModState()
      let isShift = (uint32(modState) and uint32(SDL_KMOD_SHIFT)) != 0'u32
      let isCtrl  = (uint32(modState) and uint32(SDL_KMOD_CTRL))  != 0'u32
      
      # НОВОЕ: Обработка Ctrl+ комбинаций
      if isCtrl:
        case event.key.key:
        of SDLK_A:  # Ctrl+A - выделить всё
          if area.lines.len > 0:
            clearSelection(area)
            area.hasSelection = true
            area.selectionStartLine = 0
            area.selectionStartCol = 0
            area.selectionEndLine = area.lines.len - 1
            area.selectionEndCol = area.lines[^1].runeLen
          return true
        
        of SDLK_C:  # Ctrl+C - копировать
          if area.hasSelection:
            let selectedText = getSelectedText(area)
            discard SDL_SetClipboardText(selectedText.cstring)
          return true
        
        of SDLK_V:  # Ctrl+V - вставить
          let clipText = SDL_GetClipboardText()
          if not clipText.isNil:
            let text = $clipText
            if text.len > 0:
              # Удаляем выделение если есть
              if area.hasSelection:
                deleteSelectedText(area)
              
              # Вставляем текст по строкам
              let lines = text.split('\n')
              for i, line in lines:
                if i == 0:
                  # Первая строка - вставляем в текущую позицию
                  var runes = area.lines[area.cursorLine].toRunes
                  let newRunes = line.toRunes
                  for j in 0..<newRunes.len:
                    runes.insert(newRunes[j], area.cursorCol + j)
                  area.lines[area.cursorLine] = $runes
                  area.cursorCol += newRunes.len
                else:
                  # Остальные строки - создаём новые
                  let currentRunes = area.lines[area.cursorLine].toRunes
                  let rightPart = if area.cursorCol < currentRunes.len:
                                    $currentRunes[area.cursorCol..^1]
                                  else:
                                    ""
                  area.lines[area.cursorLine] = $currentRunes[0..<area.cursorCol]
                  area.lines.insert(line & rightPart, area.cursorLine + 1)
                  area.cursorLine += 1
                  area.cursorCol = line.runeLen
              
              if area.onChange != nil:
                area.onChange(area)
          return true
        
        of SDLK_X:  # Ctrl+X - вырезать
          if area.hasSelection:
            let selectedText = getSelectedText(area)
            discard SDL_SetClipboardText(selectedText.cstring)
            deleteSelectedText(area)
            if area.onChange != nil:
              area.onChange(area)
          return true
        
        else:
          discard
      
      # НОВОЕ: Запоминаем позицию для Shift+стрелки
      if isShift and not area.hasSelection:
        startSelection(area, area.cursorLine, area.cursorCol)
      
      case event.key.key:
      of SDLK_BACKSPACE:
        # НОВОЕ: удаляем выделение если есть
        if area.hasSelection:
          deleteSelectedText(area)
        elif area.cursorCol > 0:
          # Удаляем символ слева от курсора
          var runes = area.lines[area.cursorLine].toRunes
          runes.delete(area.cursorCol - 1)
          area.lines[area.cursorLine] = $runes
          area.cursorCol -= 1
        elif area.cursorLine > 0:
          # Объединить с предыдущей строкой
          let prevLen = area.lines[area.cursorLine - 1].runeLen
          area.lines[area.cursorLine - 1] &= area.lines[area.cursorLine]
          area.lines.delete(area.cursorLine)
          area.cursorLine -= 1
          area.cursorCol = prevLen
        
        if area.onChange != nil:
          area.onChange(area)
        return true

      of SDLK_DELETE, SDLK_DELETE_CHAR:  # Обрабатываем оба варианта Delete
        # НОВОЕ: удаляем выделение если есть
        if area.hasSelection:
          deleteSelectedText(area)
        else:
          # Удаление символа справа от курсора
          let lineLen = area.lines[area.cursorLine].runeLen
          if area.cursorCol < lineLen:
            var runes = area.lines[area.cursorLine].toRunes
            runes.delete(area.cursorCol)
            area.lines[area.cursorLine] = $runes
          elif area.cursorLine < area.lines.len - 1:
            # Объединить со следующей строкой
            area.lines[area.cursorLine] &= area.lines[area.cursorLine + 1]
            area.lines.delete(area.cursorLine + 1)
        
        if area.onChange != nil:
          area.onChange(area)
        return true

      of SDLK_RETURN, SDLK_KP_ENTER:
        # Новая строка
        let runes = area.lines[area.cursorLine].toRunes
        let rightPart = if area.cursorCol < runes.len:
                          $runes[area.cursorCol..^1]
                        else:
                          ""
        area.lines[area.cursorLine] = if area.cursorCol > 0:
                                         $runes[0..<area.cursorCol]
                                       else:
                                         ""
        area.lines.insert(rightPart, area.cursorLine + 1)
        area.cursorLine += 1
        area.cursorCol = 0
        
        if area.onChange != nil:
          area.onChange(area)
        return true
      
      of SDLK_LEFT:
        if area.cursorCol > 0:
          area.cursorCol -= 1
        elif area.cursorLine > 0:
          area.cursorLine -= 1
          area.cursorCol = area.lines[area.cursorLine].runeLen
        # НОВОЕ: обновляем выделение при Shift
        if isShift:
          updateSelection(area, area.cursorLine, area.cursorCol)
        else:
          clearSelection(area)
        return true
      
      of SDLK_RIGHT:
        let lineLen = area.lines[area.cursorLine].runeLen
        if area.cursorCol < lineLen:
          area.cursorCol += 1
        elif area.cursorLine < area.lines.len - 1:
          area.cursorLine += 1
          area.cursorCol = 0
        # НОВОЕ: обновляем выделение при Shift
        if isShift:
          updateSelection(area, area.cursorLine, area.cursorCol)
        else:
          clearSelection(area)
        return true
      
      of SDLK_UP:
        if area.cursorLine > 0:
          area.cursorLine -= 1
          let lineLen = area.lines[area.cursorLine].runeLen
          area.cursorCol = min(area.cursorCol, lineLen)
        # НОВОЕ: обновляем выделение при Shift
        if isShift:
          updateSelection(area, area.cursorLine, area.cursorCol)
        else:
          clearSelection(area)
        return true
      
      of SDLK_DOWN:
        if area.cursorLine < area.lines.len - 1:
          area.cursorLine += 1
          let lineLen = area.lines[area.cursorLine].runeLen
          area.cursorCol = min(area.cursorCol, lineLen)
        # НОВОЕ: обновляем выделение при Shift
        if isShift:
          updateSelection(area, area.cursorLine, area.cursorCol)
        else:
          clearSelection(area)
        return true
      
      of SDLK_HOME:
        area.cursorCol = 0
        # НОВОЕ: обновляем выделение при Shift
        if isShift:
          updateSelection(area, area.cursorLine, area.cursorCol)
        else:
          clearSelection(area)
        return true
      
      of SDLK_END:
        area.cursorCol = area.lines[area.cursorLine].runeLen
        # НОВОЕ: обновляем выделение при Shift
        if isShift:
          updateSelection(area, area.cursorLine, area.cursorCol)
        else:
          clearSelection(area)
        return true
      
      of SDLK_PAGEUP:
        # Листаем вверх на экран
        let linesPerPage = (area.rect.h.int - gui.theme.padding * 2) div (getTextSize(gui.theme.font, "Ag").h + 2)
        area.cursorLine = max(0, area.cursorLine - linesPerPage)
        area.cursorCol = min(area.cursorCol, area.lines[area.cursorLine].runeLen)
        return true
      
      of SDLK_PAGEDOWN:
        # Листаем вниз на экран
        let linesPerPage = (area.rect.h.int - gui.theme.padding * 2) div (getTextSize(gui.theme.font, "Ag").h + 2)
        area.cursorLine = min(area.lines.len - 1, area.cursorLine + linesPerPage)
        area.cursorCol = min(area.cursorCol, area.lines[area.cursorLine].runeLen)
        return true
      
      else:
        discard
  
  else:
    discard
  
  return false

# =============================================================================
# Чекбокс
# =============================================================================

proc createCheckBox*(id: string, x, y: int, text: string, checked: bool = false): CheckBox =
  ## Создать чекбокс
  let boxSize = 20
  result = CheckBox(
    id: id,
    rect: initRect(x, y, boxSize, boxSize),
    text: text,
    checked: checked,
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    textColor: initColor(0, 0, 0),
    bgColor: initColor(255, 255, 255),
    checkColor: initColor(0, 120, 215),
    borderColor: initColor(122, 122, 122)
  )

proc renderCheckBox*(gui: GuiManager, cb: CheckBox) =
  ## Отрендерить чекбокс
  if not cb.visible:
    return
  
  # Фон чекбокса
  renderFillRect(gui.renderer, cb.rect, cb.bgColor)
  
  # Граница
  var borderColor = cb.borderColor
  if cb.state == wsHover:
    borderColor = gui.theme.accentColor
  renderRect(gui.renderer, cb.rect, borderColor, gui.theme.borderWidth)
  
  # Галочка
  if cb.checked:
    let padding = 4
    let checkRect = initRect(
      cb.rect.x.int + padding,
      cb.rect.y.int + padding,
      cb.rect.w.int - padding * 2,
      cb.rect.h.int - padding * 2
    )
    renderFillRect(gui.renderer, checkRect, cb.checkColor)
  
  # Текст
  if cb.text.len > 0:
    let textX = cb.rect.x.int + cb.rect.w.int + gui.theme.padding
    let textY = cb.rect.y.int + (cb.rect.h.int - getTextSize(gui.theme.font, cb.text).h) div 2
    discard renderText(gui.renderer, gui.theme.font, cb.text, textX, textY, cb.textColor)

proc handleCheckBoxEvent*(cb: CheckBox, event: ptr SdlEvent): bool =
  ## Обработать событие для чекбокса
  if not cb.enabled or not cb.visible:
    return false
  
  case event.type:
  of SDL_EVENT_MOUSE_MOTION:
    let x = event.motion.x
    let y = event.motion.y
    if pointInRect(x, y, cb.rect):
      cb.state = wsHover
      return true
    else:
      cb.state = wsNormal
  
  of SDL_EVENT_MOUSE_BUTTON_DOWN:
    let x = event.button.x
    let y = event.button.y
    if pointInRect(x, y, cb.rect):
      cb.checked = not cb.checked
      if cb.onChange != nil:
        cb.onChange(cb, cb.checked)
      return true
  
  else:
    discard
  
  return false

# =============================================================================
# Радиокнопка
# =============================================================================

proc createRadioButton*(id: string, x, y: int, text: string, group: string): RadioButton =
  ## Создать радиокнопку
  let boxSize = 20
  result = RadioButton(
    id: id,
    rect: initRect(x, y, boxSize, boxSize),
    text: text,
    checked: false,
    group: group,
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    textColor: initColor(0, 0, 0),
    bgColor: initColor(255, 255, 255),
    checkColor: initColor(0, 120, 215),
    borderColor: initColor(122, 122, 122)
  )

proc renderRadioButton*(gui: GuiManager, rb: RadioButton) =
  ## Отрендерить радиокнопку
  if not rb.visible:
    return
  
  # Фон (круг)
  let centerX = rb.rect.x.int + rb.rect.w.int div 2
  let centerY = rb.rect.y.int + rb.rect.h.int div 2
  let radius = rb.rect.w.int div 2
  
  # Рисуем круг через много линий
  renderFillRect(gui.renderer, rb.rect, rb.bgColor)
  
  # Граница круга
  var borderColor = rb.borderColor
  if rb.state == wsHover:
    borderColor = gui.theme.accentColor
  renderRect(gui.renderer, rb.rect, borderColor, gui.theme.borderWidth)
  
  # Точка если выбрана
  if rb.checked:
    let innerRadius = radius - 4
    let innerRect = initRect(
      centerX - innerRadius,
      centerY - innerRadius,
      innerRadius * 2,
      innerRadius * 2
    )
    renderFillRect(gui.renderer, innerRect, rb.checkColor)
  
  # Текст
  if rb.text.len > 0:
    let textX = rb.rect.x.int + rb.rect.w.int + gui.theme.padding
    let textY = rb.rect.y.int + (rb.rect.h.int - getTextSize(gui.theme.font, rb.text).h) div 2
    discard renderText(gui.renderer, gui.theme.font, rb.text, textX, textY, rb.textColor)

proc handleRadioButtonEvent*(gui: GuiManager, rb: RadioButton, event: ptr SdlEvent): bool =
  ## Обработать событие для радиокнопки
  if not rb.enabled or not rb.visible:
    return false
  
  case event.type:
  of SDL_EVENT_MOUSE_MOTION:
    let x = event.motion.x
    let y = event.motion.y
    if pointInRect(x, y, rb.rect):
      rb.state = wsHover
      return true
    else:
      rb.state = wsNormal
  
  of SDL_EVENT_MOUSE_BUTTON_DOWN:
    let x = event.button.x
    let y = event.button.y
    if pointInRect(x, y, rb.rect):
      # Снять выбор со всех в группе
      if gui.radioGroups.hasKey(rb.group):
        for other in gui.radioGroups[rb.group]:
          other.checked = false
      
      rb.checked = true
      if rb.onChange != nil:
        rb.onChange(rb, rb.checked)
      return true
  
  else:
    discard
  
  return false

proc registerRadioButton*(gui: GuiManager, rb: RadioButton) =
  ## Зарегистрировать радиокнопку в группе
  if not gui.radioGroups.hasKey(rb.group):
    gui.radioGroups[rb.group] = @[]
  gui.radioGroups[rb.group].add(rb)

# =============================================================================
# Слайдер
# =============================================================================

proc createSlider*(id: string, x, y, w, h: int, minVal, maxVal: float, 
                  orientation: Alignment = alignLeft): Slider =
  ## Создать слайдер
  result = Slider(
    id: id,
    rect: initRect(x, y, w, h),
    minValue: minVal,
    maxValue: maxVal,
    value: minVal,
    step: 0.0,
    orientation: orientation,
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    trackColor: initColor(200, 200, 200),
    thumbColor: initColor(0, 120, 215),
    fillColor: initColor(100, 180, 255)
  )
  
  # Инициализация thumbRect
  let thumbSize = if orientation == alignLeft: h else: w
  result.thumbRect = initRect(x, y, thumbSize, thumbSize)

proc updateSliderThumb*(slider: Slider) =
  ## Обновить позицию бегунка
  let range = slider.maxValue - slider.minValue
  let ratio = (slider.value - slider.minValue) / range
  
  if slider.orientation == alignLeft: # horizontal
    let trackWidth = slider.rect.w.int - slider.thumbRect.w.int
    slider.thumbRect.x = (slider.rect.x.int + (trackWidth.float * ratio).int).cint
    slider.thumbRect.y = slider.rect.y
  else: # vertical
    let trackHeight = slider.rect.h.int - slider.thumbRect.h.int
    slider.thumbRect.y = (slider.rect.y.int + (trackHeight.float * ratio).int).cint
    slider.thumbRect.x = slider.rect.x

proc renderSlider*(gui: GuiManager, slider: Slider) =
  ## Отрендерить слайдер
  if not slider.visible:
    return
  
  updateSliderThumb(slider)
  
  if slider.orientation == alignLeft: # horizontal
    # Трек
    let trackY = slider.rect.y.int + slider.rect.h.int div 2 - 2
    let trackRect = initRect(slider.rect.x.int, trackY, slider.rect.w.int, 4)
    renderFillRect(gui.renderer, trackRect, slider.trackColor)
    
    # Заполненная часть
    let fillWidth = slider.thumbRect.x.int - slider.rect.x.int + slider.thumbRect.w.int div 2
    if fillWidth > 0:
      let fillRect = initRect(slider.rect.x.int, trackY, fillWidth, 4)
      renderFillRect(gui.renderer, fillRect, slider.fillColor)
  else: # vertical
    # Трек
    let trackX = slider.rect.x.int + slider.rect.w.int div 2 - 2
    let trackRect = initRect(trackX, slider.rect.y.int, 4, slider.rect.h.int)
    renderFillRect(gui.renderer, trackRect, slider.trackColor)
    
    # Заполненная часть
    let fillHeight = slider.thumbRect.y.int - slider.rect.y.int + slider.thumbRect.h.int div 2
    if fillHeight > 0:
      let fillRect = initRect(trackX, slider.rect.y.int, 4, fillHeight)
      renderFillRect(gui.renderer, fillRect, slider.fillColor)
  
  # Бегунок
  renderFillRect(gui.renderer, slider.thumbRect, slider.thumbColor)
  renderRect(gui.renderer, slider.thumbRect, initColor(255, 255, 255), 2)

proc handleSliderEvent*(slider: Slider, event: ptr SdlEvent): bool =
  ## Обработать событие для слайдера
  if not slider.enabled or not slider.visible:
    return false
  
  # Обновляем позицию бегунка перед обработкой событий
  updateSliderThumb(slider)
  
  case event.type:
  of SDL_EVENT_MOUSE_BUTTON_DOWN:
    let x = event.button.x
    let y = event.button.y
    if pointInRect(x, y, slider.thumbRect) or pointInRect(x, y, slider.rect):
      slider.state = wsPressed
      return true
  
  of SDL_EVENT_MOUSE_BUTTON_UP:
    if slider.state == wsPressed:
      slider.state = wsNormal
      return true
  
  of SDL_EVENT_MOUSE_MOTION:
    if slider.state == wsPressed:
      let range = slider.maxValue - slider.minValue
      var ratio: float
      
      if slider.orientation == alignLeft: # horizontal
        let trackWidth = slider.rect.w.int - slider.thumbRect.w.int
        let mouseX = event.motion.x.int - slider.rect.x.int - slider.thumbRect.w.int div 2
        ratio = mouseX.float / trackWidth.float
      else: # vertical
        let trackHeight = slider.rect.h.int - slider.thumbRect.h.int
        let mouseY = event.motion.y.int - slider.rect.y.int - slider.thumbRect.h.int div 2
        ratio = mouseY.float / trackHeight.float
      
      ratio = max(0.0, min(1.0, ratio))
      let newValue = slider.minValue + range * ratio
      
      if slider.step > 0:
        slider.value = round(newValue / slider.step) * slider.step
      else:
        slider.value = newValue
      
      slider.value = max(slider.minValue, min(slider.maxValue, slider.value))
      
      if slider.onChange != nil:
        slider.onChange(slider, slider.value)
      
      return true
  
  else:
    discard
  
  return false

# =============================================================================
# Прогресс-бар
# =============================================================================

proc createProgressBar*(id: string, x, y, w, h: int, minVal, maxVal: float): ProgressBar =
  ## Создать прогресс-бар
  result = ProgressBar(
    id: id,
    rect: initRect(x, y, w, h),
    minValue: minVal,
    maxValue: maxVal,
    value: minVal,
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    bgColor: initColor(230, 230, 230),
    fillColor: initColor(6, 176, 37),
    borderColor: initColor(180, 180, 180),
    showText: true,
    textColor: initColor(0, 0, 0)
  )

proc renderProgressBar*(gui: GuiManager, pb: ProgressBar) =
  ## Отрендерить прогресс-бар
  if not pb.visible:
    return
  
  # Фон
  renderFillRect(gui.renderer, pb.rect, pb.bgColor)
  
  # Заполнение
  let range = pb.maxValue - pb.minValue
  let ratio = (pb.value - pb.minValue) / range
  let fillWidth = (pb.rect.w.float * ratio).int
  
  if fillWidth > 0:
    let fillRect = initRect(pb.rect.x.int, pb.rect.y.int, fillWidth, pb.rect.h.int)
    renderFillRect(gui.renderer, fillRect, pb.fillColor)
  
  # Граница
  renderRect(gui.renderer, pb.rect, pb.borderColor, gui.theme.borderWidth)
  
  # Текст процентов
  if pb.showText:
    let percent = (ratio * 100).int
    let text = $percent & "%"
    let textSize = getTextSize(gui.theme.font, text)
    let textX = pb.rect.x.int + (pb.rect.w.int - textSize.w) div 2
    let textY = pb.rect.y.int + (pb.rect.h.int - textSize.h) div 2
    discard renderText(gui.renderer, gui.theme.font, text, textX, textY, pb.textColor)

# =============================================================================
# Метка (Label)
# =============================================================================

proc createLabel*(id: string, x, y, w, h: int, text: string): Label =
  ## Создать метку
  result = Label(
    id: id,
    rect: initRect(x, y, w, h),
    text: text,
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    textColor: initColor(0, 0, 0),
    bgColor: initColor(240, 240, 240, 0), # прозрачный фон
    textAlign: alignLeft,
    wordWrap: false
  )

proc renderLabel*(gui: GuiManager, label: Label) =
  ## Отрендерить метку
  if not label.visible:
    return
  
  # Фон (если не прозрачный)
  if label.bgColor.a > 0:
    renderFillRect(gui.renderer, label.rect, label.bgColor)
  
  # Текст
  if label.text.len > 0:
    var textX = label.rect.x.int
    let textY = label.rect.y.int
    
    let textSize = getTextSize(gui.theme.font, label.text)
    
    case label.textAlign:
    of alignCenter:
      textX = label.rect.x.int + (label.rect.w.int - textSize.w) div 2
    of alignRight:
      textX = label.rect.x.int + label.rect.w.int - textSize.w
    else:
      discard
    
    # TODO: поддержка word wrap
    discard renderText(gui.renderer, gui.theme.font, label.text, textX, textY, label.textColor)

# =============================================================================
# Панель
# =============================================================================

proc createPanel*(id: string, x, y, w, h: int): Panel =
  ## Создать панель
  result = Panel(
    id: id,
    rect: initRect(x, y, w, h),
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    bgColor: initColor(240, 240, 240),
    borderColor: initColor(180, 180, 180),
    scrollX: 0,
    scrollY: 0,
    scrollable: false
  )

# Forward declarations для функций рендеринга, используемых в renderPanel
proc renderListBox*(gui: GuiManager, list: ListBox)
proc renderComboBox*(gui: GuiManager, combo: ComboBox)
proc renderSpinBox*(gui: GuiManager, spin: SpinBox)
proc renderTabControl*(gui: GuiManager, tc: TabControl)

proc renderPanel*(gui: GuiManager, panel: Panel) =
  ## Отрендерить панель
  if not panel.visible:
    return
  
  # Фон
  renderFillRect(gui.renderer, panel.rect, panel.bgColor)
  
  # Граница
  renderRect(gui.renderer, panel.rect, panel.borderColor, gui.theme.borderWidth)
  
  # Рендерим дочерние виджеты с учетом позиции панели
  for child in panel.children:
    if not child.visible:
      continue
    
    # Сохраняем оригинальные координаты
    let origX = child.rect.x
    let origY = child.rect.y
    
    # Применяем смещение панели
    child.rect.x = panel.rect.x + origX
    child.rect.y = panel.rect.y + origY
    
    # Рендеринг в зависимости от типа виджета
    if child of Button:
      renderButton(gui, Button(child))
    elif child of TextField:
      renderTextField(gui, TextField(child))
    elif child of TextArea:
      renderTextArea(gui, TextArea(child))
    elif child of CheckBox:
      renderCheckBox(gui, CheckBox(child))
    elif child of RadioButton:
      renderRadioButton(gui, RadioButton(child))
    elif child of Slider:
      renderSlider(gui, Slider(child))
    elif child of ProgressBar:
      renderProgressBar(gui, ProgressBar(child))
    elif child of Label:
      renderLabel(gui, Label(child))
    elif child of Panel:
      # Рекурсивная отрисовка вложенных панелей
      renderPanel(gui, Panel(child))
    elif child of ListBox:
      renderListBox(gui, ListBox(child))
    elif child of ComboBox:
      # Рендерим ComboBox, но БЕЗ выпадающего списка
      let combo = ComboBox(child)
      if not combo.visible:
        child.rect.x = origX
        child.rect.y = origY
        continue
      
      # Основное поле
      var bgColor = combo.bgColor
      if combo.state == wsHover or combo.isOpen:
        bgColor = combo.hoverColor
      
      renderFillRect(gui.renderer, combo.rect, bgColor)
      renderRect(gui.renderer, combo.rect, combo.borderColor, gui.theme.borderWidth)
      
      # Текст выбранного элемента
      if combo.selectedIndex >= 0 and combo.selectedIndex < combo.items.len:
        let text = combo.items[combo.selectedIndex]
        let textSize = getTextSize(gui.theme.font, text)
        let textX = combo.rect.x.int + gui.theme.padding
        let textY = combo.rect.y.int + (combo.rect.h.int - textSize.h) div 2
        discard renderText(gui.renderer, gui.theme.font, text, textX, textY, combo.textColor)
      
      # Стрелка вниз
      let arrowSize = 8
      let arrowX = combo.rect.x.int + combo.rect.w.int - arrowSize - gui.theme.padding
      let arrowY = combo.rect.y.int + (combo.rect.h.int - arrowSize) div 2
      
      # Рисуем треугольник
      setRenderColor(gui.renderer, combo.textColor)
      for i in 0..<arrowSize:
        let y = arrowY + i
        let x1 = arrowX + (arrowSize - i) div 2
        let x2 = arrowX + arrowSize - (arrowSize - i) div 2
        discard SDL_RenderLine(gui.renderer, x1.cfloat, y.cfloat, x2.cfloat, y.cfloat)
      
      # Выпадающий список откладывается на потом (рендерится в renderGui)
    elif child of SpinBox:
      renderSpinBox(gui, SpinBox(child))
    elif child of TabControl:
      renderTabControl(gui, TabControl(child))
    
    # Восстанавливаем оригинальные координаты
    child.rect.x = origX
    child.rect.y = origY


proc addChild*(panel: Panel, widget: Widget) =
  ## Добавить дочерний виджет в панель
  ## Координаты виджета остаются относительно панели
  widget.parent = panel
  panel.children.add(widget)

proc removeChild*(panel: Panel, widget: Widget) =
  ## Удалить дочерний виджет из панели
  for i in 0..<panel.children.len:
    if panel.children[i] == widget:
      widget.parent = nil
      panel.children.delete(i)
      break

proc clearChildren*(panel: Panel) =
  ## Удалить все дочерние виджеты из панели
  for child in panel.children:
    child.parent = nil
  panel.children = @[]

proc getChildById*(panel: Panel, id: string): Widget =
  ## Найти дочерний виджет по ID
  for child in panel.children:
    if child.id == id:
      return child
  return nil

# Forward declarations для обработчиков событий, объявленных после handlePanelEvent
proc handleComboBoxEvent*(gui: GuiManager, combo: ComboBox, event: ptr SdlEvent): bool
proc handleSpinBoxEvent*(gui: GuiManager, spin: SpinBox, event: ptr SdlEvent): bool

proc handlePanelEvent*(gui: GuiManager, panel: Panel, event: ptr SdlEvent): bool =
  ## Обработать событие для панели и её дочерних виджетов
  if not panel.visible or not panel.enabled:
    return false
  
  # Передаём события дочерним виджетам (в обратном порядке, чтобы верхние обрабатывались первыми)
  for i in countdown(panel.children.len - 1, 0):
    let child = panel.children[i]
    if not child.visible or not child.enabled:
      continue
    
    # Сохраняем оригинальные координаты и применяем смещение
    let origX = child.rect.x
    let origY = child.rect.y
    child.rect.x = panel.rect.x + origX
    child.rect.y = panel.rect.y + origY
    
    # Проверяем тип дочернего виджета и вызываем соответствующий обработчик
    var handled = false
    
    if child of Button:
      let btn = Button(child)
      if event.type == SDL_EVENT_MOUSE_BUTTON_DOWN:
        let mouseX = event.button.x
        let mouseY = event.button.y
        if pointInRect(mouseX, mouseY, btn.rect):
          if not btn.onClick.isNil:
            btn.onClick(btn)
          handled = true
    
    elif child of TextField:
      handled = handleTextFieldEvent(gui, TextField(child), event)
    
    elif child of TextArea:
      handled = handleTextAreaEvent(gui, TextArea(child), event)
    
    elif child of CheckBox:
      let cb = CheckBox(child)
      if event.type == SDL_EVENT_MOUSE_BUTTON_DOWN:
        let mouseX = event.button.x
        let mouseY = event.button.y
        if pointInRect(mouseX, mouseY, cb.rect):
          cb.checked = not cb.checked
          if not cb.onChange.isNil:
            cb.onChange(cb, cb.checked)
          handled = true
    
    elif child of RadioButton:
      handled = handleRadioButtonEvent(gui, RadioButton(child), event)
    
    elif child of Slider:
      handled = handleSliderEvent(Slider(child), event)
    
    elif child of ComboBox:
      handled = handleComboBoxEvent(gui, ComboBox(child), event)
    
    elif child of SpinBox:
      handled = handleSpinBoxEvent(gui, SpinBox(child), event)
    
    elif child of ListBox:
      let lb = ListBox(child)
      if event.type == SDL_EVENT_MOUSE_BUTTON_DOWN:
        let mouseX = event.button.x
        let mouseY = event.button.y
        if pointInRect(mouseX, mouseY, lb.rect):
          let relY = mouseY.int - lb.rect.y.int - lb.scrollOffset
          let index = relY div lb.itemHeight
          if index >= 0 and index < lb.items.len:
            lb.selectedIndex = index
            if not lb.onSelect.isNil:
              lb.onSelect(lb, index)
          handled = true
    
    elif child of Panel:
      # Рекурсивная обработка вложенных панелей
      handled = handlePanelEvent(gui, Panel(child), event)
    
    # Восстанавливаем оригинальные координаты
    child.rect.x = origX
    child.rect.y = origY
    
    if handled:
      return true
  
  return false


# =============================================================================
# Список
# =============================================================================

proc createListBox*(id: string, x, y, w, h: int): ListBox =
  ## Создать список
  result = ListBox(
    id: id,
    rect: initRect(x, y, w, h),
    items: @[],
    selectedIndex: -1,
    itemHeight: 24,
    scrollOffset: 0,
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    textColor: initColor(0, 0, 0),
    selectedColor: initColor(0, 120, 215),
    hoverColor: initColor(229, 243, 255),
    bgColor: initColor(255, 255, 255),
    borderColor: initColor(122, 122, 122)
  )

proc renderListBox*(gui: GuiManager, list: ListBox) =
  ## Отрендерить список
  if not list.visible:
    return
  
  # Фон
  renderFillRect(gui.renderer, list.rect, list.bgColor)
  
  # Граница
  renderRect(gui.renderer, list.rect, list.borderColor, gui.theme.borderWidth)
  
  # Установить область отсечения
  var clipRect = SdlRect(
    x: (list.rect.x + 1).cint,
    y: (list.rect.y + 1).cint,
    w: (list.rect.w - 2).cint,
    h: (list.rect.h - 2).cint
  )
  discard SDL_SetRenderClipRect(gui.renderer, addr clipRect)
  
  # Элементы
  let startIndex = list.scrollOffset div list.itemHeight
  let visibleItems = (list.rect.h.int div list.itemHeight) + 1
  let endIndex = min(startIndex + visibleItems, list.items.len)
  
  for i in startIndex..<endIndex:
    let itemY = list.rect.y.int + (i - startIndex) * list.itemHeight - 
                (list.scrollOffset mod list.itemHeight)
    let itemRect = initRect(list.rect.x.int + 1, itemY, list.rect.w.int - 2, list.itemHeight)
    
    # Фон элемента
    if i == list.selectedIndex:
      renderFillRect(gui.renderer, itemRect, list.selectedColor)
    # TODO: hover состояние
    
    # Текст
    let textX = itemRect.x.int + gui.theme.padding
    let textY = itemRect.y.int + (list.itemHeight - getTextSize(gui.theme.font, list.items[i]).h) div 2
    
    var textColor = list.textColor
    if i == list.selectedIndex:
      textColor = initColor(255, 255, 255)
    
    discard renderText(gui.renderer, gui.theme.font, list.items[i], textX, textY, textColor)
  
  discard SDL_SetRenderClipRect(gui.renderer, nil)

proc handleListBoxEvent*(list: ListBox, event: ptr SdlEvent): bool =
  ## Обработать событие для списка
  if not list.enabled or not list.visible:
    return false
  
  case event.type:
  of SDL_EVENT_MOUSE_BUTTON_DOWN:
    let x = event.button.x
    let y = event.button.y
    if pointInRect(x, y, list.rect):
      let relY = y.int - list.rect.y.int + list.scrollOffset
      let index = relY div list.itemHeight
      if index >= 0 and index < list.items.len:
        list.selectedIndex = index
        if list.onSelect != nil:
          list.onSelect(list, index)
        return true
  
  of SDL_EVENT_MOUSE_WHEEL:
    if pointInRect(event.wheel.mouse_x, event.wheel.mouse_y, list.rect):
      list.scrollOffset -= (event.wheel.y * list.itemHeight.float).int
      let maxScroll = max(0, list.items.len * list.itemHeight - list.rect.h.int)
      list.scrollOffset = max(0, min(list.scrollOffset, maxScroll))
      return true
  
  else:
    discard
  
  return false

# =============================================================================

# =============================================================================
# ComboBox (Выпадающий список)
# =============================================================================

proc createComboBox*(id: string, x, y, w, h: int): ComboBox =
  ## Создать выпадающий список
  result = ComboBox(
    id: id,
    rect: initRect(x, y, w, h),
    items: @[],
    selectedIndex: -1,
    isOpen: false,
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    textColor: initColor(0, 0, 0),
    bgColor: initColor(255, 255, 255),
    borderColor: initColor(122, 122, 122),
    hoverColor: initColor(229, 243, 255),
    selectedColor: initColor(0, 120, 215),
    dropdownHeight: 150,
    hoveredIndex: -1
  )

proc renderComboBox*(gui: GuiManager, combo: ComboBox) =
  ## Отрендерить выпадающий список
  if not combo.visible:
    return
  
  # Основное поле
  var bgColor = combo.bgColor
  if combo.state == wsHover or combo.isOpen:
    bgColor = combo.hoverColor
  
  renderFillRect(gui.renderer, combo.rect, bgColor)
  renderRect(gui.renderer, combo.rect, combo.borderColor, gui.theme.borderWidth)
  
  # Текст выбранного элемента
  if combo.selectedIndex >= 0 and combo.selectedIndex < combo.items.len:
    let text = combo.items[combo.selectedIndex]
    let textSize = getTextSize(gui.theme.font, text)
    let textX = combo.rect.x.int + gui.theme.padding
    let textY = combo.rect.y.int + (combo.rect.h.int - textSize.h) div 2
    discard renderText(gui.renderer, gui.theme.font, text, textX, textY, combo.textColor)
  
  # Стрелка вниз
  let arrowSize = 8
  let arrowX = combo.rect.x.int + combo.rect.w.int - arrowSize - gui.theme.padding
  let arrowY = combo.rect.y.int + (combo.rect.h.int - arrowSize) div 2
  
  # Рисуем треугольник
  setRenderColor(gui.renderer, combo.textColor)
  for i in 0..<arrowSize:
    let y = arrowY + i
    let x1 = arrowX + (arrowSize - i) div 2
    let x2 = arrowX + arrowSize - (arrowSize - i) div 2
    discard SDL_RenderLine(gui.renderer, x1.cfloat, y.cfloat, x2.cfloat, y.cfloat)
  
  # Выпадающий список
  if combo.isOpen and combo.items.len > 0:
    let itemHeight = max(20, combo.rect.h.int)
    let maxItems = min(combo.items.len, combo.dropdownHeight div itemHeight)
    let dropHeight = maxItems * itemHeight
    
    let dropRect = initRect(
      combo.rect.x.int,
      combo.rect.y.int + combo.rect.h.int,
      combo.rect.w.int,
      dropHeight
    )
    
    # Фон списка
    renderFillRect(gui.renderer, dropRect, combo.bgColor)
    renderRect(gui.renderer, dropRect, combo.borderColor, gui.theme.borderWidth)
    
    # Элементы
    for i in 0..<maxItems:
      let itemY = dropRect.y.int + i * itemHeight
      let itemRect = initRect(dropRect.x.int, itemY, dropRect.w.int, itemHeight)
      
      # Подсветка наведённого элемента
      if i == combo.hoveredIndex:
        renderFillRect(gui.renderer, itemRect, combo.hoverColor)
        # Добавляем толстый яркий зелёный контур для наведённого элемента
        let borderColor = initColor(0, 255, 0)  # Яркий зелёный цвет
        renderRect(gui.renderer, itemRect, borderColor, 2)  # Толщина 2 пикселя
      elif i == combo.selectedIndex:
        renderFillRect(gui.renderer, itemRect, combo.selectedColor)
        renderRect(gui.renderer, itemRect, combo.selectedColor, 1)
      
      # Текст элемента
      let text = combo.items[i]
      let textSize = getTextSize(gui.theme.font, text)
      let textX = itemRect.x.int + gui.theme.padding
      let textY = itemY + (itemHeight - textSize.h) div 2
      let textColor = if i == combo.selectedIndex: initColor(255, 255, 255) else: combo.textColor
      discard renderText(gui.renderer, gui.theme.font, text, textX, textY, textColor)

proc handleComboBoxEvent*(gui: GuiManager, combo: ComboBox, event: ptr SdlEvent): bool =
  ## Обработать событие для выпадающего списка
  if not combo.visible or not combo.enabled:
    return false
  
  case event.type:
  of SDL_EVENT_MOUSE_MOTION:
    let x = event.motion.x
    let y = event.motion.y
    
    # Сначала проверяем наведение на выпадающий список
    if combo.isOpen:
      let itemHeight = max(20, combo.rect.h.int)
      let maxItems = min(combo.items.len, combo.dropdownHeight div itemHeight)
      let dropHeight = maxItems * itemHeight
      let dropY = combo.rect.y.int + combo.rect.h.int
      let dropX = combo.rect.x.int
      let dropW = combo.rect.w.int
      
      # Проверяем, находится ли курсор над выпадающим списком
      if x.int >= dropX and x.int < dropX + dropW and
         y.int >= dropY and y.int < dropY + dropHeight:
        let relY = y.int - dropY
        let index = relY div itemHeight
        if index >= 0 and index < combo.items.len:
          combo.hoveredIndex = index
        else:
          combo.hoveredIndex = -1
        return true
      else:
        combo.hoveredIndex = -1
    
    # Теперь проверяем наведение на основное поле
    if pointInRect(x, y, combo.rect):
      combo.state = wsHover
      return true
    else:
      if combo.state == wsHover:
        combo.state = wsNormal
      combo.hoveredIndex = -1
  
  of SDL_EVENT_MOUSE_BUTTON_DOWN:
    let x = event.button.x
    let y = event.button.y
    
    # Клик по основному полю
    if pointInRect(x, y, combo.rect):
      combo.isOpen = not combo.isOpen
      if combo.isOpen:
        gui.setFocus(combo)
      return true
    
    # Клик по выпадающему списку
    if combo.isOpen:
      let itemHeight = max(20, combo.rect.h.int)
      let maxItems = min(combo.items.len, combo.dropdownHeight div itemHeight)
      let dropHeight = maxItems * itemHeight
      let dropY = combo.rect.y.int + combo.rect.h.int
      
      if x.int >= combo.rect.x.int and x.int <= (combo.rect.x + combo.rect.w).int and
         y.int >= dropY and y.int < dropY + dropHeight:
        let relY = y.int - dropY
        let index = relY div itemHeight
        
        if index >= 0 and index < combo.items.len:
          combo.selectedIndex = index
          combo.isOpen = false
          if combo.onSelect != nil:
            combo.onSelect(combo, index)
          return true
      else:
        # Клик вне списка - закрываем
        combo.isOpen = false
    
    return false
  
  of SDL_EVENT_KEY_DOWN:
    if combo.state == wsFocused and combo.isOpen:
      case event.key.key:
      of SDLK_ESCAPE:
        combo.isOpen = false
        return true
      of SDLK_RETURN, SDLK_KP_ENTER:
        if combo.hoveredIndex >= 0:
          combo.selectedIndex = combo.hoveredIndex
          combo.isOpen = false
          if combo.onSelect != nil:
            combo.onSelect(combo, combo.selectedIndex)
        return true
      of SDLK_UP:
        if combo.hoveredIndex > 0:
          combo.hoveredIndex -= 1
        else:
          combo.hoveredIndex = combo.items.len - 1
        return true
      of SDLK_DOWN:
        if combo.hoveredIndex < combo.items.len - 1:
          combo.hoveredIndex += 1
        else:
          combo.hoveredIndex = 0
        return true
      else:
        discard
  
  else:
    discard
  
  return false

# =============================================================================
# SpinBox (Числовое поле со стрелками)
# =============================================================================

proc createSpinBox*(id: string, x, y, w, h: int, minVal, maxVal: float, decimals: int = 0): SpinBox =
  ## Создать числовое поле со стрелками
  result = SpinBox(
    id: id,
    rect: initRect(x, y, w, h),
    value: minVal,
    minValue: minVal,
    maxValue: maxVal,
    step: if decimals > 0: 0.1 else: 1.0,
    decimals: decimals,
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    textColor: initColor(0, 0, 0),
    bgColor: initColor(255, 255, 255),
    borderColor: initColor(122, 122, 122),
    buttonColor: initColor(240, 240, 240),
    upPressed: false,
    downPressed: false
  )

proc renderSpinBox*(gui: GuiManager, spin: SpinBox) =
  ## Отрендерить SpinBox
  if not spin.visible:
    return
  
  let buttonWidth = 16
  let textRect = initRect(
    spin.rect.x.int,
    spin.rect.y.int,
    spin.rect.w.int - buttonWidth,
    spin.rect.h.int
  )
  
  # Поле для текста
  renderFillRect(gui.renderer, textRect, spin.bgColor)
  renderRect(gui.renderer, textRect, spin.borderColor, gui.theme.borderWidth)
  
  # Текст значения
  let valueStr = if spin.decimals > 0:
    formatFloat(spin.value, ffDecimal, spin.decimals)
  else:
    $spin.value.int
  
  let textSize = getTextSize(gui.theme.font, valueStr)
  let textX = textRect.x.int + (textRect.w.int - textSize.w) div 2
  let textY = textRect.y.int + (textRect.h.int - textSize.h) div 2
  discard renderText(gui.renderer, gui.theme.font, valueStr, textX, textY, spin.textColor)
  
  # Кнопки вверх/вниз
  let btnHeight = spin.rect.h.int div 2
  let upRect = initRect(
    spin.rect.x.int + spin.rect.w.int - buttonWidth,
    spin.rect.y.int,
    buttonWidth,
    btnHeight
  )
  let downRect = initRect(
    spin.rect.x.int + spin.rect.w.int - buttonWidth,
    spin.rect.y.int + btnHeight,
    buttonWidth,
    spin.rect.h.int - btnHeight
  )
  
  # Кнопка вверх
  let upColor = if spin.upPressed: gui.theme.activeColor else: spin.buttonColor
  renderFillRect(gui.renderer, upRect, upColor)
  renderRect(gui.renderer, upRect, spin.borderColor, gui.theme.borderWidth)
  
  # Стрелка вверх
  let upArrowSize = 6
  let upArrowX = upRect.x.int + (upRect.w.int - upArrowSize) div 2
  let upArrowY = upRect.y.int + (upRect.h.int - upArrowSize div 2) div 2
  setRenderColor(gui.renderer, spin.textColor)
  for i in 0..<upArrowSize div 2:
    let y = upArrowY + upArrowSize div 2 - i
    let x1 = upArrowX + i
    let x2 = upArrowX + upArrowSize - i
    discard SDL_RenderLine(gui.renderer, x1.cfloat, y.cfloat, x2.cfloat, y.cfloat)
  
  # Кнопка вниз
  let downColor = if spin.downPressed: gui.theme.activeColor else: spin.buttonColor
  renderFillRect(gui.renderer, downRect, downColor)
  renderRect(gui.renderer, downRect, spin.borderColor, gui.theme.borderWidth)
  
  # Стрелка вниз
  let downArrowSize = 6
  let downArrowX = downRect.x.int + (downRect.w.int - downArrowSize) div 2
  let downArrowY = downRect.y.int + (downRect.h.int - downArrowSize div 2) div 2
  setRenderColor(gui.renderer, spin.textColor)
  for i in 0..<downArrowSize div 2:
    let y = downArrowY + i
    let x1 = downArrowX + i
    let x2 = downArrowX + downArrowSize - i
    discard SDL_RenderLine(gui.renderer, x1.cfloat, y.cfloat, x2.cfloat, y.cfloat)

proc handleSpinBoxEvent*(gui: GuiManager, spin: SpinBox, event: ptr SdlEvent): bool =
  ## Обработать событие для SpinBox
  if not spin.visible or not spin.enabled:
    return false
  
  let buttonWidth = 16
  let btnHeight = spin.rect.h.int div 2
  let upRect = initRect(
    spin.rect.x.int + spin.rect.w.int - buttonWidth,
    spin.rect.y.int,
    buttonWidth,
    btnHeight
  )
  let downRect = initRect(
    spin.rect.x.int + spin.rect.w.int - buttonWidth,
    spin.rect.y.int + btnHeight,
    buttonWidth,
    spin.rect.h.int - btnHeight
  )
  
  case event.type:
  of SDL_EVENT_MOUSE_BUTTON_DOWN:
    let x = event.button.x
    let y = event.button.y
    
    if pointInRect(x, y, upRect):
      spin.upPressed = true
      spin.value = min(spin.maxValue, spin.value + spin.step)
      if spin.onChange != nil:
        spin.onChange(spin, spin.value)
      return true
    
    if pointInRect(x, y, downRect):
      spin.downPressed = true
      spin.value = max(spin.minValue, spin.value - spin.step)
      if spin.onChange != nil:
        spin.onChange(spin, spin.value)
      return true
    
    if pointInRect(x, y, spin.rect):
      gui.setFocus(spin)
      return true
  
  of SDL_EVENT_MOUSE_BUTTON_UP:
    spin.upPressed = false
    spin.downPressed = false
  
  of SDL_EVENT_MOUSE_WHEEL:
    if spin.state == wsFocused:
      if event.wheel.y > 0:
        spin.value = min(spin.maxValue, spin.value + spin.step)
      else:
        spin.value = max(spin.minValue, spin.value - spin.step)
      if spin.onChange != nil:
        spin.onChange(spin, spin.value)
      return true
  
  of SDL_EVENT_KEY_DOWN:
    if spin.state == wsFocused:
      case event.key.key:
      of SDLK_UP:
        spin.value = min(spin.maxValue, spin.value + spin.step)
        if spin.onChange != nil:
          spin.onChange(spin, spin.value)
        return true
      of SDLK_DOWN:
        spin.value = max(spin.minValue, spin.value - spin.step)
        if spin.onChange != nil:
          spin.onChange(spin, spin.value)
        return true
      else:
        discard
  
  else:
    discard
  
  return false

# =============================================================================
# TabControl (Вкладки)
# =============================================================================

proc createTab*(title: string): Tab =
  ## Создать вкладку
  result = Tab(
    title: title,
    content: @[],
    enabled: true
  )

proc createTabControl*(id: string, x, y, w, h: int): TabControl =
  ## Создать элемент управления вкладками
  result = TabControl(
    id: id,
    rect: initRect(x, y, w, h),
    tabs: @[],
    activeTab: 0,
    tabHeight: 30,
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    tabColor: initColor(220, 220, 220),
    activeTabColor: initColor(255, 255, 255),
    textColor: initColor(0, 0, 0),
    borderColor: initColor(180, 180, 180),
    hoveredTab: -1
  )

proc addTab*(tc: TabControl, tab: Tab) =
  ## Добавить вкладку
  tc.tabs.add(tab)

proc renderTabControl*(gui: GuiManager, tc: TabControl) =
  ## Отрендерить TabControl
  if not tc.visible or tc.tabs.len == 0:
    return
  
  let tabWidth = if tc.tabs.len > 0: tc.rect.w.int div tc.tabs.len else: 100
  
  # Рендерим заголовки вкладок
  for i, tab in tc.tabs:
    let tabX = tc.rect.x.int + i * tabWidth
    let tabRect = initRect(tabX, tc.rect.y.int, tabWidth, tc.tabHeight)
    
    # Фон вкладки
    let bgColor = if i == tc.activeTab:
      tc.activeTabColor
    elif i == tc.hoveredTab:
      gui.theme.hoverColor
    else:
      tc.tabColor
    
    renderFillRect(gui.renderer, tabRect, bgColor)
    renderRect(gui.renderer, tabRect, tc.borderColor, gui.theme.borderWidth)
    
    # Текст вкладки
    let textSize = getTextSize(gui.theme.font, tab.title)
    let textX = tabX + (tabWidth - textSize.w) div 2
    let textY = tc.rect.y.int + (tc.tabHeight - textSize.h) div 2
    discard renderText(gui.renderer, gui.theme.font, tab.title, textX, textY, tc.textColor)
  
  # Область содержимого
  let contentRect = initRect(
    tc.rect.x.int,
    tc.rect.y.int + tc.tabHeight,
    tc.rect.w.int,
    tc.rect.h.int - tc.tabHeight
  )
  
  renderFillRect(gui.renderer, contentRect, tc.activeTabColor)
  renderRect(gui.renderer, contentRect, tc.borderColor, gui.theme.borderWidth)
  
  # Рендерим содержимое активной вкладки
  if tc.activeTab >= 0 and tc.activeTab < tc.tabs.len:
    let tab = tc.tabs[tc.activeTab]
    for widget in tab.content:
      if not widget.visible:
        continue
      
      # Рендерим виджеты содержимого
      if widget of Button:
        renderButton(gui, Button(widget))
      elif widget of Label:
        renderLabel(gui, Label(widget))
      elif widget of TextField:
        renderTextField(gui, TextField(widget))
      elif widget of CheckBox:
        renderCheckBox(gui, CheckBox(widget))
      # Добавьте остальные типы виджетов по необходимости

proc handleTabControlEvent*(gui: GuiManager, tc: TabControl, event: ptr SdlEvent): bool =
  ## Обработать событие для TabControl
  if not tc.visible or not tc.enabled or tc.tabs.len == 0:
    return false
  
  case event.type:
  of SDL_EVENT_MOUSE_MOTION:
    let x = event.motion.x
    let y = event.motion.y
    
    # Проверяем наведение на заголовки вкладок
    if y.int >= tc.rect.y.int and y.int < (tc.rect.y + tc.tabHeight).int:
      let tabWidth = tc.rect.w.int div tc.tabs.len
      if x.int >= tc.rect.x.int and x.int < (tc.rect.x + tc.rect.w).int:
        tc.hoveredTab = ((x.int - tc.rect.x.int)) div tabWidth
        if tc.hoveredTab >= tc.tabs.len:
          tc.hoveredTab = -1
      else:
        tc.hoveredTab = -1
    else:
      tc.hoveredTab = -1
  
  of SDL_EVENT_MOUSE_BUTTON_DOWN:
    let x = event.button.x
    let y = event.button.y
    
    # Клик по заголовку вкладки
    if y.int >= tc.rect.y.int and y.int < (tc.rect.y + tc.tabHeight).int:
      let tabWidth = tc.rect.w.int div tc.tabs.len
      if x.int >= tc.rect.x.int and x.int < (tc.rect.x + tc.rect.w).int:
        let clickedTab = ((x.int - tc.rect.x.int)) div tabWidth
        if clickedTab >= 0 and clickedTab < tc.tabs.len and tc.tabs[clickedTab].enabled:
          tc.activeTab = clickedTab
          if tc.onTabChange != nil:
            tc.onTabChange(tc, clickedTab)
          return true
  
  else:
    discard
  
  return false

# =============================================================================
# Menu (Меню)
# =============================================================================

proc createMenuItem*(text: string, onClick: proc(item: MenuItem) = nil): MenuItem =
  ## Создать элемент меню
  result = MenuItem(
    text: text,
    shortcut: "",
    enabled: true,
    checkable: false,
    checked: false,
    separator: false,
    submenu: @[],
    onClick: onClick
  )

proc createMenuSeparator*(): MenuItem =
  ## Создать разделитель меню
  result = MenuItem(
    text: "",
    enabled: false,
    separator: true,
    submenu: @[]
  )

proc createMenu*(id: string, x, y, w: int): Menu =
  ## Создать меню
  result = Menu(
    id: id,
    rect: initRect(x, y, w, 0),  # Высота вычисляется динамически
    items: @[],
    isOpen: false,
    selectedIndex: -1,
    itemHeight: 25,
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    bgColor: initColor(255, 255, 255),
    hoverColor: initColor(229, 243, 255),
    textColor: initColor(0, 0, 0),
    borderColor: initColor(160, 160, 160),
    openSubmenu: -1
  )

proc addMenuItem*(menu: Menu, item: MenuItem) =
  ## Добавить элемент в меню
  menu.items.add(item)
  # Обновляем высоту меню
  menu.rect.h = cint(menu.items.len * menu.itemHeight)

proc renderMenu*(gui: GuiManager, menu: Menu) =
  ## Отрендерить меню
  if not menu.visible or not menu.isOpen:
    return
  
  # Фон меню
  renderFillRect(gui.renderer, menu.rect, menu.bgColor)
  renderRect(gui.renderer, menu.rect, menu.borderColor, 1)
  
  # Элементы меню
  for i, item in menu.items:
    let itemY = menu.rect.y.int + i * menu.itemHeight
    let itemRect = initRect(menu.rect.x.int, itemY, menu.rect.w.int, menu.itemHeight)
    
    if item.separator:
      # Разделитель
      let lineY = itemY + menu.itemHeight div 2
      setRenderColor(gui.renderer, menu.borderColor)
      discard SDL_RenderLine(gui.renderer,
        (menu.rect.x + 5).cfloat, lineY.cfloat,
        (menu.rect.x + menu.rect.w - 5).cfloat, lineY.cfloat)
    else:
      # Подсветка наведённого элемента
      if i == menu.selectedIndex and item.enabled:
        renderFillRect(gui.renderer, itemRect, menu.hoverColor)
        # Добавляем толстый яркий зелёный контур для наведённого элемента
        let borderColor = initColor(0, 255, 0)  # Яркий зелёный цвет
        renderRect(gui.renderer, itemRect, borderColor, 2)  # Толщина 2 пикселя
      
      # Текст элемента
      let textColor = if item.enabled: menu.textColor else: initColor(150, 150, 150)
      let textSize = getTextSize(gui.theme.font, item.text)
      let textX = menu.rect.x.int + gui.theme.padding
      let textY = itemY + (menu.itemHeight - textSize.h) div 2
      discard renderText(gui.renderer, gui.theme.font, item.text, textX, textY, textColor)
      
      # Галочка для checkable элементов
      if item.checkable and item.checked:
        let checkX = menu.rect.x.int + menu.rect.w.int - 20
        let checkY = itemY + menu.itemHeight div 2
        setRenderColor(gui.renderer, menu.textColor)
        discard SDL_RenderLine(gui.renderer, (checkX).cfloat, (checkY).cfloat, (checkX + 4).cfloat, (checkY + 4).cfloat)
        discard SDL_RenderLine(gui.renderer, (checkX + 4).cfloat, (checkY + 4).cfloat, (checkX + 10).cfloat, (checkY - 4).cfloat)
      
      # Ярлык (shortcut)
      if item.shortcut.len > 0:
        let shortcutSize = getTextSize(gui.theme.font, item.shortcut)
        let shortcutX = menu.rect.x.int + menu.rect.w.int - shortcutSize.w - gui.theme.padding
        discard renderText(gui.renderer, gui.theme.font, item.shortcut, shortcutX, textY, 
                          initColor(128, 128, 128))

proc handleMenuEvent*(gui: GuiManager, menu: Menu, event: ptr SdlEvent): bool =
  ## Обработать событие для меню
  if not menu.visible or not menu.enabled:
    return false
  
  case event.type:
  of SDL_EVENT_MOUSE_MOTION:
    if not menu.isOpen:
      return false
    
    let x = event.motion.x
    let y = event.motion.y
    
    if x.int >= menu.rect.x.int and x.int < (menu.rect.x + menu.rect.w).int and
       y.int >= menu.rect.y.int and y.int < (menu.rect.y + menu.rect.h).int:
      let relY = y.int - menu.rect.y.int
      let index = relY div menu.itemHeight
      if index >= 0 and index < menu.items.len and not menu.items[index].separator:
        menu.selectedIndex = index
      return true
    else:
      menu.selectedIndex = -1
  
  of SDL_EVENT_MOUSE_BUTTON_DOWN:
    let x = event.button.x
    let y = event.button.y
    
    if not menu.isOpen:
      # Открываем меню при клике на область
      if pointInRect(x, y, menu.rect):
        menu.isOpen = true
        return true
    else:
      # Обрабатываем клик по элементу меню
      if x.int >= menu.rect.x.int and x.int < (menu.rect.x + menu.rect.w).int and
         y.int >= menu.rect.y.int and y.int < (menu.rect.y + menu.rect.h).int:
        let relY = y.int - menu.rect.y.int
        let index = relY div menu.itemHeight
        
        if index >= 0 and index < menu.items.len:
          let item = menu.items[index]
          if not item.separator and item.enabled:
            if item.checkable:
              item.checked = not item.checked
            if item.onClick != nil:
              item.onClick(item)
            menu.isOpen = false
            return true
      else:
        # Клик вне меню - закрываем
        menu.isOpen = false
        return true
  
  of SDL_EVENT_KEY_DOWN:
    if menu.isOpen:
      case event.key.key:
      of SDLK_ESCAPE:
        menu.isOpen = false
        return true
      of SDLK_UP:
        if menu.selectedIndex > 0:
          menu.selectedIndex -= 1
          # Пропускаем разделители
          while menu.selectedIndex > 0 and menu.items[menu.selectedIndex].separator:
            menu.selectedIndex -= 1
        return true
      of SDLK_DOWN:
        if menu.selectedIndex < menu.items.len - 1:
          menu.selectedIndex += 1
          # Пропускаем разделители
          while menu.selectedIndex < menu.items.len - 1 and menu.items[menu.selectedIndex].separator:
            menu.selectedIndex += 1
        return true
      of SDLK_RETURN, SDLK_KP_ENTER:
        if menu.selectedIndex >= 0 and menu.selectedIndex < menu.items.len:
          let item = menu.items[menu.selectedIndex]
          if not item.separator and item.enabled:
            if item.checkable:
              item.checked = not item.checked
            if item.onClick != nil:
              item.onClick(item)
            menu.isOpen = false
          return true
      else:
        discard
  
  else:
    discard
  
  return false

# =============================================================================
# MenuBar (Горизонтальное меню)
# =============================================================================

proc createMenuBar*(id: string, x, y, w, h: int): MenuBar =
  ## Создать горизонтальное меню
  result = MenuBar(
    id: id,
    rect: initRect(x, y, w, h),
    menus: @[],
    hoveredMenu: -1,
    openMenu: -1,
    itemWidth: 80,  # Будет пересчитано при добавлении меню
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    bgColor: initColor(240, 240, 240),
    textColor: initColor(0, 0, 0),
    hoverColor: initColor(229, 243, 255),
    borderColor: initColor(180, 180, 180)
  )

proc addMenu*(menubar: MenuBar, menu: Menu) =
  ## Добавить меню в MenuBar
  menubar.menus.add(menu)

proc calculateMenuWidths*(menubar: MenuBar, font: TTF_Font): seq[int] =
  ## Вычислить ширину каждого пункта меню на основе текста
  result = @[]
  for menu in menubar.menus:
    let menuTitle = if menu.items.len > 0: menu.id else: "Меню"
    let textSize = getTextSize(font, menuTitle)
    # Добавляем отступы по 20 пикселей с каждой стороны
    result.add(textSize.w + 40)

proc renderMenuBar*(gui: GuiManager, menubar: MenuBar) =
  ## Отрендерить MenuBar (только панель, без выпадающего меню)
  if not menubar.visible:
    return
  
  # Фон MenuBar
  renderFillRect(gui.renderer, menubar.rect, menubar.bgColor)
  renderRect(gui.renderer, menubar.rect, menubar.borderColor, 1)
  
  # Вычисляем ширины пунктов меню
  let widths = calculateMenuWidths(menubar, gui.theme.font)
  
  # Рендерим заголовки меню
  var currentX = menubar.rect.x.int
  let highlightPadding = 3  # Отступ сверху и снизу для подсветки
  
  for i, menu in menubar.menus:
    let itemWidth = widths[i]
    
    # Подсветка наведённого или открытого меню (с отступами сверху и снизу)
    if i == menubar.hoveredMenu or i == menubar.openMenu:
      let highlightRect = initRect(
        currentX, 
        menubar.rect.y.int + highlightPadding,
        itemWidth, 
        menubar.rect.h.int - highlightPadding * 2
      )
      renderFillRect(gui.renderer, highlightRect, menubar.hoverColor)
    
    # Текст заголовка меню (берём первый пункт как заголовок или используем id)
    let menuTitle = if menu.items.len > 0: menu.id else: "Меню"
    let textSize = getTextSize(gui.theme.font, menuTitle)
    let textX = currentX + (itemWidth - textSize.w) div 2
    let textY = menubar.rect.y.int + (menubar.rect.h.int - textSize.h) div 2
    discard renderText(gui.renderer, gui.theme.font, menuTitle, textX, textY, menubar.textColor)
    
    currentX += itemWidth

proc renderMenuBarDropdown*(gui: GuiManager, menubar: MenuBar) =
  ## Отрендерить выпадающее меню MenuBar (должно вызываться поверх всех виджетов)
  if not menubar.visible:
    return
  
  # Рендерим открытое выпадающее меню
  if menubar.openMenu >= 0 and menubar.openMenu < menubar.menus.len:
    let menu = menubar.menus[menubar.openMenu]
    
    # Вычисляем позицию X для выпадающего меню
    let widths = calculateMenuWidths(menubar, gui.theme.font)
    var menuX = menubar.rect.x.int
    for i in 0..<menubar.openMenu:
      menuX += widths[i]
    
    let menuY = menubar.rect.y.int + menubar.rect.h.int
    menu.rect.x = menuX.cint
    menu.rect.y = menuY.cint
    menu.isOpen = true
    renderMenu(gui, menu)

proc handleMenuBarEvent*(gui: GuiManager, menubar: MenuBar, event: ptr SdlEvent): bool =
  ## Обработать событие для MenuBar
  if not menubar.visible or not menubar.enabled:
    return false
  
  case event.type:
  of SDL_EVENT_MOUSE_MOTION:
    let x = event.motion.x
    let y = event.motion.y
    
    # Проверяем наведение на заголовки меню
    if y.int >= menubar.rect.y.int and y.int < (menubar.rect.y + menubar.rect.h).int:
      if x.int >= menubar.rect.x.int and x.int < (menubar.rect.x + menubar.rect.w).int:
        # Вычисляем ширины и находим пункт под курсором
        let widths = calculateMenuWidths(menubar, gui.theme.font)
        var currentX = menubar.rect.x.int
        menubar.hoveredMenu = -1
        for i in 0..<menubar.menus.len:
          if x.int >= currentX and x.int < currentX + widths[i]:
            menubar.hoveredMenu = i
            # Если какое-то меню уже открыто, переключаемся на наведённое
            if menubar.openMenu >= 0:
              menubar.openMenu = i
            return true
          currentX += widths[i]
      else:
        menubar.hoveredMenu = -1
    else:
      menubar.hoveredMenu = -1
    
    # Если меню открыто, передаём событие в него
    if menubar.openMenu >= 0 and menubar.openMenu < menubar.menus.len:
      let menu = menubar.menus[menubar.openMenu]
      return handleMenuEvent(gui, menu, event)
  
  of SDL_EVENT_MOUSE_BUTTON_DOWN:
    let x = event.button.x
    let y = event.button.y
    
    # Клик по заголовку меню
    if y.int >= menubar.rect.y.int and y.int < (menubar.rect.y + menubar.rect.h).int:
      if x.int >= menubar.rect.x.int and x.int < (menubar.rect.x + menubar.rect.w).int:
        # Вычисляем ширины и находим пункт под курсором
        let widths = calculateMenuWidths(menubar, gui.theme.font)
        var currentX = menubar.rect.x.int
        for i in 0..<menubar.menus.len:
          if x.int >= currentX and x.int < currentX + widths[i]:
            if menubar.openMenu == i:
              # Закрываем если кликнули на уже открытое меню
              menubar.openMenu = -1
            else:
              # Открываем меню
              menubar.openMenu = i
            return true
          currentX += widths[i]
    
    # Если меню открыто, передаём событие в него
    if menubar.openMenu >= 0 and menubar.openMenu < menubar.menus.len:
      let menu = menubar.menus[menubar.openMenu]
      let handled = handleMenuEvent(gui, menu, event)
      # Если меню обработало клик (выбран пункт), закрываем меню
      if handled and not menu.isOpen:
        menubar.openMenu = -1
      return handled
    else:
      # Клик вне меню - закрываем
      if menubar.openMenu >= 0:
        menubar.openMenu = -1
        return true
  
  of SDL_EVENT_KEY_DOWN:
    if menubar.openMenu >= 0 and menubar.openMenu < menubar.menus.len:
      let menu = menubar.menus[menubar.openMenu]
      let handled = handleMenuEvent(gui, menu, event)
      # Если меню закрылось, сбрасываем openMenu
      if not menu.isOpen:
        menubar.openMenu = -1
      return handled
  
  else:
    discard
  
  return false

# =============================================================================
# ToolBar (Панель инструментов)
# =============================================================================

proc createToolBar*(id: string, x, y, w, h: int): ToolBar =
  ## Создать панель инструментов
  result = ToolBar(
    id: id,
    rect: initRect(x, y, w, h),
    buttons: @[],
    buttonSize: 32,
    spacing: 4,
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    bgColor: initColor(240, 240, 240),
    borderColor: initColor(180, 180, 180)
  )

proc addToolButton*(toolbar: ToolBar, button: Button) =
  ## Добавить кнопку на панель инструментов
  # Просто добавляем кнопку, не меняя её размер и позицию
  # Позиция и размер должны быть заданы при создании кнопки
  toolbar.buttons.add(button)

proc renderToolBar*(gui: GuiManager, toolbar: ToolBar) =
  ## Отрендерить панель инструментов
  if not toolbar.visible:
    return
  
  # Фон панели
  renderFillRect(gui.renderer, toolbar.rect, toolbar.bgColor)
  renderRect(gui.renderer, toolbar.rect, toolbar.borderColor, 1)
  
  # Кнопки - рендерим с учетом позиции toolbar
  for button in toolbar.buttons:
    # Сохраняем оригинальные координаты (относительные)
    let origX = button.rect.x
    let origY = button.rect.y
    
    # Преобразуем в абсолютные координаты
    button.rect.x = toolbar.rect.x + origX
    button.rect.y = toolbar.rect.y + origY
    
    # Рендерим кнопку
    renderButton(gui, button)
    
    # Восстанавливаем относительные координаты
    button.rect.x = origX
    button.rect.y = origY

proc handleToolBarEvent*(gui: GuiManager, toolbar: ToolBar, event: ptr SdlEvent): bool =
  ## Обработать событие для панели инструментов
  if not toolbar.visible or not toolbar.enabled:
    return false
  
  # Передаём события кнопкам с учетом относительных координат
  for button in toolbar.buttons:
    # Сохраняем оригинальные координаты (относительные)
    let origX = button.rect.x
    let origY = button.rect.y
    
    # Преобразуем в абсолютные координаты
    button.rect.x = toolbar.rect.x + origX
    button.rect.y = toolbar.rect.y + origY
    
    # Обрабатываем событие
    let handled = handleButtonEvent(button, event)
    
    # Восстанавливаем относительные координаты
    button.rect.x = origX
    button.rect.y = origY
    
    if handled:
      return true
  
  return false

# =============================================================================
# ToolTip (Всплывающая подсказка)
# =============================================================================

proc updateTooltip*(gui: GuiManager) =
  ## Обновить состояние всплывающей подсказки
  if gui.tooltip.widget == nil:
    gui.tooltip.visible = false
    gui.tooltip.timer = 0
    return
  
  # Проверяем, наведён ли курсор на виджет
  let hovering = pointInRect(gui.cursorX, gui.cursorY, gui.tooltip.widget.rect)
  
  if hovering and gui.tooltip.widget.tooltip.len > 0:
    gui.tooltip.timer += 1
    if gui.tooltip.timer > gui.tooltip.delay:
      gui.tooltip.visible = true
      gui.tooltip.text = gui.tooltip.widget.tooltip
      
      # Вычисляем размер и позицию подсказки
      let textSize = getTextSize(gui.theme.font, gui.tooltip.text)
      let padding = 6
      let w = textSize.w + padding * 2
      let h = textSize.h + padding * 2
      
      # Позиционируем под курсором
      gui.tooltip.rect = initRect(
        gui.cursorX.int + 10,
        gui.cursorY.int + 20,
        w,
        h
      )
  else:
    gui.tooltip.visible = false
    gui.tooltip.timer = 0
    if not hovering:
      gui.tooltip.widget = nil

proc renderTooltip*(gui: GuiManager) =
  ## Отрендерить всплывающую подсказку
  if not gui.tooltip.visible or gui.tooltip.text.len == 0:
    return
  
  # Фон подсказки
  renderFillRect(gui.renderer, gui.tooltip.rect, gui.tooltip.bgColor)
  renderRect(gui.renderer, gui.tooltip.rect, gui.tooltip.borderColor, 1)
  
  # Текст
  let padding = 6
  let textX = gui.tooltip.rect.x.int + padding
  let textY = gui.tooltip.rect.y.int + padding
  discard renderText(gui.renderer, gui.theme.font, gui.tooltip.text, textX, textY, 
                    gui.tooltip.textColor)

proc checkTooltipHover*(gui: GuiManager, widget: Widget) =
  ## Проверить наведение для отображения подсказки
  if widget.tooltip.len > 0 and pointInRect(gui.cursorX, gui.cursorY, widget.rect):
    if gui.tooltip.widget != widget:
      gui.tooltip.widget = widget
      gui.tooltip.timer = 0
      gui.tooltip.visible = false

# Диалоговое окно
# =============================================================================

proc createDialog*(title, message: string, dialogType: DialogType, 
                  buttons: seq[DialogButton]): Dialog =
  ## Создать диалоговое окно
  result = Dialog(
    id: "dialog_" & $dialogType,
    rect: initRect(0, 0, 400, 200),
    title: title,
    message: message,
    dialogType: dialogType,
    buttons: buttons,
    result: dbCancel,
    isModal: true,
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[]
  )

proc renderDialog*(gui: GuiManager, dlg: Dialog, windowW, windowH: int) =
  ## Отрендерить диалоговое окно
  if not dlg.visible:
    return
  
  # Центрировать диалог
  dlg.rect.x = ((windowW - dlg.rect.w.int) div 2).cint
  dlg.rect.y = ((windowH - dlg.rect.h.int) div 2).cint
  
  # Полупрозрачный фон (легкое затемнение вместо черного)
  let overlayRect = initRect(0, 0, windowW, windowH)
  renderFillRect(gui.renderer, overlayRect, initColor(0, 0, 0, 180))
  
  # Окно диалога
  renderFillRect(gui.renderer, dlg.rect, gui.theme.bgColor)
  renderRect(gui.renderer, dlg.rect, gui.theme.borderColor, 2)
  
  # Заголовок
  let titleRect = initRect(dlg.rect.x.int, dlg.rect.y.int, dlg.rect.w.int, 30)
  renderFillRect(gui.renderer, titleRect, gui.theme.accentColor)
  
  let titleX = dlg.rect.x.int + gui.theme.padding
  let titleY = dlg.rect.y.int + (30 - getTextSize(gui.theme.font, dlg.title).h) div 2
  discard renderText(gui.renderer, gui.theme.font, dlg.title, titleX, titleY, 
                    initColor(255, 255, 255))
  
  # Сообщение
  let msgX = dlg.rect.x.int + gui.theme.padding
  let msgY = dlg.rect.y.int + 40
  discard renderText(gui.renderer, gui.theme.font, dlg.message, msgX, msgY, 
                    gui.theme.textColor)
  
  # Кнопки
  let buttonWidth = 80
  let buttonHeight = 30
  let buttonSpacing = 10
  let totalButtonWidth = dlg.buttons.len * buttonWidth + (dlg.buttons.len - 1) * buttonSpacing
  var buttonX = dlg.rect.x.int + (dlg.rect.w.int - totalButtonWidth) div 2
  let buttonY = dlg.rect.y.int + dlg.rect.h.int - buttonHeight - gui.theme.padding
  
  for btn in dlg.buttons:
    let btnText = case btn:
      of dbOk: "OK"
      of dbCancel: "Отмена"
      of dbYes: "Да"
      of dbNo: "Нет"
      of dbRetry: "Повтор"
      of dbAbort: "Прервать"
      of dbIgnore: "Игнорировать"
    
    let btnRect = initRect(buttonX, buttonY, buttonWidth, buttonHeight)
    renderFillRect(gui.renderer, btnRect, gui.theme.bgColor)
    renderRect(gui.renderer, btnRect, gui.theme.borderColor, 1)
    
    let textSize = getTextSize(gui.theme.font, btnText)
    let textX = buttonX + (buttonWidth - textSize.w) div 2
    let textY = buttonY + (buttonHeight - textSize.h) div 2
    discard renderText(gui.renderer, gui.theme.font, btnText, textX, textY, 
                      gui.theme.textColor)
    
    buttonX += buttonWidth + buttonSpacing

proc handleDialogEvent*(dlg: Dialog, event: ptr SdlEvent): bool =
  ## Обработать событие для диалога
  if not dlg.visible:
    return false
  
  case event.type:
  of SDL_EVENT_MOUSE_BUTTON_DOWN:
    let x = event.button.x
    let y = event.button.y
    
    # Проверить клик по кнопкам
    let buttonWidth = 80
    let buttonHeight = 30
    let buttonSpacing = 10
    let totalButtonWidth = dlg.buttons.len * buttonWidth + (dlg.buttons.len - 1) * buttonSpacing
    var buttonX = dlg.rect.x.int + (dlg.rect.w.int - totalButtonWidth) div 2
    let buttonY = dlg.rect.y.int + dlg.rect.h.int - buttonHeight - 8
    
    for btn in dlg.buttons:
      let btnRect = initRect(buttonX, buttonY, buttonWidth, buttonHeight)
      if pointInRect(x, y, btnRect):
        dlg.result = btn
        if dlg.onClose != nil:
          dlg.onClose(dlg, btn)
        dlg.visible = false
        return true
      buttonX += buttonWidth + buttonSpacing
    
    # Блокировать клики вне диалога
    return true
  
  of SDL_EVENT_KEY_DOWN:
    case event.key.key:
    of SDLK_RETURN, SDLK_KP_ENTER:
      if dbOk in dlg.buttons:
        dlg.result = dbOk
      elif dbYes in dlg.buttons:
        dlg.result = dbYes
      else:
        return false
      if dlg.onClose != nil:
        dlg.onClose(dlg, dlg.result)
      dlg.visible = false
      return true
    
    of SDLK_ESCAPE:
      if dbCancel in dlg.buttons:
        dlg.result = dbCancel
      elif dbNo in dlg.buttons:
        dlg.result = dbNo
      else:
        return false
      if dlg.onClose != nil:
        dlg.onClose(dlg, dlg.result)
      dlg.visible = false
      return true
    
    else:
      discard
    
    return true
  
  else:
    discard
  
  return false

# =============================================================================
# StatusBar (Строка состояния)
# =============================================================================

proc createStatusBar*(id: string, x, y, w, h: int): StatusBar =
  ## Создать строку состояния
  result = StatusBar(
    id: id,
    rect: initRect(x, y, w, h),
    text: "Готов",
    sections: @[],
    state: wsNormal,
    visible: true,
    enabled: true,
    children: @[],
    textColor: initColor(0, 0, 0),
    bgColor: initColor(240, 240, 240),
    borderColor: initColor(180, 180, 180)
  )

proc setText*(statusbar: StatusBar, text: string) =
  ## Установить текст строки состояния
  statusbar.text = text

proc setSections*(statusbar: StatusBar, sections: seq[string]) =
  ## Установить несколько секций текста
  statusbar.sections = sections

proc renderStatusBar*(gui: GuiManager, statusbar: StatusBar) =
  ## Отрендерить строку состояния
  if not statusbar.visible:
    return
  
  # Фон
  renderFillRect(gui.renderer, statusbar.rect, statusbar.bgColor)
  
  # Верхняя граница
  let borderRect = initRect(statusbar.rect.x.int, statusbar.rect.y.int, 
                           statusbar.rect.w.int, 1)
  renderFillRect(gui.renderer, borderRect, statusbar.borderColor)
  
  # Если есть секции, рисуем их
  if statusbar.sections.len > 0:
    let sectionWidth = statusbar.rect.w.int div statusbar.sections.len
    for i, section in statusbar.sections:
      let sectionX = statusbar.rect.x.int + i * sectionWidth
      
      # Разделитель между секциями (кроме первой)
      if i > 0:
        setRenderColor(gui.renderer, statusbar.borderColor)
        discard SDL_RenderLine(gui.renderer, 
          sectionX.cfloat, statusbar.rect.y.cfloat,
          sectionX.cfloat, (statusbar.rect.y + statusbar.rect.h).cfloat)
      
      # Текст секции
      let textSize = getTextSize(gui.theme.font, section)
      let textX = sectionX + gui.theme.padding
      let textY = statusbar.rect.y.int + (statusbar.rect.h.int - textSize.h) div 2
      discard renderText(gui.renderer, gui.theme.font, section, textX, textY, 
                        statusbar.textColor)
  else:
    # Просто один текст
    let textSize = getTextSize(gui.theme.font, statusbar.text)
    let textX = statusbar.rect.x.int + gui.theme.padding
    let textY = statusbar.rect.y.int + (statusbar.rect.h.int - textSize.h) div 2
    discard renderText(gui.renderer, gui.theme.font, statusbar.text, textX, textY, 
                      statusbar.textColor)

# =============================================================================
# Главная функция рендеринга
# =============================================================================

proc renderGui*(gui: GuiManager) =
  ## Отрендерить все виджеты
  # Обновляем мигание курсора
  gui.updateCursorBlink()
  
  # Сначала рендерим все виджеты кроме открытых ComboBox, Menu и выпадающих меню MenuBar
  var openComboBoxes: seq[tuple[combo: ComboBox, absX: int, absY: int]] = @[]
  var openMenus: seq[Menu] = @[]
  var openMenuBars: seq[MenuBar] = @[]
  
  # Вспомогательная функция для сбора ComboBox из Panel
  proc collectFromPanel(panel: Panel, offsetX, offsetY: int) =
    for child in panel.children:
      if not child.visible:
        continue
      if child of Panel:
        let childPanel = Panel(child)
        collectFromPanel(childPanel, offsetX + panel.rect.x.int, offsetY + panel.rect.y.int)
      elif child of ComboBox:
        let combo = ComboBox(child)
        if combo.isOpen:
          openComboBoxes.add((combo, offsetX + panel.rect.x.int + child.rect.x.int, 
                              offsetY + panel.rect.y.int + child.rect.y.int))
  
  for widget in gui.widgets:
    if not widget.visible:
      continue
    
    # Пропускаем виджеты, у которых есть parent (они будут отрисованы через parent)
    if widget.parent != nil:
      continue
    
    # Собираем открытые ComboBox из Panel
    if widget of Panel:
      collectFromPanel(Panel(widget), 0, 0)
    
    # Откладываем рендеринг открытых ComboBox и Menu (но рендерим их сейчас)
    if widget of ComboBox:
      let combo = ComboBox(widget)
      renderComboBox(gui, combo)
      if combo.isOpen:
        openComboBoxes.add((combo, combo.rect.x.int, combo.rect.y.int))
      continue
    elif widget of Menu:
      let menu = Menu(widget)
      if menu.isOpen:
        openMenus.add(menu)
        continue
    elif widget of MenuBar:
      let menubar = MenuBar(widget)
      if menubar.openMenu >= 0:
        openMenuBars.add(menubar)
    
    # Рендеринг в зависимости от типа виджета
    if widget of Button:
      renderButton(gui, Button(widget))
    elif widget of TextField:
      renderTextField(gui, TextField(widget))
    elif widget of TextArea:
      renderTextArea(gui, TextArea(widget))
    elif widget of CheckBox:
      renderCheckBox(gui, CheckBox(widget))
    elif widget of RadioButton:
      renderRadioButton(gui, RadioButton(widget))
    elif widget of Slider:
      renderSlider(gui, Slider(widget))
    elif widget of ProgressBar:
      renderProgressBar(gui, ProgressBar(widget))
    elif widget of Label:
      renderLabel(gui, Label(widget))
    elif widget of Panel:
      renderPanel(gui, Panel(widget))
    elif widget of ListBox:
      renderListBox(gui, ListBox(widget))
    elif widget of SpinBox:
      renderSpinBox(gui, SpinBox(widget))
    elif widget of TabControl:
      renderTabControl(gui, TabControl(widget))
    elif widget of Menu:
      renderMenu(gui, Menu(widget))
    elif widget of MenuBar:
      renderMenuBar(gui, MenuBar(widget))
    elif widget of StatusBar:
      renderStatusBar(gui, StatusBar(widget))
    elif widget of ToolBar:
      renderToolBar(gui, ToolBar(widget))
  
  # Теперь рендерим ТОЛЬКО выпадающие списки открытых ComboBox поверх всего
  for item in openComboBoxes:
    let combo = item.combo
    let absX = item.absX
    let absY = item.absY
    
    if combo.isOpen and combo.items.len > 0:
      let itemHeight = max(20, combo.rect.h.int)
      let maxItems = min(combo.items.len, combo.dropdownHeight div itemHeight)
      let dropHeight = maxItems * itemHeight
      
      let dropRect = initRect(
        absX,
        absY + combo.rect.h.int,
        combo.rect.w.int,
        dropHeight
      )
      
      # Фон списка
      renderFillRect(gui.renderer, dropRect, combo.bgColor)
      renderRect(gui.renderer, dropRect, combo.borderColor, gui.theme.borderWidth)
      
      # Элементы
      for i in 0..<maxItems:
        let itemY = dropRect.y.int + i * itemHeight
        let itemRect = initRect(dropRect.x.int, itemY, dropRect.w.int, itemHeight)
        
        # Подсветка наведённого элемента
        if i == combo.hoveredIndex:
          renderFillRect(gui.renderer, itemRect, combo.hoverColor)
          # Добавляем толстый яркий зелёный контур для наведённого элемента
          let borderColor = initColor(0, 255, 0)  # Яркий зелёный цвет
          renderRect(gui.renderer, itemRect, borderColor, 2)  # Толщина 2 пикселя
        elif i == combo.selectedIndex:
          renderFillRect(gui.renderer, itemRect, combo.selectedColor)
          renderRect(gui.renderer, itemRect, combo.selectedColor, 1)
        
        # Текст элемента
        let text = combo.items[i]
        let textSize = getTextSize(gui.theme.font, text)
        let textX = itemRect.x.int + gui.theme.padding
        let textY = itemY + (itemHeight - textSize.h) div 2
        let textColor = if i == combo.selectedIndex: initColor(255, 255, 255) else: combo.textColor
        discard renderText(gui.renderer, gui.theme.font, text, textX, textY, textColor)
  
  # Рендерим открытые Menu поверх всего
  for menu in openMenus:
    renderMenu(gui, menu)
  
  # Рендерим выпадающие меню MenuBar поверх всего
  for menubar in openMenuBars:
    renderMenuBarDropdown(gui, menubar)
  
  # Модальный диалог рендерится поверх всего
  if gui.modalDialog != nil and gui.modalDialog.visible:
    var w, h: cint
    discard SDL_GetRenderOutputSize(gui.renderer, addr w, addr h)
    renderDialog(gui, gui.modalDialog, w.int, h.int)
  
  # Рендерим tooltip поверх всего
  renderTooltip(gui)
  
  # Рендерим tooltip поверх всего
  renderTooltip(gui)

proc handleGuiEvent*(gui: GuiManager, event: ptr SdlEvent): bool =
  ## Обработать событие для всех виджетов
  result = false
  
  # Обновление позиции курсора
  if event.type == SDL_EVENT_MOUSE_MOTION:
    gui.cursorX = event.motion.x
    gui.cursorY = event.motion.y
  
  # Если есть модальный диалог, обрабатываем только его
  if gui.modalDialog != nil and gui.modalDialog.visible:
    return handleDialogEvent(gui.modalDialog, event)
  
  # ИСПРАВЛЕНИЕ: при клике мыши проверяем, попал ли клик в какой-либо виджет
  var clickHandled = false
  
  # КРИТИЧЕСКИ ВАЖНО: Сначала обрабатываем открытые MenuBar, ComboBox и Menu
  # Они должны перехватывать события первыми, так как рисуются поверх
  for i in countdown(gui.widgets.len - 1, 0):
    let widget = gui.widgets[i]
    if not widget.visible or not widget.enabled:
      continue
    
    # Обрабатываем MenuBar с открытым меню ПЕРВЫМ (он всегда вверху окна)
    if widget of MenuBar:
      let menubar = MenuBar(widget)
      if menubar.openMenu >= 0:
        if handleMenuBarEvent(gui, menubar, event):
          return true
    
    # Обрабатываем только открытые ComboBox
    elif widget of ComboBox:
      let combo = ComboBox(widget)
      if combo.isOpen:
        if handleComboBoxEvent(gui, combo, event):
          return true
    
    # Обрабатываем только открытые Menu
    elif widget of Menu:
      let menu = Menu(widget)
      if menu.isOpen:
        if handleMenuEvent(gui, menu, event):
          return true
  
  # Теперь обрабатываем остальные виджеты в обратном порядке (сверху вниз)
  for i in countdown(gui.widgets.len - 1, 0):
    let widget = gui.widgets[i]
    if not widget.visible or not widget.enabled:
      continue
    
    var handled = false
    
    if widget of Button:
      handled = handleButtonEvent(Button(widget), event)
    elif widget of TextField:
      handled = handleTextFieldEvent(gui, TextField(widget), event)
    elif widget of TextArea:
      handled = handleTextAreaEvent(gui, TextArea(widget), event)
    elif widget of CheckBox:
      handled = handleCheckBoxEvent(CheckBox(widget), event)
    elif widget of RadioButton:
      handled = handleRadioButtonEvent(gui, RadioButton(widget), event)
    elif widget of Slider:
      handled = handleSliderEvent(Slider(widget), event)
    elif widget of ListBox:
      handled = handleListBoxEvent(ListBox(widget), event)
    elif widget of ComboBox:
      # Закрытые ComboBox обрабатываем как обычно
      let combo = ComboBox(widget)
      if not combo.isOpen:
        handled = handleComboBoxEvent(gui, combo, event)
    elif widget of SpinBox:
      handled = handleSpinBoxEvent(gui, SpinBox(widget), event)
    elif widget of TabControl:
      handled = handleTabControlEvent(gui, TabControl(widget), event)
    elif widget of Panel:
      handled = handlePanelEvent(gui, Panel(widget), event)
    elif widget of Menu:
      # Закрытые Menu обрабатываем как обычно
      let menu = Menu(widget)
      if not menu.isOpen:
        handled = handleMenuEvent(gui, menu, event)
    elif widget of MenuBar:
      # MenuBar с открытым меню уже обработан в приоритетной секции
      let menubar = MenuBar(widget)
      if menubar.openMenu < 0:
        handled = handleMenuBarEvent(gui, menubar, event)
    elif widget of ToolBar:
      handled = handleToolBarEvent(gui, ToolBar(widget), event)
    
    if handled:
      clickHandled = true
      return true
  
  # ИСПРАВЛЕНИЕ: если клик мыши не попал ни в один виджет, снимаем фокус
  if event.type == SDL_EVENT_MOUSE_BUTTON_DOWN and not clickHandled:
    if gui.focusedWidget != nil:
      gui.setFocus(nil)
  
  return false

# =============================================================================
# Удобные функции для создания диалогов
# =============================================================================

proc showInfoDialog*(gui: GuiManager, title, message: string, 
                    onClose: proc(dlg: Dialog, result: DialogButton) = nil) =
  ## Показать информационный диалог
  gui.modalDialog = createDialog(title, message, dtInfo, @[dbOk])
  gui.modalDialog.onClose = onClose

proc showWarningDialog*(gui: GuiManager, title, message: string,
                       onClose: proc(dlg: Dialog, result: DialogButton) = nil) =
  ## Показать диалог с предупреждением
  gui.modalDialog = createDialog(title, message, dtWarning, @[dbOk])
  gui.modalDialog.onClose = onClose

proc showErrorDialog*(gui: GuiManager, title, message: string,
                     onClose: proc(dlg: Dialog, result: DialogButton) = nil) =
  ## Показать диалог с ошибкой
  gui.modalDialog = createDialog(title, message, dtError, @[dbOk])
  gui.modalDialog.onClose = onClose

proc showQuestionDialog*(gui: GuiManager, title, message: string,
                        onClose: proc(dlg: Dialog, result: DialogButton)) =
  ## Показать диалог с вопросом
  gui.modalDialog = createDialog(title, message, dtQuestion, @[dbYes, dbNo])
  gui.modalDialog.onClose = onClose

proc showConfirmDialog*(gui: GuiManager, title, message: string,
                       onClose: proc(dlg: Dialog, result: DialogButton)) =
  ## Показать диалог подтверждения
  gui.modalDialog = createDialog(title, message, dtQuestion, @[dbOk, dbCancel])
  gui.modalDialog.onClose = onClose

# =============================================================================
# Экспорт
# =============================================================================

export Widget, Button, TextField, TextArea, CheckBox, RadioButton
export Slider, ProgressBar, Label, Panel, ListBox, ComboBox, SpinBox
export Dialog, DialogType, DialogButton, TabControl, Tab
export Menu, MenuItem, MenuBar, ToolBar, ToolTip, StatusBar
export GuiManager, GuiTheme, WidgetState, Alignment
export createGuiManager, addWidget, removeWidget, findWidgetById, setFocus, updateCursorBlink
export createButton, createTextField, createTextArea, createCheckBox, createRadioButton
export createSlider, createProgressBar, createLabel, createPanel, createListBox
export createComboBox, createSpinBox, createTabControl, createTab, addTab
export createMenu, createMenuItem, createMenuSeparator, addMenuItem
export createMenuBar, addMenu
export createToolBar, addToolButton
export createStatusBar, setText, setSections
export createDialog, registerRadioButton
export updateTooltip, checkTooltipHover
export renderGui, handleGuiEvent
export showInfoDialog, showWarningDialog, showErrorDialog
export showQuestionDialog, showConfirmDialog
export createDefaultTheme, createDarkTheme
export initColor, initRect, initFRect








# nim c -d:release sdlGuiLib.nim

