## SDL3 Modern Calculator Application with TTF Fonts
## ==================================================
##
## A beautiful, modern calculator with proper TTF font rendering

import libSDL
import std/[strformat, math, strutils]

# =============================================================================
# Constants
# =============================================================================

const
  WINDOW_WIDTH = 500
  WINDOW_HEIGHT = 700
  WINDOW_TITLE = "SDL3 Calculator"
  
  # Colors (RGBA)
  COLOR_BG_TOP = (r: 20'u8, g: 30'u8, b: 48'u8, a: 255'u8)
  COLOR_BG_BOTTOM = (r: 36'u8, g: 59'u8, b: 85'u8, a: 255'u8)
  COLOR_PANEL = (r: 44'u8, g: 62'u8, b: 80'u8, a: 255'u8)
  COLOR_INPUT_BG = (r: 30'u8, g: 40'u8, b: 55'u8, a: 255'u8)
  COLOR_INPUT_ACTIVE = (r: 40'u8, g: 55'u8, b: 75'u8, a: 255'u8)
  COLOR_TEXT = (r: 220'u8, g: 220'u8, b: 220'u8, a: 255'u8)
  COLOR_TEXT_DIM = (r: 150'u8, g: 160'u8, b: 180'u8, a: 255'u8)
  COLOR_BUTTON = (r: 52'u8, g: 73'u8, b: 94'u8, a: 255'u8)
  COLOR_BUTTON_HOVER = (r: 70'u8, g: 90'u8, b: 115'u8, a: 255'u8)
  COLOR_BUTTON_ACTIVE = (r: 40'u8, g: 60'u8, b: 80'u8, a: 255'u8)
  COLOR_PRIMARY = (r: 52'u8, g: 152'u8, b: 219'u8, a: 255'u8)
  COLOR_PRIMARY_HOVER = (r: 65'u8, g: 165'u8, b: 230'u8, a: 255'u8)
  COLOR_SUCCESS = (r: 46'u8, g: 204'u8, b: 113'u8, a: 255'u8)
  COLOR_SUCCESS_HOVER = (r: 60'u8, g: 220'u8, b: 130'u8, a: 255'u8)
  COLOR_DANGER = (r: 231'u8, g: 76'u8, b: 60'u8, a: 255'u8)
  COLOR_SHADOW = (r: 0'u8, g: 0'u8, b: 0'u8, a: 80'u8)

# =============================================================================
# Font Management
# =============================================================================

proc findSystemFont(): string =
  ## Try to find a system font
  when defined(linux):
    const fonts = [
      # Fedora/RHEL paths
      "/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf",
      "/usr/share/fonts/dejavu-sans-mono-fonts/DejaVuSansMono.ttf",
      "/usr/share/fonts/liberation-sans/LiberationSans-Regular.ttf",
      # Debian/Ubuntu paths
      "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
      "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
      # Generic
      "/usr/share/fonts/truetype/crosextra/Carlito-Regular.ttf"
    ]
  elif defined(windows):
    const fonts = [
      "C:\\Windows\\Fonts\\arial.ttf",
      "C:\\Windows\\Fonts\\calibri.ttf",
      "C:\\Windows\\Fonts\\segoeui.ttf"
    ]
  elif defined(macosx):
    const fonts = [
      "/System/Library/Fonts/Helvetica.ttc",
      "/Library/Fonts/Arial.ttf"
    ]
  else:
    const fonts: array[0, string] = []
  
  for font in fonts:
    when defined(posix):
      proc access(path: cstring, mode: cint): cint {.importc, header: "<unistd.h>".}
      if access(font.cstring, 0) == 0:
        return font
    else:
      if fileExists(font):
        return font
  
  return ""

# =============================================================================
# Types
# =============================================================================

type
  ButtonState = enum
    bsNormal, bsHover, bsActive
  
  Button = object
    x, y, w, h: float32
    text: string
    state: ButtonState
    normalColor: tuple[r, g, b, a: uint8]
    hoverColor: tuple[r, g, b, a: uint8]
  
  TextInput = object
    x, y, w, h: float32
    text: string
    placeholder: string
    active: bool
    cursorVisible: bool
    lastCursorBlink: uint64
  
  AppState = object
    window: SdlWindow
    renderer: SdlRenderer
    font: TTF_Font
    fontLarge: TTF_Font
    fontSmall: TTF_Font
    running: bool
    
    input1: TextInput
    input2: TextInput
    
    addButton: Button
    subtractButton: Button
    multiplyButton: Button
    divideButton: Button
    clearButton: Button
    
    resultText: string
    
    mouseX, mouseY: float32
    mousePressed: bool
    animationTime: float32


