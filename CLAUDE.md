# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

3D20 is an iOS dice-rolling app for tabletop games. It renders physics-based 3D dice using RealityKit with two modes: a virtual 3D camera view and an AR view that anchors dice to a real-world horizontal plane.

## Building and running

Open `3D20.xcodeproj` in Xcode and run on a physical device (RealityKit AR requires a device with ARKit support; the Simulator can run the virtual 3D view only).

```bash
# Build from CLI
xcodebuild -project 3D20.xcodeproj -scheme 3D20 -destination 'platform=iOS Simulator,name=iPhone 16'

# Run tests
xcodebuild test -project 3D20.xcodeproj -scheme 3D20Tests -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Architecture

### Data flow

`DiceData` (`DataModels/DiceDataModel.swift`) is the single `@Observable` class injected at the root as `.environment(DiceData())`. All views read it via `@Environment(DiceData.self)`. Mutations are done through boolean flags (`hasRolled`, `changeDieSkin`, `changeDie`, etc.) that the `RealityView` update closure reads and acts on.

### View hierarchy

```
ThereD20 (App)
└── ContentView
    ├── _3Dexp         — virtual camera mode (content.camera = .virtual)
    └── ARexp          — AR mode (AnchorEntity on horizontal plane)
        Both embed:
        └── HUDControls — glass-effect overlay with roll button, nav links
            ├── Sheet: diceOptions   — pick die type (D04–D20)
            └── Sheet: Skins         — pick die or tray skin
```

Navigation destinations from the HUD:
- `Store` — placeholder ("Coming soon")
- `DiceBag` — tabbed collection browser
  - `DiceView` → `DetailView` — solo/group 3D preview of a die skin
  - `TrayView` → `TrayDetailView` — 3D preview of a tray skin

### RealityKit entity hierarchy

Both `_3Dexp` and `ARexp` maintain the same entity tree:

```
dice_anchor (Entity / AnchorEntity)
├── die             — the active die (ModelEntity, physics-enabled)
└── Root            — TrayAndCover entity
    └── [child]
        ├── tray    — bottom of the dice tray (static physics body)
        └── cover   — transparent collision boundary above the tray
```

Entity names are string-matched (`$0.name == "die"`, etc.) — keep them consistent if restructuring.

### 3D assets — DiceEnv package

All USDZ/USDA assets and ShaderGraph materials live in the `DiceEnv` Swift package (`https://github.com/mburger89/DiceEnv.git`, `main` branch). Assets are loaded at runtime:

```swift
// Die mesh
Entity(named: "\(dice_type)", in: DiceEnv.diceEnvBundle)   // e.g. "D20"

// Die skin material
ShaderGraphMaterial(named: "/Root/<skinName>/<skinName>_<diceType>", from: "Scene.usda", in: DiceEnv.diceEnvBundle)
// e.g. "/Root/SteelDarkAged/SteelDarkAged_D20"

// Tray skin material
ShaderGraphMaterial(named: "/Root/TraySkins/<traySkin>_tray", from: "Scene.usda", in: DiceEnv.diceEnvBundle)

// Tray mesh
Entity(named: "TrayAndCover", in: DiceEnv.diceEnvBundle)

// Full dice collection (used in DetailView group mode)
Entity(named: "diceCollection", in: DiceEnv.diceEnvBundle)
```

### Skin data

`Data/SkinData.json` is the source of truth for available skins. It is decoded into `SDData` (struct with `dice: [SD]` and `trays: [SD]`) by `DiceData.parsedSDData()` at init. `SD.name` must exactly match the material/asset name in `DiceEnv`. When adding a new skin, update `SkinData.json` and add a corresponding image asset for the UI thumbnail.

Die skin images in `Assets.xcassets` are named by `skin.name` (e.g. `SteelDarkAged`). Tray thumbnail images are prefixed with `tray_` (e.g. `tray_woodAcajou`).

### SpinComponent

`diceBag/Util/Rotation.swift` defines a custom RealityKit ECS `SpinComponent` + `SpinSystem` that continuously rotates entities in detail views. It self-registers its system on init.

## Key conventions

- The app targets iOS 26 and uses `glassEffect()`, which is only available on iOS 26+.
- State management uses the Swift `@Observable` macro — not `@StateObject`/`@ObservedObject`.
- Die types available in the main roll view: `D04`, `D06`, `D08`, `D10`, `D12`, `D20`. Detail view additionally includes `D100`.
- `DiceData` methods that touch `RealityViewCameraContent` are marked `@MainActor` and use `Task { }` internally for async asset loading.
