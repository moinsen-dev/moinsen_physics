# Gravity Lab - Screen Design Specifications
## Visual Mockups and Detailed UI/UX Guide

**Version:** 1.0  
**Date:** May 2024  
**Purpose:** Detailed screen-by-screen design guide for implementation  

---

## 1. Splash Screen Design

### Visual Layout
```
┌─────────────────────────────────────┐
│                                     │
│         [Moinsen Dev Logo]          │
│            (fade in)                │
│                                     │
│     ╭─────────────────────╮        │
│     │    GRAVITY LAB      │        │
│     │    ⚛️ 🧪 🌌          │        │
│     ╰─────────────────────╯        │
│                                     │
│     [═══════════════>    ]         │
│         Loading Physics...          │
│                                     │
│     💡 Tip: Gravity can be          │
│        your best friend!            │
│                                     │
│         v0.3.0                      │
└─────────────────────────────────────┘
```

### Animation Sequence
1. **0-0.5s**: Moinsen Dev logo fades in
2. **0.5-1s**: Gravity Lab title appears with particle burst
3. **1-2s**: Loading bar fills with liquid physics animation
4. **2s**: Particle transition to main menu

### Visual Effects
- Floating particles in background (10-20 particles)
- Subtle gravity distortion effect on logo
- Liquid fill animation for loading bar
- Rotating tips every 3 seconds
- Glow effect on emojis

---

## 2. Main Menu Screen

### Layout Design
```
┌─────────────────────────────────────┐
│ [👤]                          [⚙️]  │
├─────────────────────────────────────┤
│                                     │
│        ⚛️ GRAVITY LAB ⚛️           │
│     [Animated Logo Scene]          │
│                                     │
│   ╭─────────────────────────╮      │
│   │      🎮 PLAY           │      │
│   ╰─────────────────────────╯      │
│                                     │
│   ╭─────────────────────────╮      │
│   │      🏆 CHALLENGES     │      │
│   ╰─────────────────────────╯      │
│                                     │
│   ╭─────────────────────────╮      │
│   │      🔧 CREATE         │      │
│   ╰─────────────────────────╯      │
│                                     │
│   ╭─────────────────────────╮      │
│   │      📊 LEADERBOARD    │      │
│   ╰─────────────────────────╯      │
│                                     │
├─────────────────────────────────────┤
│ [🎁 Daily]  [📰 News]  [👥 Friends]│
└─────────────────────────────────────┘
```

### Interactive Elements
- **Logo Scene**: Mini physics simulation with 5-7 objects
- **Button States**:
  - Idle: Soft glow, subtle float animation
  - Hover/Touch: Scale to 105%, bright glow
  - Press: Scale to 95%, particle burst
- **Background**: Animated star field with parallax
- **Physics Objects**: Float and collide in background

### Color Scheme
```dart
class MenuColors {
  static const background = Color(0xFF0A0E27);
  static const buttonPrimary = Color(0xFF00A8FF);
  static const buttonSecondary = Color(0xFF8B5CF6);
  static const accent = Color(0xFFFFD93D);
  static const text = Color(0xFFFFFFFF);
}
```

---

## 3. World Selection Screen

### Visual Concept
```
┌─────────────────────────────────────┐
│ [← Back]     CHOOSE WORLD    [👤]   │
├─────────────────────────────────────┤
│                                     │
│  ←  [Previous World]  [Next] →     │
│                                     │
│      ╭─────────────────╮           │
│      │                 │           │
│      │   🧪 NEWTON'S   │           │
│      │   LABORATORY    │           │
│      │                 │           │
│      │   ⭐⭐⭐ 18/20  │           │
│      ╰─────────────────╯           │
│                                     │
│  [🔒] [🔒] [🔒] [🔒] [🔒] [🔒]     │
│   1    2    3    4    5    6       │
│                                     │
│  ╭─────────────────────────────╮   │
│  │ Tutorial World               │   │
│  │ Learn the basics of gravity  │   │
│  │ manipulation and physics     │   │
│  │                              │   │
│  │ 🏆 Best Time: 12:34         │   │
│  │ 🌟 Total Stars: 54/60       │   │
│  ╰─────────────────────────────╯   │
│                                     │
│      [  ENTER WORLD  ]              │
└─────────────────────────────────────┘
```

