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

win:Show()
```

## Categories

`win:AddCategory({label = "LID_..."})` starts a collapsible group. Every element
added afterwards belongs to it, is indented, and is hidden while the category is
collapsed. Clicking the header toggles it. Pass `collapsed = true` to start closed.

Pass `sub = true` for a sub-category: it attaches to the last top-level category
instead of starting a new one, and its own elements are indented one step further.
Collapsing the parent hides the sub-category and everything under it.

```lua
win:AddCategory({label = "LID_FLAG"})
win:AddCategory({label = "LID_GROUP", sub = true})
win:AddCheckbox({label = "LID_SHOWFLAG", ...})
win:AddCategory({label = "LID_RAID", sub = true})
win:AddCheckbox({label = "LID_SHOWFLAG", ...})
win:AddCategory({label = "LID_ITEMLEVEL"})
```

Nesting is one level deep by design; a `sub` category always hangs off the most
recent top-level one, never off another sub-category.

## Search

`win:AddSearch()` puts a search box into the header, creating the header if there is
none yet. It is not parented to the scroll content, so it stays put while everything
below it scrolls, and it sits outside the inset.

It filters every element that is added **after** it. Elements added before the
search box are never filtered, which is the place for things that must always stay
visible. Matching is case-insensitive against the translated label.

Options: `label` (defaults to `LID_SEARCH`), `maxLetters`.

Search and categories combine: a category is shown when its own label matches or
any of its children match, a category whose own label matches pulls in all of its
children, and while a search is active collapsed categories are shown anyway so a
hit is never hidden behind a closed group.

## Elements

All `Add*` calls take one options table and return the created frame. Search box,
category header, slider and dropdown stretch to the window width; the checkbox
does not, because it is a fixed box with a label next to it.

- `AddCheckbox`: `label`, `value`, `func(value)`
- `AddSlider`: `label`, `value`, `min`, `max`, `step`, `decimals`, `func(value)`.
  If the translated label contains a format placeholder (`%s`, `%.2f`), the value is
  inserted there; otherwise it is appended as `label: value`.
- `AddDropdown`: `label`, `value`, `width`, `choices`, `func(value)`.
  `choices` is an ordered array of `{value = ..., label = "LID_..."}`.
  The returned frame has `holder:SetValue(value)` to change the selection without
  firing `func`.

## Window

`D4:CreateUIWindow` options: `name`, `title`, `width`, `height`, `parent`, `pTab`,
`templates`, `resizable`, `minWidth`, `minHeight`, `onResize`. The window is movable,
scrollable and starts hidden. `win:Toggle()` shows or hides it.

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

The footer keeps 24px clear on the right so it never sits under the resize grip.

## Scrolling

If the client has `WowScrollBox`, `MinimalScrollBar`, `ScrollUtil` and
`CreateScrollBoxLinearView` (retail 10.0+), the window uses the modern scrollbar
Blizzard uses in its own options panel, and `win.scrollBox` / `win.scrollBar` are set.
Otherwise it falls back to `UIPanelScrollFrameTemplate` and sets `win.scroll`.

Either way the content is a single frame that all widgets are anchored into, so
`win:Layout()` only resizes that frame; `win:UpdateScroll()` afterwards tells the
scroll box to recalculate its range and is a no-op on the fallback path.
