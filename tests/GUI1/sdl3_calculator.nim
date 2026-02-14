## SDL3 Modern Calculator Application with Bitmap Font
## ====================================================
##
## A beautiful, modern calculator with proper text rendering
## Uses a simple bitmap font for displaying text

import libSDL
import std/[strformat, math, strutils, tables]

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
# Bitmap Font Data (8x8 pixels per character)
# =============================================================================

const FONT_WIDTH = 5
const FONT_HEIGHT = 7
const FONT_SCALE = 2

# Simple 5x7 bitmap font for numbers and common symbols
const FONT_DATA = {
  '0': [
    0b01110,
    0b10001,
    0b10011,
    0b10101,
    0b11001,
    0b10001,
    0b01110
  ],
  '1': [
    0b00100,
    0b01100,
    0b00100,
    0b00100,
    0b00100,
    0b00100,
    0b01110
  ],
  '2': [
    0b01110,
    0b10001,
    0b00001,
    0b00010,
    0b00100,
    0b01000,
    0b11111
  ],
  '3': [
    0b01110,
    0b10001,
    0b00001,
    0b00110,
    0b00001,
    0b10001,
    0b01110
  ],
  '4': [
    0b00010,
    0b00110,
    0b01010,
    0b10010,
    0b11111,
    0b00010,
    0b00010
  ],
  '5': [
    0b11111,
    0b10000,
    0b11110,
    0b00001,
    0b00001,
    0b10001,
    0b01110
  ],
  '6': [
    0b01110,
    0b10001,
    0b10000,
    0b11110,
    0b10001,
    0b10001,
    0b01110
  ],
  '7': [
    0b11111,
    0b00001,
    0b00010,
    0b00100,
    0b01000,
    0b01000,
    0b01000
  ],
  '8': [
    0b01110,
    0b10001,
    0b10001,
    0b01110,
    0b10001,
    0b10001,
    0b01110
  ],
  '9': [
    0b01110,
    0b10001,
    0b10001,
    0b01111,
    0b00001,
    0b10001,
    0b01110
  ],
  '.': [
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b01100,
    0b01100
  ],
  '-': [
    0b00000,
    0b00000,
    0b00000,
    0b11111,
    0b00000,
    0b00000,
    0b00000
  ],
  '+': [
    0b00000,
    0b00100,
    0b00100,
    0b11111,
    0b00100,
    0b00100,
    0b00000
  ],
  '*': [
    0b00000,
    0b10101,
    0b01110,
    0b11111,
    0b01110,
    0b10101,
    0b00000
  ],
  '/': [
    0b00000,
    0b00001,
    0b00010,
    0b00100,
    0b01000,
    0b10000,
    0b00000
  ],
  ':': [
    0b00000,
    0b01100,
    0b01100,
    0b00000,
    0b01100,
    0b01100,
    0b00000
  ],
  ' ': [
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000,
    0b00000
  ],
  'A': [
    0b01110,
    0b10001,
    0b10001,
    0b11111,
    0b10001,
    0b10001,
    0b10001
  ],
  'B': [
    0b11110,
    0b10001,
    0b10001,
    0b11110,
    0b10001,
    0b10001,
    0b11110
  ],
  'C': [
    0b01110,
    0b10001,
    0b10000,
    0b10000,
    0b10000,
    0b10001,
    0b01110
  ],
  'D': [
    0b11110,
    0b10001,
    0b10001,
    0b10001,
    0b10001,
    0b10001,
    0b11110
  ],
  'E': [
    0b11111,
    0b10000,
    0b10000,
    0b11110,
    0b10000,
    0b10000,
    0b11111
  ],
  'F': [
    0b11111,
    0b10000,
    0b10000,
    0b11110,
    0b10000,
    0b10000,
    0b10000
  ],
  'G': [
    0b01110,
    0b10001,
    0b10000,
    0b10111,
    0b10001,
    0b10001,
    0b01110
  ],
  'H': [
    0b10001,
    0b10001,
    0b10001,
    0b11111,
    0b10001,
    0b10001,
    0b10001
  ],
  'I': [
    0b01110,
    0b00100,
    0b00100,
    0b00100,
    0b00100,
    0b00100,
    0b01110
  ],
  'L': [
    0b10000,
    0b10000,
    0b10000,
    0b10000,
    0b10000,
    0b10000,
    0b11111
  ],
  'M': [
    0b10001,
    0b11011,
    0b10101,
    0b10001,
    0b10001,
    0b10001,
    0b10001
  ],
  'N': [
    0b10001,
    0b11001,
    0b10101,
    0b10011,
    0b10001,
    0b10001,
    0b10001
  ],
  'O': [
    0b01110,
    0b10001,
    0b10001,
    0b10001,
    0b10001,
    0b10001,
    0b01110
  ],
  'R': [
    0b11110,
    0b10001,
    0b10001,
    0b11110,
    0b10100,
    0b10010,
    0b10001
  ],
  'S': [
    0b01110,
    0b10001,
    0b10000,
    0b01110,
    0b00001,
    0b10001,
    0b01110
  ],
  'T': [
    0b11111,
    0b00100,
    0b00100,
    0b00100,
    0b00100,
    0b00100,
    0b00100
  ],
  'U': [
    0b10001,
    0b10001,
    0b10001,
    0b10001,
    0b10001,
    0b10001,
    0b01110
  ],
  'V': [
    0b10001,
    0b10001,
    0b10001,
    0b10001,
    0b10001,
    0b01010,
    0b00100
  ],
  'Y': [
    0b10001,
    0b10001,
    0b01010,
    0b00100,
    0b00100,
    0b00100,
    0b00100
  ],
  'Z': [
    0b11111,
    0b00001,
    0b00010,
    0b00100,
    0b01000,
    0b10000,
    0b11111
  ],
  'a': [
    0b00000,
    0b00000,
    0b01110,
    0b00001,
    0b01111,
    0b10001,
    0b01111
  ],
  'b': [
    0b10000,
    0b10000,
    0b11110,
    0b10001,
    0b10001,
    0b10001,
    0b11110
  ],
  'c': [
    0b00000,
    0b00000,
    0b01110,
    0b10000,
    0b10000,
    0b10001,
    0b01110
  ],
  'd': [
    0b00001,
    0b00001,
    0b01111,
    0b10001,
    0b10001,
    0b10001,
    0b01111
  ],
  'e': [
    0b00000,
    0b00000,
    0b01110,
    0b10001,
    0b11111,
    0b10000,
    0b01110
  ],
  'i': [
    0b00100,
    0b00000,
    0b01100,
    0b00100,
    0b00100,
    0b00100,
    0b01110
  ],
  'l': [
    0b01100,
    0b00100,
    0b00100,
    0b00100,
    0b00100,
    0b00100,
    0b01110
  ],
  'm': [
    0b00000,
    0b00000,
    0b11010,
    0b10101,
    0b10101,
    0b10001,
    0b10001
  ],
  'n': [
    0b00000,
    0b00000,
    0b11110,
    0b10001,
    0b10001,
    0b10001,
    0b10001
  ],
  'o': [
    0b00000,
    0b00000,
    0b01110,
    0b10001,
    0b10001,
    0b10001,
    0b01110
  ],
  'r': [
    0b00000,
    0b00000,
    0b10110,
    0b11001,
    0b10000,
    0b10000,
    0b10000
  ],
  's': [
    0b00000,
    0b00000,
    0b01111,
    0b10000,
    0b01110,
    0b00001,
    0b11110
  ],
  't': [
    0b00100,
    0b00100,
    0b11111,
    0b00100,
    0b00100,
    0b00100,
    0b00010
  ],
  'u': [
    0b00000,
    0b00000,
    0b10001,
    0b10001,
    0b10001,
    0b10011,
    0b01101
  ],
  'v': [
    0b00000,
    0b00000,
    0b10001,
    0b10001,
    0b10001,
    0b01010,
    0b00100
  ],
  'y': [
    0b00000,
    0b00000,
    0b10001,
    0b10001,
    0b01111,
    0b00001,
    0b01110
  ],
  'z': [
    0b00000,
    0b00000,
    0b11111,
    0b00010,
    0b00100,
    0b01000,
    0b11111
  ]
}.toTable

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
    normalColor, hoverColor, activeColor: tuple[r, g, b, a: uint8]
    textColor: tuple[r, g, b, a: uint8]
    cornerRadius: float32
  
  TextInput = object
    x, y, w, h: float32
    text: string
    placeholder: string
    active: bool
    cursorPos: int
    cursorVisible: bool
    lastCursorBlink: uint64
  
  AppState = object
    window: SdlWindow
    renderer: SdlRenderer
    running: bool
    mouseX, mouseY: float32
    mousePressed: bool
    
    # UI Elements
    input1: TextInput
    input2: TextInput
    resultText: string
    
    addButton: Button
    subtractButton: Button
    multiplyButton: Button
    divideButton: Button
    clearButton: Button
    
    animationTime: float32