# =============================================================================
# Helper Functions
# =============================================================================

proc isPointInRect(x, y, rx, ry, rw, rh: float32): bool =
  x >= rx and x <= rx + rw and y >= ry and y <= ry + rh

proc drawRoundedRect(renderer: SdlRenderer, x, y, w, h, radius: float32) =
  # Draw filled rectangle with rounded corners (simplified version)
  # Draw main rectangle
  var mainRect = SdlFRect(x: x + radius, y: y, w: w - radius * 2, h: h)
  discard SDL_RenderFillRect(renderer, addr mainRect)
  
  var sideRect = SdlFRect(x: x, y: y + radius, w: w, h: h - radius * 2)
  discard SDL_RenderFillRect(renderer, addr sideRect)
  
  # Draw corner circles (simplified as rectangles for now)
  var cornerSize = radius * 2
  var tlRect = SdlFRect(x: x, y: y, w: cornerSize, h: cornerSize)
  discard SDL_RenderFillRect(renderer, addr tlRect)
  
  var trRect = SdlFRect(x: x + w - cornerSize, y: y, w: cornerSize, h: cornerSize)
  discard SDL_RenderFillRect(renderer, addr trRect)
  
  var blRect = SdlFRect(x: x, y: y + h - cornerSize, w: cornerSize, h: cornerSize)
  discard SDL_RenderFillRect(renderer, addr blRect)
  
  var brRect = SdlFRect(x: x + w - cornerSize, y: y + h - cornerSize, w: cornerSize, h: cornerSize)
  discard SDL_RenderFillRect(renderer, addr brRect)

proc drawGradientBackground(renderer: SdlRenderer, width, height: int) =
  let steps = 100
  for i in 0..<steps:
    let t = i.float / steps.float
    let r = uint8(COLOR_BG_TOP.r.float * (1 - t) + COLOR_BG_BOTTOM.r.float * t)
    let g = uint8(COLOR_BG_TOP.g.float * (1 - t) + COLOR_BG_BOTTOM.g.float * t)
    let b = uint8(COLOR_BG_TOP.b.float * (1 - t) + COLOR_BG_BOTTOM.b.float * t)
    
    discard SDL_SetRenderDrawColor(renderer, r, g, b, 255)
    let y = (i * height) div steps
    let h = (height div steps) + 1
    var rect = SdlFRect(x: 0, y: y.float32, w: width.float32, h: h.float32)
    discard SDL_RenderFillRect(renderer, addr rect)

proc drawTextCentered(renderer: SdlRenderer, font: TTF_Font, text: string, 
                      x, y: float32, color: SdlColor) =
  if text.len == 0:
    return
  
  let surface = renderTextBlended(font, text, color)
  if surface.isNil:
    return
  
  let texture = SDL_CreateTextureFromSurface(renderer, surface)
  SDL_DestroySurface(surface)
  
  if texture.isNil:
    return
  
  var w, h: cfloat
  discard SDL_GetTextureSize(texture, addr w, addr h)
  
  var dstRect = SdlFRect(x: x - w / 2, y: y, w: w, h: h)
  discard SDL_RenderTexture(renderer, texture, nil, addr dstRect)
  SDL_DestroyTexture(texture)

proc drawText(renderer: SdlRenderer, font: TTF_Font, text: string, 
              x, y: float32, color: SdlColor) =
  if text.len == 0:
    return
  
  let surface = renderTextBlended(font, text, color)
  if surface.isNil:
    return
  
  let texture = SDL_CreateTextureFromSurface(renderer, surface)
  SDL_DestroySurface(surface)
  
  if texture.isNil:
    return
  
  var w, h: cfloat
  discard SDL_GetTextureSize(texture, addr w, addr h)
  
  var dstRect = SdlFRect(x: x, y: y, w: w, h: h)
  discard SDL_RenderTexture(renderer, texture, nil, addr dstRect)
  SDL_DestroyTexture(texture)

