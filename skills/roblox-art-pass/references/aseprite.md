# Aseprite (pixel art)

Use when the game or a part of it is pixel-styled: decals, pixel UI, 2D sprites on
`ImageLabel`s or `Decal`s, a retro billboard.

- Draw with the aseprite MCP into `assets/src/<name>.aseprite`, one layer per part, only the
  Style Guide's palette colors.
- Preview: export a frame at 4–8× into a scratch folder and look at it (Read the PNG) before
  showing anyone.
- Export the final PNG at native size (or an exact integer multiple). In Roblox set
  `ImageLabel.ResampleMode = Enum.ResamplerMode.Pixelated` so it stays crisp instead of blurry.
- Animations: export a spritesheet (frames in a grid) and step `ImageRectOffset` /
  `ImageRectSize` from code. Keep sheets ≤ 1024 px on a side (Roblox downscales larger images).
- Check every MCP result message: some failures come back as "success" text.