# =============================================================================
# Bitmap Font Rendering
# =============================================================================

proc drawChar(renderer: SdlRenderer, c: char, x, y: float32, 
              color: tuple[r, g, b, a: uint8], scale: int = FONT_SCALE) =
  if not FONT_DATA.hasKey(c):
    return
  
  discard SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
  
  let charData = FONT_DATA[c]
  for row in 0..<FONT_HEIGHT:
    let bits = charData[row]
    for col in 0..<FONT_WIDTH:
      if (bits and (1 shl (FONT_WIDTH - 1 - col))) != 0:
        var rect = SdlFRect(
          x: x + float32(col * scale),
          y: y + float32(row * scale),
          w: float32(scale),
          h: float32(scale)
        )
        discard SDL_RenderFillRect(renderer, addr rect)

proc drawText(renderer: SdlRenderer, text: string, x, y: float32, 
              color: tuple[r, g, b, a: uint8], scale: int = FONT_SCALE) =
  var currentX = x
  for c in text:
    drawChar(renderer, c, currentX, y, color, scale)
    currentX += float32((FONT_WIDTH + 1) * scale)

proc getTextWidth(text: string, scale: int = FONT_SCALE): float32 =
  float32(text.len * (FONT_WIDTH + 1) * scale)

# =============================================================================
# Helper Functions
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
  result.activeColor = (r: normalColor.r - 10, g: normalColor.g - 10, 
                        b: normalColor.b - 10, a: normalColor.a)
  result.textColor = COLOR_TEXT
  result.cornerRadius = 8.0

