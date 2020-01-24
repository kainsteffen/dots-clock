// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:dots_clock/models/dots_clock_style.dart';
import 'package:dots_clock/widgets/dots_clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:flutter_clock_helper/model.dart';

void main() {
  // A temporary measure until Platform supports web and TargetPlatform supports
  // macOS.
  if (!kIsWeb && Platform.isMacOS) {
    // TODO(gspencergoog): Update this when TargetPlatform includes macOS.
    // https://github.com/flutter/flutter/issues/31366
    // See https://github.com/flutter/flutter/wiki/Desktop-shells#target-platform-override.
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  // This creates a clock that enables you to customize it.
  //
  // The [ClockCustomizer] takes in a [ClockBuilder] that consists of:
  //  - A clock widget (in this case, [DigitalClock])
  //  - A model (provided to you by [ClockModel])
  // For more information, see the flutter_clock_helper package.
  //
  // Your job is to edit [DigitalClock], or replace it with your
  // own clock widget. (Look in digital_clock.dart for more details!)
  runApp(
    ClockCustomizer(
      (ClockModel model) => LayoutBuilder(
        builder: (context, constraints) => DotsClock(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          model: model,
          // For other clocks, replace DotsClockStyle with the
          // following ones or make your own clock and reload.
          //
          // DotsClockStyle.blobs(),
          // DotsClockStyle.cellularNoise(),
          // DotsClockStyle.cubicNoise(),
          // DotsClockStyle.gooey(),
          // DotsClockStyle.simplexNoise(),
          // DotsClockStyle.valueNoise(),
          // DotsClockStyle.whiteNoise()
          style: DotsClockStyle.standard().copyWith(
            // Use box constraint height dependant units for consistent sizing
            // on all displays since aspect ratio is always the same for the contest.
            dotSpacing: constraints.maxHeight * 0.017,
            dotBaseSize: 0.5,
            dotActiveScale: constraints.maxHeight * 0.013,
            brightBackgroundColor: Color(0xFFF4F4F4),
            darkBackgroundColor: Color(0xFF10151B),
          ),
        ),
      ),
    ),
  );
}