### World Carousel
1. **Newton's Laboratory** 🧪 - Classic physics
2. **Zero-G Station** 🚀 - Space puzzles  
3. **Aqua Depths** 🌊 - Underwater physics
4. **Magnetic Factory** 🧲 - Electromagnetic
5. **Time Nexus** ⏰ - Time manipulation
6. **Quantum Realm** ⚛️ - Probability physics

### Visual Features
- 3D rotating planet/environment preview
- Particle effects matching world theme
- Progress satellites orbiting the world
- Unlock animation with particle explosion
- Background changes with selected world

---

## 4. Level Selection Grid

### Layout Pattern
```
┌─────────────────────────────────────┐
│ [← Back]  NEWTON'S LABORATORY  [?]  │
├─────────────────────────────────────┤
│                                     │
│    1⭐⭐⭐   2⭐⭐⭐   3⭐⭐☆      │
│      ⬢        ⬢        ⬢          │
│                                     │
│    4⭐☆☆   5⭐⭐⭐   6⭐⭐⭐      │
│      ⬢   ━━━  ⬢  ━━━  ⬢          │
│                |                    │
│    7⭐⭐☆   8⚡     9🔒          │
│      ⬢   ━━━  ⬢       ⬢          │
│                                     │
│   10🔒     11🔒     12🔒         │
│      ⬢        ⬢        ⬢          │
│                                     │
│ ╭─────────────────────────────────╮ │
│ │ Level 8 - Gravity Wells         │ │
│ │ ┌─────────┐ Difficulty: ⚛️⚛️⚛️  │ │
│ │ │ Preview │ Par Time: 45s       │ │
│ │ │   ...   │ Best: 32s           │ │
│ │ └─────────┘ Rank: #142          │ │
│ ╰─────────────────────────────────╯ │
└─────────────────────────────────────┘
```

### Level States
- **Completed**: Bright with stars (⭐)
- **Current**: Pulsing glow (⚡)
- **Locked**: Darkened (🔒)
- **Special**: Rainbow border (bonus levels)

### Preview Window Features
- Minimap of level layout
- Animated preview of solution hint
- Difficulty atoms (1-5)
- Speed run times
- Friend scores comparison

---

## 5. Gameplay Screen Layout

### Interface Zones
```
┌─────────────────────────────────────┐
│ [⏸️] 00:23 | Moves: 5 | [💡] [🔄] │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │     🟢 ← (Start Object)        │ │
│ │      |                         │ │
│ │      ↓                         │ │
│ │   ═══╪═══════                  │ │
│ │      |                         │ │
│ │      ↓                         │ │
│ │   ▓▓▓▓▓▓▓                      │ │
│ │      ↓                         │ │
│ │      ⭐ ← (Goal)               │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│  [↑]  [↗]  [→]  [↘]  [↓]  [↙]  [←]│
│         GRAVITY CONTROLS            │
├─────────────────────────────────────┤
│ [🧲] [🌊] [⚡] [❄️] [🕳️]         │
│      SPECIAL TOOLS                  │
└─────────────────────────────────────┘
```

### Touch Gestures
- **Tap**: Select/activate object
- **Drag**: Move objects or draw paths
- **Pinch**: Zoom in/out
- **Two-finger rotate**: Rotate gravity
- **Long press**: Object properties
- **Swipe**: Quick gravity change

### Visual Feedback
- Gravity field lines (subtle)
- Object trajectory preview
- Force indicators
- Collision predictions
- Success path highlighting

---

## 6. Victory Screen

### Celebration Sequence
```
┌─────────────────────────────────────┐
│                                     │
│         LEVEL COMPLETE!             │
│                                     │
│         ⭐ ⭐ ⭐                    │
│                                     │
│   ╭─────────────────────────────╮  │
│   │ Time:      00:32  ⚡BEST!   │  │
│   │ Moves:     5/7              │  │
│   │ Score:     1,250            │  │
│   │ Rank:      #42 ↑23         │  │
│   ╰─────────────────────────────╯  │
│                                     │
│   🏆 NEW ACHIEVEMENT UNLOCKED!      │
│   "Speed Demon" - Under par time    │
│                                     │
│   +100 XP    +50 ⚛️ Atoms          │
│                                     │
│ [📤 SHARE] [🔄 REPLAY] [➡️ NEXT]   │
└─────────────────────────────────────┘
```

