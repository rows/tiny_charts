import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

import 'utils.dart';

var _kAxisLayoutId = 'axis';

/// Default [TinyColumnChartOptions] for [new TinyColumnChart] and
/// [TinyColumnChart.fromDataVectors].
const kDefaultColumnChartOptions = TinyColumnChartOptions(
  positiveColor: Color(0xFF27A083),
  negativeColor: Color(0xFFE92F3C),
);

/// A [Widget] that paints a simple column chart.
///
/// It is ideal for sparkline charts.
///
/// The data can be provided by a list of double values by `vector_math`'s
/// [Vector2]. Then that is the case, the x value in each vector represents the
/// column order and the y represents the value.
///
/// The chart renders each column with its respective value. Negative columns
/// are rendered in a specific color with (if specified) an axis line in thee
/// position equal to zero.
///
/// If both [width] and [height] are passed, the chart will try to keep aspect
/// ratio.
///
/// To customize things like column colors and axis line visibility, see
/// [options].
///
/// See also:
/// - [new TinyColumnChart] to build a column chart based on a list of numbers.
/// = [TinyColumnChart.fromDataVectors]  to build a column chart based on a
/// list of [Vector2].
/// - [TinyColumnChartOptions] for more details on options.
class TinyColumnChart extends StatefulWidget {
  /// A set of options to customize the chart display, defaults to
  /// [kDefaultColumnChartOptions] when null on construction.
  final TinyColumnChartOptions options;

  /// The set of vectors that represents the columns data.
  final Iterable<Vector2> dataPoints;

  /// If non-null, require the chart to have this width.
  final double? width;

  /// If non-null, require the chart to have this height.
  final double? height;

  /// Creates a [TinyColumnChart] from a [Iterable] of [double].
  ///
  /// [dataPoints] will be converted and saved into [TinyLineChart.dataPoints]
  /// as a [Vector2] list.
  ///
  /// See also:
  /// = [TinyColumnChart.fromDataVectors]  to build a column chart based on a
  /// list of [Vector2].
  factory TinyColumnChart({
    Key? key,
    required Iterable<double> data,
    TinyColumnChartOptions? options,
    double? width,
    double? height,
  }) {
    return TinyColumnChart.fromDataVectors(
      key: key,
      dataPoints: <Vector2>[
        for (var index = 0; index < data.length; index++)
          Vector2(index.toDouble(), data.elementAt(index))
      ],
      options: options,
      width: width,
      height: height,
    );
  }

  /// Creates a [TinyLineChart] from a [Iterable] of [Vector2].
  ///
  /// The x value in each vector represents the column order and the
  /// y represents its value.
  const TinyColumnChart.fromDataVectors({
    Key? key,
    required this.dataPoints,
    TinyColumnChartOptions? options,
    this.width,
    this.height,
  })  : options = options ?? kDefaultColumnChartOptions,
        super(key: key);

  @override
  State<TinyColumnChart> createState() => _TinyColumnChartState();
}

class _TinyColumnChartState extends State<TinyColumnChart> {
  late List<Vector2> sortedColumns;
  late double positiveAxisHeight;
  double lowestValue = double.infinity;
  double highestValue = -double.infinity;

  @override
  void initState() {
    super.initState();
    updateColumns();
  }

  @override
  void didUpdateWidget(covariant TinyColumnChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateColumns();
  }

