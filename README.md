# OKLCH

A lightweight Swift package that extends SwiftUI's `Color` to support the **OKLCH** color space. 

OKLCH is a perceptually uniform color space that makes it incredibly easy to create accessible, predictable, and beautiful colors. It provides a more intuitive way to manipulate colors compared to traditional RGB or HSL by separating lightness, chroma (saturation), and hue.

## Features

- 🎨 **Native SwiftUI Integration**: Seamlessly extends `SwiftUI.Color`.
- 🧠 **Perceptually Uniform**: Adjusting lightness or chroma behaves predictably to the human eye.
- 🌈 **Color Space Support**: Supports creating colors in `sRGB`, `sRGBLinear`, and `displayP3` color spaces.
- ⚡️ **Lightweight**: Zero external dependencies.

## Requirements

- iOS 13.0+
- macOS 10.15+
- tvOS 13.0+
- watchOS 6.0+
- Swift 6.2+

## Installation

### Swift Package Manager

You can add `OKLCH` to your project using Swift Package Manager. 

1. In Xcode, go to **File** > **Add Packages...**
2. Enter the repository URL for this package.
3. Choose the dependency rule that suits your needs (e.g., Up to Next Major Version).
4. Add the `OKLCH` product to your target.

Alternatively, you can add it to your `Package.swift` file:

```swift
dependencies: [
  .package(url: "https://github.com/graddotdev/SwiftUI-OKLCH.git", from: "1.0.0")
]
```

## Usage

Import the package and use the `.oklch()` static method directly on `Color`:

```swift
import OKLCH
import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      // Basic usage (Defaults to sRGB)
      Rectangle()
        .fill(Color.oklch(lightness: 0.7, chroma: 0.1, hue: 250))
        .frame(width: 100, height: 100)

      // With Opacity
      Rectangle()
        .fill(Color.oklch(lightness: 0.6, chroma: 0.15, hue: 140, opacity: 0.5))
        .frame(width: 100, height: 100)

      // Specifying a different Color Space (e.g., Display P3)
      Rectangle()
        .fill(Color.oklch(.displayP3, lightness: 0.8, chroma: 0.2, hue: 45))
        .frame(width: 100, height: 100)

      // Elegant ShapeStyle syntax
      Rectangle()
        .fill(.oklch(lightness: 0.7, chroma: 0.1, hue: 250))
        .frame(width: 100, height: 100)
    }
  }
}
```

### Parameters

- `colorSpace`: The target `Color.RGBColorSpace` (`.sRGB` (default), `.sRGBLinear`, or `.displayP3`).
- `lightness` (`l`): The perceived lightness from `0.0` (black) to `1.0` (white).
- `chroma` (`c`): The amount of color. `0.0` is neutral grey. Maximum values depend on the lightness and hue but generally go up to `0.4` or `0.5` for very saturated colors.
- `hue` (`h`): The hue angle in degrees, from `0` to `360`.
- `opacity`: The alpha value from `0.0` (transparent) to `1.0` (opaque). Default is `1.0`.

## License

This project is licensed under the MIT License.
