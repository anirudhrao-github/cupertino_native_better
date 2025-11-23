# cupertino_native_better

[![Pub Version](https://img.shields.io/pub/v/cupertino_native_better)](https://pub.dev/packages/cupertino_native_better)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS-lightgrey)](https://flutter.dev)

Native iOS 26+ **Liquid Glass** widgets for Flutter with pixel-perfect fidelity. This package renders authentic Apple UI components using native platform views, providing the genuine iOS/macOS look and feel that Flutter's built-in widgets cannot achieve.

<p align="center">
  <img src="https://raw.githubusercontent.com/gunumdogdu/cupertino_native_better/main/misc/screenshots/preview.jpg" alt="Preview" width="600"/>
</p>

## Why cupertino_native_better?

### Comparison with Other Packages

| Feature | cupertino_native_better | cupertino_native_plus | cupertino_native |
|---------|:-----------------------:|:---------------------:|:----------------:|
| iOS 26+ Liquid Glass | **Yes** | Yes | No |
| Release Build Version Detection | **Fixed** | Broken | N/A |
| SF Symbol Fallback (iOS < 26) | **CNIcon renders natively** | Placeholder icons | N/A |
| Button Label + Icon Fallback | **Both render correctly** | Label disappears | N/A |
| Tab Bar Icon Fallback | **CNIcon renders natively** | Empty circles | N/A |
| Image Asset Support (PNG/SVG) | **Full support** | Partial | No |
| Automatic Asset Resolution | **Yes (1x-4x)** | No | No |
| Dark Mode Sync | **Automatic** | Manual | Manual |
| Glass Effect Unioning | **Yes** | Yes | No |
| macOS Support | **Yes** | Yes | Yes |

### The Problem with Other Packages

**cupertino_native_plus** has a critical bug: it uses platform channels to detect iOS versions, which fails with *"Null check operator used on a null value"* in release builds. This causes:

- `shouldUseNativeGlass` returns `false` even on iOS 26+
- Falls back to old Cupertino widgets incorrectly
- Icons show as "..." or empty circles on iOS 18
- Button labels disappear when buttons have both icon and label

### Our Solution

**cupertino_native_better** fixes all these issues:

```dart
// We parse Platform.operatingSystemVersion directly
// Example: "Version 26.1 (Build 23B82)" -> 26
static int? _getIOSVersionManually() {
  final versionString = Platform.operatingSystemVersion;
  final match = RegExp(r'Version (\d+)\.').firstMatch(versionString);
  return int.tryParse(match?.group(1) ?? '');
}
```

This approach works reliably in **both debug and release builds**.

## Features

### Widgets

| Widget | Description |
|--------|-------------|
| `CNButton` | Native push button with Liquid Glass effects, SF Symbols, and image assets |
| `CNIcon` | Platform-rendered SF Symbols, custom IconData, or image assets |
| `CNTabBar` | Native tab bar with split mode for scroll-aware layouts |
| `CNSlider` | Native slider with controller for imperative updates |
| `CNSwitch` | Native toggle switch with controller support |
| `CNPopupMenuButton` | Native popup menu with dividers and icons |
| `CNSegmentedControl` | Native segmented control |
| `CNGlassButtonGroup` | Grouped buttons with unified glass blending |
| `LiquidGlassContainer` | Apply Liquid Glass effects to any widget |

### Icon Support

All widgets support three icon types with unified priority:

1. **Image Assets** (highest priority) - PNG, SVG, JPG with automatic resolution selection
2. **Custom Icons** - Any `IconData` (CupertinoIcons, Icons, custom)
3. **SF Symbols** - Native Apple SF Symbols with rendering modes

```dart
// SF Symbol
CNButton(
  label: 'Settings',
  icon: CNSymbol('gear', size: 20),
  onPressed: () {},
)

// Custom Icon
CNButton(
  label: 'Home',
  customIcon: CupertinoIcons.home,
  onPressed: () {},
)

// Image Asset
CNButton(
  label: 'Custom',
  imageAsset: CNImageAsset('assets/icons/custom.png', size: 20),
  onPressed: () {},
)
```

### Button Styles

```dart
CNButtonStyle.plain           // Minimal, text-only
CNButtonStyle.gray            // Subtle gray background
CNButtonStyle.tinted          // Tinted text
CNButtonStyle.bordered        // Bordered outline
CNButtonStyle.borderedProminent // Accent-colored border
CNButtonStyle.filled          // Solid filled background
CNButtonStyle.glass           // Liquid Glass effect (iOS 26+)
CNButtonStyle.prominentGlass  // Prominent glass effect (iOS 26+)
```

### Glass Effect Unioning

Multiple buttons can share a unified glass effect:

```dart
Row(
  children: [
    CNButton(
      label: 'Left',
      config: CNButtonConfig(
        style: CNButtonStyle.glass,
        glassEffectUnionId: 'toolbar',
      ),
      onPressed: () {},
    ),
    CNButton(
      label: 'Right',
      config: CNButtonConfig(
        style: CNButtonStyle.glass,
        glassEffectUnionId: 'toolbar',
      ),
      onPressed: () {},
    ),
  ],
)
```

### Tab Bar with Split Mode

```dart
CNTabBar(
  items: [
    CNTabBarItem(
      label: 'Home',
      icon: CNSymbol('house'),
      activeIcon: CNSymbol('house.fill'),
    ),
    CNTabBarItem(
      label: 'Profile',
      icon: CNSymbol('person.crop.circle'),
      activeIcon: CNSymbol('person.crop.circle.fill'),
    ),
  ],
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
  split: true, // Separates tabs when scrolling
  rightCount: 1, // Number of tabs pinned to the right
)
```

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  cupertino_native_better: ^1.0.6
```

## Usage

### ⚠️ REQUIRED: Initialize Before Use

**You MUST call `PlatformVersion.initialize()` before using any widgets!**

Without initialization, the package cannot detect your iOS/macOS version and will **always fall back to old Cupertino buttons** - even on iOS 26+ devices.

```dart
import 'package:cupertino_native_better/cupertino_native_better.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // REQUIRED: Initialize platform version detection
  await PlatformVersion.initialize();

  runApp(MyApp());
}
```

> **Why is this required?**
> The package needs to detect your OS version to decide whether to use native Liquid Glass (iOS 26+) or fallback widgets (iOS < 26). Without initialization, `PlatformVersion.shouldUseNativeGlass` always returns `false`.

### Basic Button

```dart
CNButton(
  label: 'Get Started',
  icon: CNSymbol('arrow.right', size: 18),
  config: CNButtonConfig(
    style: CNButtonStyle.filled,
    imagePlacement: CNImagePlacement.trailing,
  ),
  onPressed: () {
    // Handle tap
  },
)
```

### Icon-Only Button

```dart
CNButton.icon(
  icon: CNSymbol('plus', size: 24),
  config: CNButtonConfig(style: CNButtonStyle.glass),
  onPressed: () {},
)
```

### Native Icons

```dart
CNIcon(
  symbol: CNSymbol(
    'star.fill',
    size: 32,
    color: Colors.amber,
    mode: CNSymbolRenderingMode.multicolor,
  ),
)
```

### Slider with Controller

```dart
final controller = CNSliderController();

CNSlider(
  value: 0.5,
  min: 0,
  max: 1,
  controller: controller,
  onChanged: (value) {
    print('Value: $value');
  },
)

// Programmatic update
controller.setValue(0.75);
```

### Liquid Glass Container

```dart
LiquidGlassContainer(
  config: LiquidGlassConfig(
    effect: CNGlassEffect.regular,
    shape: CNGlassEffectShape.rect,
    cornerRadius: 16,
    interactive: true,
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Glass Effect'),
  ),
)

// Or use the extension
Text('Glass Effect')
  .liquidGlass(cornerRadius: 16)
```

## Platform Fallbacks

| Platform | Liquid Glass | SF Symbols | Other Widgets |
|----------|:------------:|:----------:|:-------------:|
| iOS 26+ | Native | Native | Native |
| iOS 13-25 | CupertinoButton | Native via CNIcon | CupertinoWidgets |
| macOS 26+ | Native | Native | Native |
| macOS 11-25 | CupertinoButton | Native via CNIcon | CupertinoWidgets |
| Android/Web/etc | Material fallback | Flutter Icon | Material fallback |

## Version Detection

Check platform capabilities:

```dart
// Check if Liquid Glass is available
if (PlatformVersion.shouldUseNativeGlass) {
  // iOS 26+ or macOS 26+
}

// Check if SF Symbols are available (iOS 13+, macOS 11+)
if (PlatformVersion.supportsSFSymbols) {
  // Use CNIcon for native rendering
}

// Get specific version
print('iOS version: ${PlatformVersion.iosVersion}');
print('macOS version: ${PlatformVersion.macOSVersion}');
```

## Requirements

- **Flutter**: >= 3.3.0
- **Dart SDK**: >= 3.9.0
- **iOS**: >= 13.0 (Liquid Glass requires iOS 26+)
- **macOS**: >= 11.0 (Liquid Glass requires macOS 26+)

## Migration from cupertino_native_plus

1. Update your `pubspec.yaml`:
   ```yaml
   # Before
   cupertino_native_plus: ^x.x.x

   # After
   cupertino_native_better: ^1.0.6
   ```

2. Update imports:
   ```dart
   // Before
   import 'package:cupertino_native_plus/cupertino_native_plus.dart';

   // After
   import 'package:cupertino_native_better/cupertino_native_better.dart';
   ```

3. No other code changes needed - API is fully compatible!

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Credits

This package is based on:
- [cupertino_native_plus](https://pub.dev/packages/cupertino_native_plus) by NarekManukyan
- [cupertino_native](https://pub.dev/packages/cupertino_native) by Serverpod

## License

MIT License - see [LICENSE](LICENSE) for details.