  void updateColumns() {
    final sortedColumns = widget.dataPoints.toList()
      ..sort(
        (a, b) => a.x.compareTo(b.x),
      );

    var lowestValue = double.infinity;
    var highestValue = -double.infinity;
    final lowColor = widget.options.lowestColor;
    final highColor = widget.options.highestColor;

    // Only compute the boundary values when boundary colors are specified.
    if (lowColor != null || highColor != null) {
      for (final column in sortedColumns) {
        lowestValue = min(lowestValue, column.y);
        highestValue = max(highestValue, column.y);
      }
    }

    setState(() {
      this.sortedColumns = sortedColumns;
      this.lowestValue = lowestValue;
      this.highestValue = highestValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _TinyColumnChartLayoutDelegate(
        sortedColumns: sortedColumns,
        width: widget.width,
        height: widget.height,
        options: widget.options,
      ),
      children: [
        for (int index = 0; index < sortedColumns.length; index++)
          LayoutId(
            id: index,
            child: Tooltip(
              message: sortedColumns.elementAt(index).y.toStringAsFixed(2),
              child: CustomPaint(
                painter: _TinyColumnChartPaintDelegate(
                  options: widget.options,
                  dataPoint: sortedColumns.elementAt(index),
                  index: index,
                  columnsCount: sortedColumns.length,
                  lowestValue: lowestValue,
                  highestValue: highestValue,
                ),
              ),
            ),
          ),
        if (widget.options.showAxis == true)
          LayoutId(
            id: _kAxisLayoutId,
            child: ColoredBox(
              color: widget.options.axisColor,
            ),
          )
      ],
    );
  }
}

class _TinyColumnChartLayoutDelegate extends MultiChildLayoutDelegate {
  final double? width;
  final double? height;
  final Iterable<Vector2> sortedColumns;
  final TinyColumnChartOptions options;
  late final Aabb2 limits;

  _TinyColumnChartLayoutDelegate({
    required this.sortedColumns,
    required this.options,
    this.width,
    this.height,
  }) {
    limits = getEffectiveLimits();
  }

  double positiveSpaceHeight = 0;
  double negativeSpaceHeight = 0;

  /// Get he effective limits given the limits recovered from the data points
  /// passed to [options].
  Aabb2 getEffectiveLimits() {
    final dataLimits = aabb2FromVectors(sortedColumns) ?? Aabb2();
    var minLimit = options.minLimit ?? dataLimits.min.y;

    var maxLimit = options.maxLimit ?? dataLimits.max.y;

    if (minLimit > maxLimit) {
      minLimit = 0;
      maxLimit = 0;
    }

    return Aabb2.minMax(
      Vector2(0, minLimit),
      Vector2(0, maxLimit),
    );
  }

  @override
  Size getSize(BoxConstraints constraints) {
    final width = this.width;
    final height = this.height;

    final size = defineTinyChartSize(
      constraints: constraints,
      width: width,
      height: height,
    );
    definePositiveAndNegativeSpaces(size);
    return size;
  }

  /// From the actual widget size, define which portion of that is occupied by
  /// either psitive and negative columns.
  void definePositiveAndNegativeSpaces(Size size) {
    final positiveAxisSize = max(0.0, limits.max.y);
    final negativeAxisSize = min(limits.min.y, 0.0).abs();

    final dataExtent = positiveAxisSize + negativeAxisSize;

    if (dataExtent == 0) {
      positiveSpaceHeight = 0;
      negativeSpaceHeight = 0;
      return;
    }

    final positiveAxisPercentage = positiveAxisSize / dataExtent;
    final negativeAxisPercentage = negativeAxisSize / dataExtent;

    positiveSpaceHeight = positiveAxisPercentage * size.height;
    negativeSpaceHeight = negativeAxisPercentage * size.height;
  }

