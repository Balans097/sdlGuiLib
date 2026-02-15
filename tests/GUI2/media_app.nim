################################################################
##           Media Application
##    Медиаприложение с панелями и вкладками
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
  "Медиаприложение — эффективная обработка видеоконтента",
  1280, 720,
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
# Переменные для управления активной вкладкой
# =============================================================================
type
  TabType = enum
    tabStart,      # Начало
    tabVideo,      # Видео
    tabAudio,      # Аудио
    tabSubtitles,  # Субтитры
    tabOther       # Прочее

var currentTab: TabType = tabStart

# =============================================================================
# ГЛАВНОЕ МЕНЮ
# =============================================================================

let menuBar = createMenuBar("mainmenu", 0, 0, 1280, 30)

# ---------- Меню "Файл" ----------
let menuFile = createMenu("Файл", 0, 0, 200)

let menuFileNew = createMenuItem("Новый проект") do (item: MenuItem):
  gui.showInfoDialog("Файл", "Создать новый проект")
  echo "[Меню] Новый проект"
menuFileNew.shortcut = "Ctrl+N"

let menuFileOpen = createMenuItem("Открыть проект") do (item: MenuItem):
  gui.showInfoDialog("Файл", "Открыть существующий проект")
  echo "[Меню] Открыть проект"
menuFileOpen.shortcut = "Ctrl+O"

let menuFileSave = createMenuItem("Сохранить проект") do (item: MenuItem):
  gui.showInfoDialog("Файл", "Сохранить текущий проект")
  echo "[Меню] Сохранить проект"
menuFileSave.shortcut = "Ctrl+S"

let menuFileSaveAs = createMenuItem("Сохранить как...") do (item: MenuItem):
  gui.showInfoDialog("Файл", "Сохранить проект под новым именем")
  echo "[Меню] Сохранить как..."
menuFileSaveAs.shortcut = "Ctrl+Shift+S"

let menuFileExit = createMenuItem("Выход") do (item: MenuItem):
  gui.showQuestionDialog("Выход", "Действительно выйти из приложения?") do (dlg: Dialog, result: DialogButton):
    if result == dbYes:
      echo "[Меню] Выход из приложения"
      quit(0)
menuFileExit.shortcut = "Alt+F4"

menuFile.addMenuItem(menuFileNew)
menuFile.addMenuItem(menuFileOpen)
menuFile.addMenuItem(createMenuSeparator())
menuFile.addMenuItem(menuFileSave)
menuFile.addMenuItem(menuFileSaveAs)
menuFile.addMenuItem(createMenuSeparator())
menuFile.addMenuItem(menuFileExit)

# ---------- Меню "Настройки" ----------
let menuSettings = createMenu("Настройки", 0, 0, 200)

let menuSettingsGeneral = createMenuItem("Общие настройки") do (item: MenuItem):
  gui.showInfoDialog("Настройки", "Открыть общие настройки приложения")
  echo "[Меню] Общие настройки"
menuSettingsGeneral.shortcut = "Ctrl+,"

let menuSettingsVideo = createMenuItem("Настройки видео") do (item: MenuItem):
  gui.showInfoDialog("Настройки", "Настройка параметров видео")
  echo "[Меню] Настройки видео"

let menuSettingsAudio = createMenuItem("Настройки аудио") do (item: MenuItem):
  gui.showInfoDialog("Настройки", "Настройка параметров аудио")
  echo "[Меню] Настройки аудио"

let menuSettingsHotkeys = createMenuItem("Горячие клавиши") do (item: MenuItem):
  gui.showInfoDialog("Настройки", "Настройка горячих клавиш")
  echo "[Меню] Горячие клавиши"

let menuSettingsLanguage = createMenuItem("Язык интерфейса") do (item: MenuItem):
  gui.showInfoDialog("Настройки", "Выбор языка интерфейса")
  echo "[Меню] Язык интерфейса"

menuSettings.addMenuItem(menuSettingsGeneral)
menuSettings.addMenuItem(createMenuSeparator())
menuSettings.addMenuItem(menuSettingsVideo)
menuSettings.addMenuItem(menuSettingsAudio)
menuSettings.addMenuItem(createMenuSeparator())
menuSettings.addMenuItem(menuSettingsHotkeys)
menuSettings.addMenuItem(menuSettingsLanguage)

# ---------- Меню "Медиафайл" ----------
let menuMedia = createMenu("Медиафайл", 0, 0, 200)

let menuMediaAdd = createMenuItem("Добавить медиафайл") do (item: MenuItem):
  gui.showInfoDialog("Медиафайл", "Добавить медиафайл в проект")
  echo "[Меню] Добавить медиафайл"
menuMediaAdd.shortcut = "Ctrl+I"

let menuMediaRemove = createMenuItem("Удалить медиафайл") do (item: MenuItem):
  gui.showInfoDialog("Медиафайл", "Удалить выбранный медиафайл")
  echo "[Меню] Удалить медиафайл"
