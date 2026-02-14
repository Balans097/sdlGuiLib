################################################################
##           GUI Library Demo Example
##    Демонстрация возможностей sdlGuiLib
################################################################

import libSDL
import sdlGuiLib
import unicode

# Инициализация SDL
if SDL_Init(SDL_INIT_VIDEO) != SDL_TRUE:
  echo "SDL Init Error: ", SDL_GetError()
  quit(1)

# Инициализация TTF
if not TTF_Init():
  echo "TTF Init Error: ", SDL_GetError()
  quit(1)

# Создание окна
let window = SDL_CreateWindow(
  "SDL GUI Library Demo",
  1024, 768,
  SDL_WINDOW_RESIZABLE
)

if window.isNil:
  echo "Window creation failed: ", SDL_GetError()
  quit(1)

# Создание рендерера
let renderer = SDL_CreateRenderer(window, nil)
if renderer.isNil:
  echo "Renderer creation failed: ", SDL_GetError()
  quit(1)

# Загрузка шрифта (замените на ваш путь к шрифту)
# Попробуем несколько распространённых путей к шрифтам
var font = TTF_OpenFont("arial.ttf", 14.0)
if font.isNil:
  font = TTF_OpenFont("C:/Windows/Fonts/arial.ttf", 14.0)
if font.isNil:
  # Fedora Linux
  font = TTF_OpenFont("/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf", 14.0)
