//
//  OKLCH.swift
//  OKLCH
//
//  Created by Alex Grad <alex@grad.dev> (https://grad.dev) on 15.03.2026.
//

import SwiftUI

/// Provides OKLCH color space support to SwiftUI's `Color` type.
extension Color {

  /// Creates a constant color from OKLCH values.
  ///
  /// This method allows you to define colors using the OKLCH color space, which provides perceptual
  /// uniformity. This means that changes in lightness, chroma, or hue correspond to visually equal changes.
  ///
  /// Expected ranges:
  /// - Lightness: `0.0` (black) to `1.0` (white).
  /// - Chroma: `0.0` (achromatic) to `~0.4` (maximum possible saturation depending on hue and lightness).
  /// - Hue: `0.0` to `360.0` degrees.
  ///
  /// ```swift
  /// let brandColor = Color.oklch(lightness: 0.7, chroma: 0.1, hue: 250)
  /// ```
  ///
  /// - Parameters:
  ///   - colorSpace: The target RGB color space for the resulting color. Defaults to `.sRGB`.
  ///   - lightness: The perceived lightness of the color (`0.0` to `1.0`).
  ///   - chroma: The amount of color or saturation (`0.0` to `~0.4`).
  ///   - hue: The hue angle in degrees (`0.0` to `360.0`).
  ///   - opacity: The opacity of the color (`0.0` to `1.0`). Defaults to `1`.
  /// - Returns: A SwiftUI `Color`.
  public static func oklch(
    _ colorSpace: Color.RGBColorSpace = .sRGB,
    lightness l: Double,
    chroma c: Double,
    hue h: Double,
    opacity: Double = 1
  ) -> Color {
    // 1. Edge cases
    if l >= 0.99999 { return Color(colorSpace, red: 1.0, green: 1.0, blue: 1.0, opacity: opacity) }
    if l <= 0.00001 { return Color(colorSpace, red: 0.0, green: 0.0, blue: 0.0, opacity: opacity) }

    // 2. Conversion Pipeline
    let oklab = convertOKLCHToOKLAB(l: l, c: c, h: h)
    let lms = convertOKLABToLMS(l: oklab.l, a: oklab.a, b: oklab.b)
    let rgb = convertLMSToLinearRGB(l: lms.l, m: lms.m, s: lms.s, colorSpace: colorSpace)

    // 3. Gamma Correction & Output
    if colorSpace == .sRGBLinear {
      return Color(colorSpace, red: rgb.r, green: rgb.g, blue: rgb.b, opacity: opacity)
    } else {
      return Color(
        colorSpace,
        red: applyGammaCorrection(rgb.r),
        green: applyGammaCorrection(rgb.g),
        blue: applyGammaCorrection(rgb.b),
        opacity: opacity
      )
    }
  }

  /// Converts from cylindrical OKLCH coordinates (Lightness, Chroma, Hue angle) to Cartesian OKLAB coordinates (Lightness, a-axis, b-axis).
  private static func convertOKLCHToOKLAB(l: Double, c: Double, h: Double) -> (
    l: Double, a: Double, b: Double
  ) {
    let hRadians = h * .pi / 180.0
    let a = c * cos(hRadians)
    let b = c * sin(hRadians)
    return (l, a, b)
  }

  /// Transforms from the OKLAB color space to the LMS (Long, Medium, Short cone responses) color space using standard matrix operations.
  private static func convertOKLABToLMS(l: Double, a: Double, b: Double) -> (
    l: Double, m: Double, s: Double
  ) {
    let lmsL = l + 0.3963377774 * a + 0.2158037573 * b
    let lmsM = l - 0.1055613458 * a - 0.0638541728 * b
    let lmsS = l - 0.0894841775 * a - 1.2914855480 * b

    return (
      lmsL * lmsL * lmsL,
      lmsM * lmsM * lmsM,
      lmsS * lmsS * lmsS
    )
  }

  /// Converts from LMS to Linear RGB, using different transformation matrices depending on the target `colorSpace` (e.g., Display P3 vs. sRGB).
  private static func convertLMSToLinearRGB(
    l: Double, m: Double, s: Double, colorSpace: Color.RGBColorSpace
  ) -> (r: Double, g: Double, b: Double) {
    switch colorSpace {
    case .displayP3:
      return (
        3.1281105290 * l - 2.2570750185 * m + 0.1293047886 * s,
        -1.0911281609 * l + 2.4132667618 * m - 0.3221681709 * s,
        -0.0260136497 * l - 0.5080276489 * m + 1.5333166822 * s
      )
    default:  // sRGB, sRGBLinear
      return (
        4.0765380105 * l - 3.3070961456 * m + 0.2308224808 * s,
        -1.2686057610 * l + 2.6097473507 * m - 0.3411636471 * s,
        -0.0041975888 * l - 0.7035684652 * m + 1.7072056752 * s
      )
    }
  }

  /// Applies the standard gamma curve to convert linear RGB values into gamma-encoded RGB values for display.
  private static func applyGammaCorrection(_ value: Double) -> Double {
    let absC = abs(value)
    let signC = value < 0 ? -1.0 : 1.0
    return absC <= 0.0031308
      ? signC * (12.92 * absC) : signC * (1.055 * pow(absC, 1.0 / 2.4) - 0.055)
  }
}

/// Allows the `oklch` method to be used seamlessly in SwiftUI modifiers that expect a `ShapeStyle`.
extension ShapeStyle where Self == Color {

  /// Creates a constant color from OKLCH values.
  ///
  /// This method allows you to define colors using the OKLCH color space, which provides perceptual
  /// uniformity. This means that changes in lightness, chroma, or hue correspond to visually equal changes.
  ///
  /// Expected ranges:
  /// - Lightness: `0.0` (black) to `1.0` (white).
  /// - Chroma: `0.0` (achromatic) to `~0.4` (maximum possible saturation depending on hue and lightness).
  /// - Hue: `0.0` to `360.0` degrees.
  ///
  /// ```swift
  /// Rectangle()
  ///     .fill(.oklch(lightness: 0.7, chroma: 0.1, hue: 250))
  /// ```
  ///
  /// - Parameters:
  ///   - colorSpace: The target RGB color space for the resulting color. Defaults to `.sRGB`.
  ///   - lightness: The perceived lightness of the color (`0.0` to `1.0`).
  ///   - chroma: The amount of color or saturation (`0.0` to `~0.4`).
  ///   - hue: The hue angle in degrees (`0.0` to `360.0`).
  ///   - opacity: The opacity of the color (`0.0` to `1.0`). Defaults to `1`.
  /// - Returns: A SwiftUI `Color`.
  public static func oklch(
    _ colorSpace: Color.RGBColorSpace = .sRGB,
    lightness l: Double,
    chroma c: Double,
    hue h: Double,
    opacity: Double = 1
  ) -> Color {
    return Color.oklch(
      colorSpace,
      lightness: l,
      chroma: c,
      hue: h,
      opacity: opacity
    )
  }
}
