// Copyright 2020 Tran Duy Khanh Steffen. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the dots_clock/LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:dots_clock/models/dots_clock_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:text_to_path_maker/text_to_path_maker.dart';

class DotsClock extends StatefulWidget {
  const DotsClock({
    @required this.model,
    @required this.style,
    @required this.width,
    @required this.height,
  });

  /// [ClockModel] to provide weather, temperature, location information.
  final ClockModel model;

  /// Data model that has the style specifications.
  final DotsClockStyle style;

  /// Width of the available render space.
  final double width;

  /// Height of the available render space.
  final double height;

  @override
  State<StatefulWidget> createState() => DotsClockState();
}

class DotsClockState extends State<DotsClock> with TickerProviderStateMixin {
  /// Current time.
  DateTime _dateTime = DateTime.now();

  /// [Timer] to update clock in an interval.
  Timer _timer;

  /// Font for the digital clock face.
  PMFont _targetFont;

  /// Current [Path] of the clock face's font.
  ///
  /// Used to compare active/inactive dots differences between 
  /// clock updates and animate transitions for the dots.
  Path _currentPath;

  /// Previous [Path] of the clock face's font.
  ///
  /// Used to compare differences between clock ticks and
  /// animate transitions for the dots.
  Path _oldPath;

  /// 2D array containing the initial size values for each dot.
  List<List<double>> _dotsGrid;

  /// [AnimationController] for the dot idle animations.
  AnimationController _dotPulseController;

  /// [Animation] values for the dot idle scaling animations.
  Animation<double> _dotPulseAnimation;

  /// [AnimationController] for the dot transition animations.
  AnimationController _dotTransitionController;

  /// [Animation] values for the dot transition animations.
  Animation<double> _dotTransitionAnimation;

  /// Number of rows based on [DotsClockStyle] and it's dot spacing.
  int _rows;

  /// Number of columns based on [DotsClockStyle] and it's dot spacing.
  int _columns;

  @override
  void initState() {
    super.initState();
    // Calculate number of columns, rows based on dot spacing.
    _rows = (widget.height / widget.style.dotSpacing).floor();
    _columns = (widget.width / widget.style.dotSpacing).floor();

    // Dot idle pulsing animation that scales the dots' sizes.
    //
    // Is set to repeat as it should always be animating.
    _dotPulseController = AnimationController(
      duration: Duration(
        milliseconds: widget.style.idleAnimationDuration,
      ),
      vsync: this,
    );
    _dotPulseAnimation = Tween(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(
        curve: Curves.linear,
        parent: _dotPulseController,
      ),
    )..addListener(() => setState(() {}));
    _dotPulseController.repeat();

    // Dot transition animation between active/inactive state
    // by scaling them up or down to their correct size.
    //
    // Plays for each clock update.
    _dotTransitionController = AnimationController(
      duration:
          Duration(milliseconds: widget.style.transitionAnimationDuration),
      vsync: this,
    );
    _dotTransitionAnimation =
        Tween(begin: widget.style.dotActiveScale, end: 0.0).animate(
      CurvedAnimation(
        curve: Curves.easeInOut,
        parent: _dotTransitionController,
      ),
    )..addListener(() => setState(() {}));

    widget.model.addListener(_updateModel);

    _loadFont().then((v) {
      _updatePath(_getFormattedTime());
    });

    _initDotsGrid();
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DotsClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
    _updatePath(_getFormattedTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dotPulseController.dispose();
    _dotTransitionController.dispose();
    super.dispose();
  }

  /// Update 3rd party information model.
  ///
  /// Currently unused.
  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  /// Initialise dots grid via [DotsClockStyle] builder function.
  _initDotsGrid() {
    _dotsGrid = widget.style.gridBuilder(_rows, _columns);
  }

  /// Update current [_time] in a given interval and update clock face path.
  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );

      _updatePath(_getFormattedTime());
    });
    _dotTransitionController.reset();
    _dotTransitionController.forward();
  }

  /// Get the current formatted time.
  String _getFormattedTime() {
    final String hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final String minute = DateFormat('mm').format(_dateTime);
    return '$hour$minute';
  }

  /// Load the target font.
  Future<PMFont> _loadFont() async {
    ByteData data = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");
    PMFontReader reader = PMFontReader();
    _targetFont = reader.parseTTFAsset(data);
    return reader.parseTTFAsset(data);
  }

  /// Update the clock face path.
  void _updatePath(String time) {
    _oldPath = _currentPath;
    _currentPath = _buildClockFacePath(time);
  }

  /// Calculate the next clock face path.
  Path _buildClockFacePath(String string) {
    if (_targetFont != null) {
      Path stringPath = Path();

      for (int i = 0; i < string.length; i++) {
        Path charPath =
            _targetFont.generatePathForCharacter(string.codeUnitAt(i));

        // PMTransform.moveAndScale scales by minus y-scale.
        //
        // Flip char path on y-axis because inital paths are reversed.
        charPath = PMTransform.moveAndScale(charPath, 0.0, 0.0, 1.0, 1.0);

        // Scale char path to defined font size.
        double targetHeight = widget.style.fontSize * widget.height;
        double yScaleFactor = targetHeight / charPath.getBounds().height;
        charPath = PMTransform.moveAndScale(
            charPath, 0.0, 0.0, yScaleFactor, -yScaleFactor);

        // Apply x-position corrections to make the font monospace.
        //
        // Some chars may overlap with other chars otherwise.
        charPath = widget.style.charXPosCorrections.containsKey(string[i])
            ? PMTransform.moveAndScale(
                charPath,
                widget.style.charXPosCorrections[string[i]] * targetHeight,
                0.0,
                1.0,
                -1.0,
              )
            : charPath;

        // Apply middle spacing based on char height.
        charPath = i >= string.length / 2
            ? PMTransform.moveAndScale(charPath,
                widget.width * widget.style.middleSpacing, 0.0, 1.0, -1.0)
            : charPath;

        // Position char path.
        charPath = PMTransform.moveAndScale(
          charPath,
          i * targetHeight * widget.style.fontSpacing +
              (widget.style.xOffset * widget.width),
          0.0,
          1.0,
          -1.0,
        );

        // Add char path to string path.
        stringPath.addPath(
          charPath,
          Offset(
            0,
            0,
          ),
        );
      }

      // Center string path horizontally.
      if (widget.style.shouldCenterHorizontally) {
        final double targetXPos =
            (widget.width / 2) - (stringPath.getBounds().width / 2);
        final double xTranslation = targetXPos - stringPath.getBounds().left;
        stringPath =
            PMTransform.moveAndScale(stringPath, xTranslation, 0.0, 1.0, -1.0);
      }

      // Center string path vertically.
      if (widget.style.shouldCenterVertically) {
        final double targetYPos =
            (widget.height / 2) - (stringPath.getBounds().height / 2);
        final double yTranslation = targetYPos - stringPath.getBounds().top;
        stringPath =
            PMTransform.moveAndScale(stringPath, 0.0, yTranslation, 1.0, -1.0);
      }

      return stringPath;
    } else {
      return Path();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.light
          ? widget.style.brightBackgroundColor
          : widget.style.darkBackgroundColor,
      child: ClipRect(
        child: CustomPaint(
          painter: DotsPainter(
            color: Theme.of(context).brightness == Brightness.light
                ? widget.style.brightColor
                : widget.style.darkColor,
            oldPath: _oldPath,
            currentPath: _currentPath,
            pulseValue: _dotPulseAnimation.value,
            grid: _dotsGrid,
            rows: _rows,
            columns: _columns,
            transitionValue: _dotTransitionAnimation.value,
            spacing: widget.style.dotSpacing,
            activeScale: widget.style.dotActiveScale,
          ),
        ),
      ),
    );
  }
}

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
    @required this.activeScale,
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
  final double spacing;

  /// Maximum scale of an active dot.
  final double activeScale;

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
        double radius = sin(grid[i][j] + pulseValue);

        // Paint dots differently based on their state:
        if (oldPath != null && currentPath != null) {
          // Dot is at inactive -> active state (transition scale down animation)
          if (oldPath.contains(offset) && !currentPath.contains(offset)) {
            radius = radius * transitionValue.clamp(1, activeScale);
          }

          // Dot is at inactive -> active state (transition scale up animation)
          if (!oldPath.contains(offset) && currentPath.contains(offset)) {
            radius = (radius * (activeScale - transitionValue)).abs();
            //.clamp(1.0, 10.0);
          }

          // Dot is at inactive state (idle at base scale)
          if (!oldPath.contains(offset) && !currentPath.contains(offset)) {
            radius = radius;
          }

          // Dot is at active state (idle at activeScale)
          if (oldPath.contains(offset) && currentPath.contains(offset)) {
            radius = (radius * activeScale).abs(); //.clamp(1.0, 10.0);
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
        oldDelegate.activeScale != activeScale;
  }
}