proc getTextWidth(font: TTF_Font, text: string): float32 =
  if text.len == 0:
    return 0.0
  
  let (w, h) = getTextSize(font, text)
  return w.float32

# =============================================================================
# UI Components
# =============================================================================

proc createButton(x, y, w, h: float32, text: string, 
                  normalColor, hoverColor: tuple[r, g, b, a: uint8]): Button =
  result.x = x
  result.y = y
  result.w = w
  result.h = h
  result.text = text
  result.state = bsNormal
  result.normalColor = normalColor
  result.hoverColor = hoverColor

proc createTextInput(x, y, w, h: float32, placeholder: string): TextInput =
  result.x = x
  result.y = y
  result.w = w
  result.h = h
  result.text = ""
  result.placeholder = placeholder
  result.active = false
  result.cursorVisible = true
  result.lastCursorBlink = SDL_GetTicks()

proc renderButton(renderer: SdlRenderer, font: TTF_Font, button: Button) =
  # Draw shadow
  discard SDL_SetRenderDrawColor(renderer, COLOR_SHADOW.r, COLOR_SHADOW.g,
                                  COLOR_SHADOW.b, COLOR_SHADOW.a)
  drawRoundedRect(renderer, button.x + 2, button.y + 2, button.w, button.h, 8.0)
  
  # Draw button background
  let color = case button.state
    of bsNormal: button.normalColor
    of bsHover: button.hoverColor
    of bsActive: 
      (r: uint8(button.normalColor.r * 3 div 4), 
       g: uint8(button.normalColor.g * 3 div 4),
       b: uint8(button.normalColor.b * 3 div 4), 
       a: button.normalColor.a)
  
  discard SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
  drawRoundedRect(renderer, button.x, button.y, button.w, button.h, 8.0)
  
  # Draw text
  let textColor = SdlColor(r: COLOR_TEXT.r, g: COLOR_TEXT.g, b: COLOR_TEXT.b, a: COLOR_TEXT.a)
  let textWidth = getTextWidth(font, button.text)
  let textX = button.x + (button.w - textWidth) / 2.0
  let textY = button.y + (button.h - 20.0) / 2.0
  
  drawText(renderer, font, button.text, textX, textY, textColor)

proc renderTextInput(renderer: SdlRenderer, font: TTF_Font, input: TextInput) =
  # Draw background
  let bgColor = if input.active: COLOR_INPUT_ACTIVE else: COLOR_INPUT_BG
  discard SDL_SetRenderDrawColor(renderer, bgColor.r, bgColor.g, bgColor.b, bgColor.a)
  drawRoundedRect(renderer, input.x, input.y, input.w, input.h, 8.0)
  
  # Draw border if active
  if input.active:
    discard SDL_SetRenderDrawColor(renderer, COLOR_PRIMARY.r, COLOR_PRIMARY.g, 
                                    COLOR_PRIMARY.b, 255)
    var borderRect = SdlFRect(x: input.x, y: input.y, w: input.w, h: input.h)
    discard SDL_RenderRect(renderer, addr borderRect)
    borderRect = SdlFRect(x: input.x + 1, y: input.y + 1, w: input.w - 2, h: input.h - 2)
    discard SDL_RenderRect(renderer, addr borderRect)
  
  # Draw text or placeholder
  let textX = input.x + 15.0
  let textY = input.y + (input.h - 24.0) / 2.0
  
  if input.text.len > 0:
    let textColor = SdlColor(r: COLOR_TEXT.r, g: COLOR_TEXT.g, b: COLOR_TEXT.b, a: COLOR_TEXT.a)
    drawText(renderer, font, input.text, textX, textY, textColor)
    
    # Draw cursor if active and visible
    if input.active and input.cursorVisible:
      let cursorX = textX + getTextWidth(font, input.text) + 2
      discard SDL_SetRenderDrawColor(renderer, COLOR_TEXT.r, COLOR_TEXT.g, 
                                      COLOR_TEXT.b, COLOR_TEXT.a)
      var cursorRect = SdlFRect(x: cursorX, y: textY, w: 2, h: 24)
      discard SDL_RenderFillRect(renderer, addr cursorRect)
  elif not input.active:
    let dimColor = SdlColor(r: COLOR_TEXT_DIM.r, g: COLOR_TEXT_DIM.g, b: COLOR_TEXT_DIM.b, a: COLOR_TEXT_DIM.a)
    drawText(renderer, font, input.placeholder, textX, textY, dimColor)

