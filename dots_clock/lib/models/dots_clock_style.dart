import 'dart:math';

import 'package:fast_noise/fast_noise.dart';
import 'package:flutter/material.dart';

class DotsClockStyle {
  const DotsClockStyle({
    @required this.dotSpacing,
    @required this.dotActiveScale,
    @required this.fontPath,
    @required this.charXPosCorrections,
    @required this.gridBuilder,
    this.idleAnimationDuration: 10000,
    this.transitionAnimationDuration: 1000,
    this.fontSize: 0.4,
    this.fontSpacing: 1,
    this.middleSpacing: 0,
    this.xOffset: 0,
    this.yOffset: 0,
    this.shouldCenterVertically: true,
    this.shouldCenterHorizontally: false,
  })  : assert(dotSpacing != null),
        assert(dotActiveScale != null),
        assert(fontPath != null),
        assert(charXPosCorrections != null),
        assert(idleAnimationDuration != null),
        assert(transitionAnimationDuration != null),
        assert(dotSpacing != null),
        assert(fontSize != null),
        assert(fontSpacing != null),
        assert(middleSpacing != null),
        assert(xOffset != null),
        assert(yOffset != null),
        assert(shouldCenterVertically != null),
        assert(shouldCenterHorizontally != null),
        assert(idleAnimationDuration > 0),
        assert(transitionAnimationDuration > 0);

  /// Duration of 1 cycle of the dots' idle animations.
  final int idleAnimationDuration;

  /// Duration of 1 cycle of the dots' transition animations.
  final int transitionAnimationDuration;

  /// Space between each dot.
  final double dotSpacing;

  /// Scale of each dot when active.
  final double dotActiveScale;

  /// Filepath for a font.
  final String fontPath;

  /// Size of the font as a percentage of the window height.
  final double fontSize;

  /// Size of the font spacing as a percentage of font's height.
  final double fontSpacing;

  /// Size of the middle spacing as a percentage of windows width.
  final double middleSpacing;

  /// X-position to offset
  ///
  /// Overwritten by [shouldCenterHorizontally] when true.
  final double xOffset;

  /// Y-position to offset
  ///
  /// Overwritten by [shouldCenterVertically] when true.
  final double yOffset;

  /// Centers the clock face path vertically when true.
  final bool shouldCenterVertically;

  /// Centers the clock face path horitontally when true.
  final bool shouldCenterHorizontally;

  /// Corecctional values for the x-position of certain characters
  /// for when the font is not monospaced.
  final Map<String, double> charXPosCorrections;

  /// Callback function to build initial 2d-array of dot sizes.
  final Function(int rows, int columns) gridBuilder;

  /// Overrides existing [DotsClockStyle] with defined values.
  DotsClockStyle copyWith({
    double dotSpacing,
    double dotActiveScale,
    String fontPath,
    double fontSize,
    double fontSpacing,
    double middleSpacing,
    double xOffset,
    double yOffset,
    bool shouldCenterVertically,
    bool shouldCenterHorizontally,
    Map<String, double> charXPosCorrections,
    Function(int rows, int columns) gridBuilder,
  }) {
    return DotsClockStyle(
      dotSpacing: dotSpacing ?? this.dotSpacing,
      dotActiveScale: dotActiveScale ?? this.dotActiveScale,
      fontPath: fontPath ?? this.fontPath,
      gridBuilder: gridBuilder ?? this.gridBuilder,
      charXPosCorrections: charXPosCorrections ?? this.charXPosCorrections,
      fontSize: fontSize ?? this.fontSize,
      fontSpacing: fontSpacing ?? this.fontSpacing,
      middleSpacing: middleSpacing ?? this.middleSpacing,
      xOffset: xOffset ?? this.xOffset,
      yOffset: yOffset ?? this.yOffset,
      shouldCenterVertically:
          shouldCenterVertically ?? this.shouldCenterVertically,
      shouldCenterHorizontally:
          shouldCenterHorizontally ?? this.shouldCenterHorizontally,
    );
  }