  /// Define the height of a [column] given the current [positiveSpaceHeight]
  /// and [negativeSpaceHeight].
  double getColumnHeight(Vector2 column) {
    final minLimit = limits.min.y;
    final maxLimit = limits.max.y;
    if (minLimit == 0 && maxLimit == 0) {
      return 0;
    }

    final value = column.y;

    if (positiveSpaceHeight > 0 && value > 0) {
      if (value >= maxLimit) {
        return positiveSpaceHeight;
      }
      if (value == minLimit) {
        return 1;
      }
      if (value < minLimit) {
        return 0;
      }

      final positiveMin = max(0.0, minLimit);
      final positiveMax = max(0.0, maxLimit);

      return calculatePhysicalPositionFromDataPosition(
        dataPoint: value,
        dataSpaceStart: positiveMin,
        dataSpaceEnd: positiveMax,
        physicalExtent: positiveSpaceHeight,
      );
    }

    if (negativeSpaceHeight > 0 && value < 0) {
      if (value <= minLimit) {
        return -negativeSpaceHeight;
      }
      if (value == maxLimit) {
        return -1;
      }
      if (value > maxLimit) {
        return 0;
      }

      final negativeMin = min(0.0, minLimit);
      final negativeMax = min(0.0, maxLimit);

      return -calculatePhysicalPositionFromDataPosition(
        dataPoint: value.abs(),
        dataSpaceStart: negativeMax.abs(),
        dataSpaceEnd: negativeMin.abs(),
        physicalExtent: negativeSpaceHeight,
      );
    }

    return 0;
  }

