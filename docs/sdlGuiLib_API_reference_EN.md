# sdlGuiLib - API Reference

## General Information

**Version:** 0.3  
**Date:** 2026-02-15  
**Dependencies:** libSDL.nim (SDL3 wrapper)  
**Author:** github.com/Balans097

Cross-platform GUI library for Nim built on SDL3.

---

## Table of Contents

1. [Constants and Types](#constants-and-types)
2. [Themes](#themes)
3. [GUI Manager](#gui-manager)
4. [Base Widgets](#base-widgets)
5. [Buttons and Controls](#buttons-and-controls)
6. [Text Fields](#text-fields)
7. [Lists and Selection](#lists-and-selection)
8. [Containers and Panels](#containers-and-panels)
9. [Menus and Toolbars](#menus-and-toolbars)
10. [Dialogs](#dialogs)
11. [Utility Functions](#utility-functions)

---

## Constants and Types

### Keyboard Keys (SdlKeycode)

Additional keyboard key constants for SDL3:

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

### WidgetState (enumeration)

Widget states:

- `wsNormal` - normal state
- `wsHover` - cursor over widget
- `wsPressed` - widget pressed
- `wsActive` - widget active
- `wsDisabled` - widget disabled
- `wsFocused` - widget focused

### Alignment (enumeration)

Element alignment:

- `alignLeft` - align to left
- `alignCenter` - align to center
- `alignRight` - align to right
- `alignTop` - align to top
- `alignMiddle` - align to middle
- `alignBottom` - align to bottom

### DialogType (enumeration)

Dialog window types:

- `dtInfo` - information message
- `dtWarning` - warning
- `dtError` - error
- `dtQuestion` - question

### DialogButton (enumeration)

Dialog buttons:

- `dbOk` - "OK" button
- `dbCancel` - "Cancel" button
- `dbYes` - "Yes" button
- `dbNo` - "No" button

---

## Themes

### GuiTheme

GUI theme styling.

```nim
type GuiTheme* = ref object
  bgColor*: SdlColor              # background color
  textColor*: SdlColor            # text color
  borderColor*: SdlColor          # border color
  accentColor*: SdlColor          # accent color
  hoverColor*: SdlColor           # hover color
  activeColor*: SdlColor          # active element color
  disabledColor*: SdlColor        # disabled element color
  font*: TTF_Font                 # main font
  fontSize*: float                # font size
  padding*: int                   # padding
  borderWidth*: int               # border width
```

### createDefaultTheme

Create default light theme.

```nim
proc createDefaultTheme*(font: TTF_Font, fontSize: float = 16.0): GuiTheme
```

**Parameters:**
- `font` - font for the theme
- `fontSize` - font size (default 16.0)

**Returns:** new light theme

**Example:**
```nim
let theme = createDefaultTheme(myFont, 14.0)
```

### createDarkTheme

Create dark theme.

```nim
proc createDarkTheme*(font: TTF_Font, fontSize: float = 16.0): GuiTheme
```

**Parameters:**
- `font` - font for the theme
- `fontSize` - font size (default 16.0)

**Returns:** new dark theme

**Example:**
```nim
let darkTheme = createDarkTheme(myFont, 16.0)
```

---

## GUI Manager

### GuiManager

Manager for GUI control.

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

Create GUI manager.

```nim
proc createGuiManager*(renderer: SdlRenderer, theme: GuiTheme): GuiManager
```

**Parameters:**
- `renderer` - SDL renderer
- `theme` - GUI theme

**Returns:** new GUI manager

**Example:**
```nim
let gui = createGuiManager(renderer, theme)
```

### addWidget

Add widget to manager.

```nim
proc addWidget*(gui: GuiManager, widget: Widget)
```

**Parameters:**
- `gui` - GUI manager
- `widget` - widget to add

**Example:**
```nim
gui.addWidget(button)
```

### removeWidget

Remove widget from manager.

```nim
proc removeWidget*(gui: GuiManager, widget: Widget)
```

**Parameters:**
- `gui` - GUI manager
- `widget` - widget to remove

### findWidgetById

Find widget by ID.

```nim
proc findWidgetById*(gui: GuiManager, id: string): Widget
```

**Parameters:**
- `gui` - GUI manager
- `id` - widget identifier

**Returns:** widget or nil if not found

### setFocus

Set focus to widget.

```nim
proc setFocus*(gui: GuiManager, widget: Widget)
```

**Parameters:**
- `gui` - GUI manager
- `widget` - widget to focus (or nil to clear focus)

### updateCursorBlink

Update cursor blinking (call in main loop).

```nim
proc updateCursorBlink*(gui: GuiManager)
```

**Parameters:**
- `gui` - GUI manager

### renderGui

Render all GUI widgets.

```nim
proc renderGui*(gui: GuiManager)
```

**Parameters:**
- `gui` - GUI manager

**Example:**
```nim
# In main loop
gui.renderGui()
```

### handleGuiEvent

Handle event for all widgets.

```nim
proc handleGuiEvent*(gui: GuiManager, event: ptr SdlEvent): bool
```

**Parameters:**
- `gui` - GUI manager
- `event` - SDL event

**Returns:** true if event was handled

**Example:**
```nim
if gui.handleGuiEvent(addr event):
  continue  # Event handled by GUI
```

---

## Base Widgets

### Widget (base class)

Base class for all widgets.

```nim
type Widget* = ref object of RootObj
  id*: string                    # unique identifier
  rect*: SdlRect                 # position and size
  state*: WidgetState            # widget state
  visible*: bool                 # visibility
  enabled*: bool                 # enabled/disabled
  parent*: Widget                # parent widget
  children*: seq[Widget]         # child widgets
  tooltip*: string               # tooltip text
  userData*: pointer             # user data
```

---

## Buttons and Controls

### Button

Push button.

```nim
type Button* = ref object of Widget
  text*: string                  # button text
  textColor*: SdlColor           # text color
  bgColor*: SdlColor             # background color
  hoverColor*: SdlColor          # hover color
  activeColor*: SdlColor         # active/pressed color
  borderColor*: SdlColor         # border color
  icon*: SdlTexture              # icon texture
  iconRect*: SdlRect             # icon position
  onClick*: proc(btn: Button)    # click handler
  textAlign*: Alignment          # text alignment
```

### createButton

Create button.

```nim
proc createButton*(theme: GuiTheme, id: string, text: string, 
                  x, y, w, h: int): Button
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `text` - button text
- `x, y` - coordinates
- `w, h` - width and height

**Returns:** new button

**Example:**
```nim
let button = createButton(theme, "btnSave", "Save", 10, 10, 100, 30)
button.onClick = proc(btn: Button) =
  echo "Button clicked!"
gui.addWidget(button)
```

### CheckBox

Checkbox for on/off states.

```nim
type CheckBox* = ref object of Widget
  text*: string                     # label text
  checked*: bool                    # checked state
  textColor*: SdlColor              # text color
  bgColor*: SdlColor                # background color
  checkColor*: SdlColor             # check mark color
  borderColor*: SdlColor            # border color
  onChange*: proc(cb: CheckBox, checked: bool)  # change handler
```

### createCheckBox

Create checkbox.

```nim
proc createCheckBox*(theme: GuiTheme, id: string, text: string, 
                    x, y: int, checked: bool = false): CheckBox
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `text` - label text
- `x, y` - coordinates
- `checked` - initial state

**Returns:** new checkbox

**Example:**
```nim
let checkbox = createCheckBox(theme, "cbRemember", "Remember me", 10, 50)
checkbox.onChange = proc(cb: CheckBox, checked: bool) =
  echo "Checkbox: ", checked
gui.addWidget(checkbox)
```

### RadioButton

Radio button for mutually exclusive selection.

```nim
type RadioButton* = ref object of Widget
  text*: string                     # label text
  checked*: bool                    # checked state
  group*: string                    # radio button group
  textColor*: SdlColor              # text color
  bgColor*: SdlColor                # background color
  checkColor*: SdlColor             # check mark color
  borderColor*: SdlColor            # border color
  onChange*: proc(rb: RadioButton, checked: bool)  # change handler
```

### createRadioButton

Create radio button.

```nim
proc createRadioButton*(theme: GuiTheme, id: string, text: string, 
                       group: string, x, y: int, 
                       checked: bool = false): RadioButton
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `text` - label text
- `group` - group name (buttons with same group are mutually exclusive)
- `x, y` - coordinates
- `checked` - initial state

**Returns:** new radio button

**Example:**
```nim
let rb1 = createRadioButton(theme, "rb1", "Option 1", "group1", 10, 80, true)
let rb2 = createRadioButton(theme, "rb2", "Option 2", "group1", 10, 110)
gui.registerRadioButton(rb1)
gui.registerRadioButton(rb2)
gui.addWidget(rb1)
gui.addWidget(rb2)
```

### registerRadioButton

Register radio button in group.

```nim
proc registerRadioButton*(gui: GuiManager, radioButton: RadioButton)
```

**Parameters:**
- `gui` - GUI manager
- `radioButton` - radio button to register

### Slider

Slider for selecting a value in range.

```nim
type Slider* = ref object of Widget
  minValue*: float                # minimum value
  maxValue*: float                # maximum value
  value*: float                   # current value
  step*: float                    # step value
  orientation*: Alignment         # orientation (alignLeft=horizontal, alignTop=vertical)
  trackColor*: SdlColor           # track color
  thumbColor*: SdlColor           # thumb color
  fillColor*: SdlColor            # fill color
  thumbRect*: SdlRect             # thumb rectangle
  onChange*: proc(slider: Slider, value: float)  # change handler
```

### createSlider

Create slider.

```nim
proc createSlider*(theme: GuiTheme, id: string, x, y, w, h: int,
                  minValue, maxValue, value: float = 0.0,
                  orientation: Alignment = alignLeft): Slider
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `x, y` - coordinates
- `w, h` - width and height
- `minValue` - minimum value
- `maxValue` - maximum value
- `value` - initial value
- `orientation` - orientation (alignLeft - horizontal, alignTop - vertical)

**Returns:** new slider

**Example:**
```nim
let slider = createSlider(theme, "volume", 10, 140, 200, 20, 0.0, 100.0, 50.0)
slider.onChange = proc(s: Slider, val: float) =
  echo "Value: ", val
gui.addWidget(slider)
```

### ProgressBar

Progress indicator.

```nim
type ProgressBar* = ref object of Widget
  minValue*: float                # minimum value
  maxValue*: float                # maximum value
  value*: float                   # current value
  bgColor*: SdlColor              # background color
  fillColor*: SdlColor            # fill color
  borderColor*: SdlColor          # border color
  showText*: bool                 # show percentage text
  textColor*: SdlColor            # text color
```

### createProgressBar

Create progress bar.

```nim
proc createProgressBar*(theme: GuiTheme, id: string, x, y, w, h: int,
                       minValue, maxValue, value: float = 0.0): ProgressBar
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `x, y` - coordinates
- `w, h` - width and height
- `minValue` - minimum value
- `maxValue` - maximum value
- `value` - initial value

**Returns:** new progress bar

**Example:**
```nim
let progress = createProgressBar(theme, "progress", 10, 170, 200, 25, 0.0, 100.0, 30.0)
progress.showText = true
gui.addWidget(progress)
```

### SpinBox

Numeric input field with increment/decrement buttons.

```nim
type SpinBox* = ref object of Widget
  value*: float                   # current value
  minValue*: float                # minimum value
  maxValue*: float                # maximum value
  step*: float                    # step value
  decimals*: int                  # decimal places
  textColor*: SdlColor            # text color
  bgColor*: SdlColor              # background color
  borderColor*: SdlColor          # border color
  buttonColor*: SdlColor          # button color
  upButtonRect*: SdlRect          # up button area
  downButtonRect*: SdlRect        # down button area
  onChange*: proc(spin: SpinBox, value: float)  # change handler
```

### createSpinBox

Create spin box.

```nim
proc createSpinBox*(theme: GuiTheme, id: string, x, y, w, h: int,
                   value: float = 0.0, minValue: float = 0.0, 
                   maxValue: float = 100.0, step: float = 1.0): SpinBox
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `x, y` - coordinates
- `w, h` - width and height
- `value` - initial value
- `minValue` - minimum value
- `maxValue` - maximum value
- `step` - step value

**Returns:** new spin box

**Example:**
```nim
let spinbox = createSpinBox(theme, "spin", 10, 200, 120, 30, 5.0, 0.0, 10.0, 0.5)
spinbox.onChange = proc(sb: SpinBox, val: float) =
  echo "New value: ", val
gui.addWidget(spinbox)
```

---

## Text Fields

### TextField

Single-line text input field.

```nim
type TextField* = ref object of Widget
  text*: string                   # field text
  placeholder*: string            # placeholder text
  textColor*: SdlColor            # text color
  placeholderColor*: SdlColor     # placeholder color
  bgColor*: SdlColor              # background color
  borderColor*: SdlColor          # border color
  cursorPos*: int                 # cursor position
  selectionStart*: int            # selection start
  selectionEnd*: int              # selection end
  scrollOffset*: int              # scroll offset
  maxLength*: int                 # maximum text length
  passwordChar*: Rune             # password character
  isPassword*: bool               # password mode
  onChange*: proc(field: TextField, newText: string)  # change handler
  onSubmit*: proc(field: TextField, text: string)     # submit handler (Enter)
```

### createTextField

Create single-line text field.

```nim
proc createTextField*(theme: GuiTheme, id: string, x, y, w, h: int,
                     text: string = "", placeholder: string = ""): TextField
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `x, y` - coordinates
- `w, h` - width and height
- `text` - initial text
- `placeholder` - placeholder text

**Returns:** new text field

**Example:**
```nim
let textField = createTextField(theme, "name", 10, 230, 200, 30, "", "Enter name")
textField.onChange = proc(tf: TextField, newText: string) =
  echo "Text changed: ", newText
textField.onSubmit = proc(tf: TextField, text: string) =
  echo "Submitted: ", text
gui.addWidget(textField)
```

### TextArea

Multi-line text editor.

```nim
type TextArea* = ref object of Widget
  lines*: seq[string]             # text lines
  textColor*: SdlColor            # text color
  bgColor*: SdlColor              # background color
  borderColor*: SdlColor          # border color
  selectionColor*: SdlColor       # selection color
  cursorLine*: int                # cursor line
  cursorCol*: int                 # cursor column
  scrollX*: int                   # horizontal scroll
  scrollY*: int                   # vertical scroll
  selectionStartLine*: int        # selection start line
  selectionStartCol*: int         # selection start column
  selectionEndLine*: int          # selection end line
  selectionEndCol*: int           # selection end column
  hasSelection*: bool             # has selection
  onChange*: proc(area: TextArea) # change handler
```

### createTextArea

Create multi-line text area.

```nim
proc createTextArea*(theme: GuiTheme, id: string, x, y, w, h: int,
                    text: string = ""): TextArea
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `x, y` - coordinates
- `w, h` - width and height
- `text` - initial text (can contain line breaks)

**Returns:** new text area

**Example:**
```nim
let textArea = createTextArea(theme, "editor", 10, 270, 300, 150, "Line 1\nLine 2")
textArea.onChange = proc(ta: TextArea) =
  echo "Text changed"
gui.addWidget(textArea)
```

### Label

Text label for displaying text.

```nim
type Label* = ref object of Widget
  text*: string                   # label text
  textColor*: SdlColor            # text color
  bgColor*: SdlColor              # background color
  textAlign*: Alignment           # text alignment
  wordWrap*: bool                 # word wrap
```

### createLabel

Create text label.

```nim
proc createLabel*(theme: GuiTheme, id: string, text: string, 
                 x, y, w, h: int): Label
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `text` - label text
- `x, y` - coordinates
- `w, h` - width and height

**Returns:** new label

**Example:**
```nim
let label = createLabel(theme, "lblTitle", "Title", 10, 430, 200, 30)
label.textAlign = alignCenter
gui.addWidget(label)
```

---

## Lists and Selection

### ListBox

List of items for selection.

```nim
type ListBox* = ref object of Widget
  items*: seq[string]             # list items
  selectedIndex*: int             # selected item index
  itemHeight*: int                # item height
  scrollOffset*: int              # scroll offset
  textColor*: SdlColor            # text color
  selectedColor*: SdlColor        # selected item color
  hoverColor*: SdlColor           # hover color
  bgColor*: SdlColor              # background color
  borderColor*: SdlColor          # border color
  onSelect*: proc(list: ListBox, index: int)  # selection handler
```

### createListBox

Create list box.

```nim
proc createListBox*(theme: GuiTheme, id: string, items: seq[string],
                   x, y, w, h: int): ListBox
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `items` - list items
- `x, y` - coordinates
- `w, h` - width and height

**Returns:** new list box

**Example:**
```nim
let listbox = createListBox(theme, "list", @["Item 1", "Item 2", "Item 3"], 
                           10, 470, 200, 120)
listbox.onSelect = proc(lb: ListBox, idx: int) =
  echo "Selected item ", idx, ": ", lb.items[idx]
gui.addWidget(listbox)
```

### ComboBox

Drop-down list (combo box).

```nim
type ComboBox* = ref object of Widget
  items*: seq[string]             # list items
  selectedIndex*: int             # selected item index
  isOpen*: bool                   # list open/closed
  textColor*: SdlColor            # text color
  bgColor*: SdlColor              # background color
  borderColor*: SdlColor          # border color
  hoverColor*: SdlColor           # hover color
  selectedColor*: SdlColor        # selected item color
  dropdownHeight*: int            # dropdown height
  hoveredIndex*: int              # hovered item index
  onSelect*: proc(combo: ComboBox, index: int)  # selection handler
```

### createComboBox

Create combo box.

```nim
proc createComboBox*(theme: GuiTheme, id: string, items: seq[string],
                    x, y, w, h: int, selectedIndex: int = 0): ComboBox
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `items` - list items
- `x, y` - coordinates
- `w, h` - width and height
- `selectedIndex` - selected item index (default 0)

**Returns:** new combo box

**Example:**
```nim
let combo = createComboBox(theme, "combo", @["Option 1", "Option 2", "Option 3"], 
                          220, 10, 150, 30)
combo.onSelect = proc(cb: ComboBox, idx: int) =
  echo "Selected option ", idx
gui.addWidget(combo)
```

---

## Containers and Panels

### Panel

Container for other widgets.

```nim
type Panel* = ref object of Widget
  bgColor*: SdlColor              # background color
  borderColor*: SdlColor          # border color
  scrollX*: int                   # horizontal scroll
  scrollY*: int                   # vertical scroll
  scrollable*: bool               # enable scrolling
```

### createPanel

Create panel container.

```nim
proc createPanel*(theme: GuiTheme, id: string, x, y, w, h: int): Panel
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `x, y` - coordinates
- `w, h` - width and height

**Returns:** new panel

**Example:**
```nim
let panel = createPanel(theme, "panel", 380, 10, 300, 400)
panel.bgColor = initColor(240, 240, 240, 255)
gui.addWidget(panel)

# Add child widget
let childButton = createButton(theme, "btnChild", "Button in panel", 10, 10, 120, 30)
childButton.parent = panel
panel.children.add(childButton)
```

### TabControl

Tab control widget.

```nim
type Tab* = object
  title*: string                  # tab title
  content*: Widget                # tab content

type TabControl* = ref object of Widget
  tabs*: seq[Tab]                 # tabs
  activeTab*: int                 # active tab index
  tabHeight*: int                 # tab header height
  textColor*: SdlColor            # text color
  bgColor*: SdlColor              # background color
  activeColor*: SdlColor          # active tab color
  borderColor*: SdlColor          # border color
  onTabChange*: proc(tc: TabControl, index: int)  # tab change handler
```

### createTabControl

Create tab control.

```nim
proc createTabControl*(theme: GuiTheme, id: string, x, y, w, h: int): TabControl
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `x, y` - coordinates
- `w, h` - width and height

**Returns:** new tab control

### createTab

Create tab for TabControl.

```nim
proc createTab*(title: string, content: Widget): Tab
```

**Parameters:**
- `title` - tab title
- `content` - tab content (widget)

**Returns:** new tab

### addTab

Add tab to TabControl.

```nim
proc addTab*(tc: TabControl, tab: Tab)
```

**Parameters:**
- `tc` - tab control
- `tab` - tab to add

**Example:**
```nim
let tabs = createTabControl(theme, "tabs", 10, 600, 400, 300)

let tab1Content = createLabel(theme, "tab1lbl", "Tab 1 content", 10, 10, 380, 30)
let tab1 = createTab("Tab 1", tab1Content)
tabs.addTab(tab1)

let tab2Content = createButton(theme, "tab2btn", "Button on tab 2", 10, 10, 150, 30)
let tab2 = createTab("Tab 2", tab2Content)
tabs.addTab(tab2)

gui.addWidget(tabs)
```

---

## Menus and Toolbars

### MenuItem

Menu item.

```nim
type MenuItem* = ref object
  id*: string                     # identifier
  text*: string                   # item text
  enabled*: bool                  # enabled/disabled
  checked*: bool                  # checked (for checkable items)
  checkable*: bool                # can be checked
  isSeparator*: bool              # is separator
  icon*: SdlTexture               # icon
  shortcut*: string               # keyboard shortcut (text)
  submenu*: seq[MenuItem]         # submenu
  onClick*: proc(item: MenuItem)  # click handler
```

### Menu

Drop-down menu.

```nim
type Menu* = ref object of Widget
  items*: seq[MenuItem]           # menu items
  isOpen*: bool                   # menu open/closed
  hoveredIndex*: int              # hovered item index
  textColor*: SdlColor            # text color
  bgColor*: SdlColor              # background color
  hoverColor*: SdlColor           # hover color
  borderColor*: SdlColor          # border color
  itemHeight*: int                # item height
```

### createMenu

Create drop-down menu.

```nim
proc createMenu*(theme: GuiTheme, id: string, x, y: int): Menu
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `x, y` - coordinates

**Returns:** new menu

### createMenuItem

Create menu item.

```nim
proc createMenuItem*(id, text: string, onClick: proc(item: MenuItem) = nil): MenuItem
```

**Parameters:**
- `id` - item identifier
- `text` - item text
- `onClick` - click handler (optional)

**Returns:** new menu item

### createMenuSeparator

Create menu separator.

```nim
proc createMenuSeparator*(): MenuItem
```

**Returns:** menu separator

### addMenuItem

Add item to menu.

```nim
proc addMenuItem*(menu: Menu, item: MenuItem)
```

**Parameters:**
- `menu` - menu
- `item` - item to add

**Example:**
```nim
let menu = createMenu(theme, "contextMenu", 100, 100)
menu.addMenuItem(createMenuItem("open", "Open", proc(mi: MenuItem) = echo "Open"))
menu.addMenuItem(createMenuItem("save", "Save", proc(mi: MenuItem) = echo "Save"))
menu.addMenuItem(createMenuSeparator())
menu.addMenuItem(createMenuItem("exit", "Exit", proc(mi: MenuItem) = echo "Exit"))
gui.addWidget(menu)
```

### MenuBar

Menu bar (typically at top of window).

```nim
type MenuBar* = ref object of Widget
  menus*: seq[tuple[title: string, menu: Menu]]  # menus and their titles
  openMenu*: int                  # open menu index (-1 if closed)
  hoveredMenu*: int               # hovered menu index
  textColor*: SdlColor            # text color
  bgColor*: SdlColor              # background color
  hoverColor*: SdlColor           # hover color
  borderColor*: SdlColor          # border color
```

### createMenuBar

Create menu bar.

```nim
proc createMenuBar*(theme: GuiTheme, id: string, x, y, w, h: int): MenuBar
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `x, y` - coordinates
- `w, h` - width and height

**Returns:** new menu bar

### addMenu

Add menu to menu bar.

```nim
proc addMenu*(menuBar: MenuBar, title: string, menu: Menu)
```

**Parameters:**
- `menuBar` - menu bar
- `title` - menu title
- `menu` - menu to add

**Example:**
```nim
let menubar = createMenuBar(theme, "menubar", 0, 0, 800, 30)

# File menu
let fileMenu = createMenu(theme, "fileMenu", 0, 30)
fileMenu.addMenuItem(createMenuItem("new", "New", proc(mi: MenuItem) = echo "New file"))
fileMenu.addMenuItem(createMenuItem("open", "Open...", proc(mi: MenuItem) = echo "Open"))
fileMenu.addMenuItem(createMenuSeparator())
fileMenu.addMenuItem(createMenuItem("exit", "Exit", proc(mi: MenuItem) = echo "Exit"))
menubar.addMenu("File", fileMenu)

# Edit menu
let editMenu = createMenu(theme, "editMenu", 0, 30)
editMenu.addMenuItem(createMenuItem("undo", "Undo", proc(mi: MenuItem) = echo "Undo"))
editMenu.addMenuItem(createMenuItem("redo", "Redo", proc(mi: MenuItem) = echo "Redo"))
menubar.addMenu("Edit", editMenu)

gui.addWidget(menubar)
```

### ToolBar

Toolbar with buttons.

```nim
type ToolBar* = ref object of Widget
  buttons*: seq[Button]           # toolbar buttons
  bgColor*: SdlColor              # background color
  borderColor*: SdlColor          # border color
  buttonSpacing*: int             # button spacing
```

### createToolBar

Create toolbar.

```nim
proc createToolBar*(theme: GuiTheme, id: string, x, y, w, h: int): ToolBar
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `x, y` - coordinates
- `w, h` - width and height

**Returns:** new toolbar

### addToolButton

Add button to toolbar.

```nim
proc addToolButton*(toolbar: ToolBar, button: Button)
```

**Parameters:**
- `toolbar` - toolbar
- `button` - button to add

**Example:**
```nim
let toolbar = createToolBar(theme, "toolbar", 0, 30, 800, 40)

let btnNew = createButton(theme, "toolNew", "New", 0, 0, 60, 30)
btnNew.onClick = proc(b: Button) = echo "Create new"
toolbar.addToolButton(btnNew)

let btnOpen = createButton(theme, "toolOpen", "Open", 0, 0, 70, 30)
btnOpen.onClick = proc(b: Button) = echo "Open file"
toolbar.addToolButton(btnOpen)

gui.addWidget(toolbar)
```

### StatusBar

Status bar (typically at bottom of window).

```nim
type StatusBar* = ref object of Widget
  text*: string                   # status bar text
  sections*: seq[string]          # status bar sections
  textColor*: SdlColor            # text color
  bgColor*: SdlColor              # background color
  borderColor*: SdlColor          # border color
```

### createStatusBar

Create status bar.

```nim
proc createStatusBar*(theme: GuiTheme, id: string, x, y, w, h: int): StatusBar
```

**Parameters:**
- `theme` - GUI theme
- `id` - unique identifier
- `x, y` - coordinates
- `w, h` - width and height

**Returns:** new status bar

### setText (StatusBar)

Set text for status bar.

```nim
proc setText*(statusbar: StatusBar, text: string)
```

**Parameters:**
- `statusbar` - status bar
- `text` - text to set

### setSections

Set sections for status bar.

```nim
proc setSections*(statusbar: StatusBar, sections: seq[string])
```

**Parameters:**
- `statusbar` - status bar
- `sections` - list of sections

**Example:**
```nim
let statusbar = createStatusBar(theme, "status", 0, 570, 800, 30)
statusbar.setText("Ready")
# or with sections:
statusbar.setSections(@["Ready", "Line: 1", "Column: 1"])
gui.addWidget(statusbar)
```

---

## Dialogs

### Dialog

Modal dialog window.

```nim
type Dialog* = ref object of Widget
  title*: string                  # dialog title
  message*: string                # message text
  dialogType*: DialogType         # dialog type
  buttons*: seq[DialogButton]     # dialog buttons
  titleColor*: SdlColor           # title color
  messageColor*: SdlColor         # message color
  bgColor*: SdlColor              # background color
  borderColor*: SdlColor          # border color
  iconTexture*: SdlTexture        # dialog icon
  onClose*: proc(dlg: Dialog, result: DialogButton)  # close handler
```

### createDialog

Create dialog window.

```nim
proc createDialog*(title, message: string, dialogType: DialogType,
                  buttons: seq[DialogButton]): Dialog
```

**Parameters:**
- `title` - dialog title
- `message` - message text
- `dialogType` - dialog type (dtInfo, dtWarning, dtError, dtQuestion)
- `buttons` - dialog buttons (dbOk, dbCancel, dbYes, dbNo)

**Returns:** new dialog

**Example:**
```nim
let dialog = createDialog("Confirmation", "Are you sure?", dtQuestion, @[dbYes, dbNo])
dialog.onClose = proc(dlg: Dialog, result: DialogButton) =
  if result == dbYes:
    echo "User confirmed"
  else:
    echo "User cancelled"
gui.modalDialog = dialog
```

### Convenience Functions for Creating Dialogs

#### showInfoDialog

Show information dialog.

```nim
proc showInfoDialog*(gui: GuiManager, title, message: string, 
                    onClose: proc(dlg: Dialog, result: DialogButton) = nil)
```

**Example:**
```nim
gui.showInfoDialog("Information", "Operation completed successfully")
```

#### showWarningDialog

Show warning dialog.

```nim
proc showWarningDialog*(gui: GuiManager, title, message: string,
                       onClose: proc(dlg: Dialog, result: DialogButton) = nil)
```

**Example:**
```nim
gui.showWarningDialog("Warning", "This action cannot be undone")
```

#### showErrorDialog

Show error dialog.

```nim
proc showErrorDialog*(gui: GuiManager, title, message: string,
                     onClose: proc(dlg: Dialog, result: DialogButton) = nil)
```

**Example:**
```nim
gui.showErrorDialog("Error", "Failed to open file")
```

#### showQuestionDialog

Show question dialog (Yes/No buttons).

```nim
proc showQuestionDialog*(gui: GuiManager, title, message: string,
                        onClose: proc(dlg: Dialog, result: DialogButton))
```

**Example:**
```nim
gui.showQuestionDialog("Question", "Save changes?", 
  proc(dlg: Dialog, result: DialogButton) =
    if result == dbYes:
      echo "Saving"
)
```

#### showConfirmDialog

Show confirmation dialog (OK/Cancel buttons).

```nim
proc showConfirmDialog*(gui: GuiManager, title, message: string,
                       onClose: proc(dlg: Dialog, result: DialogButton))
```

**Example:**
```nim
gui.showConfirmDialog("Confirmation", "Delete file?", 
  proc(dlg: Dialog, result: DialogButton) =
    if result == dbOk:
      echo "Deleting file"
)
```

---

## Utility Functions

### ToolTip

Tooltip system.

```nim
type ToolTip* = object
  text*: string                   # tooltip text
  x*, y*: int                     # position
  visible*: bool                  # visibility
```

### updateTooltip

Update tooltip state.

```nim
proc updateTooltip*(gui: GuiManager)
```

**Parameters:**
- `gui` - GUI manager

**Note:** Called automatically in `renderGui`

### checkTooltipHover

Check hover for tooltip.

```nim
proc checkTooltipHover*(gui: GuiManager, widget: Widget, mx, my: int)
```

**Parameters:**
- `gui` - GUI manager
- `widget` - widget to check
- `mx, my` - mouse cursor coordinates

### Utility Functions for Creating Colors and Rectangles

#### initColor

Create SDL color.

```nim
proc initColor*(r, g, b, a: uint8): SdlColor
```

**Parameters:**
- `r, g, b` - red, green, blue components (0-255)
- `a` - alpha/transparency (0-255)

**Returns:** SDL color

**Example:**
```nim
let red = initColor(255, 0, 0, 255)
let semiTransparentBlue = initColor(0, 0, 255, 128)
```

#### initRect

Create SDL rectangle (integer).

```nim
proc initRect*(x, y, w, h: int): SdlRect
```

**Parameters:**
- `x, y` - coordinates
- `w, h` - width and height

**Returns:** SDL rectangle

**Example:**
```nim
let rect = initRect(10, 20, 100, 50)
```

#### initFRect

Create SDL rectangle with floating point.

```nim
proc initFRect*(x, y, w, h: float): SdlFRect
```

**Parameters:**
- `x, y` - coordinates
- `w, h` - width and height

**Returns:** SDL floating point rectangle

**Example:**
```nim
let frect = initFRect(10.5, 20.5, 100.5, 50.5)
```

---

## Complete Usage Example

```nim
import sdlGuiLib
import libSDL

# Initialize SDL
if not SDL_Init(SDL_INIT_VIDEO):
  quit "Failed to initialize SDL"

# Create window and renderer
let window = SDL_CreateWindow("GUI Demo", 800, 600, SDL_WINDOW_RESIZABLE)
let renderer = SDL_CreateRenderer(window, nil)

# Initialize SDL_ttf
if not TTF_Init():
  quit "Failed to initialize SDL_ttf"

# Load font
let font = TTF_OpenFont("font.ttf", 16)
if font.isNil:
  quit "Failed to load font"

# Create theme and GUI manager
let theme = createDefaultTheme(font, 16.0)
let gui = createGuiManager(renderer, theme)

# Create widgets
let button = createButton(theme, "btn1", "Click me", 10, 10, 120, 40)
button.onClick = proc(btn: Button) =
  echo "Button clicked!"
gui.addWidget(button)

let textField = createTextField(theme, "input", 10, 60, 200, 30, "", "Enter text")
gui.addWidget(textField)

let checkbox = createCheckBox(theme, "cb1", "Enable option", 10, 100)
gui.addWidget(checkbox)

# Main loop
var running = true
var event: SdlEvent

while running:
  while SDL_PollEvent(addr event):
    if event.type == SDL_EVENT_QUIT:
      running = false
    
    # Handle GUI events
    if gui.handleGuiEvent(addr event):
      continue  # Event handled by GUI
  
  # Update and render
  gui.updateCursorBlink()
  
  discard SDL_SetRenderDrawColor(renderer, 50, 50, 50, 255)
  discard SDL_RenderClear(renderer)
  
  gui.renderGui()
  
  discard SDL_RenderPresent(renderer)
  SDL_Delay(16)  # ~60 FPS

# Cleanup
TTF_CloseFont(font)
TTF_Quit()
SDL_DestroyRenderer(renderer)
SDL_DestroyWindow(window)
SDL_Quit()
```

---

## Notes

### Event Handling

Event handling order is important:

1. Modal dialogs are handled first
2. Open MenuBar, ComboBox and Menu are handled with priority
3. Other widgets are handled in reverse order (top to bottom)

### Input Focus

Input focus is automatically managed for text fields. Use `gui.setFocus(widget)` to set focus programmatically.

### Parent and Child Widgets

Child widgets are automatically rendered with their parents. When adding a child widget:

```nim
childWidget.parent = parentWidget
parentWidget.children.add(childWidget)
```

### Performance

- Widgets with `visible = false` are not rendered and don't handle events
- Widgets with `enabled = false` are rendered but don't handle events
- Use `Panel` with `scrollable = true` for large lists of child widgets

---

## License

See the library source file for license information.
