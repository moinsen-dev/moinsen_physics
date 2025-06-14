# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Gravity Lab** (transforming from Moinsen Physics) is a Flutter-based physics puzzle game where players manipulate gravity to solve challenging puzzles. The game features realistic physics simulation using Forge2D, creative level design across 6 themed worlds, and a clean architecture approach.

## Design Documentation

Comprehensive design documents are available in `docs/design/`:
- `gravity-lab-feature-spec.md` - Complete game design document
- `ui-ux-design.md` - Visual design, color schemes, and UI patterns
- `level-design-guide.md` - Level creation principles and mechanics
- `tutorial-system-design.md` - Progressive learning system
- `world-themes-design.md` - Detailed world and level progression
- `physics-system-design.md` - Core physics implementation details
- `monetization-strategy.md` - Revenue model and pricing
- `technical-architecture.md` - Clean architecture implementation

## Development Commands

```bash
# Core development
flutter pub get                    # Install dependencies
flutter run                       # Run debug mode
flutter run -d android           # Run on specific platform
flutter analyze                  # Code analysis
dart format .                    # Format code

# Building
flutter build apk                 # Android release
flutter build ios                # iOS release  
flutter build web                # Web release

# Testing
flutter test                      # Run all tests
flutter test test/screenshot_test.dart --update-goldens  # Update golden files
```

## Architecture

### Clean Architecture Structure
The project follows clean architecture principles with clear separation of concerns:

```
lib/
├── core/                    # Shared utilities and constants
│   ├── physics/            # Physics constants and helpers
│   ├── theme/              # App theming and colors
│   └── utils/              # Common utilities
├── data/                   # Data layer
│   ├── repositories/       # Data repositories
│   └── models/            # Data models
├── domain/                 # Business logic
│   ├── entities/          # Core entities
│   ├── repositories/      # Repository interfaces
│   └── use_cases/         # Business logic
├── presentation/           # UI layer
│   ├── screens/           # Screen widgets
│   ├── widgets/           # Reusable widgets
│   └── providers/         # State management
└── features/              # Feature modules
    ├── game_engine/       # Flame/Forge2D integration
    ├── level_editor/      # Level creation tools
    └── tutorial/          # Tutorial system
```

### Key Components
- **Game Engine**: Flame + Forge2D for physics simulation
- **State Management**: Riverpod for app state
- **Audio System**: Flutter Sound with dynamic collision-based effects
- **Level System**: JSON-based level definitions with physics parameters
- **Visual Effects**: Particle systems and animations

### Dependencies
- **Game Engine**: `flame` + `flame_forge2d` for physics
- **State**: `flutter_riverpod` for state management
- **Audio**: `flutter_sound` with permission handling
- **Testing**: `golden_toolkit` for visual regression
- **Analytics**: `firebase_analytics` (future implementation)

## Game Development Guidelines

### Physics Implementation
- **Forge2D Integration**: Use Box2D physics for realistic simulation
- **Gravity System**: 8-directional gravity with smooth transitions
- **Object Types**: Standard, Heavy, Light, Bouncy, Sticky, Fragile, Magnetic, Portal
- **Performance**: Target 60 FPS with efficient collision detection

### Level Design
- **Structure**: JSON-based level definitions in `assets/levels/`
- **Progression**: 6 worlds × 20 levels = 120 total levels
- **Difficulty**: Progressive difficulty with star-based scoring
- **Testing**: Each level must be completable within time limits

### Visual Standards
- **Theme**: Modern, clean with physics-inspired aesthetics
- **Colors**: World-specific palettes (see `docs/design/ui-ux-design.md`)
- **Animations**: Smooth transitions, particle effects for interactions
- **Accessibility**: High contrast mode, colorblind-friendly options

## Testing Strategy

### Unit Tests
- Physics calculations and gravity mechanics
- Level loading and validation
- Score calculation algorithms

### Widget Tests
- UI component behavior
- Screen navigation flows
- Control responsiveness

### Golden Tests
- Visual regression across devices:
  - Android: Phone, 7" tablet, 10" tablet
  - iOS: iPhone 6.5", 6.9", iPad Pro 12.9"
- Run with: `flutter test test/screenshot_test.dart --update-goldens`

### Integration Tests
- Full gameplay flow
- Level completion mechanics
- Save/load functionality

## Development Workflow

### Git Workflow
- **Main branch**: `develop`
- **Feature branches**: `feat/feature-name`
- **Release branches**: `release/version`
- **Hotfix branches**: `hotfix/issue-name`

### GitHub Integration
```bash
# Current work context
gh pr view 2              # View current PR

# Issue management
gh issue create --title "Title" --body "Description"
gh issue list --label "bug"

# PR workflow
gh pr create --title "Title" --body "Description"
gh pr status
```

### Code Standards
- **Exports**: Use `_index.dart` files for clean module exports
- **Naming**: Follow Flutter conventions (lowerCamelCase, UpperCamelCase)
- **Documentation**: Document complex physics calculations
- **Performance**: Profile regularly, optimize draw calls

## Performance Optimization

### Key Metrics
- **Target FPS**: 60 on all supported devices
- **Load Time**: < 3 seconds for app start
- **Level Load**: < 500ms per level
- **Memory**: < 150MB runtime usage

### Optimization Strategies
- Efficient sprite batching
- Object pooling for particles
- Lazy loading of world assets
- Physics body sleeping for inactive objects

## Monetization Implementation

### Revenue Streams
- **Ads**: Rewarded videos for hints/retries
- **IAP**: Hint packs, world unlocks, cosmetics
- **Season Pass**: Monthly content updates
- **Remove Ads**: One-time purchase option

### Implementation Notes
- Use `in_app_purchase` package for IAP
- `google_mobile_ads` for ad integration
- Server validation for purchases
- Offline play capability maintained

## Current Development Status

### Completed
- Basic project structure
- Core physics engine setup
- Initial UI framework

### In Progress (PR #2)
- Clean architecture implementation
- Game engine integration
- Level system foundation

### Upcoming
- Tutorial system implementation
- First world levels (Newton's Lab)
- Visual polish and effects
- Sound system enhancement