  /// A standard [DotsClockStyle]
  factory DotsClockStyle.standard() {
    return DotsClockStyle(
      dotSpacing: 6.5,
      dotActiveScale: 3,
      fontPath: "assets/fonts/Poppins-Bold.ttf",
      fontSize: 0.4,
      fontSpacing: 0.9,
      middleSpacing: 0.05,
      shouldCenterHorizontally: true,
      charXPosCorrections: <String, double>{
        "1": 0.175,
        "7": 0.1,
      },
      gridBuilder: (rows, columns) {
        PerlinNoise noise = PerlinNoise(
          octaves: 4,
          frequency: 0.35,
        );
        return List.generate(
          rows,
          (int row) => List.generate(
            columns,
            (int column) {
              double noiseValue =
                  noise.getPerlin2(column.toDouble(), row.toDouble());
              double percentage = (noiseValue + sqrt1_2) / (2 * sqrt1_2);
              double value = percentage * 2 * pi;
              return value;
            },
          ),
        );
      },
    );
  }

  /// A [DotsClockStyle] with oversized dots.
  factory DotsClockStyle.blobs() {
    return DotsClockStyle(
      dotSpacing: 6.5,
      dotActiveScale: 6,
      fontPath: "assets/fonts/Poppins-Bold.ttf",
      fontSize: 0.4,
      fontSpacing: 0.9,
      middleSpacing: 0.05,
      shouldCenterHorizontally: true,
      charXPosCorrections: <String, double>{
        "1": 0.175,
        "7": 0.1,
      },
      gridBuilder: (rows, columns) {
        PerlinNoise noise = PerlinNoise(
          octaves: 4,
          frequency: 0.35,
        );
        return List.generate(
          rows,
          (int row) => List.generate(
            columns,
            (int column) {
              double noiseValue =
                  noise.getPerlin2(column.toDouble(), row.toDouble());
              double percentage = (noiseValue + sqrt1_2) / (2 * sqrt1_2);
              double value = percentage * 2 * pi;
              return value;
            },
          ),
        );
      },
    );
  }

  /// A [DotsClockStyle] with gooey animations.
  factory DotsClockStyle.gooey() {
    return DotsClockStyle(
      dotSpacing: 6.5,
      dotActiveScale: 3,
      fontPath: "assets/fonts/Poppins-Bold.ttf",
      fontSize: 0.4,
      fontSpacing: 0.9,
      middleSpacing: 0.05,
      shouldCenterHorizontally: true,
      charXPosCorrections: <String, double>{
        "1": 0.175,
        "7": 0.1,
      },
      gridBuilder: (rows, columns) {
        PerlinNoise noise = PerlinNoise(
          octaves: 4,
          frequency: 0.1,
        );
        return List.generate(
          rows,
          (int row) => List.generate(
            columns,
            (int column) {
              double noiseValue =
                  noise.getPerlin2(column.toDouble(), row.toDouble());
              double percentage = (noiseValue + sqrt1_2) / (2 * sqrt1_2);
              double value = percentage * 2 * pi;
              return value;
            },
          ),
        );
      },
    );
  }

  /// A [DotsClockStyle] using celluar noise.
  factory DotsClockStyle.cellularNoise() {
    return DotsClockStyle(
      dotSpacing: 6.5,
      dotActiveScale: 3,
      fontPath: "assets/fonts/Poppins-Bold.ttf",
      fontSize: 0.4,
      fontSpacing: 0.9,
      middleSpacing: 0.05,
      shouldCenterHorizontally: true,
      charXPosCorrections: <String, double>{
        "1": 0.175,
        "7": 0.1,
      },
      gridBuilder: (rows, columns) {
        CellularNoise noise = CellularNoise(
          octaves: 3,
          frequency: 0.3,
        );
        return List.generate(
          rows,
          (int row) => List.generate(
            columns,
            (int column) {
              double noiseValue =
                  noise.getCellular2(column.toDouble(), row.toDouble());
              double percentage = (noiseValue + sqrt1_2) / (2 * sqrt1_2);
              double value = percentage * 2 * pi;
              return value;
            },
          ),
        );
      },
    );
  }