menuMediaRemove.shortcut = "Delete"

let menuMediaProperties = createMenuItem("Свойства медиафайла") do (item: MenuItem):
  gui.showInfoDialog("Медиафайл", "Просмотр свойств медиафайла")
  echo "[Меню] Свойства медиафайла"
menuMediaProperties.shortcut = "Alt+Enter"

let menuMediaConvert = createMenuItem("Конвертировать") do (item: MenuItem):
  gui.showInfoDialog("Медиафайл", "Конвертировать медиафайл")
  echo "[Меню] Конвертировать"
menuMediaConvert.shortcut = "Ctrl+E"

let menuMediaExport = createMenuItem("Экспортировать") do (item: MenuItem):
  gui.showInfoDialog("Медиафайл", "Экспортировать медиафайл")
  echo "[Меню] Экспортировать"
menuMediaExport.shortcut = "Ctrl+Shift+E"

menuMedia.addMenuItem(menuMediaAdd)
menuMedia.addMenuItem(menuMediaRemove)
menuMedia.addMenuItem(createMenuSeparator())
menuMedia.addMenuItem(menuMediaProperties)
menuMedia.addMenuItem(createMenuSeparator())
menuMedia.addMenuItem(menuMediaConvert)
menuMedia.addMenuItem(menuMediaExport)

# ---------- Меню "Помощь" ----------
let menuHelp = createMenu("Помощь", 0, 0, 200)

let menuHelpContents = createMenuItem("Содержание справки") do (item: MenuItem):
  gui.showInfoDialog("Помощь", "Открыть содержание справки")
  echo "[Меню] Содержание справки"
menuHelpContents.shortcut = "F1"

let menuHelpQuickStart = createMenuItem("Быстрый старт") do (item: MenuItem):
  gui.showInfoDialog("Помощь", "Руководство по быстрому старту")
  echo "[Меню] Быстрый старт"

let menuHelpUpdates = createMenuItem("Проверить обновления") do (item: MenuItem):
  gui.showInfoDialog("Помощь", "Проверка наличия обновлений")
  echo "[Меню] Проверить обновления"

let menuHelpReportBug = createMenuItem("Сообщить об ошибке") do (item: MenuItem):
  gui.showInfoDialog("Помощь", "Отправить отчёт об ошибке")
  echo "[Меню] Сообщить об ошибке"

let menuHelpAbout = createMenuItem("О программе") do (item: MenuItem):
  gui.showInfoDialog("О программе", "Медиа Приложение v1.0\n\nРазработано с использованием SDL и Nim")
  echo "[Меню] О программе"
menuHelpAbout.shortcut = "F12"

menuHelp.addMenuItem(menuHelpContents)
menuHelp.addMenuItem(menuHelpQuickStart)
menuHelp.addMenuItem(createMenuSeparator())
menuHelp.addMenuItem(menuHelpUpdates)
menuHelp.addMenuItem(menuHelpReportBug)
menuHelp.addMenuItem(createMenuSeparator())
menuHelp.addMenuItem(menuHelpAbout)

# Добавление меню в MenuBar
menuBar.addMenu(menuFile)
menuBar.addMenu(menuSettings)
menuBar.addMenu(menuMedia)
menuBar.addMenu(menuHelp)

gui.addWidget(menuBar)

# =============================================================================
# ПАНЕЛЬ ИНСТРУМЕНТОВ (ToolBar) с кнопками-вкладками - ИСПРАВЛЕНО
# =============================================================================

let toolBar = createToolBar("toolbar", 0, 30, 1280, 50)

# Forward declaration для updatePanelVisibility
proc updatePanelVisibility()

# ИСПРАВЛЕНИЕ: позиции кнопок вычисляются правильно
const buttonSpacing = 10
var btnX = buttonSpacing
const btnY = 5  # относительно toolbar (toolbar начинается с Y=30)
const btnWidth = 160
const btnHeight = 40

# Кнопка "Начало"
let btnStart = createButton("btnStart", btnX, btnY, btnWidth, btnHeight, "Начало")
btnStart.onClick = proc(btn: Button) =
  currentTab = tabStart
  updatePanelVisibility()
  echo "[Клик] Переключение на вкладку: Начало"
toolBar.addToolButton(btnStart)
btnX += btnWidth + buttonSpacing

# Кнопка "Видео"
let btnVideo = createButton("btnVideo", btnX, btnY, btnWidth, btnHeight, "Видео")
btnVideo.onClick = proc(btn: Button) =
  currentTab = tabVideo
  updatePanelVisibility()
  echo "[Клик] Переключение на вкладку: Видео"
toolBar.addToolButton(btnVideo)
btnX += btnWidth + buttonSpacing