### Animation Timeline
1. **0-0.5s**: Objects celebrate with physics
2. **0.5-1s**: Stars appear one by one
3. **1-1.5s**: Score counter animates
4. **1.5-2s**: Achievements slide in
5. **2s+**: Buttons appear with bounce

---

## 7. Level Editor Interface

### Tool Palette
```
┌─────────────────────────────────────┐
│ [← Back] LEVEL EDITOR [Test ▶️] [💾]│
├─────────────────────────────────────┤
│ ┌───┬───────────────────────┬────┐ │
│ │ O │                       │Properties│
│ │ B │                       │┌────────┐│
│ │ J │    CANVAS AREA        ││Object: ││
│ │ E │    (Grid Visible)     ││ Ball   ││
│ │ C │                       ││        ││
│ │ T │                       ││Mass: 5 ││
│ │ S │                       ││Size: M ││
│ │   │                       │└────────┘│
│ └───┴───────────────────────┴────┘ │
│ ┌─────────────────────────────────┐ │
│ │ [⏮️][⏸️][▶️][⏭️] Timeline    │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Object Palette
- 🟢 Basic Ball
- 🟦 Heavy Cube  
- 🎈 Balloon
- 🟣 Sticky Blob
- 👻 Ghost Orb
- ⚡ Energy Sphere
- 🧊 Ice Cube
- 🧲 Magnetic Ball

### Editor Features
- Snap-to-grid (toggleable)
- Copy/paste objects
- Undo/redo (Ctrl+Z/Y)
- Test mode instant preview
- AI balance checker
- Solution validator

---

## 8. Settings Screen Design

### Layout Structure
```
┌─────────────────────────────────────┐
│ [← Back]      SETTINGS              │
├─────────────────────────────────────┤
│                                     │
│ 🔊 AUDIO                           │
│ ├─ Music          [━━━━━●━━] 70%   │
│ ├─ Sound Effects  [━━━━━━━●] 100%  │
│ └─ Haptics        [ON ✓]           │
│                                     │
│ 🎮 GAMEPLAY                        │
│ ├─ Show Hints     [ON ✓]           │
│ ├─ Grid Overlay   [OFF ]           │
│ ├─ Trajectories   [ON ✓]           │
│ └─ Particle Density [Medium ▼]     │
│                                     │
│ 📱 DISPLAY                         │
│ ├─ Quality        [High ▼]         │
│ ├─ FPS Limit      [60 FPS ▼]      │
│ └─ Screen Shake   [ON ✓]           │
│                                     │
│ 🌍 LANGUAGE      [English ▼]       │
│                                     │
│ [📖 CREDITS] [❓ HELP] [🔄 RESET]  │
└─────────────────────────────────────┘
```

---

## Implementation Priority Guide

### Phase 1: Core Screens (Week 1-2)
1. ✅ Splash Screen (simple version)
2. ✅ Main Menu
3. ✅ Basic Gameplay Screen
4. ✅ Settings (minimal)

### Phase 2: Game Flow (Week 3-4)  
1. ⏳ World Selection
2. ⏳ Level Selection
3. ⏳ Victory Screen
4. ⏳ Tutorial Overlays

### Phase 3: Advanced (Week 5-6)
1. ⏳ Level Editor
2. ⏳ Leaderboards
3. ⏳ Profile/Stats
4. ⏳ Social Features

---

## Design Tokens

### Typography
```dart
class AppTypography {
  static const headerLarge = TextStyle(
    fontFamily: 'Orbitron',
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static const headerMedium = TextStyle(
    fontFamily: 'Orbitron', 
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  
  static const body = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
}
```

### Spacing
- Small: 8px
- Medium: 16px  
- Large: 24px
- XLarge: 32px

### Border Radius
- Small: 8px
- Medium: 16px
- Large: 24px
- Full: 999px