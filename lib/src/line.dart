import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart';

import 'utils.dart';

/// Default [TinyLineChartOptions] for [new TinyLineChart] and
/// [TinyLineChart.fromDataVectors].
const kDefaultLineChartOptions = TinyLineChartOptions(
  color: Color(0xFF000000),
  lineWidth: 1,
);

/// A [Widget] that paints a simple line chart.
///
/// It is ideal for sparkline charts.
///
/// The data can be provided by a list of coordinates that can be
/// represented by either flutter's [Offset] or by `vector_math`'s [Vector2].
///
/// The line will be draw using [dataPoints] as vertices. The data space to be
/// painted by the chart can be bounded by passing the limits to [options].
///
/// For example, if [options.xMaxLimit] is passed, the line chart will be
/// painted in such a way that any data point beyond that limit will not be
/// painted.
///
/// If both [width] and [height] are passed, the chart will try to keep aspect
/// ratio.
///
/// See also:
///  - [new TinyLineChart] to build a line chart using [Offset]
///  - [TinyLineChart.fromDataVectors] to build a line chart using [Vector2]
///  - [TinyLineChartOptions] for more details on options.
class TinyLineChart extends StatelessWidget {
  /// A set of options to customize the chart display, defaults to
  /// [kDefaultLineChartOptions] when null on construction.
  final TinyLineChartOptions options;

  /// The set of coordinates that represents the vertices of the line path.
  final Iterable<Vector2> dataPoints;

  /// If non-null, require the chart to have this width.
  final double? width;

  /// If non-null, require the chart to have this height.
  final double? height;

  /// Creates a [TinyLineChart] from a [Iterable] of [Offset].
  ///
  /// [dataPoints] will be converted and saved into [TinyLineChart.dataPoints]
  /// as a [Vector2] list.
  factory TinyLineChart({
    Key? key,
    required Iterable<Offset> dataPoints,
    TinyLineChartOptions? options,
    double? width,
    double? height,
  }) {
    return TinyLineChart.fromDataVectors(
      key: key,
      dataPoints: dataPoints.map((point) => Vector2(point.dx, point.dy)),
      options: options,
      width: width,
      height: height,
    );
  }

  /// Creates a [TinyLineChart] from a [Iterable] of [Vector2].
  const TinyLineChart.fromDataVectors({
    Key? key,
    required this.dataPoints,
    TinyLineChartOptions? options,
    this.width,
    this.height,
  })  : options = options ?? kDefaultLineChartOptions,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: _TinyLineChartPaintDelegate(
            dataPoints: dataPoints,
            options: options,
          ),
          size: defineTinyChartSize(
            constraints: constraints,
            width: width,
            height: height,
          ),
        );
      },
    );
  }
}

/// A [CustomPainter] that paints a [Path] connecting each element of
/// [dataPoints] in a space delimited by the values itself or the limits
/// specified by [TinyLineChartOptions]
@immutable
class _TinyLineChartPaintDelegate extends CustomPainter {
  final TinyLineChartOptions options;
  final Iterable<Vector2> dataPoints;

  const _TinyLineChartPaintDelegate({
    required this.options,
    required this.dataPoints,
  });

  /// Convert a [Vector2] that represents a data point with data values to an
  /// offset that actually represents the relative pixel coordinate in the
  /// canvas.
  Offset vectorToOffset(
    Vector2 value,
    Aabb2 limits,
    Size size,
  ) {
    final relative = (value - limits.min)..divide(limits.max - limits.min);

    late double x;
    if (limits.min.x == limits.max.x) {
      x = size.width / 2;
    } else {
      x = size.width * relative.x;
    }

    late double y;
    if (limits.min.y == limits.max.y) {
      y = size.height / 2;
    } else {
      y = size.height - (size.height * relative.y);
    }

    return Offset(x, y);
  }

