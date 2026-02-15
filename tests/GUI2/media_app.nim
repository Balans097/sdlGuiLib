################################################################
##           Media Application
##    Медиа-приложение с панелями и вкладками
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
  "Медиа Приложение",
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
# ПАНЕЛЬ ИНСТРУМЕНТОВ (ToolBar) с кнопками-вкладками
# =============================================================================

let toolBar = createToolBar("toolbar", 0, 30, 1280, 50)

# Forward declaration для updatePanelVisibility
proc updatePanelVisibility()

# Кнопка "Начало"
let btnStart = createButton("btnStart", 10, 5, 120, 40, "📋 Начало")
btnStart.onClick = proc(btn: Button) =
  currentTab = tabStart
  updatePanelVisibility()
  echo "[Клик] Переключение на вкладку: Начало"
toolBar.addToolButton(btnStart)

# Кнопка "Видео"
let btnVideo = createButton("btnVideo", 145, 5, 120, 40, "🎬 Видео")
btnVideo.onClick = proc(btn: Button) =
  currentTab = tabVideo
  updatePanelVisibility()
  echo "[Клик] Переключение на вкладку: Видео"
toolBar.addToolButton(btnVideo)

# Кнопка "Аудио"
let btnAudio = createButton("btnAudio", 280, 5, 120, 40, "🔊 Аудио")
btnAudio.onClick = proc(btn: Button) =
  currentTab = tabAudio
  updatePanelVisibility()
  echo "[Клик] Переключение на вкладку: Аудио"
toolBar.addToolButton(btnAudio)

# Кнопка "Субтитры"
let btnSubtitles = createButton("btnSubtitles", 415, 5, 120, 40, "💬 Субтитры")
btnSubtitles.onClick = proc(btn: Button) =
  currentTab = tabSubtitles
  updatePanelVisibility()
  echo "[Клик] Переключение на вкладку: Субтитры"
toolBar.addToolButton(btnSubtitles)

# Кнопка "Прочее"
let btnOther = createButton("btnOther", 550, 5, 120, 40, "⚙️ Прочее")
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
let panelStart = createPanel("panelStart", 10, 90, 1260, 560)
panelStart.bgColor = initColor(245, 245, 245)
panelStart.borderColor = initColor(180, 180, 180)

let labelStartTitle = createLabel("labelStartTitle", 20, 20, 600, 30, "Добро пожаловать в Медиа Приложение!")
labelStartTitle.textColor = initColor(0, 100, 200)
panelStart.addChild(labelStartTitle)

let labelStartInfo = createLabel("labelStartInfo", 20, 60, 800, 30, "Начните работу с создания нового проекта или откройте существующий.")
panelStart.addChild(labelStartInfo)

let btnStartNew = createButton("btnStartNew", 20, 110, 200, 40, "Создать проект")
btnStartNew.bgColor = initColor(0, 120, 215)
btnStartNew.textColor = initColor(255, 255, 255)
btnStartNew.onClick = proc(btn: Button) =
  gui.showInfoDialog("Начало", "Создание нового проекта...")
  echo "[Панель Начало] Создать проект"
panelStart.addChild(btnStartNew)

let btnStartOpen = createButton("btnStartOpen", 230, 110, 200, 40, "Открыть проект")
btnStartOpen.onClick = proc(btn: Button) =
  gui.showInfoDialog("Начало", "Открытие существующего проекта...")
  echo "[Панель Начало] Открыть проект"
panelStart.addChild(btnStartOpen)

let labelStartRecent = createLabel("labelStartRecent", 20, 170, 400, 30, "Недавние проекты:")
panelStart.addChild(labelStartRecent)

let listStartRecent = createListBox("listStartRecent", 20, 210, 600, 150)
listStartRecent.items = @[
  "Проект_1.media",
  "Проект_2.media",
  "Видео_монтаж_01.media",
  "Аудио_редактирование.media"
]
listStartRecent.onSelect = proc(lb: ListBox, index: int) =
  echo "[Панель Начало] Выбран проект: ", lb.items[index]
  gui.showInfoDialog("Открыть", "Открыть проект: " & lb.items[index] & "?")
panelStart.addChild(listStartRecent)

gui.addWidget(panelStart)

# ===== ПАНЕЛЬ "ВИДЕО" =====
let panelVideo = createPanel("panelVideo", 10, 90, 1260, 560)
panelVideo.bgColor = initColor(240, 248, 255)
panelVideo.borderColor = initColor(100, 149, 237)

