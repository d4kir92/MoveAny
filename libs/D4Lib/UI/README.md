# D4Lib UI

Small, reusable settings UI for D4Lib addons. Every label goes through `D4:TryTrans`,
so any string starting with `LID_` is translated and any other string is used as-is.

## Files

| File | Contains |
| --- | --- |
| `D4UICore.lua` | element list, layout, search filtering, shared helpers |
| `D4UITranslations.lua` | translations the UI itself needs (`LID_SEARCH`) |
| `D4UIWindow.lua` | `D4:CreateUIWindow` |
| `D4UISearch.lua` | `win:AddSearch` |
| `D4UICategory.lua` | `win:AddCategory` |
| `D4UICheckbox.lua` | `win:AddCheckbox` |
| `D4UISlider.lua` | `win:AddSlider` |
| `D4UIDropdown.lua` | `win:AddDropdown` |
| `D4UIEditbox.lua` | `win:AddEditbox` |
| `D4UIColorPicker.lua` | `win:AddColorPicker` |

## Usage

```lua
local win = D4:CreateUIWindow({
    name = "MyAddonWindow",
    title = "LID_MYADDON",
    width = 420,
    height = 520,
})

win:AddCheckbox({
    label = "LID_ALWAYSVISIBLE",
    value = MyAddonDB.alwaysVisible,
    func = function(value) MyAddonDB.alwaysVisible = value end,
})

win:AddSearch()

win:AddSlider({
    label = "LID_SCALE",
    value = MyAddonDB.scale,
    min = 0.5,
    max = 2,
    step = 0.05,
    decimals = 2,
    func = function(value) MyAddonDB.scale = value end,
})

win:AddDropdown({
    label = "LID_FLAGPOSITION",
    value = MyAddonDB.flagPoint,
    choices = {
        {value = "TOPLEFT", label = "LID_TOPLEFT"},
        {value = "TOPRIGHT", label = "LID_TOPRIGHT"},
        {value = "BOTTOMLEFT", label = "LID_BOTTOMLEFT"},
        {value = "BOTTOMRIGHT", label = "LID_BOTTOMRIGHT"},
    },
    func = function(value) MyAddonDB.flagPoint = value end,
})

win:AddEditbox({
    label = "LID_BLOCKWORDS",
    value = MyAddonDB.blockWords,
    func = function(value) MyAddonDB.blockWords = value end,
})

win:AddColorPicker({
    label = "LID_BORDERCOLOR",
    value = {r = 0, g = 0, b = 0, a = 0.4},
    func = function(r, g, b, a) MyAddon:SetBorderColor(r, g, b, a) end,
})

win:Show()
```

## Categories

`win:AddCategory({label = "LID_..."})` starts a collapsible group. Every element
added afterwards belongs to it, is indented, and is hidden while the category is
collapsed. Clicking the header toggles it. Pass `collapsed = true` to start closed.

Pass `level = n` to nest: `level = 1` is top-level, `level = n` attaches to the most
recent category at `level = n - 1`, and its own elements are indented one step further.
Collapsing a category hides everything under it, however deep. Nesting is not capped —
but every step costs `UI.INDENT` of usable width, so three or four levels is the
practical limit.

`sub = true` is the shorthand for `level = 2`.

```lua
win:AddCategory({label = "LID_FLAG"})
win:AddCategory({label = "LID_GROUP", level = 2})
win:AddCheckbox({label = "LID_SHOWFLAG", ...})
win:AddCategory({label = "LID_RAID", level = 3})
win:AddCheckbox({label = "LID_SHOWFLAG", ...})
win:AddCategory({label = "LID_ITEMLEVEL"})
```

A `level` that skips a step falls back to the nearest existing shallower category.

### Remembering the collapsed state

The module keeps the open/closed state in memory only. To persist it, give the
window a pair of callbacks and every category a stable `key`:

```lua
local win = D4:CreateUIWindow({
    ["getCollapsed"] = function(key) return MyAddon:GetCollapsed(key) end,
    ["setCollapsed"] = function(key, collapsed) MyAddon:SetCollapsed(key, collapsed) end,
})
```

`getCollapsed` is asked once while the category is being created; anything other
than `nil` overrides `collapsed`, so a stored value wins over the default while an
unknown key keeps it. `setCollapsed` is called on every click with the new state.

`key` falls back to `search`, and to the translated label if there is no `search`
either — pass it explicitly so the stored state survives a language change.

## Search

`win:AddSearch()` puts a search box into the header, creating the header if there is
none yet. It is not parented to the scroll content, so it stays put while everything
below it scrolls, and it sits outside the inset.

It filters every element that is added **after** it. Elements added before the
search box are never filtered, which is the place for things that must always stay
visible. Matching is case-insensitive against the translated label and against the
element's `search` string, so an internal key stays findable in every locale.

Options: `label` (defaults to `LID_SEARCH`), `maxLetters`, `leftInset`, `rightInset`.
The insets reserve room at either end of the header for buttons of your own.

Search and categories combine: a category is shown when its own label matches or
any of its children match, a category whose own label matches pulls in all of its
children, and while a search is active collapsed categories are shown anyway so a
hit is never hidden behind a closed group.

## Elements

All `Add*` calls take one options table and return the created frame. Search box,
category header, slider and dropdown stretch to the window width; the checkbox
does not, because it is a fixed box with a label next to it.

Every `Add*` also takes `search`: an extra string the search box matches against,
on top of the translated label.

