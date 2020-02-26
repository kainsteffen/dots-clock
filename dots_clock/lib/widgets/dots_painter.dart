import 'dart:math';

import 'package:flutter/material.dart';

/// [CustomPainter] that draws the clock face for [DotsClock].
class DotsPainter extends CustomPainter {
  DotsPainter({
    this.oldPath,
    this.currentPath,
    @required this.color,
    @required this.grid,
    @required this.rows,
    @required this.columns,
    @required this.pulseValue,
    @required this.transitionValue,
    @required this.spacing,
    @required this.dotBaseSize,
    @required this.dotActiveScale,
  });

  /// Previous [Path] of the clock face's font.
  ///
  /// Used to compare differences between clock updates and
  /// animate transitions for the dots.
  final Path oldPath;

  /// Current [Path] of the clock face's font.
  ///
  /// Used to compare differences between clock updates and
  /// animate transitions for the dots.
  final Path currentPath;

  /// [Color] with which to draw the dots.
  final Color color;

  /// 2D array containing the initial size values for each dot.
  final List<List<double>> grid;

  /// Number of rows to paint.
  final int rows;

  /// Number of columns to paint.
  final int columns;

  /// Current idle scale animation value to add onto each dot's size.
  final double pulseValue;

  /// Current transition animation value to add onto some dot's size.
  final double transitionValue;

  /// Spacing between rows and columns of dots.
  ///
  /// The higher this value the more space there is between dots
  /// and less dots will be displayed.
  final double spacing;

  /// Size of dots at the sine wave's peak value.
  final double dotBaseSize;

  /// Maximum scale multiplier of an active dot.
  final double dotActiveScale;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        Offset offset = Offset(
          j * spacing + (spacing / 2),
          i * spacing + (spacing / 2),
        );

        // Calculate the dot's current size by adding idle animation value
        // onto initial size and then applying sine function.
        double radius = sin(grid[i][j] + pulseValue) * dotBaseSize;

        // Paint dots differently based on their state:
        if (oldPath != null && currentPath != null) {
          // Dot is at active -> inactive state (transition scale down animation)
          if (oldPath.contains(offset) && !currentPath.contains(offset)) {
            radius = (radius * transitionValue.clamp(1, dotActiveScale)).abs();
          }

          // Dot is at inactive -> active state (transition scale up animation)
          if (!oldPath.contains(offset) && currentPath.contains(offset)) {
            radius = (radius * (dotActiveScale - transitionValue)).abs();
          }

          // Dot is at inactive state (idle at base scale)
          if (!oldPath.contains(offset) && !currentPath.contains(offset)) {
            radius = radius;
          }

          // Dot is at active state (idle at activeScale)
          if (oldPath.contains(offset) && currentPath.contains(offset)) {
            radius = (radius * dotActiveScale).abs();
          }
        }

        canvas.drawOval(
          Rect.fromCircle(center: offset, radius: radius),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DotsPainter oldDelegate) {
    return oldDelegate.oldPath != oldPath ||
        oldDelegate.currentPath != currentPath ||
        oldDelegate.color != color ||
        oldDelegate.grid != grid ||
        oldDelegate.rows != rows ||
        oldDelegate.columns != columns ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.transitionValue != transitionValue ||
        oldDelegate.spacing != spacing ||
        oldDelegate.dotActiveScale != dotActiveScale;
  }
}
