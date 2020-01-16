import 'package:fast_noise/fast_noise.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';

import 'package:flutter_clock_helper/model.dart';
import 'package:text_to_path_maker/text_to_path_maker.dart';

final PerlinNoise perlinNoise = PerlinNoise(
  octaves: 4,
  frequency: 0.35,
);

// Correcting the x-position of certain characters since the font is not monospaced
final Map<String, double> charPathOffset = <String, double>{
  "1": 150.0,
  "7": 70.0,
};

class DotsClock extends StatefulWidget {
  final ClockModel model;
  final double dotSpacing;
  final double dotActiveScale;

  const DotsClock(
    this.model, {
    this.dotSpacing: 6.5,
    this.dotActiveScale: 3,
  });

  @override
  State<StatefulWidget> createState() => DotsClockState();
}

class DotsClockState extends State<DotsClock> with TickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  List<List<double>> dotGrid;
  int rows = 39;
  int columns = 64;

  PMFont _targetFont;

  Path _currentPath;
  Path _oldPath;

  AnimationController _dotPulseController;
  Animation<double> _dotPulseAnimation;

  AnimationController _dotTransitionController;
  Animation<double> _dotTransitionAnimation;

  // DotsClockState({
  //   @required this.rows,
  //   @required this.columns,
  //   @required this.dotSpacing,
  //   @required this.dotActiveScale,
  // });

  @override
  void initState() {
    super.initState();
    _dotPulseController = AnimationController(
        duration: Duration(milliseconds: 10000), vsync: this);
    _dotPulseAnimation = Tween(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(
        curve: Curves.linear,
        parent: _dotPulseController,
      ),
    )..addListener(() => setState(() {}));

    _dotPulseController.repeat();

    _dotTransitionController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    _dotTransitionAnimation =
        Tween(begin: widget.dotActiveScale, end: 0.0).animate(
      CurvedAnimation(
        curve: Curves.linear,
        parent: _dotTransitionController,
      ),
    )..addListener(() => setState(() {}));
    widget.model.addListener(_updateModel);
    _loadFont();
    _initDotsGrid();
    _updateTime();
    _updateModel();
  }

  @override
  void didChangeDependencies() {
    rows = (MediaQuery.of(context).size.height / widget.dotSpacing).floor();
    columns = (MediaQuery.of(context).size.width / widget.dotSpacing).floor();
    _initDotsGrid();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _dotPulseController.dispose();
    _dotTransitionController.dispose();
    super.dispose();
  }

  void _loadFont() async {
    ByteData data = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");
    PMFontReader reader = PMFontReader();
    _targetFont = reader.parseTTFAsset(data);
  }

  void _updatePath(String time) {
    _oldPath = _currentPath;
    if (_targetFont != null) {
      _currentPath = _buildClockFacePath(time);
    }
  }

  Path _buildClockFacePath(String string) {
    Path stringPath = Path();

    for (int i = 0; i < string.length; i++) {
      Path charPath =
          _targetFont.generatePathForCharacter(string.codeUnitAt(i));

      // y-scale needs to be -1 because the method scales by minus y-scale
      charPath = charPathOffset.containsKey(string[i])
          ? PMTransform.moveAndScale(
              charPath, charPathOffset[string[i]], 0.0, 1.0, -1.0)
          : charPath;

      stringPath.addPath(
        PMTransform.moveAndScale(charPath, i * 100.0 + 20, 220.0, 0.225, 0.225),
        Offset(
          i * 50.0,
          50,
        ),
      );
    }
    return stringPath;
  }

  @override
  void didUpdateWidget(DotsClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      // _timer = Timer(
      //   Duration(minutes: 1) -
      //       Duration(seconds: _dateTime.second) -
      //       Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 4) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      final String hour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh')
          .format(_dateTime);
      final String minute = DateFormat('mm').format(_dateTime);

      _updatePath('$hour$minute');
    });
    _dotTransitionController.reset();
    _dotTransitionController.forward();
  }

  _initDotsGrid() {
    dotGrid = List.generate(
      rows,
      (int row) => List.generate(
        columns,
        (int column) {
          double noise =
              perlinNoise.getPerlin2(column.toDouble(), row.toDouble());
          double percentage = (noise + sqrt1_2) / (2 * sqrt1_2);
          double value = percentage * 2 * pi;
          return value;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_targetFont != null) {
      return LayoutBuilder(builder: (context, contraints) {
        rows = (contraints.minHeight / widget.dotSpacing).floor();
        columns = (contraints.minWidth / widget.dotSpacing).floor();
        return CustomPaint(
          painter: DotsPainter(
              oldPath: _oldPath,
              currentPath: _currentPath,
              pulseValue: _dotPulseAnimation.value,
              grid: dotGrid,
              rows: rows,
              columns: columns,
              transitionValue: _dotTransitionAnimation.value,
              spacing: widget.dotSpacing,
              activeSizeScale: widget.dotActiveScale),
        );
      });
    } else {
      return CircularProgressIndicator();
    }
  }
}

class DotsPainter extends CustomPainter {
  List<List<double>> grid;
  Path oldPath;
  Path currentPath;
  double pulseValue;
  double transitionValue;
  double spacing;
  double activeSizeScale;
  int rows;
  int columns;

  DotsPainter({
    this.oldPath,
    this.currentPath,
    @required this.grid,
    @required this.rows,
    @required this.columns,
    @required this.pulseValue,
    @required this.transitionValue,
    @required this.spacing,
    @required this.activeSizeScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        Offset offset = Offset(j * spacing, i * spacing);
        double radius = sin(grid[i][j] + pulseValue);

        if (oldPath != null && currentPath != null) {
          // Dot scales down to base size
          if (oldPath.contains(offset) && !currentPath.contains(offset)) {
            radius = radius * transitionValue.clamp(1, activeSizeScale);
          }

          // Dot scales up active size
          if (!oldPath.contains(offset) && currentPath.contains(offset)) {
            radius = (radius * (activeSizeScale - transitionValue)).abs();
            //.clamp(1.0, 10.0);
          }

          // Dot is at inactive size
          if (!oldPath.contains(offset) && !currentPath.contains(offset)) {
            radius = radius;
          }

          // Dot is at active size
          if (oldPath.contains(offset) && currentPath.contains(offset)) {
            radius = (radius * activeSizeScale).abs(); //.clamp(1.0, 10.0);
          }
        }

        canvas.drawOval(
          Rect.fromCircle(center: offset, radius: radius),
          Paint(),
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
