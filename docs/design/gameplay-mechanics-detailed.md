# Gravity Lab - Enhanced Gameplay Mechanics
## Detailed Game Design Document

**Version:** 1.0  
**Date:** May 2024  
**Focus:** Core gameplay loop, physics interactions, and level design  

---

## 1. Core Gameplay Loop

### Basic Flow
```
Start Level → Analyze Puzzle → Plan Solution → Execute Actions → 
    ↓                                                    ↓
    ↓                                            Success? → Victory!
    ↓                                                    ↓
    └────────── Retry with Learning ←───────── Failure ←┘
```

### Player Actions Per Turn
1. **Observe** current state
2. **Adjust** gravity direction (optional)
3. **Activate** special tools (optional)
4. **Release** objects or triggers
5. **Watch** physics simulation
6. **Learn** from result

---

## 2. Gravity Manipulation System

### Gravity States
```
        ↑ (0°)
    ↖   ↑   ↗
     ╲  │  ╱
  ← ━━━ ⊕ ━━━ →  (90°/270°)
     ╱  │  ╲
    ↙   ↓   ↘
        ↓ (180°)
```

### Gravity Strength Levels
- **Zero-G** (0%): Objects float
- **Low** (25%): Moon gravity
- **Normal** (100%): Earth gravity
- **High** (150%): Heavy gravity
- **Extreme** (200%): Crushing force

### Advanced Gravity Features
1. **Gravity Wells**: Localized gravity points
2. **Gravity Waves**: Oscillating fields
3. **Gravity Shields**: Null zones
4. **Gravity Streams**: Directional flows

---

## 3. Physics Objects - Detailed Behaviors

### 🟢 Basic Ball
```dart
class BasicBall {
  mass: 1.0
  bounciness: 0.7
  friction: 0.3
  special: none
  
  behavior: "Standard physics object"
}
```

### 🟦 Heavy Cube
```dart
class HeavyCube {
  mass: 5.0
  bounciness: 0.1
  friction: 0.8
  special: "Breaks weak platforms"
  
  interaction: "Activates heavy switches"
}
```

### 🎈 Balloon
```dart
class Balloon {
  mass: -0.5 // Negative mass!
  bounciness: 0.9
  friction: 0.1
  special: "Always floats up"
  
  mechanic: "Pops on spikes"
}
```

### 🟣 Sticky Blob
```dart  
class StickyBlob {
  mass: 2.0
  bounciness: 0.0
  friction: 10.0
  special: "Sticks to surfaces"
  
  usage: "Create bridges, hold objects"
}
```

### 👻 Ghost Orb
```dart
class GhostOrb {
  mass: 0.5
  bounciness: 0.5
  friction: 0.0
  special: "Phases through specific materials"
  
  phases_through: ["wood", "glass"]
  blocked_by: ["metal", "energy"]
}
```

### ⚡ Energy Sphere
```dart
class EnergySphere {
  mass: 1.0
  bounciness: 1.0 // Perfect bounce!
  friction: 0.0
  special: "Powers mechanisms"
  
  charge: 100
  discharge_rate: 10/second
}
```

### 🧊 Ice Cube  
```dart
class IceCube {
  mass: 0.8
  bounciness: 0.3
  friction: 0.05 // Very slippery!
  special: "Melts over time"
  
  melt_time: 30_seconds
  leaves_water: true
}
```

### 🧲 Magnetic Ball
```dart
class MagneticBall {
  mass: 3.0
  bounciness: 0.4
  friction: 0.5
  special: "Magnetic properties"
  
  polarity: "north" | "south"
  field_strength: 5.0
  attraction_range: 100_pixels
}
```

---

## 4. Interactive Elements Details

### Platform Types

#### Static Platform
- Immovable obstacle
- Can have different materials
- May have special properties

#### Moving Platform
```
Path Types:
- Linear: A ←→ B
- Circular: Rotation
- Custom: Bezier curves
- Triggered: Player activated
```

#### Breakable Platform
```
Durability Levels:
- Weak: 1 hit (any object)
- Medium: 2 hits or heavy object
- Strong: Only heavy objects
- Timed: Breaks after X seconds
```

#### Spring Platform
```
Spring Properties:
- Force: 1x to 5x gravity
- Angle: Fixed or rotating
- Cooldown: Instant or delayed
- Visual: Compression animation
```

### Mechanism Types

#### Switches
```
Types:
- Toggle: On/Off state
- Hold: Must stay pressed
- Sequence: Specific order
- Timed: Limited activation
```

