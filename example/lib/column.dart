import 'package:dashbook/dashbook.dart';
import 'package:flutter/widgets.dart';
import 'package:tiny_charts/tiny_charts.dart';
import 'package:vector_math/vector_math.dart';

import 'common.dart';

void addColumnChartStories(Dashbook dashbook) {
  dashbook.storiesOf('Tiny Column Chart')
    ..add('List of values', listOfValues)
    ..add('List of vectors', listOfVectors)
    ..add('Values playground', valuesPlayground)
    ..add('Options playground', optionsPlayground);
}

Widget listOfValues(DashbookContext context) {
  return DemoStage(
    child: TinyColumnChart(
      data: const [20, 22, 14, 12, 19, 28, -15, 11],
      width: context.numberProperty('width', 120),
      height: context.numberProperty('height', 28),
    ),
  );
}

Widget listOfVectors(DashbookContext context) {
  return DemoStage(
    child: TinyColumnChart.fromDataVectors(
      dataPoints: [
        Vector2(0, 18),
        Vector2(6, 22),
        Vector2(2, 12),
        Vector2(3, 14),
        Vector2(5, -34),
        Vector2(4, 5),
        Vector2(1, 24),
      ],
      width: context.numberProperty('width', 120),
      height: context.numberProperty('height', 28),
    ),
  );
}

Widget valuesPlayground(DashbookContext context) {
  return DemoStage(
    child: TinyColumnChart(
      data: [
        context.numberProperty('1', 18),
        context.numberProperty('2', 22),
        context.numberProperty('3', -2),
        context.numberProperty('4', 12),
        context.numberProperty('5', 14),
        context.numberProperty('6', 34),
        context.numberProperty('7', -15),
        context.numberProperty('8', 24),
      ],
      width: context.numberProperty('width', 120),
      height: context.numberProperty('height', 28),
    ),
  );
}

Widget optionsPlayground(DashbookContext context) {
  return DemoStage(
    child: TinyColumnChart(
      data: const [18, 22, -2, 32, 14, -34, -5, 24],
      width: context.numberProperty('width', 120),
      height: context.numberProperty('height', 28),
      options: TinyColumnChartOptions(
        maxLimit: context.numberProperty('maxLimit', 30),
        minLimit: context.numberProperty('minLimit', -12),
        positiveColor: context.colorProperty(
          'positiveColor',
          const Color(0xFF236536),
        ),
        negativeColor: context.colorProperty(
          'negativeColor',
          const Color(0xFFD70000),
        ),
        lowestColor: context.colorProperty(
          'lowestColor',
          const Color(0xFFAC2701),
        ),
        highestColor: context.colorProperty(
          'highestColor',
          const Color(0xFF00D73F),
        ),
        firstColor: context.colorProperty(
          'firstColor',
          const Color(0xFFFFE500),
        ),
        lastColor: context.colorProperty(
          'lastColor',
          const Color(0xFFD900FF),
        ),
        showAxis: context.boolProperty('showAxis', true),
        axisColor: context.colorProperty(
          'axisColor',
          const Color(0xFF000000),
        ),
      ),
    ),
  );
}
