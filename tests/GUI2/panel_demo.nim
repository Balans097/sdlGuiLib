################################################################
##           Panel Demo
##    Демонстрация работы с Panel
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
  "Panel Demo",
  800, 600,
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

# Загрузка шрифта
var font = TTF_OpenFont("arial.ttf", 14.0)
if font.isNil:
  font = TTF_OpenFont("C:/Windows/Fonts/arial.ttf", 14.0)
if font.isNil:
  font = TTF_OpenFont("/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf", 14.0)
if font.isNil:
  font = TTF_OpenFont("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 14.0)
if font.isNil:
  font = TTF_OpenFont("/System/Library/Fonts/Helvetica.ttc", 14.0)
if font.isNil:
  echo "ОШИБКА: Не удалось загрузить шрифт!"
  TTF_Quit()
  SDL_Quit()
  quit(1)

# Создание GUI менеджера
var gui = createGuiManager(renderer, font)

# Активируем текстовый ввод
discard SDL_StartTextInput(window)

# =============================================================================
# Создание панелей с виджетами
# =============================================================================

# Панель 1 - с кнопками
let panel1 = createPanel("panel1", 20, 20, 360, 250)
panel1.bgColor = initColor(240, 248, 255)  # AliceBlue
panel1.borderColor = initColor(100, 149, 237)  # CornflowerBlue

# Заголовок панели (координаты относительно панели)
let label1 = createLabel("label1", 10, 10, 340, 30, "Панель с кнопками")
label1.textColor = initColor(0, 0, 128)
panel1.addChild(label1)

# Кнопки в панели (координаты относительно панели)
let btn1 = createButton("btn1", 10, 50, 150, 40, "Кнопка 1")
btn1.onClick = proc(btn: Button) =
  echo "[Panel1] Нажата Кнопка 1"
  gui.showInfoDialog("Панель 1", "Вы нажали кнопку 1 в первой панели")
panel1.addChild(btn1)

let btn2 = createButton("btn2", 10, 100, 150, 40, "Кнопка 2")
btn2.onClick = proc(btn: Button) =
  echo "[Panel1] Нажата Кнопка 2"
  gui.showInfoDialog("Панель 1", "Вы нажали кнопку 2 в первой панели")
panel1.addChild(btn2)

let btn3 = createButton("btn3", 10, 150, 150, 40, "Кнопка 3")
btn3.onClick = proc(btn: Button) =
  echo "[Panel1] Нажата Кнопка 3"
  gui.showInfoDialog("Панель 1", "Вы нажали кнопку 3 в первой панели")
panel1.addChild(btn3)

# Чекбокс в панели
let checkbox1 = createCheckBox("cb1", 180, 50, "Опция 1")
checkbox1.onChange = proc(cb: CheckBox, checked: bool) =
  echo "[Panel1] Чекбокс: ", checked
panel1.addChild(checkbox1)

let checkbox2 = createCheckBox("cb2", 180, 90, "Опция 2")
checkbox2.onChange = proc(cb: CheckBox, checked: bool) =
  echo "[Panel1] Чекбокс 2: ", checked
panel1.addChild(checkbox2)

gui.addWidget(panel1)

# Панель 2 - с полями ввода
let panel2 = createPanel("panel2", 400, 20, 380, 250)
panel2.bgColor = initColor(255, 250, 240)  # FloralWhite
panel2.borderColor = initColor(255, 140, 0)  # DarkOrange

let label2 = createLabel("label2", 10, 10, 360, 30, "Панель с полями ввода")
label2.textColor = initColor(139, 69, 19)
panel2.addChild(label2)

let labelName = createLabel("labelName", 10, 50, 100, 30, "Имя:")
panel2.addChild(labelName)

let fieldName = createTextField("fieldName", 120, 50, 240, 30)
fieldName.placeholder = "Введите имя"
fieldName.onChange = proc(field: TextField, newText: string) =
  echo "[Panel2] Имя изменено: ", newText
panel2.addChild(fieldName)

let labelEmail = createLabel("labelEmail", 10, 90, 100, 30, "Email:")
panel2.addChild(labelEmail)

let fieldEmail = createTextField("fieldEmail", 120, 90, 240, 30)
fieldEmail.placeholder = "example@mail.com"
fieldEmail.onChange = proc(field: TextField, newText: string) =
  echo "[Panel2] Email изменён: ", newText
panel2.addChild(fieldEmail)

let btnSubmit = createButton("btnSubmit", 120, 140, 120, 40, "Отправить")
btnSubmit.bgColor = initColor(34, 139, 34)  # ForestGreen
btnSubmit.textColor = initColor(255, 255, 255)
btnSubmit.onClick = proc(btn: Button) =
  echo "[Panel2] Отправка формы"
  let name = fieldName.text
  let email = fieldEmail.text
  if name.len > 0 and email.len > 0:
    gui.showInfoDialog("Форма", "Имя: " & name & "\nEmail: " & email)
  else:
    gui.showWarningDialog("Предупреждение", "Заполните все поля!")
panel2.addChild(btnSubmit)

gui.addWidget(panel2)

# Панель 3 - вложенная панель
let panel3 = createPanel("panel3", 20, 290, 760, 280)
panel3.bgColor = initColor(245, 245, 245)
panel3.borderColor = initColor(128, 128, 128)

let label3 = createLabel("label3", 10, 10, 740, 30, "Панель с вложенной панелью")
label3.textColor = initColor(0, 0, 0)
panel3.addChild(label3)

# Вложенная панель
let panel3inner = createPanel("panel3inner", 20, 50, 350, 210)
panel3inner.bgColor = initColor(255, 255, 224)  # LightYellow
panel3inner.borderColor = initColor(218, 165, 32)  # GoldenRod

let label3inner = createLabel("label3inner", 10, 10, 330, 30, "Вложенная панель")
label3inner.textColor = initColor(184, 134, 11)
panel3inner.addChild(label3inner)

let innerBtn1 = createButton("innerBtn1", 10, 50, 150, 40, "Внутренняя кнопка 1")
innerBtn1.onClick = proc(btn: Button) =
  echo "[Panel3Inner] Нажата внутренняя кнопка 1"
  gui.showInfoDialog("Вложенная панель", "Кнопка из вложенной панели!")
panel3inner.addChild(innerBtn1)

let innerBtn2 = createButton("innerBtn2", 10, 100, 150, 40, "Внутренняя кнопка 2")
innerBtn2.onClick = proc(btn: Button) =
  echo "[Panel3Inner] Нажата внутренняя кнопка 2"
panel3inner.addChild(innerBtn2)

let innerSlider = createSlider("innerSlider", 10, 160, 330, 30, 0.0, 100.0)
innerSlider.value = 50.0
innerSlider.onChange = proc(slider: Slider, value: float) =
  echo "[Panel3Inner] Слайдер: ", value
panel3inner.addChild(innerSlider)

panel3.addChild(panel3inner)

# Виджеты рядом с вложенной панелью
let label3side = createLabel("label3side", 390, 50, 350, 30, "Виджеты рядом с вложенной панелью:")
panel3.addChild(label3side)

let listbox1 = createListBox("list1", 390, 90, 200, 150)
listbox1.items = @["Элемент 1", "Элемент 2", "Элемент 3", "Элемент 4", "Элемент 5"]
listbox1.onSelect = proc(lb: ListBox, index: int) =
  echo "[Panel3] Выбран элемент: ", lb.items[index]
panel3.addChild(listbox1)

let btnClearSelection = createButton("btnClear", 600, 90, 140, 40, "Очистить выбор")
btnClearSelection.onClick = proc(btn: Button) =
  listbox1.selectedIndex = -1
  echo "[Panel3] Выбор очищен"
panel3.addChild(btnClearSelection)

gui.addWidget(panel3)

# =============================================================================
# Главный цикл
# =============================================================================

var running = true
var event: SdlEvent

echo "Panel Demo запущен!"
echo "Демонстрация работы панелей с вложенными виджетами"

while running:
  while SDL_PollEvent(addr event) == SDL_TRUE:
    if event.type == SDL_EVENT_QUIT:
      running = false
      echo "Приложение закрывается..."
    else:
      discard gui.handleGuiEvent(addr event)
  
  # Очистка экрана
  discard SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255)
  discard SDL_RenderClear(renderer)
  
  # Отрисовка GUI
  gui.renderGui()
  
  # Вывод на экран
  discard SDL_RenderPresent(renderer)
  
  # Ограничение FPS
  SDL_Delay(16)  # ~60 FPS

# Очистка ресурсов
TTF_CloseFont(font)
SDL_DestroyRenderer(renderer)
SDL_DestroyWindow(window)
TTF_Quit()
SDL_Quit()

echo "Приложение завершено."