# Кнопка "Аудио"
let btnAudio = createButton("btnAudio", btnX, btnY, btnWidth, btnHeight, "Аудио")
btnAudio.onClick = proc(btn: Button) =
  currentTab = tabAudio
  updatePanelVisibility()
  echo "[Клик] Переключение на вкладку: Аудио"
toolBar.addToolButton(btnAudio)
btnX += btnWidth + buttonSpacing

# Кнопка "Субтитры"
let btnSubtitles = createButton("btnSubtitles", btnX, btnY, btnWidth, btnHeight, "Субтитры")
btnSubtitles.onClick = proc(btn: Button) =
  currentTab = tabSubtitles
  updatePanelVisibility()
  echo "[Клик] Переключение на вкладку: Субтитры"
toolBar.addToolButton(btnSubtitles)
btnX += btnWidth + buttonSpacing

# Кнопка "Прочее"
let btnOther = createButton("btnOther", btnX, btnY, btnWidth, btnHeight, "Прочее")
btnOther.onClick = proc(btn: Button) =
  currentTab = tabOther
  updatePanelVisibility()
  echo "[Клик] Переключение на вкладку: Прочее"
toolBar.addToolButton(btnOther)

gui.addWidget(toolBar)

# =============================================================================
# ПАНЕЛИ КОНТЕНТА (для каждой вкладки)
# =============================================================================

# ===== ПАНЕЛЬ "НАЧАЛО" =====
let panelStart = createPanel("panelStart", 10, 90, 1260, 600)
panelStart.bgColor = initColor(255, 255, 255)
panelStart.borderColor = initColor(200, 200, 200)

let labelStartTitle = createLabel("lblStartTitle", 20, 20, 1220, 40, "Добро пожаловать в Медиа Приложение!")
labelStartTitle.textColor = initColor(0, 0, 128)
labelStartTitle.textAlign = alignCenter
panelStart.addChild(labelStartTitle)

let labelStartInfo = createLabel("lblStartInfo", 20, 70, 1220, 60,
  "Это приложение позволяет работать с различными медиафайлами:\n" &
  "видео, аудио и субтитрами. Используйте вкладки вверху для навигации.")
labelStartInfo.wordWrap = true
panelStart.addChild(labelStartInfo)

let btnStartNewProject = createButton("btnStartNew", 400, 150, 200, 50, "Создать новый проект")
btnStartNewProject.bgColor = initColor(0, 120, 215)
btnStartNewProject.textColor = initColor(255, 255, 255)
btnStartNewProject.onClick = proc(btn: Button) =
  gui.showInfoDialog("Файл", "Создать новый проект")
panelStart.addChild(btnStartNewProject)

let btnStartOpenProject = createButton("btnStartOpen", 640, 150, 200, 50, "Открыть проект")
btnStartOpenProject.onClick = proc(btn: Button) =
  gui.showInfoDialog("Файл", "Открыть существующий проект")
panelStart.addChild(btnStartOpenProject)

let labelStartQuickActions = createLabel("lblQuickActions", 20, 230, 1220, 30, "Быстрые действия:")
labelStartQuickActions.textColor = initColor(0, 0, 0)
panelStart.addChild(labelStartQuickActions)

let listQuickActions = createListBox("listQuickActions", 20, 270, 600, 300)
listQuickActions.items = @[
  "Добавить видеофайл",
  "Добавить аудиофайл",
  "Добавить файл субтитров",
  "Конвертировать файл",
  "Экспортировать проект",
  "Настройки приложения",
  "Справка и документация"
]
listQuickActions.onSelect = proc(lb: ListBox, idx: int) =
  echo "[QuickActions] Выбрано: ", lb.items[idx]
  gui.showInfoDialog("Быстрое действие", "Выбрано: " & lb.items[idx])
panelStart.addChild(listQuickActions)

let labelRecentProjects = createLabel("lblRecent", 650, 270, 500, 30, "Недавние проекты:")
panelStart.addChild(labelRecentProjects)

let listRecentProjects = createListBox("listRecent", 650, 310, 580, 260)
listRecentProjects.items = @[
  "Проект 1.media",
  "Проект 2.media",
  "Видео презентация.media"
]
listRecentProjects.onSelect = proc(lb: ListBox, idx: int) =
  echo "[Recent] Выбран проект: ", lb.items[idx]
  gui.showInfoDialog("Недавние проекты", "Открыть проект: " & lb.items[idx])
panelStart.addChild(listRecentProjects)

gui.addWidget(panelStart)

# ===== ПАНЕЛЬ "ВИДЕО" =====
let panelVideo = createPanel("panelVideo", 10, 90, 1260, 600)
panelVideo.bgColor = initColor(250, 250, 255)
panelVideo.borderColor = initColor(100, 149, 237)
panelVideo.visible = false

let labelVideoTitle = createLabel("lblVideoTitle", 20, 20, 1220, 40, "Редактирование видео")
labelVideoTitle.textColor = initColor(0, 0, 128)
labelVideoTitle.textAlign = alignCenter
panelVideo.addChild(labelVideoTitle)