let labelVideoTitle = createLabel("labelVideoTitle", 20, 20, 600, 30, "Настройки видео")
labelVideoTitle.textColor = initColor(0, 0, 128)
panelVideo.addChild(labelVideoTitle)

let labelVideoFormat = createLabel("labelVideoFormat", 20, 70, 150, 30, "Формат видео:")
panelVideo.addChild(labelVideoFormat)

let comboVideoFormat = createComboBox("comboVideoFormat", 180, 70, 200, 30)
comboVideoFormat.items = @["MP4", "AVI", "MKV", "MOV", "WebM"]
comboVideoFormat.selectedIndex = 0
comboVideoFormat.onSelect = proc(combo: ComboBox, index: int) =
  echo "[Панель Видео] Выбран формат: ", combo.items[index]
panelVideo.addChild(comboVideoFormat)

let labelVideoCodec = createLabel("labelVideoCodec", 20, 120, 150, 30, "Кодек:")
panelVideo.addChild(labelVideoCodec)

let comboVideoCodec = createComboBox("comboVideoCodec", 180, 120, 200, 30)
comboVideoCodec.items = @["H.264", "H.265", "VP9", "AV1"]
comboVideoCodec.selectedIndex = 0
panelVideo.addChild(comboVideoCodec)

let labelVideoResolution = createLabel("labelVideoResolution", 20, 170, 150, 30, "Разрешение:")
panelVideo.addChild(labelVideoResolution)

let comboVideoResolution = createComboBox("comboVideoResolution", 180, 170, 200, 30)
comboVideoResolution.items = @["1920x1080", "1280x720", "3840x2160", "2560x1440"]
comboVideoResolution.selectedIndex = 0
panelVideo.addChild(comboVideoResolution)

let labelVideoBitrate = createLabel("labelVideoBitrate", 20, 220, 150, 30, "Битрейт (Mbps):")
panelVideo.addChild(labelVideoBitrate)

let spinVideoBitrate = createSpinBox("spinVideoBitrate", 180, 220, 150, 30, 0.5, 50.0, 1)
spinVideoBitrate.value = 5.0
panelVideo.addChild(spinVideoBitrate)

let labelVideoFps = createLabel("labelVideoFps", 20, 270, 150, 30, "FPS:")
panelVideo.addChild(labelVideoFps)

let spinVideoFps = createSpinBox("spinVideoFps", 180, 270, 150, 30, 24.0, 120.0, 0)
spinVideoFps.value = 30.0
panelVideo.addChild(spinVideoFps)

let cbVideoDeinterlace = createCheckBox("cbVideoDeinterlace", 20, 320, "Деинтерлейс")
panelVideo.addChild(cbVideoDeinterlace)

let cbVideoHwAccel = createCheckBox("cbVideoHwAccel", 20, 350, "Аппаратное ускорение")
cbVideoHwAccel.checked = true
panelVideo.addChild(cbVideoHwAccel)

let btnVideoApply = createButton("btnVideoApply", 20, 400, 150, 40, "Применить")
btnVideoApply.bgColor = initColor(34, 139, 34)
btnVideoApply.textColor = initColor(255, 255, 255)
btnVideoApply.onClick = proc(btn: Button) =
  echo "[Панель Видео] Применить настройки"
  gui.showInfoDialog("Видео", "Настройки видео применены")
panelVideo.addChild(btnVideoApply)

gui.addWidget(panelVideo)

# ===== ПАНЕЛЬ "АУДИО" =====
let panelAudio = createPanel("panelAudio", 10, 90, 1260, 560)
panelAudio.bgColor = initColor(255, 250, 240)
panelAudio.borderColor = initColor(255, 140, 0)

let labelAudioTitle = createLabel("labelAudioTitle", 20, 20, 600, 30, "Настройки аудио")
labelAudioTitle.textColor = initColor(139, 69, 19)
panelAudio.addChild(labelAudioTitle)

let labelAudioCodec = createLabel("labelAudioCodec", 20, 70, 150, 30, "Аудио кодек:")
panelAudio.addChild(labelAudioCodec)

let comboAudioCodec = createComboBox("comboAudioCodec", 180, 70, 200, 30)
comboAudioCodec.items = @["AAC", "MP3", "FLAC", "Vorbis", "Opus"]
comboAudioCodec.selectedIndex = 0
panelAudio.addChild(comboAudioCodec)

