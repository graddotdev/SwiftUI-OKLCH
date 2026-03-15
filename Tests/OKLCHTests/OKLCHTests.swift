//
//  OKLCHTests.swift
//  OKLCHTests
//
//  Created by Alex Grad <alex@grad.dev> (https://grad.dev) on 15.03.2026.
//

import SwiftUI
import XCTest

@testable import OKLCH

final class OKLCHTests: XCTestCase {

  func assertColorEqual(
    colorSpace: Color.RGBColorSpace = .sRGB,
    oklch: (l: Double, c: Double, h: Double),
    rgb: (r: Double, g: Double, b: Double),
    accuracy: Double = 0.005,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    let resolved1 = Color.oklch(colorSpace, lightness: oklch.l, chroma: oklch.c, hue: oklch.h)
      .resolve(in: EnvironmentValues())
    let resolved2 = Color(colorSpace, red: rgb.r, green: rgb.g, blue: rgb.b)
      .resolve(in: EnvironmentValues())

    XCTAssertEqual(
      Double(resolved1.red), Double(resolved2.red),
      accuracy: accuracy, file: file, line: line
    )
    XCTAssertEqual(
      Double(resolved1.green), Double(resolved2.green),
      accuracy: accuracy, file: file, line: line
    )
    XCTAssertEqual(
      Double(resolved1.blue), Double(resolved2.blue),
      accuracy: accuracy, file: file, line: line
    )
  }

  // MARK: - Standard sRGB Conversions

  func testConversion_sRGB_Green() {
    assertColorEqual(oklch: (0.51975, 0.17686, 142.495), rgb: (0.0, 0.50196, 0.0))
  }

  func testConversion_sRGB_Hue0() {
    assertColorEqual(oklch: (0.5, 0.2, 0), rgb: (0.70492, 0.02351, 0.37073))
  }

  func testConversion_sRGB_Hue270() {
    assertColorEqual(oklch: (0.5, 0.2, 270), rgb: (0.23056, 0.31730, 0.82628))
  }

  func testConversion_sRGB_Hue160() {
    assertColorEqual(oklch: (0.8, 0.15, 160), rgb: (0.32022, 0.85805, 0.61147))
  }

  func testConversion_sRGB_Hue345() {
    assertColorEqual(oklch: (0.55, 0.15, 345), rgb: (0.67293, 0.27791, 0.52280))
  }

  // MARK: - Display P3 Gamut

  func testConversion_DisplayP3_Green() {
    assertColorEqual(
      colorSpace: .displayP3, oklch: (0.84883, 0.36853, 145.645), rgb: (0.0, 1.0, 0.0))
  }

  // MARK: - Edge Cases & Clamping

  func testEdgeCase_PureBlack() {
    assertColorEqual(oklch: (0, 0, 0), rgb: (0, 0, 0))
    assertColorEqual(oklch: (0, 1.1, 60), rgb: (0, 0, 0))
  }

  func testEdgeCase_PureWhite() {
    assertColorEqual(oklch: (1, 0, 0), rgb: (1, 1, 1))
    assertColorEqual(oklch: (1, 110, 60), rgb: (1, 1, 1))
  }

  func testEdgeCase_LightnessOver1() {
    assertColorEqual(oklch: (1.5, 0.2, 45), rgb: (1, 1, 1))
  }

  func testEdgeCase_LightnessCloseTo0() {
    assertColorEqual(oklch: (0.000001, 0.2, 45), rgb: (0, 0, 0))
  }

  func testEdgeCase_LightnessCloseTo1() {
    assertColorEqual(oklch: (0.999999, 0.2, 45), rgb: (1, 1, 1))
  }
}