proc updateButtonState(button: var Button, mouseX, mouseY: float32, mousePressed: bool) =
  let isHovering = isPointInRect(mouseX, mouseY, button.x, button.y, button.w, button.h)
  
  if mousePressed and isHovering:
    button.state = bsActive
  elif isHovering:
    button.state = bsHover
  else:
    button.state = bsNormal

proc isButtonClicked(button: Button, mouseX, mouseY: float32): bool =
  isPointInRect(mouseX, mouseY, button.x, button.y, button.w, button.h)

proc isInputClicked(input: TextInput, mouseX, mouseY: float32): bool =
  isPointInRect(mouseX, mouseY, input.x, input.y, input.w, input.h)

# =============================================================================
# Application Logic
# =============================================================================

proc performCalculation(state: var AppState, operation: string) =
  try:
    let num1 = parseFloat(state.input1.text)
    let num2 = parseFloat(state.input2.text)
    
    let result = case operation
      of "add": num1 + num2
      of "subtract": num1 - num2
      of "multiply": num1 * num2
      of "divide":
        if num2 == 0.0:
          state.resultText = "Error: Div by zero"
          return
        else:
          num1 / num2
      else: 0.0
    
    state.resultText = &"Result: {result:.4f}"
  except ValueError:
    state.resultText = "Error: Invalid number"

proc clearInputs(state: var AppState) =
  state.input1.text = ""
  state.input2.text = ""
  state.resultText = ""

proc initApp(): AppState =
  result.running = false
  
  # Create text inputs
  result.input1 = createTextInput(50, 120, 400, 60, "First number")
  result.input2 = createTextInput(50, 200, 400, 60, "Second number")
  
  # Create operation buttons
  let buttonY = 320.0
  let buttonWidth = 85.0
  let buttonHeight = 60.0
  let spacing = 10.0
  
  result.addButton = createButton(50, buttonY, buttonWidth, buttonHeight, 
                                   "+", COLOR_PRIMARY, COLOR_PRIMARY_HOVER)
  result.subtractButton = createButton(50 + buttonWidth + spacing, buttonY, 
                                        buttonWidth, buttonHeight, 
                                        "-", COLOR_PRIMARY, COLOR_PRIMARY_HOVER)
  result.multiplyButton = createButton(50 + (buttonWidth + spacing) * 2, buttonY, 
                                        buttonWidth, buttonHeight, 
                                        "*", COLOR_PRIMARY, COLOR_PRIMARY_HOVER)
  result.divideButton = createButton(50 + (buttonWidth + spacing) * 3, buttonY, 
                                      buttonWidth, buttonHeight, 
                                      "/", COLOR_PRIMARY, COLOR_PRIMARY_HOVER)
  
  # Create clear button
  result.clearButton = createButton(50, 410, 400, 50, 
                                     "CLEAR", COLOR_DANGER, COLOR_DANGER)
  
  result.resultText = ""
  result.animationTime = 0.0

proc handleTextInput(input: var TextInput, text: cstring) =
  if input.active and not text.isNil:
    let str = $text
    for c in str:
      if c in '0'..'9' or c == '.' or c == '-':
        input.text.add(c)

proc handleKeyPress(input: var TextInput, scancode: SdlScancode) =
  if not input.active:
    return
  
  case scancode
  of SDL_SCANCODE_BACKSPACE:
    if input.text.len > 0:
      input.text.setLen(input.text.len - 1)
  of SDL_SCANCODE_DELETE:
    input.text = ""
  else:
    discard