let labelVideoFile = createLabel("lblVideoFile", 20, 80, 150, 30, "Видеофайл:")
panelVideo.addChild(labelVideoFile)

let fieldVideoFile = createTextField("fieldVideoFile", 180, 80, 800, 30)
fieldVideoFile.placeholder = "Путь к видеофайлу..."
panelVideo.addChild(fieldVideoFile)

let btnVideoBrowse = createButton("btnVideoBrowse", 1000, 80, 120, 30, "Обзор...")
btnVideoBrowse.onClick = proc(btn: Button) =
  gui.showInfoDialog("Видео", "Выбрать видеофайл")
panelVideo.addChild(btnVideoBrowse)

let labelVideoResolution = createLabel("lblVideoRes", 20, 130, 150, 30, "Разрешение:")
panelVideo.addChild(labelVideoResolution)

let comboVideoResolution = createComboBox("comboVideoRes", 180, 130, 200, 30)
comboVideoResolution.items = @["1920x1080", "1280x720", "854x480", "640x360"]
comboVideoResolution.selectedIndex = 0
comboVideoResolution.onSelect = proc(cb: ComboBox, idx: int) =
  echo "[Video] Выбрано разрешение: ", cb.items[idx]
panelVideo.addChild(comboVideoResolution)

let labelVideoCodec = createLabel("lblVideoCodec", 400, 130, 150, 30, "Кодек:")
panelVideo.addChild(labelVideoCodec)

let comboVideoCodec = createComboBox("comboVideoCodec", 560, 130, 200, 30)
comboVideoCodec.items = @["H.264", "H.265", "VP9", "AV1"]
comboVideoCodec.selectedIndex = 0
comboVideoCodec.onSelect = proc(cb: ComboBox, idx: int) =
  echo "[Video] Выбран кодек: ", cb.items[idx]
panelVideo.addChild(comboVideoCodec)

let labelVideoFPS = createLabel("lblVideoFPS", 20, 180, 150, 30, "FPS:")
panelVideo.addChild(labelVideoFPS)

let spinVideoFPS = createSpinBox("spinVideoFPS", 180, 180, 150, 30, 15.0, 120.0)
spinVideoFPS.value = 30.0
spinVideoFPS.step = 1.0
spinVideoFPS.decimals = 0
spinVideoFPS.onChange = proc(sb: SpinBox, val: float) =
  echo "[Video] FPS установлен на: ", val
panelVideo.addChild(spinVideoFPS)

let labelVideoBitrate = createLabel("lblVideoBitrate", 400, 180, 150, 30, "Битрейт (kbps):")
panelVideo.addChild(labelVideoBitrate)

let sliderVideoBitrate = createSlider("sliderVideoBitrate", 560, 180, 400, 30, 500.0, 20000.0)
sliderVideoBitrate.value = 5000.0
sliderVideoBitrate.onChange = proc(s: Slider, val: float) =
  echo "[Video] Битрейт: ", val, " kbps"
panelVideo.addChild(sliderVideoBitrate)

let labelVideoPreview = createLabel("lblVideoPreview", 20, 240, 1220, 30, "Предпросмотр:")
panelVideo.addChild(labelVideoPreview)

let panelVideoPreview = createPanel("panelVideoPreview", 20, 280, 1220, 250)
panelVideoPreview.bgColor = initColor(0, 0, 0)
panelVideoPreview.borderColor = initColor(128, 128, 128)
let labelVideoPreviewPlaceholder = createLabel("lblVidPreview", 400, 100, 400, 50, "[Область предпросмотра видео]")
labelVideoPreviewPlaceholder.textColor = initColor(200, 200, 200)
labelVideoPreviewPlaceholder.textAlign = alignCenter
panelVideoPreview.addChild(labelVideoPreviewPlaceholder)
panelVideo.addChild(panelVideoPreview)

let btnVideoProcess = createButton("btnVideoProcess", 500, 550, 250, 40, "Обработать видео")
btnVideoProcess.bgColor = initColor(0, 128, 0)
btnVideoProcess.textColor = initColor(255, 255, 255)
btnVideoProcess.onClick = proc(btn: Button) =
  gui.showInfoDialog("Видео", "Начать обработку видеофайла")
panelVideo.addChild(btnVideoProcess)

gui.addWidget(panelVideo)

# ===== ПАНЕЛЬ "АУДИО" =====
let panelAudio = createPanel("panelAudio", 10, 90, 1260, 600)
panelAudio.bgColor = initColor(255, 250, 240)
panelAudio.borderColor = initColor(255, 140, 0)
panelAudio.visible = false