  /// Get he effective limits given the limits recovered from the data points
  /// passed to [options].
  Aabb2 getEffectiveLimits() {
    final dataLimits = aabb2FromVectors(dataPoints) ?? Aabb2();

    var xMin = options.xMinLimit ?? dataLimits.min.x;
    var yMin = options.yMinLimit ?? dataLimits.min.y;

    var xMax = options.xMaxLimit ?? dataLimits.max.x;
    var yMax = options.yMaxLimit ?? dataLimits.max.y;

    // When max and min limits clash between options and data,
    // reduce everything from that axis to zero.

    if (xMin > xMax) {
      xMin = 0;
      xMax = 0;
    }

    if (yMin > yMax) {
      yMin = 0;
      yMax = 0;
    }

    return Aabb2.minMax(
      Vector2(xMin, yMin),
      Vector2(xMax, yMax),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) {
      return;
    }

    final limits = getEffectiveLimits();

    final dataOffsets = dataPoints
        .map<Offset>((dataPoint) => vectorToOffset(dataPoint, limits, size));

    final initialOffset = dataOffsets.first;
    final path = Path()..moveTo(initialOffset.dx, initialOffset.dy);

    for (final dataOffset in dataOffsets) {
      path.lineTo(dataOffset.dx, dataOffset.dy);
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = options.lineWidth
      ..color = options.color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TinyLineChartPaintDelegate &&
          runtimeType == other.runtimeType &&
          options == other.options &&
          kIterableVectorEquality.equals(dataPoints, other.dataPoints);

  @override
  int get hashCode => options.hashCode ^ dataPoints.hashCode;
}

/// A set of options to customize a [TinyLineChart] display.
///
/// ## Limits
/// Specify [xMinLimit], [yMinLimit], [xMaxLimit] or [yMaxLimit] to customize
/// the data space in which the chart will paint.
///
/// Any of these parameters, when omitted, will default to the minimum or
/// maximum value in the coordinates passed to [TinyLineChart.dataPoints].
///
/// See also:
/// - [TinyLineChart.options] the field that receives these options.
@immutable
class TinyLineChartOptions {
  /// Customize the data space in which the chart will paint.
  ///
  /// This marks the starting point of the data in which the chart paints in
  /// the horizontal axis.
  ///
  /// If omitted, defaults to the lowest x found in the data points passed
  /// to [TinyLineChart.dataPoints].
  final double? xMinLimit;

  /// Customize the data space in which the chart will paint.
  ///
  /// This marks the starting point of the data in which the chart paints in
  /// the vertical axis.
  ///
  /// If omitted, defaults to the lowest y found in the data points passed
  /// to [TinyLineChart.dataPoints].
  final double? yMinLimit;

  /// Customize the data space in which the chart will paint.
  ///
  /// This marks the trailing point of the data in which the chart paints in
  /// the horizontal axis.
  ///
  /// If omitted, defaults to the highest x found in the data points passed
  /// to [TinyLineChart.dataPoints].
  final double? xMaxLimit;

  /// Customize the data space in which the chart will paint.
  ///
  /// This marks the trailing point of the data in which the chart paints in
  /// the vertical axis.
  ///
  /// If omitted, defaults to the highest y found in the data points passed
  /// to [TinyLineChart.dataPoints].
  final double? yMaxLimit;

  /// Customize the line color.
  final Color color;

  /// Customize the width of the line.
  final double lineWidth;

  const TinyLineChartOptions({
    this.xMinLimit,
    this.yMinLimit,
    this.xMaxLimit,
    this.yMaxLimit,
    required this.color,
    required this.lineWidth,
  })  : assert(
          xMinLimit == null || xMaxLimit == null || xMinLimit <= xMaxLimit,
        ),
        assert(
          yMinLimit == null || yMaxLimit == null || yMinLimit <= yMaxLimit,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TinyLineChartOptions &&
          runtimeType == other.runtimeType &&
          xMinLimit == other.xMinLimit &&
          xMaxLimit == other.xMaxLimit &&
          yMinLimit == other.yMinLimit &&
          yMaxLimit == other.yMaxLimit &&
          color == other.color &&
          lineWidth == other.lineWidth;

  @override
  int get hashCode =>
      xMinLimit.hashCode ^
      xMaxLimit.hashCode ^
      yMinLimit.hashCode ^
      yMaxLimit.hashCode ^
      color.hashCode ^
      lineWidth.hashCode;
}