proc handleEvents(state: var AppState): bool =
  var event: SdlEvent

  while SDL_PollEvent(addr event) == SDL_TRUE:
    case event.type
    of SDL_EVENT_QUIT:
      state.running = false
      return false

    of SDL_EVENT_KEY_DOWN:
      if event.key.scancode == SDL_SCANCODE_ESCAPE:
        state.running = false
        return false

      handleKeyPress(state.input1, event.key.scancode)
      handleKeyPress(state.input2, event.key.scancode)

    of SDL_EVENT_TEXT_INPUT:
      handleTextInput(state.input1, event.text.text)
      handleTextInput(state.input2, event.text.text)

    of SDL_EVENT_MOUSE_MOTION:
      state.mouseX = event.motion.x
      state.mouseY = event.motion.y

    of SDL_EVENT_MOUSE_BUTTON_DOWN:
      if event.button.button == SDL_BUTTON_LEFT:
        state.mousePressed = true

    of SDL_EVENT_MOUSE_BUTTON_UP:
      if event.button.button == SDL_BUTTON_LEFT:
        let wasPressed = state.mousePressed
        state.mousePressed = false
        
        if wasPressed:
          # Check input clicks
          if isInputClicked(state.input1, state.mouseX, state.mouseY):
            state.input1.active = true
            state.input2.active = false
            discard SDL_StartTextInput(state.window)
          elif isInputClicked(state.input2, state.mouseX, state.mouseY):
            state.input1.active = false
            state.input2.active = true
            discard SDL_StartTextInput(state.window)
          else:
            state.input1.active = false
            state.input2.active = false
            discard SDL_StopTextInput(state.window)
          
          # Check button clicks
          if isButtonClicked(state.addButton, state.mouseX, state.mouseY):
            performCalculation(state, "add")
          elif isButtonClicked(state.subtractButton, state.mouseX, state.mouseY):
            performCalculation(state, "subtract")
          elif isButtonClicked(state.multiplyButton, state.mouseX, state.mouseY):
            performCalculation(state, "multiply")
          elif isButtonClicked(state.divideButton, state.mouseX, state.mouseY):
            performCalculation(state, "divide")
          elif isButtonClicked(state.clearButton, state.mouseX, state.mouseY):
            clearInputs(state)
    
    else:
      discard
  
  return true

proc renderApp(state: var AppState) =
  # Draw gradient background
  drawGradientBackground(state.renderer, WINDOW_WIDTH, WINDOW_HEIGHT)
  
  # Draw main panel
  discard SDL_SetRenderDrawColor(state.renderer, COLOR_PANEL.r, COLOR_PANEL.g, 
                                  COLOR_PANEL.b, COLOR_PANEL.a)
  drawRoundedRect(state.renderer, 30, 30, 440, 640, 15)
  
  # Draw title
  let titleColor = SdlColor(r: COLOR_TEXT.r, g: COLOR_TEXT.g, b: COLOR_TEXT.b, a: COLOR_TEXT.a)
  drawTextCentered(state.renderer, state.fontLarge, "CALCULATOR", 250, 50, titleColor)
  
  # Update button states
  updateButtonState(state.addButton, state.mouseX, state.mouseY, state.mousePressed)
  updateButtonState(state.subtractButton, state.mouseX, state.mouseY, state.mousePressed)
  updateButtonState(state.multiplyButton, state.mouseX, state.mouseY, state.mousePressed)
  updateButtonState(state.divideButton, state.mouseX, state.mouseY, state.mousePressed)
  updateButtonState(state.clearButton, state.mouseX, state.mouseY, state.mousePressed)
  
  # Render text inputs
  renderTextInput(state.renderer, state.font, state.input1)
  renderTextInput(state.renderer, state.font, state.input2)
  
  # Render buttons
  renderButton(state.renderer, state.font, state.addButton)
  renderButton(state.renderer, state.font, state.subtractButton)
  renderButton(state.renderer, state.font, state.multiplyButton)
  renderButton(state.renderer, state.font, state.divideButton)
  renderButton(state.renderer, state.fontSmall, state.clearButton)
  
  # Draw result
  if state.resultText.len > 0:
    let resultY = 500.0
    discard SDL_SetRenderDrawColor(state.renderer, COLOR_INPUT_BG.r, COLOR_INPUT_BG.g,
                                    COLOR_INPUT_BG.b, COLOR_INPUT_BG.a)
    drawRoundedRect(state.renderer, 50, resultY, 400, 80, 8)
    
    let textColor = if state.resultText.startsWith("Error"): 
      SdlColor(r: COLOR_DANGER.r, g: COLOR_DANGER.g, b: COLOR_DANGER.b, a: COLOR_DANGER.a)
    else: 
      SdlColor(r: COLOR_SUCCESS.r, g: COLOR_SUCCESS.g, b: COLOR_SUCCESS.b, a: COLOR_SUCCESS.a)
    
    drawTextCentered(state.renderer, state.font, state.resultText, 250, resultY + 28, textColor)
  
  # Present
  discard SDL_RenderPresent(state.renderer)