  @override
  void performLayout(Size size) {
    if (sortedColumns.isEmpty) {
      return;
    }

    final width = size.width;
    final isSingleColumn = sortedColumns.length == 1;
    final columnWidth =
        isSingleColumn ? width : (width * 0.8) / sortedColumns.length;

    final spacingWidth =
        isSingleColumn ? 0 : (width * 0.2) / (sortedColumns.length - 1);

    // Layout and position each column
    for (var index = 0; index < sortedColumns.length; index++) {
      final column = sortedColumns.elementAt(index);
      final columnHeight = getColumnHeight(column);

      layoutChild(
        index,
        BoxConstraints.tightFor(width: columnWidth, height: columnHeight.abs()),
      );

      // Get the vertical position of the column given its height.
      final y = column.y <= 0
          ? positiveSpaceHeight
          : positiveSpaceHeight - columnHeight;

      positionChild(
        index,
        Offset(index * (columnWidth + spacingWidth), y),
      );
    }

    // Layout and position the axis line if specified by options
    if (options.showAxis == true) {
      layoutChild(
        _kAxisLayoutId,
        BoxConstraints.tightFor(width: size.width, height: 1),
      );
      positionChild(
        _kAxisLayoutId,
        Offset(0, positiveSpaceHeight.clamp(0, (size.height - 1).abs())),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return oldDelegate is! _TinyColumnChartLayoutDelegate ||
        runtimeType != oldDelegate.runtimeType ||
        width != oldDelegate.width ||
        height == oldDelegate.height ||
        !kIterableVectorEquality.equals(
          sortedColumns,
          oldDelegate.sortedColumns,
        ) ||
        options == oldDelegate.options;
  }
}

@immutable
class _TinyColumnChartPaintDelegate extends CustomPainter {
  final TinyColumnChartOptions options;

  final Vector2 dataPoint;
  final int index;

  final int columnsCount;
  final double lowestValue;
  final double highestValue;

  const _TinyColumnChartPaintDelegate({
    required this.options,
    required this.dataPoint,
    required this.index,
    required this.columnsCount,
    required this.lowestValue,
    required this.highestValue,
  });

  Color get color {
    final value = dataPoint.y;

    final lowColor = options.lowestColor;
    if (lowColor != null && value <= lowestValue) {
      return lowColor;
    }

    final highColor = options.highestColor;
    if (highColor != null && value >= highestValue) {
      return highColor;
    }

    final firstColor = options.firstColor;
    if (firstColor != null && index == 0) {
      return firstColor;
    }

    final lastColor = options.lastColor;
    if (lastColor != null && index == columnsCount - 1) {
      return lastColor;
    }

    if (value < 0) {
      return options.negativeColor;
    }

    return options.positiveColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );

    canvas.drawRect(rect, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return this != oldDelegate;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TinyColumnChartPaintDelegate &&
          runtimeType == other.runtimeType &&
          options == other.options &&
          dataPoint == other.dataPoint &&
          index == other.index &&
          columnsCount == other.columnsCount &&
          lowestValue == other.lowestValue &&
          highestValue == other.highestValue;

  @override
  int get hashCode =>
      options.hashCode ^
      dataPoint.hashCode ^
      index.hashCode ^
      columnsCount.hashCode ^
      lowestValue.hashCode ^
      highestValue.hashCode;
}

/// A set of options to customize a [TinyColumnChart] display.
///
/// ## Limits
/// Specify [yminLimit], [maxLimit] to customize the data space in which the
/// chart will paint.
///
/// Any of these parameters, when omitted, will default to the minimum or
/// maximum y value in the coordinates passed to [TinyColumnChart.dataPoints].
///
/// See also:
/// - [TinyColumnChart.options] the field that receives these options.
@immutable
class TinyColumnChartOptions {
  /// Customize the data space in which the chart will paint.
  ///
  /// This marks the starting point of the data in which the chart paints in
  /// the vertical axis.
  ///
  /// If omitted, defaults to the lowest y found in the data points passed
  /// to [TinyColumnChart.dataPoints].
  final double? minLimit;

  /// Customize the data space in which the chart will paint.
  ///
  /// This marks the trailing point of the data in which the chart paints in
  /// the vertical axis.
  ///
  /// If omitted, defaults to the highest y found in the data points passed
  /// to [TinyColumnChart.dataPoints].
  final double? maxLimit;

  /// The default color of columns with positive values.
  ///
  /// Fallback to [lowestColor], [highestColor], [firstColor] and [lastColor].
  final Color positiveColor;

  /// The default color of columns with negative values.
  ///
  /// Fallback to [lowestColor], [highestColor], [firstColor] and [lastColor].
  final Color negativeColor;

  /// The color of columns with values equals or smaller than [minLimit] or the
  /// lowest y value on [TinyColumnChart.dataPoints]
  ///
  /// Takes precedence over [highestColor], [firstColor], [lastColor],
  /// [negativeColor] and [positiveColor].
  final Color? lowestColor;

  /// The color of columns with values equals or bigger than [maxLimit] or the
  /// highest y value on [TinyColumnChart.dataPoints]
  ///
  /// Takes precedence over [firstColor], [lastColor], [negativeColor]
  /// and [positiveColor].
  final Color? highestColor;

  /// The color of the fist column.
  ///
  /// Takes precedence over [lastColor], [negativeColor] and [positiveColor].
  final Color? firstColor;

  /// The color of the last column.
  ///
  /// Takes precedence over [negativeColor] and [positiveColor].
  final Color? lastColor;

  /// Defines if the line representing the x axis should be painted.
  ///
  /// Defaults to `false`.
  final bool showAxis;

  /// The color of the axis line, if visible.
  ///
  /// Defaults to black.
  final Color axisColor;

  const TinyColumnChartOptions({
    this.minLimit,
    this.maxLimit,
    required this.positiveColor,
    required this.negativeColor,
    this.lowestColor,
    this.highestColor,
    this.firstColor,
    this.lastColor,
    this.showAxis = false,
    this.axisColor = const Color(0xFF000000),
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TinyColumnChartOptions &&
          runtimeType == other.runtimeType &&
          minLimit == other.minLimit &&
          maxLimit == other.maxLimit &&
          positiveColor == other.positiveColor &&
          lowestColor == other.lowestColor &&
          highestColor == other.highestColor &&
          firstColor == other.firstColor &&
          lastColor == other.lastColor &&
          negativeColor == other.negativeColor &&
          showAxis == other.showAxis &&
          axisColor == other.axisColor;

  @override
  int get hashCode =>
      minLimit.hashCode ^
      maxLimit.hashCode ^
      positiveColor.hashCode ^
      lowestColor.hashCode ^
      highestColor.hashCode ^
      firstColor.hashCode ^
      lastColor.hashCode ^
      negativeColor.hashCode ^
      showAxis.hashCode ^
      axisColor.hashCode;
}