- `AddCheckbox`: `label`, `value`, `func(value, cb)`, `textFunc(cb)`, `onClick(button, cb)`.
  `textFunc` replaces `label` and is re-evaluated by `cb:UpdateLabel()`, which also
  refreshes what the search matches — use it for labels that change at runtime.
  `onClick` adds an invisible click surface spanning the rest of the row next to the
  box; it receives the mouse button, so left and right click can do different things.
  `cb:SetEnabled(false)` greys out the box and that surface together.
- `AddSlider`: `label`, `value`, `min`, `max`, `step`, `decimals`, `func(value)`.
  If the translated label contains a format placeholder (`%s`, `%.2f`), the value is
  inserted there; otherwise it is appended as `label: value`.
  The starting value is set before the change handler is installed, so `func` does not
  fire while the window is being built — it is safe to call into frames that do not
  exist yet at that point. `holder.value` holds the value the slider actually took,
  after clamping to `min`/`max` and rounding to `decimals`.
- `AddDropdown`: `label`, `value`, `width`, `choices`, `maxVisible`, `func(value)`.
  `choices` is an ordered array of `{value = ..., label = "LID_..."}`;
  `UI:ChoicesFromMap(map, current)` builds one from a sparse `value → label` table,
  sorted, with `current` appended if the map does not contain it.
  The returned frame has `holder:SetValue(value)` to change the selection without
  firing `func`, and `holder.control` is the widget itself.

  Where the client has `SettingsDropdownWithButtonsTemplate` (retail), the dropdown is
  Blizzard's own control from the options panel: a menu button flanked by a left and a
  right stepper that walk `choices` in order and grey out at either end. `width` sizes
  the menu button; the steppers add 70px next to it.

  Everywhere else it falls back to a self-drawn list — the same values and the same
  `func`, just a plain list opened by one button. Lists longer than `maxVisible`
  (12 by default) scroll there instead of growing off-screen.
- `AddEditbox`: `label`, `value`, `func(value, box)`, `maxLetters`, `numeric`.
  The label sits above the box, the box stretches to the window width.
  `func` fires on every actual change of the text, not on every keystroke that leaves
  it unchanged — debounce it yourself if the change is expensive. `maxLetters` defaults
  to 0 (unlimited), `numeric = true` restricts input to digits.
  Escape restores the last value and drops focus, Enter just drops focus.
  The returned frame has `holder:SetValue(value)` to set the text without firing `func`,
  `holder.value` is the current text and `holder.control` is the edit box itself.
- `AddColorPicker`: `label`, `value`, `hasOpacity`, `func(r, g, b, a)`.
  A colour swatch button on the left, the label right next to it — the swatch is built
  like Blizzard's `ColorSwatchTemplate`: a white outer square, a black inner border and
  the colour itself in the middle, drawn with its alpha so a translucent colour reads
  darker than an opaque one.
  `value` is a table and accepts `r`/`g`/`b`/`a`, `R`/`G`/`B`/`A` or `[1]`..`[4]`;
  missing channels default to 1. Clicking opens `ColorPickerFrame` through
  `D4:ShowColorPicker`, and `func` fires on every change the picker reports, already
  corrected for the inverted opacity slider on non-retail clients.
  `hasOpacity = false` pins alpha to 1 and ignores whatever the picker returns for it.
  The returned frame has `holder:SetValue(r, g, b, a)` to change the colour without
  firing `func`, `holder.r` / `holder.g` / `holder.b` / `holder.a` are the current
  channels and `holder.control` is the swatch button itself.

## Window

`D4:CreateUIWindow` options: `name`, `title`, `width`, `height`, `parent`, `pTab`,
`templates`, `resizable`, `minWidth`, `minHeight`, `maxWidth`, `maxHeight`, `onResize`,
`onMove(point, relativePoint, x, y)`, `onClose(win)`, `getCollapsed(key)`,
`setCollapsed(key, collapsed)`. The window is movable, scrollable
and starts hidden. `win:Toggle()` shows or hides it.

Building a long list one `Add*` at a time re-lays out the whole window every time.
Wrap the build in `win:SuspendLayout()` / `win:ResumeLayout()` to do it once at the end.

## Resizing

The window is resizable by default (pass `resizable = false` to turn it off) via a
grip in the bottom-right corner, limited by `minWidth` / `minHeight` (300x200 by
default). While dragging, `contentWidth` is recalculated and `Layout` re-runs, so
every stretching widget follows along.

The module does not save the size itself. Pass `onResize = function(width, height)`
and write the values into your own SavedVariables, then feed them back in as
`width` / `height` the next time you create the window.

## Header and footer

`win:AddHeader({height = 24})` and `win:AddFooter({height = 24})` return an empty
frame pinned above resp. below the scroll area. Anchor whatever you like into them —
they are plain frames, the module only positions and sizes them.

Both shrink the scroll area and the inset accordingly, so the sunken panel always
frames only the scrollable part. Calling them again just changes the height.

`height` describes the content row, not the frame: the header is drawn a few pixels
taller than asked and lifted by half of that, so the extra room is split evenly above
and below and anything anchored `LEFT`/`RIGHT` (i.e. vertically centred) stays put
whatever that padding is.

The footer keeps 24px clear on the right so it never sits under the resize grip.

## Scrolling

If the client has `WowScrollBox`, `MinimalScrollBar`, `ScrollUtil` and
`CreateScrollBoxLinearView` (retail 10.0+), the window uses the modern scrollbar
Blizzard uses in its own options panel, and `win.scrollBox` / `win.scrollBar` are set.
Otherwise it falls back to `UIPanelScrollFrameTemplate` and sets `win.scroll`.

Either way the content is a single frame that all widgets are anchored into, so
`win:Layout()` only resizes that frame; `win:UpdateScroll()` afterwards tells the
scroll box to recalculate its range and is a no-op on the fallback path.