let labelAudioTitle = createLabel("lblAudioTitle", 20, 20, 1220, 40, "Редактирование аудио")
labelAudioTitle.textColor = initColor(139, 69, 19)
labelAudioTitle.textAlign = alignCenter
panelAudio.addChild(labelAudioTitle)

let labelAudioFile = createLabel("lblAudioFile", 20, 80, 150, 30, "Аудиофайл:")
panelAudio.addChild(labelAudioFile)

let fieldAudioFile = createTextField("fieldAudioFile", 180, 80, 800, 30)
fieldAudioFile.placeholder = "Путь к аудиофайлу..."
panelAudio.addChild(fieldAudioFile)

let btnAudioBrowse = createButton("btnAudioBrowse", 1000, 80, 120, 30, "Обзор...")
btnAudioBrowse.onClick = proc(btn: Button) =
  gui.showInfoDialog("Аудио", "Выбрать аудиофайл")
panelAudio.addChild(btnAudioBrowse)

let labelAudioFormat = createLabel("lblAudioFormat", 20, 130, 150, 30, "Формат:")
panelAudio.addChild(labelAudioFormat)

let comboAudioFormat = createComboBox("comboAudioFormat", 180, 130, 200, 30)
comboAudioFormat.items = @["MP3", "AAC", "FLAC", "WAV", "OGG"]
comboAudioFormat.selectedIndex = 0
comboAudioFormat.onSelect = proc(cb: ComboBox, idx: int) =
  echo "[Audio] Выбран формат: ", cb.items[idx]
panelAudio.addChild(comboAudioFormat)

let labelAudioQuality = createLabel("lblAudioQuality", 400, 130, 150, 30, "Качество:")
panelAudio.addChild(labelAudioQuality)

let sliderAudioQuality = createSlider("sliderAudioQuality", 560, 130, 400, 30, 0.0, 10.0)
sliderAudioQuality.value = 7.0
sliderAudioQuality.onChange = proc(s: Slider, val: float) =
  echo "[Audio] Качество: ", val
panelAudio.addChild(sliderAudioQuality)

let cbAudioNormalize = createCheckBox("cbAudioNormalize", 20, 180, "Нормализовать громкость")
cbAudioNormalize.onChange = proc(cb: CheckBox, checked: bool) =
  echo "[Audio] Нормализация: ", checked
panelAudio.addChild(cbAudioNormalize)

let cbAudioRemoveNoise = createCheckBox("cbAudioNoise", 20, 220, "Удалить шум")
cbAudioRemoveNoise.onChange = proc(cb: CheckBox, checked: bool) =
  echo "[Audio] Удаление шума: ", checked
panelAudio.addChild(cbAudioRemoveNoise)

let labelAudioWaveform = createLabel("lblAudioWaveform", 20, 270, 1220, 30, "Форма волны:")
panelAudio.addChild(labelAudioWaveform)

let panelAudioWaveform = createPanel("panelAudioWaveform", 20, 310, 1220, 200)
panelAudioWaveform.bgColor = initColor(30, 30, 30)
panelAudioWaveform.borderColor = initColor(128, 128, 128)
let labelAudioWaveformPlaceholder = createLabel("lblAudWave", 400, 80, 400, 40, "[Форма аудиоволны]")
labelAudioWaveformPlaceholder.textColor = initColor(0, 255, 0)
labelAudioWaveformPlaceholder.textAlign = alignCenter
panelAudioWaveform.addChild(labelAudioWaveformPlaceholder)
panelAudio.addChild(panelAudioWaveform)

let btnAudioProcess = createButton("btnAudioProcess", 500, 530, 250, 40, "Обработать аудио")
btnAudioProcess.bgColor = initColor(255, 140, 0)
btnAudioProcess.textColor = initColor(255, 255, 255)
btnAudioProcess.onClick = proc(btn: Button) =
  gui.showInfoDialog("Аудио", "Начать обработку аудиофайла")
panelAudio.addChild(btnAudioProcess)

gui.addWidget(panelAudio)

# ===== ПАНЕЛЬ "СУБТИТРЫ" =====
let panelSubtitles = createPanel("panelSubtitles", 10, 90, 1260, 600)
panelSubtitles.bgColor = initColor(240, 255, 240)
panelSubtitles.borderColor = initColor(34, 139, 34)
panelSubtitles.visible = false

let labelSubsTitle = createLabel("lblSubsTitle", 20, 20, 1220, 40, "Работа с субтитрами")
labelSubsTitle.textColor = initColor(0, 100, 0)
labelSubsTitle.textAlign = alignCenter
panelSubtitles.addChild(labelSubsTitle)

let labelSubsFile = createLabel("lblSubsFile", 20, 80, 150, 30, "Файл субтитров:")
panelSubtitles.addChild(labelSubsFile)

let fieldSubsFile = createTextField("fieldSubsFile", 180, 80, 800, 30)
fieldSubsFile.placeholder = "Путь к файлу субтитров..."
panelSubtitles.addChild(fieldSubsFile)