  /// A [DotsClockStyle] using simplex noise.
  factory DotsClockStyle.simplexNoise() {
    return DotsClockStyle(
      dotSpacing: 6.5,
      dotActiveScale: 3,
      fontPath: "assets/fonts/Poppins-Bold.ttf",
      fontSize: 0.4,
      fontSpacing: 0.9,
      middleSpacing: 0.05,
      shouldCenterHorizontally: true,
      charXPosCorrections: <String, double>{
        "1": 0.175,
        "7": 0.1,
      },
      gridBuilder: (rows, columns) {
        SimplexNoise noise = SimplexNoise(
          octaves: 4,
          frequency: 0.0075,
        );
        return List.generate(
          rows,
          (int row) => List.generate(
            columns,
            (int column) {
              double noiseValue =
                  noise.getSimplex2(column.toDouble(), row.toDouble());
              double percentage = (noiseValue + sqrt1_2) / (2 * sqrt1_2);
              double value = percentage * 2 * pi;
              return value;
            },
          ),
        );
      },
    );
  }

  /// A [DotsClockStyle] using cubic noise.
  factory DotsClockStyle.cubicNoise() {
    return DotsClockStyle(
      dotSpacing: 6.5,
      dotActiveScale: 3,
      fontPath: "assets/fonts/Poppins-Bold.ttf",
      fontSize: 0.4,
      fontSpacing: 0.9,
      middleSpacing: 0.05,
      shouldCenterHorizontally: true,
      charXPosCorrections: <String, double>{
        "1": 0.175,
        "7": 0.1,
      },
      gridBuilder: (rows, columns) {
        CubicNoise noise = CubicNoise(
          octaves: 3,
          frequency: 0.015,
        );
        return List.generate(
          rows,
          (int row) => List.generate(
            columns,
            (int column) {
              double noiseValue =
                  noise.getCubic2(column.toDouble(), row.toDouble());
              double percentage = (noiseValue + sqrt1_2) / (2 * sqrt1_2);
              double value = percentage * 2 * pi;
              return value;
            },
          ),
        );
      },
    );
  }

  /// A [DotsClockStyle] using value noise.
  factory DotsClockStyle.valueNoise() {
    return DotsClockStyle(
      dotSpacing: 6.5,
      dotActiveScale: 3,
      fontPath: "assets/fonts/Poppins-Bold.ttf",
      fontSize: 0.4,
      fontSpacing: 0.9,
      middleSpacing: 0.05,
      shouldCenterHorizontally: true,
      charXPosCorrections: <String, double>{
        "1": 0.175,
        "7": 0.1,
      },
      gridBuilder: (rows, columns) {
        ValueNoise noise = ValueNoise(
          octaves: 3,
          frequency: 0.015,
        );
        return List.generate(
          rows,
          (int row) => List.generate(
            columns,
            (int column) {
              double noiseValue =
                  noise.getValue2(column.toDouble(), row.toDouble());
              double percentage = (noiseValue + sqrt1_2) / (2 * sqrt1_2);
              double value = percentage * 2 * pi;
              return value;
            },
          ),
        );
      },
    );
  }

  /// A [DotsClockStyle] using white noise.
  factory DotsClockStyle.whiteNoise() {
    return DotsClockStyle(
      dotSpacing: 6.5,
      dotActiveScale: 3,
      fontPath: "assets/fonts/Poppins-Bold.ttf",
      fontSize: 0.4,
      fontSpacing: 0.9,
      middleSpacing: 0.05,
      shouldCenterHorizontally: true,
      charXPosCorrections: <String, double>{
        "1": 0.175,
        "7": 0.1,
      },
      gridBuilder: (rows, columns) {
        WhiteNoise noise = WhiteNoise();
        return List.generate(
          rows,
          (int row) => List.generate(
            columns,
            (int column) {
              double noiseValue = noise.getWhiteNoise2(column, row);
              double percentage = (noiseValue + sqrt1_2) / (2 * sqrt1_2);
              double value = percentage * 2 * pi;
              return value;
            },
          ),
        );
      },
    );
  }
}