proc updateCursorBlink(state: var AppState) =
  let currentTime = SDL_GetTicks()
  if currentTime - state.input1.lastCursorBlink > 500:
    state.input1.cursorVisible = not state.input1.cursorVisible
    state.input1.lastCursorBlink = currentTime
  if currentTime - state.input2.lastCursorBlink > 500:
    state.input2.cursorVisible = not state.input2.cursorVisible
    state.input2.lastCursorBlink = currentTime

# =============================================================================
# Main Program
# =============================================================================

proc main() =
  echo "SDL3 Calculator - Modern UI Application"
  echo "========================================"
  
  # Initialize SDL
  if SDL_Init(SDL_INIT_VIDEO or SDL_INIT_EVENTS) == SDL_FALSE:
    echo "SDL_Init failed: ", SDL_GetError()
    quit(1)
  
  # Initialize TTF
  if not initTTF():
    echo "TTF initialization failed"
    SDL_Quit()
    quit(1)
  
  echo "SDL and SDL_ttf initialized"
  
  # Find and load font
  let fontPath = findSystemFont()
  if fontPath == "":
    echo "ERROR: No system fonts found!"
    echo "Please install DejaVu Sans or Liberation Sans fonts"
    quitTTF()
    SDL_Quit()
    quit(1)
  
  echo "Using font: ", fontPath
  
  var state = initApp()
  
  # Load fonts in different sizes
  state.font = loadFont(fontPath, 24)
  state.fontLarge = loadFont(fontPath, 32)
  state.fontSmall = loadFont(fontPath, 18)
  
  if state.font.isNil or state.fontLarge.isNil or state.fontSmall.isNil:
    echo "Failed to load fonts"
    quitTTF()
    SDL_Quit()
    quit(1)
  
  echo "Fonts loaded successfully"
  
  # Create window
  state.window = SDL_CreateWindow(WINDOW_TITLE, WINDOW_WIDTH, WINDOW_HEIGHT, 0)
  if state.window.isNil:
    echo "SDL_CreateWindow failed: ", SDL_GetError()
    TTF_CloseFont(state.font)
    TTF_CloseFont(state.fontLarge)
    TTF_CloseFont(state.fontSmall)
    quitTTF()
    SDL_Quit()
    quit(1)
  
  # Create renderer
  state.renderer = SDL_CreateRenderer(state.window, nil)
  if state.renderer.isNil:
    echo "SDL_CreateRenderer failed: ", SDL_GetError()
    SDL_DestroyWindow(state.window)
    TTF_CloseFont(state.font)
    TTF_CloseFont(state.fontLarge)
    TTF_CloseFont(state.fontSmall)
    quitTTF()
    SDL_Quit()
    quit(1)
  
  echo "Window and renderer created successfully"
  echo "\nControls:"
  echo "  Click input fields to enter numbers"
  echo "  Click operation buttons to calculate"
  echo "  Click CLEAR to reset"
  echo "  Press ESC to quit"
  
  # Enable VSync
  discard SDL_SetRenderVSync(state.renderer, 1)
  
  # Main loop
  state.running = true
  while state.running:
    if not handleEvents(state):
      break
    
    updateCursorBlink(state)
    renderApp(state)
    
    SDL_Delay(16)
  
  # Cleanup
  TTF_CloseFont(state.font)
  TTF_CloseFont(state.fontLarge)
  TTF_CloseFont(state.fontSmall)
  SDL_DestroyRenderer(state.renderer)
  SDL_DestroyWindow(state.window)
  quitTTF()
  SDL_Quit()
  
  echo "\nCalculator closed successfully"

when isMainModule:
  main()









# nim c -d:release Modern_sdl3_calculator.nim