let btnSubsBrowse = createButton("btnSubsBrowse", 1000, 80, 120, 30, "Обзор...")
btnSubsBrowse.onClick = proc(btn: Button) =
  gui.showInfoDialog("Субтитры", "Выбрать файл субтитров")
panelSubtitles.addChild(btnSubsBrowse)

let labelSubsFormat = createLabel("lblSubsFormat", 20, 130, 150, 30, "Формат:")
panelSubtitles.addChild(labelSubsFormat)

let comboSubsFormat = createComboBox("comboSubsFormat", 180, 130, 200, 30)
comboSubsFormat.items = @["SRT", "ASS", "VTT", "SSA", "SUB"]
comboSubsFormat.selectedIndex = 0
comboSubsFormat.onSelect = proc(cb: ComboBox, idx: int) =
  echo "[Subtitles] Выбран формат: ", cb.items[idx]
panelSubtitles.addChild(comboSubsFormat)

let labelSubsEncoding = createLabel("lblSubsEncoding", 400, 130, 150, 30, "Кодировка:")
panelSubtitles.addChild(labelSubsEncoding)

let comboSubsEncoding = createComboBox("comboSubsEncoding", 560, 130, 200, 30)
comboSubsEncoding.items = @["UTF-8", "Windows-1251", "KOI8-R", "ISO-8859-1"]
comboSubsEncoding.selectedIndex = 0
comboSubsEncoding.onSelect = proc(cb: ComboBox, idx: int) =
  echo "[Subtitles] Выбрана кодировка: ", cb.items[idx]
panelSubtitles.addChild(comboSubsEncoding)

let labelSubsEditor = createLabel("lblSubsEditor", 20, 180, 1220, 30, "Редактор субтитров:")
panelSubtitles.addChild(labelSubsEditor)

let textareaSubsEditor = createTextArea("textareaSubsEditor", 20, 220, 1220, 300)
textareaSubsEditor.lines = @[
  "1",
  "00:00:01,000 --> 00:00:04,000",
  "Пример субтитров",
  "",
  "2",
  "00:00:05,000 --> 00:00:08,000",
  "Второй пример текста субтитров"
]
textareaSubsEditor.onChange = proc(ta: TextArea) =
  echo "[Subtitles] Текст субтитров изменён"
panelSubtitles.addChild(textareaSubsEditor)

let btnSubsSave = createButton("btnSubsSave", 450, 540, 150, 40, "Сохранить")
btnSubsSave.bgColor = initColor(34, 139, 34)
btnSubsSave.textColor = initColor(255, 255, 255)
btnSubsSave.onClick = proc(btn: Button) =
  gui.showInfoDialog("Субтитры", "Сохранить файл субтитров")
panelSubtitles.addChild(btnSubsSave)

let btnSubsExport = createButton("btnSubsExport", 620, 540, 150, 40, "Экспортировать")
btnSubsExport.onClick = proc(btn: Button) =
  gui.showInfoDialog("Субтитры", "Экспортировать субтитры")
panelSubtitles.addChild(btnSubsExport)

gui.addWidget(panelSubtitles)

# ===== ПАНЕЛЬ "ПРОЧЕЕ" =====
let panelOther = createPanel("panelOther", 10, 90, 1260, 600)
panelOther.bgColor = initColor(245, 245, 245)
panelOther.borderColor = initColor(128, 128, 128)
panelOther.visible = false

let labelOtherTitle = createLabel("lblOtherTitle", 20, 20, 1220, 40, "Дополнительные функции")
labelOtherTitle.textColor = initColor(64, 64, 64)
labelOtherTitle.textAlign = alignCenter
panelOther.addChild(labelOtherTitle)

let labelOtherTools = createLabel("lblOtherTools", 20, 80, 1220, 30, "Доступные инструменты:")
panelOther.addChild(labelOtherTools)

let listOtherTools = createListBox("listOtherTools", 20, 120, 400, 400)
listOtherTools.items = @[
  "Конвертер форматов",
  "Объединение файлов",
  "Разделение файлов",
  "Извлечение аудио из видео",
  "Наложение водяного знака",
  "Изменение скорости воспроизведения",
  "Поворот видео",
  "Обрезка медиафайлов",
  "Изменение разрешения",
  "Настройка цветокоррекции"
]
listOtherTools.onSelect = proc(lb: ListBox, idx: int) =
  echo "[Other] Выбран инструмент: ", lb.items[idx]
  gui.showInfoDialog("Инструмент", "Запустить: " & lb.items[idx])
panelOther.addChild(listOtherTools)

let panelOtherInfo = createPanel("panelOtherInfo", 450, 120, 790, 460)
panelOtherInfo.bgColor = initColor(255, 255, 255)
panelOtherInfo.borderColor = initColor(200, 200, 200)

