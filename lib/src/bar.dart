import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

import 'utils.dart';

/// Default [TinyBarChartOptions] for [TinyBarChart.stacked] and
/// [TinyBarChart.stackedFromDataVectors].
const kDefaultBarChartOptions = TinyBarChartOptions(
  colors: [Color(0xFF000000), Color(0x55000000)],
);

/// A [Widget] that paints a simple bar chart.
///
/// It is ideal for sparkline charts.
///
/// The chart can be [TinyBarChart.single] or [TinyBarChart.stacked].
/// For stacked, it is also possible to pass the data in raw vectors by using
/// [TinyBarChart.stackedFromDataVectors].
///
/// The chart is rendered with a series of bars each representing the y value
/// of each element [dataPoints]. The bars are sorted by the x values.
///
/// The bars are rendered side by side (stacked).
///
/// The width of each bar represents the percentage of space occupied by the
/// data point value in a data space between zero and the "max" value.
/// The "max" value is equal to [options.max] or, when null, the sum of all
/// bar values.
///
/// If both [width] and [height] are passed, the chart will try to keep aspect
/// ratio.
///
/// See also:
/// - [TinyBarChart.single] to build a bar chart that represents only one value.
/// - [TinyBarChart.stacked] To build a bar chart of stacked bars.
/// - [TinyBarChart.stackedFromDataVectors] To build a stacked bar chart from
///   raw [Vector2].
///  - [TinyBarChartOptions] for more details on options.
class TinyBarChart extends StatelessWidget {
  /// A set of options to customize the chart display, defaults to
  /// [kDefaultBarChartOptions] when null on construction.
  final TinyBarChartOptions options;

  /// The set of vectors that represents the bars data.
  final Iterable<Vector2> dataPoints;

  /// If non-null, require the chart to have this width.
  final double? width;

  /// If non-null, require the chart to have this height.
  final double? height;

  /// Creates a [TinyBarChart] that represents the percentage of [value] in
  /// relation to [max].
  ///
  /// Defines a single element to [dataPoints] based on [value] and creates a
  /// [TinyBarChartOptions] based on [max] and [color].
  ///
  /// [color] defaults to [kDefaultBarChartOptions].colorOdd
  ///
  /// See also:
  /// - [TinyBarChart.stacked] To build a bar chart of stacked bars.
  /// - [TinyBarChart.stackedFromDataVectors] To build a stacked bar chart from
  ///   raw [Vector2].
  factory TinyBarChart.single({
    Key? key,
    required double value,
    required double max,
    Color? color,
    double? width,
    double? height,
  }) {
    return TinyBarChart.stackedFromDataVectors(
      key: key,
      dataPoints: <Vector2>[
        Vector2(0, value),
      ],
      options: TinyBarChartOptions(
        max: max,
        colors: <Color>[color ?? kDefaultBarChartOptions.colors.first],
      ),
      width: width,
      height: height,
    );
  }

  /// Creates a [TinyBarChart] that represents the bars defined by [data].
  ///
  /// The width of each bar represents the percentage of space occupied by the
  /// data point value in a data space between zero and the "max" value.
  ///
  /// The "max" value is equal to [options.max] or, when null, the sum of all
  /// bar values.
  ///
  /// [options] defaults to [kDefaultBarChartOptions]
  ///
  /// See also:
  /// - [TinyBarChart.stackedFromDataVectors] To build a stacked bar chart from
  ///   raw [Vector2].
  /// - [TinyBarChart.single] to build a bar chart that represents only one
  /// value.
  factory TinyBarChart.stacked({
    Key? key,
    required Iterable<double> data,
    TinyBarChartOptions? options,
    double? width,
    double? height,
  }) {
    return TinyBarChart.stackedFromDataVectors(
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

  /// Just like [TinyBarChart.stacked] except the data is represented by a
  /// list of [Vector2].
  ///
  /// For each bar is based on a [Vector2], the x value represents the order of
  /// the data and the y value represents the actual value of the bar.
  ///
  /// See also:
  /// - [TinyBarChart.stacked] To build a bar chart of stacked bars.
  /// - [TinyBarChart.single] to build a bar chart that represents only one
  /// value.
  const TinyBarChart.stackedFromDataVectors({
    Key? key,
    required this.dataPoints,
    TinyBarChartOptions? options,
    this.width,
    this.height,
  })  : options = options ?? kDefaultBarChartOptions,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _TinyBarChartLayoutDelegate(
        dataPoints: dataPoints,
        width: width,
        height: height,
        options: options,
      ),
      children: [
        for (int index = 0; index < dataPoints.length; index++)
          LayoutId(
            id: index,
            child: Tooltip(
              message: dataPoints.elementAt(index).y.toStringAsFixed(2),
              child: ColoredBox(
                color: options.colors.elementAt(index % options.colors.length),
              ),
            ),
          )
      ],
    );
  }
}