let labelAudioBitrate = createLabel("labelAudioBitrate", 20, 120, 150, 30, "Битрейт (kbps):")
panelAudio.addChild(labelAudioBitrate)

let spinAudioBitrate = createSpinBox("spinAudioBitrate", 180, 120, 150, 30, 64.0, 320.0, 0)
spinAudioBitrate.value = 192.0
panelAudio.addChild(spinAudioBitrate)

let labelAudioSampleRate = createLabel("labelAudioSampleRate", 20, 170, 150, 30, "Частота (Hz):")
panelAudio.addChild(labelAudioSampleRate)

let comboAudioSampleRate = createComboBox("comboAudioSampleRate", 180, 170, 200, 30)
comboAudioSampleRate.items = @["44100", "48000", "96000"]
comboAudioSampleRate.selectedIndex = 1
panelAudio.addChild(comboAudioSampleRate)

let labelAudioChannels = createLabel("labelAudioChannels", 20, 220, 150, 30, "Каналы:")
panelAudio.addChild(labelAudioChannels)

let comboAudioChannels = createComboBox("comboAudioChannels", 180, 220, 200, 30)
comboAudioChannels.items = @["Mono", "Stereo", "5.1", "7.1"]
comboAudioChannels.selectedIndex = 1
panelAudio.addChild(comboAudioChannels)

let labelAudioVolume = createLabel("labelAudioVolume", 20, 270, 150, 30, "Громкость:")
panelAudio.addChild(labelAudioVolume)

let sliderAudioVolume = createSlider("sliderAudioVolume", 180, 270, 300, 30, 0.0, 100.0)
sliderAudioVolume.value = 100.0
panelAudio.addChild(sliderAudioVolume)

let cbAudioNormalize = createCheckBox("cbAudioNormalize", 20, 320, "Нормализация громкости")
panelAudio.addChild(cbAudioNormalize)

let cbAudioNoiseReduction = createCheckBox("cbAudioNoiseReduction", 20, 350, "Шумоподавление")
panelAudio.addChild(cbAudioNoiseReduction)

let btnAudioApply = createButton("btnAudioApply", 20, 400, 150, 40, "Применить")
btnAudioApply.bgColor = initColor(34, 139, 34)
btnAudioApply.textColor = initColor(255, 255, 255)
btnAudioApply.onClick = proc(btn: Button) =
  echo "[Панель Аудио] Применить настройки"
  gui.showInfoDialog("Аудио", "Настройки аудио применены")
panelAudio.addChild(btnAudioApply)

gui.addWidget(panelAudio)

# ===== ПАНЕЛЬ "СУБТИТРЫ" =====
let panelSubtitles = createPanel("panelSubtitles", 10, 90, 1260, 560)
panelSubtitles.bgColor = initColor(255, 245, 238)
panelSubtitles.borderColor = initColor(218, 165, 32)

let labelSubtitlesTitle = createLabel("labelSubtitlesTitle", 20, 20, 600, 30, "Работа с субтитрами")
labelSubtitlesTitle.textColor = initColor(184, 134, 11)
panelSubtitles.addChild(labelSubtitlesTitle)

let btnSubtitlesLoad = createButton("btnSubtitlesLoad", 20, 70, 200, 40, "Загрузить субтитры")
btnSubtitlesLoad.onClick = proc(btn: Button) =
  gui.showInfoDialog("Субтитры", "Выберите файл субтитров...")
  echo "[Панель Субтитры] Загрузить субтитры"
panelSubtitles.addChild(btnSubtitlesLoad)

let btnSubtitlesSave = createButton("btnSubtitlesSave", 230, 70, 200, 40, "Сохранить субтитры")
btnSubtitlesSave.onClick = proc(btn: Button) =
  gui.showInfoDialog("Субтитры", "Сохранение субтитров...")
  echo "[Панель Субтитры] Сохранить субтитры"
panelSubtitles.addChild(btnSubtitlesSave)

let labelSubtitlesFormat = createLabel("labelSubtitlesFormat", 20, 130, 150, 30, "Формат:")
panelSubtitles.addChild(labelSubtitlesFormat)

let comboSubtitlesFormat = createComboBox("comboSubtitlesFormat", 180, 130, 200, 30)
comboSubtitlesFormat.items = @["SRT", "ASS", "SSA", "VTT", "SUB"]
comboSubtitlesFormat.selectedIndex = 0
panelSubtitles.addChild(comboSubtitlesFormat)