let labelOtherInfoTitle = createLabel("lblOtherInfoTitle", 20, 20, 750, 30, "Информация об инструменте")
labelOtherInfoTitle.textColor = initColor(0, 0, 128)
panelOtherInfo.addChild(labelOtherInfoTitle)

let labelOtherInfoText = createLabel("lblOtherInfoText", 20, 60, 750, 350,
  "Выберите инструмент из списка слева для просмотра подробной информации.\n\n" &
  "Каждый инструмент предоставляет специализированные функции для работы с медиафайлами.\n\n" &
  "После выбора инструмента здесь отобразится его описание, параметры и возможности.")
labelOtherInfoText.wordWrap = true
panelOtherInfo.addChild(labelOtherInfoText)

let btnOtherRun = createButton("btnOtherRun", 270, 410, 250, 40, "Запустить инструмент")
btnOtherRun.bgColor = initColor(70, 130, 180)
btnOtherRun.textColor = initColor(255, 255, 255)
btnOtherRun.onClick = proc(btn: Button) =
  gui.showInfoDialog("Инструменты", "Запуск выбранного инструмента")
panelOtherInfo.addChild(btnOtherRun)

panelOther.addChild(panelOtherInfo)

gui.addWidget(panelOther)

# =============================================================================
# СТРОКА СОСТОЯНИЯ (StatusBar)
# =============================================================================

let statusBar = createStatusBar("statusbar", 0, 720 - 30, 1280, 30)
statusBar.text = "Готов к работе | Проект: Без названия | Медиафайлов: 0"

gui.addWidget(statusBar)

# =============================================================================
# ФУНКЦИЯ УПРАВЛЕНИЯ ВИДИМОСТЬЮ ПАНЕЛЕЙ
# =============================================================================

proc updatePanelVisibility() =
  # Управление видимостью панелей
  panelStart.visible = (currentTab == tabStart)
  panelVideo.visible = (currentTab == tabVideo)
  panelAudio.visible = (currentTab == tabAudio)
  panelSubtitles.visible = (currentTab == tabSubtitles)
  panelOther.visible = (currentTab == tabOther)
  
  # Обновляем визуальное состояние кнопок (акцентный цвет для активной)
  let accentColor = initColor(0, 120, 215)
  let normalColor = initColor(225, 225, 225)
  let textNormal = initColor(0, 0, 0)
  let textAccent = initColor(255, 255, 255)
  
  if currentTab == tabStart:
    btnStart.bgColor = accentColor
    btnStart.textColor = textAccent
  else:
    btnStart.bgColor = normalColor
    btnStart.textColor = textNormal
  
  if currentTab == tabVideo:
    btnVideo.bgColor = accentColor
    btnVideo.textColor = textAccent
  else:
    btnVideo.bgColor = normalColor
    btnVideo.textColor = textNormal
  
  if currentTab == tabAudio:
    btnAudio.bgColor = accentColor
    btnAudio.textColor = textAccent
  else:
    btnAudio.bgColor = normalColor
    btnAudio.textColor = textNormal
  
  if currentTab == tabSubtitles:
    btnSubtitles.bgColor = accentColor
    btnSubtitles.textColor = textAccent
  else:
    btnSubtitles.bgColor = normalColor
    btnSubtitles.textColor = textNormal
  
  if currentTab == tabOther:
    btnOther.bgColor = accentColor
    btnOther.textColor = textAccent
  else:
    btnOther.bgColor = normalColor
    btnOther.textColor = textNormal
  
  # Обновляем строку состояния
  case currentTab
  of tabStart:
    statusBar.text = "Готов к работе | Вкладка: Начало | Проект: Без названия"
  of tabVideo:
    statusBar.text = "Готов к работе | Вкладка: Видео | Редактирование видео"
  of tabAudio:
    statusBar.text = "Готов к работе | Вкладка: Аудио | Редактирование аудио"
  of tabSubtitles:
    statusBar.text = "Готов к работе | Вкладка: Субтитры | Работа с субтитрами"
  of tabOther:
    statusBar.text = "Готов к работе | Вкладка: Прочее | Дополнительные функции"

# Инициализируем видимость панелей
updatePanelVisibility()

# =============================================================================
# ГОРЯЧИЕ КЛАВИШИ
# =============================================================================