class _TinyBarChartLayoutDelegate extends MultiChildLayoutDelegate {
  final double? width;
  final double? height;
  final Iterable<Vector2> dataPoints;
  final TinyBarChartOptions options;

  _TinyBarChartLayoutDelegate({
    required this.dataPoints,
    required this.width,
    required this.height,
    required this.options,
  });

  @override
  Size getSize(BoxConstraints constraints) {
    return defineTinyChartSize(
      constraints: constraints,
      width: width,
      height: height,
    );
  }

  @override
  void performLayout(Size size) {
    // First sort the data points
    final sortedDataPoints = dataPoints.toList()
      ..sort(
        (a, b) => a.x.compareTo(b.x),
      );

    // Then tet the actual max value.
    final effectiveMax = options.max ??
        sortedDataPoints.fold<double>(
          0.0,
          (previousValue, element) => previousValue + element.y.abs(),
        );

    var valueAcc = 0.0;
    var sizeAcc = 0.0;
    var index = 0;
    for (final dataPoint in sortedDataPoints) {
      // When already outside the max value, position and layout with minimal
      // dimensions.
      if (valueAcc >= effectiveMax) {
        layoutChild(index, BoxConstraints.tight(Size.zero));

        positionChild(index, Offset.zero);
        index++;
        continue;
      }

      final absY = dataPoint.y.abs();

      final double width;
      if ((valueAcc + absY) > effectiveMax) {
        // when extrapolating max, just paint the remaining space
        width = size.width - sizeAcc;
      } else {
        // get the bar value converted to pixels
        width = calculatePhysicalPositionFromDataPosition(
          dataPoint: dataPoint.y.abs(),
          dataSpaceStart: 0,
          dataSpaceEnd: effectiveMax,
          physicalExtent: size.width,
        );
      }

      layoutChild(
        index,
        BoxConstraints.tightFor(width: width, height: size.height),
      );

      positionChild(
        index,
        Offset(sizeAcc, 0.0),
      );

      valueAcc += absY;
      sizeAcc += width;
      index++;
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return oldDelegate is! _TinyBarChartLayoutDelegate ||
        oldDelegate.runtimeType != _TinyBarChartLayoutDelegate ||
        width != oldDelegate.width ||
        height != oldDelegate.height ||
        !kIterableVectorEquality.equals(dataPoints, oldDelegate.dataPoints) ||
        options.max != oldDelegate.options.max;
  }
}

/// A set of options to customize a [TinyBarChart] display.
///
/// Specify [max] to customize the data space in which the chart will paint the
/// bars.
///
/// When omitted, the chart will consider the space between zero and the sum of
/// all bar values as the as the data space.
///
/// See also:
/// - [TinyBarChart.options] the field that receives these options.
@immutable
class TinyBarChartOptions {
  /// Specify [max] to customize the data space in which the chart will paint
  /// the bars.
  ///
  /// When omitted, the chart will consider the space between zero and the sum
  /// of all bar values as the as the data space.
  final double? max;

  /// Customize the colors of bars. The color of each bar selection will cycle
  /// though this field.
  final Iterable<Color> colors;

  const TinyBarChartOptions({
    this.max,
    required this.colors,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TinyBarChartOptions &&
          runtimeType == other.runtimeType &&
          max == other.max &&
          kIterableColorEquality.equals(colors, other.colors);

  @override
  int get hashCode => max.hashCode ^ colors.hashCode;
}