proc createTextInput(x, y, w, h: float32, placeholder: string): TextInput =
  result.x = x
  result.y = y
  result.w = w
  result.h = h
  result.placeholder = placeholder
  result.active = false
  result.cursorPos = 0
  result.cursorVisible = true
  result.lastCursorBlink = 0

proc isPointInRect(px, py, x, y, w, h: float32): bool =
  px >= x and px <= x + w and py >= y and py <= y + h

proc drawRoundedRect(renderer: SdlRenderer, x, y, w, h, radius: float32) =
  var rect: SdlFRect
  
  # Center
  rect = SdlFRect(x: x + radius, y: y + radius, w: w - radius * 2, h: h - radius * 2)
  discard SDL_RenderFillRect(renderer, addr rect)
  
  # Top, Bottom, Left, Right
  rect = SdlFRect(x: x + radius, y: y, w: w - radius * 2, h: radius)
  discard SDL_RenderFillRect(renderer, addr rect)
  
  rect = SdlFRect(x: x + radius, y: y + h - radius, w: w - radius * 2, h: radius)
  discard SDL_RenderFillRect(renderer, addr rect)
  
  rect = SdlFRect(x: x, y: y + radius, w: radius, h: h - radius * 2)
  discard SDL_RenderFillRect(renderer, addr rect)
  
  rect = SdlFRect(x: x + w - radius, y: y + radius, w: radius, h: h - radius * 2)
  discard SDL_RenderFillRect(renderer, addr rect)
  
  # Corners
  let steps = 8
  for i in 0..steps:
    let angle = (PI / 2.0) * (float(i) / float(steps))
    let dx = radius - cos(angle) * radius
    let dy = radius - sin(angle) * radius
    
    var cornerRect = SdlFRect(x: x + dx, y: y + dy, w: 2, h: 2)
    discard SDL_RenderFillRect(renderer, addr cornerRect)
    
    cornerRect = SdlFRect(x: x + w - dx - 2, y: y + dy, w: 2, h: 2)
    discard SDL_RenderFillRect(renderer, addr cornerRect)
    
    cornerRect = SdlFRect(x: x + dx, y: y + h - dy - 2, w: 2, h: 2)
    discard SDL_RenderFillRect(renderer, addr cornerRect)
    
    cornerRect = SdlFRect(x: x + w - dx - 2, y: y + h - dy - 2, w: 2, h: 2)
    discard SDL_RenderFillRect(renderer, addr cornerRect)

proc drawGradientBackground(renderer: SdlRenderer, width, height: cint) =
  let steps = 50
  for i in 0..steps:
    let t = float(i) / float(steps)
    let r = uint8(float(COLOR_BG_TOP.r) * (1.0 - t) + float(COLOR_BG_BOTTOM.r) * t)
    let g = uint8(float(COLOR_BG_TOP.g) * (1.0 - t) + float(COLOR_BG_BOTTOM.g) * t)
    let b = uint8(float(COLOR_BG_TOP.b) * (1.0 - t) + float(COLOR_BG_BOTTOM.b) * t)
    
    discard SDL_SetRenderDrawColor(renderer, r, g, b, 255)
    
    let y = (float(height) / float(steps)) * float(i)
    let h = (float(height) / float(steps)) + 1
    var rect = SdlFRect(x: 0, y: y, w: float(width), h: h)
    discard SDL_RenderFillRect(renderer, addr rect)

# =============================================================================
# UI Rendering
# =============================================================================

