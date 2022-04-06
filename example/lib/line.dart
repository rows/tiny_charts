import 'package:dashbook/dashbook.dart';
import 'package:flutter/widgets.dart';
import 'package:tiny_charts/tiny_charts.dart';
import 'package:vector_math/vector_math.dart';

import 'common.dart';

void addLineChartStories(Dashbook dashbook) {
  dashbook
      .storiesOf('Tiny Line Chart')
      .add('Simple', simple)
      .add('Data playground', dataPlayground)
      .add('Options playground', optionsPlayground);
}

Widget simple(DashbookContext context) {
  return DemoStage(
    child: TinyLineChart(
      width: 100,
      height: 28,
      dataPoints: const [
        Offset(0, 2),
        Offset(1, 11),
        Offset(2, 17),
        Offset(2.5, 0),
        Offset(3, 10),
        Offset(4, 24),
      ],
    ),
  );
}

Widget dataPlayground(DashbookContext context) {
  return DemoStage(
    child: TinyLineChart(
      width: context.numberProperty('width', 120),
      height: context.numberProperty('height', 28),
      dataPoints: {
        Offset(
          context.numberProperty('1st x', 0),
          context.numberProperty('1st y', 12),
        ),
        Offset(
          context.numberProperty('2nd  x', 1),
          context.numberProperty('2nd y', 11),
        ),
        Offset(
          context.numberProperty('3rd x', 2),
          context.numberProperty('3rd y', 17),
        ),
        Offset(
          context.numberProperty('4th x', 3),
          context.numberProperty('4th y', 5),
        ),
        Offset(
          context.numberProperty('5th x', 4),
          context.numberProperty('5th y', 22),
        ),
        Offset(
          context.numberProperty('6th x', 5),
          context.numberProperty('6th y', 19),
        ),
      },
    ),
  );
}

Widget optionsPlayground(DashbookContext context) {
  return DemoStage(
    child: TinyLineChart.fromDataVectors(
      width: context.numberProperty('width', 120),
      height: context.numberProperty('height', 28),
      options: TinyLineChartOptions(
        color: context.colorProperty(
          'color',
          const Color(0xFFD72282),
        ),
        lineWidth: context.numberProperty('lineWidth', 1),
        xMinLimit: context.numberProperty('xMinLimit', 0),
        xMaxLimit: context.numberProperty('xMaxLimit', 5),
        yMinLimit: context.numberProperty('yMinLimit', 5),
        yMaxLimit: context.numberProperty('yMaxLimit', 22),
      ),
      dataPoints: [
        Vector2(0, 12),
        Vector2(1, 11),
        Vector2(2, 17),
        Vector2(3, 5),
        Vector2(4, 22),
        Vector2(5, 19),
      ],
    ),
  );
}