#### Portals
```
Properties:
- Instant teleport
- Maintains momentum
- Can rotate objects
- Paired or network
```

#### Force Fields
```
Types:
- Barrier: Blocks all
- Selective: Filters objects
- One-way: Directional
- Timed: Periodic on/off
```

---

## 5. Level Design Principles

### Difficulty Progression
```
World 1 (Tutorial): Single mechanic per level
World 2 (Easy): Combine 2 mechanics
World 3 (Medium): Timing elements added
World 4 (Hard): Multiple solutions required
World 5 (Expert): Precision and planning
World 6 (Master): All mechanics combined
```

### Level Structure Types

#### Teaching Levels
- Introduce one new concept
- Safe environment
- Impossible to fail
- Visual hints everywhere

#### Puzzle Levels  
- Multiple objects
- Several steps required
- Red herrings included
- Hidden optimal solutions

#### Action Levels
- Timing critical
- Moving platforms
- Quick gravity switches
- Reflex challenges

#### Sandbox Levels
- Many possible solutions
- Extra objects provided
- Creativity rewarded
- No single correct path

---

## 6. Scoring System

### Base Score Calculation
```
Base Score = 1000
- (Time Taken × 10)
- (Moves Used × 50)
+ (Objects Collected × 100)
+ (Perfect Run Bonus: 500)
```

### Star Rating Criteria
- ⭐ Complete level
- ⭐⭐ Under par time OR moves
- ⭐⭐⭐ Both under par

### Leaderboard Categories
1. **Fastest Time**
2. **Fewest Moves**
3. **Highest Score**
4. **Most Creative** (community voted)

---

## 7. Power-ups and Tools

### Temporary Power-ups
1. **Slow Motion**: 5 seconds of 0.5x speed
2. **Ghost Mode**: Pass through one obstacle
3. **Magnet Boost**: Double magnetic strength
4. **Anti-Gravity**: Reverse all objects
5. **Freeze**: Pause physics for planning

### Permanent Tools (Unlockable)
1. **Trajectory Preview**: See path before release
2. **Gravity Meter**: Precise strength control
3. **Object Scanner**: View hidden properties
4. **Solution Hint**: AI suggests direction
5. **Checkpoint**: Save mid-level progress

---

## 8. Tutorial System

### Progressive Disclosure
```
Level 1: "Tap to change gravity"
Level 2: "Hold to see trajectory"
Level 3: "Some objects have special properties"
Level 4: "Timing matters"
Level 5: "Combine mechanics creatively"
```

### Visual Indicators
- Glowing highlights on interactive elements
- Arrow indicators for suggested actions
- Ghost preview of successful path
- Particle trails showing flow

### Adaptive Hints
- First attempt: No hints
- Second attempt: Subtle visual cue
- Third attempt: Text hint appears
- Fourth+ attempt: Video solution option

---

## 9. Challenge Modes

### Daily Challenge
- One unique level per day
- Global leaderboard
- Special rewards
- Community solutions shared

### Speed Run Mode
- Series of 5 levels
- Total time tracked
- No pauses allowed
- Mistakes add time penalty

### Puzzle Rush
- Endless levels
- Increasing difficulty
- Lives system
- High score tracking

### Creator Challenge
- Theme announced weekly
- Players create levels
- Community votes
- Winner gets featured

---

## 10. Social Features

### Ghost Mode
- See other players' solutions
- Race against ghosts
- Filter by friends/global
- Learn new strategies

### Level Sharing
```
Share Code Format: XXXX-XXXX-XXXX
- Encodes full level data
- Instant loading
- Rate after playing
- Report inappropriate content
```

### Collaborative Mode
- Two players, one level
- Split control (gravity vs objects)
- Requires coordination
- Special co-op achievements

---

## Implementation Notes

### Physics Engine Settings
```dart
const physicsConfig = {
  'gravity': 9.81,
  'timeStep': 1/60,
  'velocityIterations': 10,
  'positionIterations': 10,
  'maxVelocity': 1000,
  'sleepThreshold': 0.1,
};
```

### Performance Optimizations
- Object pooling for particles
- Culling off-screen physics
- LOD for distant objects
- Simplified collision shapes
- Batch rendering similar objects

---

## Next Steps

1. Prototype core mechanics in Forge2D
2. Create 5 test levels per world
3. Implement basic scoring
4. Add tutorial overlays
5. Test with focus groups
6. Iterate based on feedback

---

**Remember**: The goal is to create a physics puzzle game that's easy to understand but difficult to master, with enough variety to keep players engaged for hours!