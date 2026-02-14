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

# Активируем текстовый ввод (необходимо для TextField)
discard SDL_StartTextInput(window)

# =============================================================================
# Создание виджетов
# =============================================================================

# --- Кнопки ---
let btnNormal = createButton("btn1", 20, 20, 150, 40, "Обычная кнопка")
btnNormal.onClick = proc(btn: Button) =
  echo "Нажата обычная кнопка!"
  gui.showInfoDialog("Информация", "Вы нажали на кнопку!")

let btnAccent = createButton("btn2", 180, 20, 150, 40, "Акцентная кнопка")
btnAccent.bgColor = initColor(0, 120, 215)
btnAccent.textColor = initColor(255, 255, 255)
btnAccent.onClick = proc(btn: Button) =
  gui.showQuestionDialog("Вопрос", "Вы уверены?") do (dlg: Dialog, result: DialogButton):
    if result == dbYes:
      echo "Пользователь подтвердил"
    else:
      echo "Пользователь отказался"

let btnDisabled = createButton("btn3", 340, 20, 150, 40, "Недоступна")
btnDisabled.enabled = false

gui.addWidget(btnNormal)
gui.addWidget(btnAccent)
gui.addWidget(btnDisabled)

# --- Текстовые поля ---
let textField1 = createTextField("text1", 20, 80, 200, 30, "Введите текст...")
textField1.onChange = proc(field: TextField, newText: string) =
  echo "Текст изменён: ", newText

let textField2 = createTextField("text2", 230, 80, 200, 30, "Пароль")
textField2.isPassword = true
textField2.passwordChar = "*".toRunes[0]

gui.addWidget(textField1)
gui.addWidget(textField2)

# --- Чекбоксы ---
let check1 = createCheckBox("check1", 20, 130, "Включить опцию 1", false)
check1.onChange = proc(cb: CheckBox, checked: bool) =
  echo "Чекбокс 1: ", checked

let check2 = createCheckBox("check2", 20, 160, "Включить опцию 2", true)
check2.onChange = proc(cb: CheckBox, checked: bool) =
  echo "Чекбокс 2: ", checked

gui.addWidget(check1)
gui.addWidget(check2)

# --- Радиокнопки ---
let radio1 = createRadioButton("radio1", 20, 200, "Вариант А", "group1")
let radio2 = createRadioButton("radio2", 20, 230, "Вариант Б", "group1")
let radio3 = createRadioButton("radio3", 20, 260, "Вариант В", "group1")

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
let slider1 = createSlider("slider1", 250, 130, 200, 20, 0, 100, alignLeft)
slider1.value = 50
slider1.onChange = proc(s: Slider, value: float) =
  echo "Слайдер 1: ", value

let slider2 = createSlider("slider2", 470, 130, 20, 150, 0, 100, alignTop)
slider2.value = 25
slider2.onChange = proc(s: Slider, value: float) =
  echo "Слайдер 2: ", value

gui.addWidget(slider1)
gui.addWidget(slider2)

# --- Прогресс-бары ---
let progress1 = createProgressBar("progress1", 250, 170, 200, 25, 0, 100)
progress1.value = 75

let progress2 = createProgressBar("progress2", 250, 210, 200, 25, 0, 100)
progress2.value = 33
progress2.fillColor = initColor(255, 140, 0)

gui.addWidget(progress1)
gui.addWidget(progress2)

# --- Метки ---
let label1 = createLabel("label1", 500, 20, 200, 30, "Текстовая метка")
let label2 = createLabel("label2", 500, 50, 200, 30, "Центрированная")
label2.textAlign = alignCenter
label2.textColor = initColor(0, 100, 200)

gui.addWidget(label1)
gui.addWidget(label2)

# --- Многострочное текстовое поле ---
let textArea1 = createTextArea("textarea1", 500, 100, 280, 180)
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
var isDarkTheme = false
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
  
  echo "Тема изменена на: ", if isDarkTheme: "тёмную" else: "светлую"

gui.addWidget(btnTheme)

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
    
    else:
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
  gui.updateCursorBlink()
  
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



