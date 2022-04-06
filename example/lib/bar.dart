import 'package:dashbook/dashbook.dart';
import 'package:flutter/widgets.dart';
import 'package:tiny_charts/tiny_charts.dart';
import 'package:vector_math/vector_math.dart';

import 'common.dart';

void addBarChartStories(Dashbook dashbook) {
  dashbook.storiesOf('Tiny Bar Chart')
    ..add('Single value', single)
    ..add('Stacked values', stacked)
    ..add('Stacked vectors', stackedVectors)
    ..add('Stacked values playground', stackedPlayground)
    ..add('Stacked values options playground', stackedOptionsPlayground);
}

Widget single(DashbookContext context) {
  return DemoStage(
    child: TinyBarChart.single(
      value: 68,
      max: 100,
      color: context.colorProperty('color', const Color(0xFF236536)),
      width: context.numberProperty('width', 120),
      height: context.numberProperty('height', 28),
    ),
  );
}

Widget stacked(DashbookContext context) {
  return DemoStage(
    child: TinyBarChart.stacked(
      data: const <double>[4, 20, 14],
      width: context.numberProperty('width', 120),
      height: context.numberProperty('height', 28),
    ),
  );
}

Widget stackedVectors(DashbookContext context) {
  return DemoStage(
    child: TinyBarChart.stackedFromDataVectors(
      dataPoints: <Vector2>[
        Vector2(2, 20),
        Vector2(0, 4),
        Vector2(4, 14),
      ],
      width: context.numberProperty('width', 120),
      height: context.numberProperty('height', 28),
    ),
  );
}

Widget stackedPlayground(DashbookContext context) {
  return DemoStage(
    child: TinyBarChart.stacked(
      data: <double>[
        context.numberProperty('1st option', 4),
        context.numberProperty('2nd option', 20),
        context.numberProperty('3rd option', 14),
      ],
      width: context.numberProperty('width', 120),
      height: context.numberProperty('height', 28),
    ),
  );
}

Widget stackedOptionsPlayground(DashbookContext context) {
  return DemoStage(
    child: TinyBarChart.stacked(
      data: const <double>[4, 20, 14, 1, 12, 9],
      options: TinyBarChartOptions(
        colors: [
          context.colorProperty('color 1', const Color(0xFF310813)),
          context.colorProperty('color 2', const Color(0xFFF8EC08)),
          context.colorProperty('color 3', const Color(0xFF22AF99)),
        ],
        max: context.numberProperty('max', 100),
      ),
      width: context.numberProperty('width', 220),
      height: context.numberProperty('height', 28),
    ),
  );
}