proc handleHotkeys(event: SdlEvent): bool =
  ## Обработка горячих клавиш
  if event.type == SDL_EVENT_KEY_DOWN:
    let ctrl = (uint32(event.key.mod) and uint32(SDL_KMOD_CTRL)) != 0'u32
    let shift = (uint32(event.key.mod) and uint32(SDL_KMOD_SHIFT)) != 0'u32
    let alt = (uint32(event.key.mod) and (uint32(SDL_KMOD_LALT) or uint32(SDL_KMOD_RALT))) != 0'u32
    
    # Ctrl+N - Новый проект
    if ctrl and not shift and not alt and event.key.key == SDLK_N:
      echo "[Hotkey] Ctrl+N - Новый проект"
      gui.showInfoDialog("Файл", "Создать новый проект")
      return true
    
    # Ctrl+O - Открыть проект
    if ctrl and not shift and not alt and event.key.key == SDLK_O:
      echo "[Hotkey] Ctrl+O - Открыть проект"
      gui.showInfoDialog("Файл", "Открыть существующий проект")
      return true
    
    # Ctrl+S - Сохранить проект
    if ctrl and not shift and not alt and event.key.key == SDLK_S:
      echo "[Hotkey] Ctrl+S - Сохранить проект"
      gui.showInfoDialog("Файл", "Сохранить текущий проект")
      return true
    
    # Ctrl+I - Добавить медиафайл
    if ctrl and not shift and not alt and event.key.key == SDLK_I:
      echo "[Hotkey] Ctrl+I - Добавить медиафайл"
      gui.showInfoDialog("Медиафайл", "Добавить медиафайл в проект")
      return true
    
    # F1 - Справка (код клавиши F1 = 0x4000003A)
    if not ctrl and not shift and not alt and event.key.key.uint32 == 0x4000003A'u32:
      echo "[Hotkey] F1 - Справка"
      gui.showInfoDialog("Помощь", "Открыть содержание справки")
      return true
    
    # F12 - О программе (код клавиши F12 = 0x40000045)
    if not ctrl and not shift and not alt and event.key.key.uint32 == 0x40000045'u32:
      echo "[Hotkey] F12 - О программе"
      gui.showInfoDialog("О программе", "Медиа Приложение v1.0\n\nРазработано с использованием SDL и Nim")
      return true
    
    # Цифры 1-5 - переключение вкладок
    if not ctrl and not shift and not alt:
      case event.key.key
      of '1'.SdlKeycode:
        echo "[Hotkey] 1 - Вкладка 'Начало'"
        currentTab = tabStart
        updatePanelVisibility()
        return true
      of '2'.SdlKeycode:
        echo "[Hotkey] 2 - Вкладка 'Видео'"
        currentTab = tabVideo
        updatePanelVisibility()
        return true
      of '3'.SdlKeycode:
        echo "[Hotkey] 3 - Вкладка 'Аудио'"
        currentTab = tabAudio
        updatePanelVisibility()
        return true
      of '4'.SdlKeycode:
        echo "[Hotkey] 4 - Вкладка 'Субтитры'"
        currentTab = tabSubtitles
        updatePanelVisibility()
        return true
      of '5'.SdlKeycode:
        echo "[Hotkey] 5 - Вкладка 'Прочее'"
        currentTab = tabOther
        updatePanelVisibility()
        return true
      else:
        discard
  
  return false

# =============================================================================
# ГЛАВНЫЙ ЦИКЛ
# =============================================================================

var running = true
var event: SdlEvent

echo "Медиа Приложение запущено!"
echo "Горячие клавиши:"
echo "  1-5: переключение вкладок"
echo "  Ctrl+N: новый проект"
echo "  Ctrl+O: открыть проект"
echo "  Ctrl+S: сохранить проект"
echo "  Ctrl+I: добавить медиафайл"
echo "  F1: справка"
echo "  F12: о программе"

while running:
  while SDL_PollEvent(addr event) == SDL_TRUE:
    if event.type == SDL_EVENT_QUIT:
      running = false
      echo "Приложение закрывается..."
    elif event.type == SDL_EVENT_WINDOW_RESIZED:
      # Обработка изменения размера окна
      let newWidth = event.window.data1
      let newHeight = event.window.data2
      echo "Окно изменено: ", newWidth, "x", newHeight
      
      # Обновляем размеры виджетов
      menuBar.rect.w = newWidth.cint
      toolBar.rect.w = newWidth.cint
      statusBar.rect.y = (newHeight - 30).cint
      statusBar.rect.w = newWidth.cint
      
      # Обновляем размеры панелей
      let panelWidth = newWidth - 20
      let panelHeight = newHeight - 120
      panelStart.rect.w = panelWidth.cint
      panelStart.rect.h = panelHeight.cint
      panelVideo.rect.w = panelWidth.cint
      panelVideo.rect.h = panelHeight.cint
      panelAudio.rect.w = panelWidth.cint
      panelAudio.rect.h = panelHeight.cint
      panelSubtitles.rect.w = panelWidth.cint
      panelSubtitles.rect.h = panelHeight.cint
      panelOther.rect.w = panelWidth.cint
      panelOther.rect.h = panelHeight.cint
    else:
      # Сначала проверяем горячие клавиши
      if not handleHotkeys(event):
        # Если не обработано горячими клавишами, передаём в GUI
        discard gui.handleGuiEvent(addr event)
  
  # Очистка экрана
  discard SDL_SetRenderDrawColor(renderer, 240, 240, 240, 255)
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