if font.isNil:
  font = TTF_OpenFont("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 14.0)
if font.isNil:
  font = TTF_OpenFont("/System/Library/Fonts/Helvetica.ttc", 14.0)
if font.isNil:
  echo "ОШИБКА: Не удалось загрузить шрифт!"
  echo "Пожалуйста, укажите правильный путь к TTF файлу."
  echo "Для Windows: C:/Windows/Fonts/arial.ttf"
  echo "Для Linux: /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
  TTF_Quit()
  SDL_Quit()
  quit(1)

# Создание GUI менеджера
var gui = createGuiManager(renderer, font)

# Загружаем иконку для кнопки
var buttonIcon: SdlTexture = nil

# Пытаемся загрузить PNG через SDL_image (если доступна)
# Используем compiles() для проверки доступности функции
when compiles(IMG_Load("test.png")):
  let iconSurface = IMG_Load("theIcon.png")
  if not iconSurface.isNil:
    buttonIcon = SDL_CreateTextureFromSurface(renderer, iconSurface)
    SDL_DestroySurface(iconSurface)
    if buttonIcon.isNil:
      echo "Предупреждение: не удалось создать текстуру из иконки"
    else:
      # ВАЖНО: Включаем blend mode для поддержки прозрачности
      # SDL_BLENDMODE_BLEND = 1 в SDL3
      when declared(SDL_BLENDMODE_BLEND):
        discard SDL_SetTextureBlendMode(buttonIcon, SDL_BLENDMODE_BLEND)
      else:
        discard SDL_SetTextureBlendMode(buttonIcon, 1.SdlBlendMode)
      echo "Иконка загружена успешно и blend mode установлен"
  else:
    echo "Предупреждение: не удалось загрузить theIcon.png"
else:
  # Если IMG_Load недоступна, пробуем BMP
  echo "IMG_Load недоступна, попытка загрузить theIcon.bmp"
  let iconSurface = SDL_LoadBMP("theIcon.bmp")
  if not iconSurface.isNil:
    buttonIcon = SDL_CreateTextureFromSurface(renderer, iconSurface)
    SDL_DestroySurface(iconSurface)
    if buttonIcon.isNil:
      echo "Предупреждение: не удалось создать текстуру из иконки"
    else:
      # Включаем blend mode для поддержки прозрачности
      when declared(SDL_BLENDMODE_BLEND):
        discard SDL_SetTextureBlendMode(buttonIcon, SDL_BLENDMODE_BLEND)
      else:
        discard SDL_SetTextureBlendMode(buttonIcon, 1.SdlBlendMode)
  else:
    echo "Предупреждение: не удалось загрузить theIcon.bmp"
    echo "Для загрузки PNG требуется SDL_image"
    echo "Кнопка будет отображаться без иконки"
    buttonIcon = nil  # Явно устанавливаем nil

# Активируем текстовый ввод (необходимо для TextField)
discard SDL_StartTextInput(window)

# =============================================================================
# Классическое горизонтальное меню
# =============================================================================

let menuBar = createMenuBar("mainmenu", 0, 0, 1024, 30)

# Меню "Файл"
let menuFile = createMenu("Файл", 0, 0, 180)
let menuFileNew = createMenuItem("Создать") do (item: MenuItem):
  gui.showInfoDialog("Файл", "Создать новый файл")
menuFileNew.shortcut = "Ctrl+N"

let menuFileOpen = createMenuItem("Открыть") do (item: MenuItem):
  gui.showInfoDialog("Файл", "Открыть файл")
menuFileOpen.shortcut = "Ctrl+O"

let menuFileSave = createMenuItem("Сохранить") do (item: MenuItem):
  gui.showInfoDialog("Файл", "Сохранить файл")
menuFileSave.shortcut = "Ctrl+S"

menuFile.addMenuItem(menuFileNew)
menuFile.addMenuItem(menuFileOpen)
menuFile.addMenuItem(menuFileSave)
menuFile.addMenuItem(createMenuSeparator())

let menuFileExit = createMenuItem("Выход") do (item: MenuItem):
  gui.showQuestionDialog("Выход", "Действительно выйти из приложения?") do (dlg: Dialog, result: DialogButton):
    if result == dbYes:
      echo "Выход из приложения"
menuFileExit.shortcut = "Alt+F4"
menuFile.addMenuItem(menuFileExit)

# Меню "Правка"
let menuEdit = createMenu("Правка", 0, 0, 180)
let menuEditUndo = createMenuItem("Отменить") do (item: MenuItem):
  gui.showInfoDialog("Правка", "Отменить последнее действие")
menuEditUndo.shortcut = "Ctrl+Z"

let menuEditRedo = createMenuItem("Повторить") do (item: MenuItem):
  gui.showInfoDialog("Правка", "Повторить действие")
menuEditRedo.shortcut = "Ctrl+Y"

menuEdit.addMenuItem(menuEditUndo)
menuEdit.addMenuItem(menuEditRedo)
menuEdit.addMenuItem(createMenuSeparator())

let menuEditCopy = createMenuItem("Копировать") do (item: MenuItem):
  gui.showInfoDialog("Правка", "Копировать в буфер обмена")
menuEditCopy.shortcut = "Ctrl+C"

let menuEditPaste = createMenuItem("Вставить") do (item: MenuItem):
  gui.showInfoDialog("Правка", "Вставить из буфера обмена")
menuEditPaste.shortcut = "Ctrl+V"

menuEdit.addMenuItem(menuEditCopy)
menuEdit.addMenuItem(menuEditPaste)

# Меню "Настройки"
let menuSettings = createMenu("Настройки", 0, 0, 180)

# Переменная для отслеживания темы (будет использоваться и кнопкой и меню)
var isDarkTheme = false

let menuSettingsTheme = createMenuItem("Сменить тему") do (item: MenuItem):
  # Переключаем тему
  isDarkTheme = not isDarkTheme
  if isDarkTheme:
    gui.theme = createDarkTheme(font)
  else:
    gui.theme = createDefaultTheme(font)
  
  # Обновляем цвета всех виджетов (копия логики из кнопки)
  for widget in gui.widgets:
    if widget of Button:
      if widget.id != "btn2":  # Не трогаем акцентную кнопку
        Button(widget).bgColor = gui.theme.bgColor
        Button(widget).textColor = gui.theme.textColor
        Button(widget).borderColor = gui.theme.borderColor
    
    elif widget of TextField:
      if isDarkTheme:
        TextField(widget).bgColor = initColor(30, 30, 30)
        TextField(widget).textColor = initColor(241, 241, 241)
        TextField(widget).borderColor = gui.theme.borderColor
      else:
        TextField(widget).bgColor = initColor(255, 255, 255)
        TextField(widget).textColor = initColor(0, 0, 0)
        TextField(widget).borderColor = initColor(122, 122, 122)
    
    elif widget of TextArea:
      if isDarkTheme:
        TextArea(widget).bgColor = initColor(30, 30, 30)
        TextArea(widget).textColor = initColor(241, 241, 241)
        TextArea(widget).borderColor = gui.theme.borderColor
      else:
        TextArea(widget).bgColor = initColor(255, 255, 255)
        TextArea(widget).textColor = initColor(0, 0, 0)
        TextArea(widget).borderColor = initColor(122, 122, 122)
    
    elif widget of CheckBox:
      CheckBox(widget).bgColor = gui.theme.bgColor
      CheckBox(widget).textColor = gui.theme.textColor
      CheckBox(widget).borderColor = gui.theme.borderColor
    
    elif widget of RadioButton:
      RadioButton(widget).bgColor = gui.theme.bgColor
      RadioButton(widget).textColor = gui.theme.textColor
      RadioButton(widget).borderColor = gui.theme.borderColor
    
    elif widget of Label:
      Label(widget).bgColor = gui.theme.bgColor
      if widget.id == "label1":
        Label(widget).textColor = gui.theme.textColor
    
    elif widget of Panel:
      Panel(widget).bgColor = gui.theme.bgColor
      Panel(widget).borderColor = gui.theme.borderColor
    
    elif widget of ListBox:
      if isDarkTheme:
        ListBox(widget).bgColor = initColor(30, 30, 30)
        ListBox(widget).textColor = initColor(241, 241, 241)
        ListBox(widget).borderColor = gui.theme.borderColor
      else:
        ListBox(widget).bgColor = initColor(255, 255, 255)
        ListBox(widget).textColor = initColor(0, 0, 0)
        ListBox(widget).borderColor = initColor(122, 122, 122)
    
    elif widget of ComboBox:
      if isDarkTheme:
        ComboBox(widget).bgColor = initColor(30, 30, 30)
        ComboBox(widget).textColor = initColor(241, 241, 241)
        ComboBox(widget).borderColor = gui.theme.borderColor
        ComboBox(widget).hoverColor = gui.theme.hoverColor
        ComboBox(widget).selectedColor = gui.theme.accentColor
      else:
        ComboBox(widget).bgColor = initColor(255, 255, 255)
        ComboBox(widget).textColor = initColor(0, 0, 0)
        ComboBox(widget).borderColor = initColor(122, 122, 122)
        ComboBox(widget).hoverColor = initColor(229, 243, 255)
        ComboBox(widget).selectedColor = initColor(0, 120, 215)
    
    elif widget of SpinBox:
      if isDarkTheme:
        SpinBox(widget).bgColor = initColor(30, 30, 30)
        SpinBox(widget).textColor = initColor(241, 241, 241)
        SpinBox(widget).borderColor = gui.theme.borderColor
        SpinBox(widget).buttonColor = initColor(60, 60, 60)
      else:
        SpinBox(widget).bgColor = initColor(255, 255, 255)
        SpinBox(widget).textColor = initColor(0, 0, 0)
        SpinBox(widget).borderColor = initColor(122, 122, 122)
        SpinBox(widget).buttonColor = initColor(240, 240, 240)
    
    elif widget of TabControl:
      if isDarkTheme:
        TabControl(widget).tabColor = initColor(60, 60, 60)
        TabControl(widget).activeTabColor = initColor(45, 45, 48)
        TabControl(widget).textColor = initColor(241, 241, 241)
        TabControl(widget).borderColor = gui.theme.borderColor
      else:
        TabControl(widget).tabColor = initColor(220, 220, 220)
        TabControl(widget).activeTabColor = initColor(255, 255, 255)
        TabControl(widget).textColor = initColor(0, 0, 0)
        TabControl(widget).borderColor = initColor(180, 180, 180)
    
    elif widget of Menu:
      if isDarkTheme:
        Menu(widget).bgColor = initColor(45, 45, 48)
        Menu(widget).hoverColor = gui.theme.hoverColor
        Menu(widget).textColor = initColor(241, 241, 241)
        Menu(widget).borderColor = gui.theme.borderColor
      else:
        Menu(widget).bgColor = initColor(255, 255, 255)
        Menu(widget).hoverColor = initColor(229, 243, 255)
        Menu(widget).textColor = initColor(0, 0, 0)
        Menu(widget).borderColor = initColor(160, 160, 160)
    
    elif widget of MenuBar:
      if isDarkTheme:
        MenuBar(widget).bgColor = initColor(45, 45, 48)
        MenuBar(widget).textColor = initColor(241, 241, 241)
        MenuBar(widget).hoverColor = gui.theme.hoverColor
        MenuBar(widget).borderColor = gui.theme.borderColor
      else:
        MenuBar(widget).bgColor = initColor(240, 240, 240)
        MenuBar(widget).textColor = initColor(0, 0, 0)
        MenuBar(widget).hoverColor = initColor(229, 243, 255)
        MenuBar(widget).borderColor = initColor(180, 180, 180)
    
    elif widget of ToolBar:
      ToolBar(widget).bgColor = gui.theme.bgColor
      ToolBar(widget).borderColor = gui.theme.borderColor
    
    elif widget of StatusBar:
      if isDarkTheme:
        StatusBar(widget).bgColor = initColor(30, 30, 30)
        StatusBar(widget).textColor = initColor(241, 241, 241)
        StatusBar(widget).borderColor = gui.theme.borderColor
      else:
        StatusBar(widget).bgColor = initColor(240, 240, 240)
        StatusBar(widget).textColor = initColor(0, 0, 0)
        StatusBar(widget).borderColor = initColor(180, 180, 180)
  
  echo "Тема изменена на: ", if isDarkTheme: "тёмную" else: "светлую"

let menuSettingsLang = createMenuItem("Язык") do (item: MenuItem):
  gui.showInfoDialog("Настройки", "Выбор языка")

menuSettings.addMenuItem(menuSettingsTheme)
menuSettings.addMenuItem(menuSettingsLang)

# Меню "Обработка"
let menuProcess = createMenu("Обработка", 0, 0, 180)
let menuProcessStart = createMenuItem("Запустить") do (item: MenuItem):
  gui.showInfoDialog("Обработка", "Запустить обработку данных")
menuProcessStart.shortcut = "F5"

let menuProcessStop = createMenuItem("Остановить") do (item: MenuItem):
  gui.showInfoDialog("Обработка", "Остановить обработку")
menuProcessStop.shortcut = "F6"

menuProcess.addMenuItem(menuProcessStart)
menuProcess.addMenuItem(menuProcessStop)

# Меню "Помощь"
let menuHelp = createMenu("Помощь", 0, 0, 180)
let menuHelpDocs = createMenuItem("Документация") do (item: MenuItem):
  gui.showInfoDialog("Помощь", "Открыть документацию")
menuHelpDocs.shortcut = "F1"

let menuHelpAbout = createMenuItem("О программе") do (item: MenuItem):
  gui.showInfoDialog("О программе", "SDL GUI Library Demo\nВерсия 0.3\n2026")

menuHelp.addMenuItem(menuHelpDocs)
menuHelp.addMenuItem(createMenuSeparator())
menuHelp.addMenuItem(menuHelpAbout)

# Добавляем все меню в MenuBar
menuBar.addMenu(menuFile)
menuBar.addMenu(menuEdit)
menuBar.addMenu(menuSettings)
menuBar.addMenu(menuProcess)
menuBar.addMenu(menuHelp)

gui.addWidget(menuBar)

# =============================================================================
# Создание виджетов
# =============================================================================

# --- Кнопки ---
let btnNormal = createButton("btn1", 20, 50, 180, 40, "Обычная кнопка")
# Добавляем иконку на кнопку
if not buttonIcon.isNil:
  btnNormal.icon = buttonIcon
  # Устанавливаем фиксированный размер иконки 24x24 (или пропорционально высоте кнопки)
  let iconSize = 24  # Размер иконки в пикселях
  let iconPadding = 8  # Отступ слева
  let iconY = (40 - iconSize) div 2  # Центрируем по вертикали
  btnNormal.iconRect = initRect(iconPadding, iconY, iconSize, iconSize)
btnNormal.onClick = proc(btn: Button) =
  echo "Нажата обычная кнопка!"
  gui.showInfoDialog("Информация", "Вы нажали на кнопку!")

let btnAccent = createButton("btn2", 210, 50, 150, 40, "Акцентная кнопка")
btnAccent.bgColor = initColor(0, 120, 215)
btnAccent.textColor = initColor(255, 255, 255)
btnAccent.onClick = proc(btn: Button) =
  gui.showQuestionDialog("Вопрос", "Вы уверены?") do (dlg: Dialog, result: DialogButton):
    if result == dbYes:
      echo "Пользователь подтвердил"
    else:
      echo "Пользователь отказался"

let btnDisabled = createButton("btn3", 370, 50, 150, 40, "Недоступна")
btnDisabled.enabled = false

gui.addWidget(btnNormal)
gui.addWidget(btnAccent)
gui.addWidget(btnDisabled)

# --- Текстовые поля ---
let textField1 = createTextField("text1", 20, 110, 200, 30, "Введите текст...")
textField1.onChange = proc(field: TextField, newText: string) =
  echo "Текст изменён: ", newText

let textField2 = createTextField("text2", 230, 110, 200, 30, "Пароль")
textField2.isPassword = true
textField2.passwordChar = "*".toRunes[0]

gui.addWidget(textField1)
gui.addWidget(textField2)

# --- Чекбоксы ---
let check1 = createCheckBox("check1", 20, 160, "Включить опцию 1", false)
check1.onChange = proc(cb: CheckBox, checked: bool) =
  echo "Чекбокс 1: ", checked

let check2 = createCheckBox("check2", 20, 190, "Включить опцию 2", true)
check2.onChange = proc(cb: CheckBox, checked: bool) =
  echo "Чекбокс 2: ", checked

gui.addWidget(check1)
gui.addWidget(check2)

# --- Радиокнопки ---
let radio1 = createRadioButton("radio1", 20, 230, "Вариант А", "group1")
let radio2 = createRadioButton("radio2", 20, 260, "Вариант Б", "group1")
let radio3 = createRadioButton("radio3", 20, 290, "Вариант В", "group1")

radio1.checked = true
radio1.onChange = proc(rb: RadioButton, checked: bool) =
  if checked: echo "Выбран вариант А"

radio2.onChange = proc(rb: RadioButton, checked: bool) =
  if checked: echo "Выбран вариант Б"

radio3.onChange = proc(rb: RadioButton, checked: bool) =
  if checked: echo "Выбран вариант В"

gui.registerRadioButton(radio1)
gui.registerRadioButton(radio2)
gui.registerRadioButton(radio3)

gui.addWidget(radio1)
gui.addWidget(radio2)
gui.addWidget(radio3)

# --- Слайдеры ---
let slider1 = createSlider("slider1", 250, 160, 200, 20, 0, 100, alignLeft)
slider1.value = 50
slider1.onChange = proc(s: Slider, value: float) =
  echo "Слайдер 1: ", value

let slider2 = createSlider("slider2", 470, 160, 20, 150, 0, 100, alignTop)
slider2.value = 25
slider2.onChange = proc(s: Slider, value: float) =
  echo "Слайдер 2: ", value

gui.addWidget(slider1)
gui.addWidget(slider2)

# --- Прогресс-бары ---
let progress1 = createProgressBar("progress1", 250, 200, 200, 25, 0, 100)
progress1.value = 75

let progress2 = createProgressBar("progress2", 250, 240, 200, 25, 0, 100)
progress2.value = 33
progress2.fillColor = initColor(255, 140, 0)

gui.addWidget(progress1)
gui.addWidget(progress2)

# --- Метки ---
let label1 = createLabel("label1", 540, 50, 200, 30, "Текстовая метка")
let label2 = createLabel("label2", 540, 80, 200, 30, "Центрированная")
label2.textAlign = alignCenter
label2.textColor = initColor(0, 100, 200)

gui.addWidget(label1)
gui.addWidget(label2)

# --- Многострочное текстовое поле ---
let textArea1 = createTextArea("textarea1", 540, 130, 280, 180)
textArea1.lines = @[
  "Это многострочное",
  "текстовое поле.",
  "",
  "Можно редактировать",
  "несколько строк текста."
]
textArea1.onChange = proc(area: TextArea) =
  echo "TextArea изменён"

gui.addWidget(textArea1)

# --- Список ---
let listBox1 = createListBox("list1", 20, 310, 200, 150)
listBox1.items = @[
  "Элемент 1",
  "Элемент 2", 
  "Элемент 3",
  "Элемент 4",
  "Элемент 5",
  "Элемент 6",
  "Элемент 7",
  "Элемент 8"
]
listBox1.onSelect = proc(list: ListBox, index: int) =
  echo "Выбран элемент: ", list.items[index]

gui.addWidget(listBox1)

# --- Дополнительные кнопки для тестирования диалогов ---
let btnInfo = createButton("btnInfo", 230, 310, 100, 30, "Инфо")
btnInfo.onClick = proc(btn: Button) =
  gui.showInfoDialog("Информация", "Это информационное сообщение")

let btnWarning = createButton("btnWarning", 230, 350, 100, 30, "Внимание")
btnWarning.onClick = proc(btn: Button) =
  gui.showWarningDialog("Внимание", "Это предупреждение!")

let btnError = createButton("btnError", 230, 390, 100, 30, "Ошибка")
btnError.onClick = proc(btn: Button) =
  gui.showErrorDialog("Ошибка", "Произошла ошибка!")

let btnConfirm = createButton("btnConfirm", 230, 430, 100, 30, "Подтвердить")
btnConfirm.onClick = proc(btn: Button) =
  gui.showConfirmDialog("Подтверждение", "Продолжить операцию?") do (dlg: Dialog, result: DialogButton):
    if result == dbOk:
      echo "Операция подтверждена"
    else:
      echo "Операция отменена"

gui.addWidget(btnInfo)
gui.addWidget(btnWarning)
gui.addWidget(btnError)
gui.addWidget(btnConfirm)

# --- Кнопка для переключения темы ---
let btnTheme = createButton("btnTheme", 340, 310, 150, 30, "Сменить тему")
btnTheme.onClick = proc(btn: Button) =
  isDarkTheme = not isDarkTheme
  if isDarkTheme:
    gui.theme = createDarkTheme(font)
  else:
    gui.theme = createDefaultTheme(font)
  
  # Обновляем цвета виджетов согласно новой теме
  for widget in gui.widgets:
    if widget of Button:
      # Обновляем только кнопки с цветами по умолчанию (не акцентные)
      if widget.id != "btn2":  # Не трогаем акцентную кнопку
        Button(widget).bgColor = gui.theme.bgColor
        Button(widget).textColor = gui.theme.textColor
        Button(widget).borderColor = gui.theme.borderColor
    
    elif widget of TextField:
      # ИСПРАВЛЕНИЕ: текстовые поля всегда имеют белый/тёмный фон
      if isDarkTheme:
        TextField(widget).bgColor = initColor(30, 30, 30)
        TextField(widget).textColor = initColor(241, 241, 241)
        TextField(widget).borderColor = gui.theme.borderColor
      else:
        TextField(widget).bgColor = initColor(255, 255, 255)
        TextField(widget).textColor = initColor(0, 0, 0)
        TextField(widget).borderColor = initColor(122, 122, 122)
    
    elif widget of TextArea:
      # ИСПРАВЛЕНИЕ: TextArea также имеет белый/тёмный фон
      if isDarkTheme:
        TextArea(widget).bgColor = initColor(30, 30, 30)
        TextArea(widget).textColor = initColor(241, 241, 241)
        TextArea(widget).borderColor = gui.theme.borderColor
      else:
        TextArea(widget).bgColor = initColor(255, 255, 255)
        TextArea(widget).textColor = initColor(0, 0, 0)
        TextArea(widget).borderColor = initColor(122, 122, 122)
    
    elif widget of CheckBox:
      CheckBox(widget).bgColor = gui.theme.bgColor
      CheckBox(widget).textColor = gui.theme.textColor
      CheckBox(widget).borderColor = gui.theme.borderColor
    
    elif widget of RadioButton:
      RadioButton(widget).bgColor = gui.theme.bgColor
      RadioButton(widget).textColor = gui.theme.textColor
      RadioButton(widget).borderColor = gui.theme.borderColor
    
    elif widget of Label:
      Label(widget).bgColor = gui.theme.bgColor
      if widget.id == "label1":  # Обновляем только обычные метки
        Label(widget).textColor = gui.theme.textColor
    
    elif widget of Panel:
      Panel(widget).bgColor = gui.theme.bgColor
      Panel(widget).borderColor = gui.theme.borderColor
    
    elif widget of ListBox:
      # ИСПРАВЛЕНИЕ: ListBox также имеет белый/тёмный фон
      if isDarkTheme:
        ListBox(widget).bgColor = initColor(30, 30, 30)
        ListBox(widget).textColor = initColor(241, 241, 241)
        ListBox(widget).borderColor = gui.theme.borderColor
      else:
        ListBox(widget).bgColor = initColor(255, 255, 255)
        ListBox(widget).textColor = initColor(0, 0, 0)
        ListBox(widget).borderColor = initColor(122, 122, 122)
    
    elif widget of ComboBox:
      # ComboBox также имеет белый/тёмный фон
      if isDarkTheme:
        ComboBox(widget).bgColor = initColor(30, 30, 30)
        ComboBox(widget).textColor = initColor(241, 241, 241)
        ComboBox(widget).borderColor = gui.theme.borderColor
        ComboBox(widget).hoverColor = gui.theme.hoverColor
        ComboBox(widget).selectedColor = gui.theme.accentColor
      else:
        ComboBox(widget).bgColor = initColor(255, 255, 255)
        ComboBox(widget).textColor = initColor(0, 0, 0)
        ComboBox(widget).borderColor = initColor(122, 122, 122)
        ComboBox(widget).hoverColor = initColor(229, 243, 255)
        ComboBox(widget).selectedColor = initColor(0, 120, 215)
    
    elif widget of SpinBox:
      # SpinBox также имеет белый/тёмный фон
      if isDarkTheme:
        SpinBox(widget).bgColor = initColor(30, 30, 30)
        SpinBox(widget).textColor = initColor(241, 241, 241)
        SpinBox(widget).borderColor = gui.theme.borderColor
        SpinBox(widget).buttonColor = initColor(60, 60, 60)
      else:
        SpinBox(widget).bgColor = initColor(255, 255, 255)
        SpinBox(widget).textColor = initColor(0, 0, 0)
        SpinBox(widget).borderColor = initColor(122, 122, 122)
        SpinBox(widget).buttonColor = initColor(240, 240, 240)
    
    elif widget of TabControl:
      # TabControl обновление цветов
      if isDarkTheme:
        TabControl(widget).tabColor = initColor(60, 60, 60)
        TabControl(widget).activeTabColor = initColor(45, 45, 48)
        TabControl(widget).textColor = initColor(241, 241, 241)
        TabControl(widget).borderColor = gui.theme.borderColor
      else:
        TabControl(widget).tabColor = initColor(220, 220, 220)
        TabControl(widget).activeTabColor = initColor(255, 255, 255)
        TabControl(widget).textColor = initColor(0, 0, 0)
        TabControl(widget).borderColor = initColor(180, 180, 180)
    
    elif widget of Menu:
      # Menu обновление цветов
      if isDarkTheme:
        Menu(widget).bgColor = initColor(45, 45, 48)
        Menu(widget).hoverColor = gui.theme.hoverColor
        Menu(widget).textColor = initColor(241, 241, 241)
        Menu(widget).borderColor = gui.theme.borderColor
      else:
        Menu(widget).bgColor = initColor(255, 255, 255)
        Menu(widget).hoverColor = initColor(229, 243, 255)
        Menu(widget).textColor = initColor(0, 0, 0)
        Menu(widget).borderColor = initColor(160, 160, 160)
    
    elif widget of ToolBar:
      # ToolBar обновление цветов
      ToolBar(widget).bgColor = gui.theme.bgColor
      ToolBar(widget).borderColor = gui.theme.borderColor
  
  echo "Тема изменена на: ", if isDarkTheme: "тёмную" else: "светлую"

gui.addWidget(btnTheme)


# --- ComboBox (Выпадающий список) ---
let combo1 = createComboBox("combo1", 840, 130, 180, 30)
combo1.items = @["Вариант 1", "Вариант 2", "Вариант 3", "Вариант 4", "Вариант 5"]
combo1.selectedIndex = 0
combo1.onSelect = proc(combo: ComboBox, index: int) =
  echo "Выбран в ComboBox: ", combo.items[index]

gui.addWidget(combo1)

# --- SpinBox (Числовое поле со стрелками) ---
let spinInt = createSpinBox("spinInt", 840, 180, 120, 30, 0, 100, 0)
spinInt.value = 50
spinInt.onChange = proc(spin: SpinBox, value: float) =
  echo "SpinBox целое: ", value.int

let spinFloat = createSpinBox("spinFloat", 840, 220, 120, 30, 0.0, 10.0, 2)
spinFloat.value = 5.5
spinFloat.onChange = proc(spin: SpinBox, value: float) =
  echo "SpinBox дробное: ", value

gui.addWidget(spinInt)
gui.addWidget(spinFloat)

# --- TabControl (Вкладки) ---
let tabControl = createTabControl("tabs1", 20, 480, 460, 220)

let tab1 = createTab("Первая вкладка")
let tab1Label = createLabel("tab1_label", 30, 520, 200, 30, "Содержимое вкладки 1")
tab1Label.textColor = initColor(0, 100, 200)
tab1.content.add(tab1Label)

let tab2 = createTab("Вторая вкладка")
let tab2Label = createLabel("tab2_label", 30, 520, 200, 30, "Содержимое вкладки 2")
tab2Label.textColor = initColor(200, 0, 100)
tab2.content.add(tab2Label)

let tab3 = createTab("Третья вкладка")
let tab3Label = createLabel("tab3_label", 30, 520, 200, 30, "Содержимое вкладки 3")
tab3Label.textColor = initColor(100, 150, 0)
tab3.content.add(tab3Label)

tabControl.addTab(tab1)
tabControl.addTab(tab2)
tabControl.addTab(tab3)
tabControl.onTabChange = proc(tc: TabControl, index: int) =
  echo "Переключено на вкладку: ", tc.tabs[index].title

gui.addWidget(tabControl)

# --- Menu (Контекстное меню) ---
let contextMenu = createMenu("menu1", 500, 480, 180)
let menuItem1 = createMenuItem("Открыть") do (item: MenuItem):
  echo "Меню: Открыть"
  gui.showInfoDialog("Меню", "Выбран пункт: Открыть")

let menuItem2 = createMenuItem("Сохранить") do (item: MenuItem):
  echo "Меню: Сохранить"
  gui.showInfoDialog("Меню", "Выбран пункт: Сохранить")

let menuItem3 = createMenuItem("Экспорт") do (item: MenuItem):
  echo "Меню: Экспорт"

let menuSep = createMenuSeparator()

let menuItem4 = createMenuItem("Выход") do (item: MenuItem):
  echo "Меню: Выход"
  gui.showQuestionDialog("Подтверждение", "Действительно выйти?") do (dlg: Dialog, result: DialogButton):
    if result == dbYes:
      echo "Выход подтверждён"

contextMenu.addMenuItem(menuItem1)
contextMenu.addMenuItem(menuItem2)
contextMenu.addMenuItem(menuItem3)
contextMenu.addMenuItem(menuSep)
contextMenu.addMenuItem(menuItem4)

# Кнопка для открытия меню
let btnMenu = createButton("btnMenu", 500, 440, 180, 30, "Показать меню")
btnMenu.onClick = proc(btn: Button) =
  contextMenu.isOpen = not contextMenu.isOpen

gui.addWidget(btnMenu)
gui.addWidget(contextMenu)

# --- ToolBar (Панель инструментов) ---
let toolbar = createToolBar("toolbar1", 700, 480, 280, 44)

let toolBtn1 = createButton("toolbtn1", 0, 0, 32, 32, "1")
toolBtn1.onClick = proc(btn: Button) =
  echo "ToolBar: Кнопка 1"
  gui.showInfoDialog("Информация", "Нажата кнопка инструментов 1")

let toolBtn2 = createButton("toolbtn2", 0, 0, 32, 32, "2")
toolBtn2.onClick = proc(btn: Button) =
  echo "ToolBar: Кнопка 2"

let toolBtn3 = createButton("toolbtn3", 0, 0, 32, 32, "3")
toolBtn3.onClick = proc(btn: Button) =
  echo "ToolBar: Кнопка 3"

let toolBtn4 = createButton("toolbtn4", 0, 0, 32, 32, "4")
toolBtn4.onClick = proc(btn: Button) =
  echo "ToolBar: Кнопка 4"

toolbar.addToolButton(toolBtn1)
toolbar.addToolButton(toolBtn2)
toolbar.addToolButton(toolBtn3)
toolbar.addToolButton(toolBtn4)

gui.addWidget(toolbar)

# --- Tooltips (Всплывающие подсказки) ---
# Добавляем подсказки к некоторым виджетам
btnNormal.tooltip = "Это обычная кнопка\nНажмите для просмотра информации"
btnAccent.tooltip = "Акцентная кнопка\nОткрывает диалог подтверждения"
slider1.tooltip = "Горизонтальный слайдер\nДиапазон: 0-100"
combo1.tooltip = "Выпадающий список\nВыберите один из вариантов"
spinInt.tooltip = "Целочисленный спиннер\nДиапазон: 0-100"


# --- StatusBar (Строка состояния) ---
let statusBar = createStatusBar("statusbar", 0, 768 - 25, 1024, 25)
statusBar.setSections(@[
  "Готов",
  "Виджетов: " & $gui.widgets.len,
  "SDL GUI Library v0.3"
])

# Обновляем цвета строки состояния при смене темы
proc updateStatusBarTheme() =
  if isDarkTheme:
    statusBar.bgColor = initColor(30, 30, 30)
    statusBar.textColor = initColor(241, 241, 241)
    statusBar.borderColor = gui.theme.borderColor
  else:
    statusBar.bgColor = initColor(240, 240, 240)
    statusBar.textColor = initColor(0, 0, 0)
    statusBar.borderColor = initColor(180, 180, 180)

gui.addWidget(statusBar)

# =============================================================================
# Главный цикл
# =============================================================================

var running = true
var event: SdlEvent

# Анимация прогресс-бара
var progressAnimValue = 0.0

echo "GUI Demo запущен!"
echo "Используйте мышь для взаимодействия с элементами"

while running:
  # Обработка событий
  while SDL_PollEvent(addr event) == SDL_TRUE:
    case event.type:
    of SDL_EVENT_QUIT:
      running = false
    
    of SDL_EVENT_MOUSE_MOTION:
      # Обновляем позицию курсора в статус-баре
      statusBar.setSections(@[
        "Курсор: (" & $event.motion.x.int & ", " & $event.motion.y.int & ")",
        "Виджетов: " & $gui.widgets.len,
        "SDL GUI Library v0.3"
      ])
    
    else:
      discard
    
    # ИСПРАВЛЕНИЕ: сначала передаём событие в GUI
    # Если GUI обработал событие (вернул true), пропускаем дальнейшую обработку
    if not gui.handleGuiEvent(addr event):
      # Событие не обработано GUI, обрабатываем сами
      if event.type == SDL_EVENT_KEY_DOWN:
        if event.key.key == SDLK_ESCAPE:
          running = false
  
  # Анимация прогресс-бара
  progressAnimValue += 0.5
  if progressAnimValue > 100:
    progressAnimValue = 0
  progress1.value = progressAnimValue
  
  # Обновление мигания курсора
  updateCursorBlink(gui)
  
  # Обновление tooltip
  updateTooltip(gui)
  
  # Проверяем наведение на виджеты для tooltip
  for widget in gui.widgets:
    if widget.visible and widget.enabled:
      checkTooltipHover(gui, widget)
  
  # Очистка экрана
  let bgColor = gui.theme.bgColor
  discard SDL_SetRenderDrawColor(renderer, bgColor.r, bgColor.g, bgColor.b, bgColor.a)
  discard SDL_RenderClear(renderer)
  
  # Рендеринг GUI
  gui.renderGui()
  
  # Обновление экрана
  discard SDL_RenderPresent(renderer)
  
  # Небольшая задержка
  SDL_Delay(16) # ~60 FPS

# Очистка ресурсов
TTF_CloseFont(font)
SDL_DestroyRenderer(renderer)
SDL_DestroyWindow(window)
TTF_Quit()
SDL_Quit()

echo "Программа завершена"




# nim c -d:release gui_demo.nim



