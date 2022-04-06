import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_charts/src/column.dart';

import 'package:vector_math/vector_math.dart';

import 'utils.dart';

void main() {
  group('TinyColumnChart', () {
    testWidgets('from values', (tester) async {
      await tester.pumpWidget(
        TestStage(
          child: TinyColumnChart(
            data: const [20, 22, 14, 12, 19, 28, 1, 11],
            width: 120,
            height: 28,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TinyColumnChart),
        matchesGoldenFile('goldens/column/1.png'),
      );
    });

    testWidgets('from values', (tester) async {
      await tester.pumpWidget(
        TestStage(
          child: TinyColumnChart.fromDataVectors(
            dataPoints: [
              Vector2(0, 18),
              Vector2(6, 22),
              Vector2(2, 12),
              Vector2(3, 14),
              Vector2(5, 34),
              Vector2(4, 5),
              Vector2(1, 24),
            ],
            width: 120,
            height: 28,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TinyColumnChart),
        matchesGoldenFile('goldens/column/2.png'),
      );
    });

    testWidgets('negative values', (tester) async {
      await tester.pumpWidget(
        TestStage(
          child: TinyColumnChart(
            data: const [20, -22, 14, -12, -19, 28, 1, 11],
            width: 120,
            height: 28,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TinyColumnChart),
        matchesGoldenFile('goldens/column/3.png'),
      );
    });

    group('options', () {
      testWidgets('show axis', (tester) async {
        await tester.pumpWidget(
          TestStage(
            child: TinyColumnChart(
              data: const [20, -22, 14, -12, -19, 28, 5, 11],
              width: 120,
              height: 28,
              options: const TinyColumnChartOptions(
                positiveColor: Color(0xFF27A083),
                negativeColor: Color(0xFFE92F3C),
                showAxis: true,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(TinyColumnChart),
          matchesGoldenFile('goldens/column/4.png'),
        );
      });

      testWidgets('custom colors', (tester) async {
        await tester.pumpWidget(
          TestStage(
            child: TinyColumnChart(
              data: const [18, 22, 28, -12, 32, 12, 9, 14, -34, -25, 24],
              width: 120,
              height: 28,
              options: const TinyColumnChartOptions(
                positiveColor: Color(0xFF0023C6),
                negativeColor: Color(0xFFBA2500),
                showAxis: true,
                axisColor: Color(0xFF00FF00),
                lowestColor: Color(0xFFFF4A1A),
                highestColor: Color(0xFF3083FF),
                firstColor: Color(0xFFFFE500),
                lastColor: Color(0xFF8000FF),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(TinyColumnChart),
          matchesGoldenFile('goldens/column/5.png'),
        );
      });
    });
  });
}