proc renderButton(renderer: SdlRenderer, button: Button) =
  # Draw shadow
  discard SDL_SetRenderDrawColor(renderer, COLOR_SHADOW.r, COLOR_SHADOW.g, 
                                  COLOR_SHADOW.b, COLOR_SHADOW.a)
  drawRoundedRect(renderer, button.x + 2, button.y + 4, button.w, button.h, button.cornerRadius)
  
  # Draw button
  let color = case button.state
    of bsNormal: button.normalColor
    of bsHover: button.hoverColor
    of bsActive: button.activeColor
  
  discard SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a)
  drawRoundedRect(renderer, button.x, button.y, button.w, button.h, button.cornerRadius)
  
  # Draw text (centered)
  let textWidth = getTextWidth(button.text, 2)
  let textX = button.x + (button.w - textWidth) / 2.0
  let textY = button.y + (button.h - float32(FONT_HEIGHT * 2)) / 2.0
  drawText(renderer, button.text, textX, textY, button.textColor, 2)

proc renderTextInput(renderer: SdlRenderer, input: TextInput) =
  # Draw shadow
  discard SDL_SetRenderDrawColor(renderer, COLOR_SHADOW.r, COLOR_SHADOW.g, 
                                  COLOR_SHADOW.b, COLOR_SHADOW.a)
  drawRoundedRect(renderer, input.x + 2, input.y + 4, input.w, input.h, 8.0)
  
  # Draw input background
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
  let textY = input.y + (input.h - float32(FONT_HEIGHT * 2)) / 2.0
  
  if input.text.len > 0:
    drawText(renderer, input.text, textX, textY, COLOR_TEXT, 2)
    
    # Draw cursor if active and visible
    if input.active and input.cursorVisible:
      let cursorX = textX + getTextWidth(input.text, 2) + 2
      discard SDL_SetRenderDrawColor(renderer, COLOR_TEXT.r, COLOR_TEXT.g, 
                                      COLOR_TEXT.b, COLOR_TEXT.a)
      var cursorRect = SdlFRect(x: cursorX, y: textY, w: 2, h: float32(FONT_HEIGHT * 2))
      discard SDL_RenderFillRect(renderer, addr cursorRect)
  elif not input.active:
    drawText(renderer, input.placeholder, textX, textY, COLOR_TEXT_DIM, 2)

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
  let titleWidth = getTextWidth("CALCULATOR", 3)
  let titleX = 250 - titleWidth / 2
  drawText(state.renderer, "CALCULATOR", titleX, 55, COLOR_TEXT, 3)
  
  # Update button states
  updateButtonState(state.addButton, state.mouseX, state.mouseY, state.mousePressed)
  updateButtonState(state.subtractButton, state.mouseX, state.mouseY, state.mousePressed)
  updateButtonState(state.multiplyButton, state.mouseX, state.mouseY, state.mousePressed)
  updateButtonState(state.divideButton, state.mouseX, state.mouseY, state.mousePressed)
  updateButtonState(state.clearButton, state.mouseX, state.mouseY, state.mousePressed)
  
  # Render text inputs
  renderTextInput(state.renderer, state.input1)
  renderTextInput(state.renderer, state.input2)
  
  # Render buttons
  renderButton(state.renderer, state.addButton)
  renderButton(state.renderer, state.subtractButton)
  renderButton(state.renderer, state.multiplyButton)
  renderButton(state.renderer, state.divideButton)
  renderButton(state.renderer, state.clearButton)
  
  # Draw result
  if state.resultText.len > 0:
    let resultY = 500.0
    discard SDL_SetRenderDrawColor(state.renderer, COLOR_INPUT_BG.r, COLOR_INPUT_BG.g,
                                    COLOR_INPUT_BG.b, COLOR_INPUT_BG.a)
    drawRoundedRect(state.renderer, 50, resultY, 400, 80, 8)
    
    let textColor = if state.resultText.startsWith("Error"): COLOR_DANGER else: COLOR_SUCCESS
    let textWidth = getTextWidth(state.resultText, 2)
    let textX = 250 - textWidth / 2
    drawText(state.renderer, state.resultText, textX, resultY + 30, textColor, 2)
  
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
  
  var state = initApp()
  
  # Create window
  state.window = SDL_CreateWindow(WINDOW_TITLE, WINDOW_WIDTH, WINDOW_HEIGHT, 0)
  if state.window.isNil:
    echo "SDL_CreateWindow failed: ", SDL_GetError()
    SDL_Quit()
    quit(1)
  
  # Create renderer
  state.renderer = SDL_CreateRenderer(state.window, nil)
  if state.renderer.isNil:
    echo "SDL_CreateRenderer failed: ", SDL_GetError()
    SDL_DestroyWindow(state.window)
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
  SDL_DestroyRenderer(state.renderer)
  SDL_DestroyWindow(state.window)
  SDL_Quit()
  
  echo "\nCalculator closed successfully"

when isMainModule:
  main()
