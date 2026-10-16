# Figma (UI screens, buttons, icons)

Use the Figma MCP the project names in CLAUDE.md (some developers prefer one over another; some
plans cap calls per month, so batch your work into few calls). Ping/check the connection first.

## Screens

- **Design at the game's design resolution** (e.g. phone landscape 844×390 at 2× = 1688×780),
  because Roblox players are mostly on phones. Check a tablet and a desktop variant only if the
  layout changes.
- **Reuse the file's components, styles and variables** before drawing new ones. A new screen
  starts by instancing the existing button/panel components.
- Respect the Roblox safe area: the top bar (Roblox menu + chat buttons) and the bottom on
  phones. Keep tappable buttons ≥ 44 design px.
- Text in the Style Guide's fonts; Roblox has a fixed built-in font list, so use fonts that exist
  in Roblox (or note the substitution).

## Icons

- A dedicated **Icons** page, one component per icon (`Icon/<name>`), same canvas size (e.g. 128
  native), same stroke/outline rule from the Style Guide.
- Draw icons; don't use raw emoji in the final UI (they render differently per device and clash
  with a drawn style). Emoji are fine as labelled placeholders.
- A reliable pipeline: write the icon as SVG (in `assets/icons/svg/`), render PNGs with a small
  Python script (e.g. cairosvg), import into Figma for review, upload the PNGs to Roblox.

## Export

- PNG at the size Roblox will display (×2 for crispness on phones), transparent background.
  Images larger than 1024 px on a side get downscaled by Roblox.
- 9-slice panels: export the panel once and note the slice center for `ImageLabel.SliceCenter`.
- Save exports in `assets/ui/` with the asset-list id in the name.

## Approval (Figma-first)

The Figma frame **is** the approval: send the developer the frame name/link (and a screenshot PNG
in `docs/Art/Previews/`). They may edit it themselves; when they say it's done, re-read the frame
before building. After building, put the Studio capture next to the frame on the board: it should
match.