let labelSubtitlesEncoding = createLabel("labelSubtitlesEncoding", 20, 180, 150, 30, "Кодировка:")
panelSubtitles.addChild(labelSubtitlesEncoding)

let comboSubtitlesEncoding = createComboBox("comboSubtitlesEncoding", 180, 180, 200, 30)
comboSubtitlesEncoding.items = @["UTF-8", "Windows-1251", "ISO-8859-1"]
comboSubtitlesEncoding.selectedIndex = 0
panelSubtitles.addChild(comboSubtitlesEncoding)

let cbSubtitlesEmbed = createCheckBox("cbSubtitlesEmbed", 20, 230, "Встроить в видео")
panelSubtitles.addChild(cbSubtitlesEmbed)

let cbSubtitlesBurn = createCheckBox("cbSubtitlesBurn", 20, 260, "Вжечь в видео")
panelSubtitles.addChild(cbSubtitlesBurn)

let labelSubtitlesText = createLabel("labelSubtitlesText", 20, 310, 300, 30, "Редактор субтитров:")
panelSubtitles.addChild(labelSubtitlesText)

let textAreaSubtitles = createTextArea("textAreaSubtitles", 20, 350, 800, 150)
textAreaSubtitles.lines = @[
  "1",
  "00:00:01,000 --> 00:00:03,000",
  "Пример текста субтитров",
  "",
  "2",
  "00:00:04,000 --> 00:00:06,000",
  "Второй блок субтитров"
]
panelSubtitles.addChild(textAreaSubtitles)

gui.addWidget(panelSubtitles)

# ===== ПАНЕЛЬ "ПРОЧЕЕ" =====
let panelOther = createPanel("panelOther", 10, 90, 1260, 560)
panelOther.bgColor = initColor(245, 245, 250)
panelOther.borderColor = initColor(128, 128, 128)

let labelOtherTitle = createLabel("labelOtherTitle", 20, 20, 600, 30, "Дополнительные функции")
labelOtherTitle.textColor = initColor(0, 0, 0)
panelOther.addChild(labelOtherTitle)

let labelOtherMetadata = createLabel("labelOtherMetadata", 20, 70, 200, 30, "Метаданные:")
panelOther.addChild(labelOtherMetadata)

let labelOtherTitle2 = createLabel("labelOtherTitle2", 20, 110, 100, 30, "Название:")
panelOther.addChild(labelOtherTitle2)

let fieldOtherTitle = createTextField("fieldOtherTitle", 130, 110, 400, 30)
fieldOtherTitle.placeholder = "Введите название"
panelOther.addChild(fieldOtherTitle)

let labelOtherAuthor = createLabel("labelOtherAuthor", 20, 150, 100, 30, "Автор:")
panelOther.addChild(labelOtherAuthor)

let fieldOtherAuthor = createTextField("fieldOtherAuthor", 130, 150, 400, 30)
fieldOtherAuthor.placeholder = "Введите автора"
panelOther.addChild(fieldOtherAuthor)

let labelOtherComment = createLabel("labelOtherComment", 20, 190, 100, 30, "Комментарий:")
panelOther.addChild(labelOtherComment)

let textAreaOtherComment = createTextArea("textAreaOtherComment", 130, 190, 400, 100)
textAreaOtherComment.lines = @[""]
panelOther.addChild(textAreaOtherComment)

let labelOtherOptions = createLabel("labelOtherOptions", 20, 310, 200, 30, "Дополнительные опции:")
panelOther.addChild(labelOtherOptions)

let cbOtherAutoSave = createCheckBox("cbOtherAutoSave", 20, 350, "Автосохранение")
cbOtherAutoSave.checked = true
panelOther.addChild(cbOtherAutoSave)

let cbOtherBackup = createCheckBox("cbOtherBackup", 20, 380, "Создавать резервные копии")
panelOther.addChild(cbOtherBackup)

let cbOtherLog = createCheckBox("cbOtherLog", 20, 410, "Вести журнал операций")
panelOther.addChild(cbOtherLog)

let btnOtherClearCache = createButton("btnOtherClearCache", 20, 460, 200, 40, "Очистить кэш")
btnOtherClearCache.onClick = proc(btn: Button) =
  gui.showQuestionDialog("Очистка", "Очистить кэш приложения?") do (dlg: Dialog, result: DialogButton):
    if result == dbYes:
      echo "[Панель Прочее] Кэш очищен"
      gui.showInfoDialog("Очистка", "Кэш успешно очищен")
panelOther.addChild(btnOtherClearCache)

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
