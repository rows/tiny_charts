import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_charts/src/line.dart';
import 'package:vector_math/vector_math.dart';

import 'utils.dart';

void main() {
  group('TinyLineChart', () {
    testWidgets('from offset', (tester) async {
      await tester.pumpWidget(
        TestStage(
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
        ),
      );

      await expectLater(
        find.byType(TinyLineChart),
        matchesGoldenFile('goldens/line/1.png'),
      );
    });

    testWidgets('from vectors', (tester) async {
      await tester.pumpWidget(
        TestStage(
          child: TinyLineChart.fromDataVectors(
            width: 100,
            height: 28,
            dataPoints: [
              Vector2(0, 14),
              Vector2(1, 13.2),
              Vector2(2, 2),
              Vector2(3, 13),
              Vector2(4, 10),
              Vector2(5, 4),
            ],
          ),
        ),
      );

      await expectLater(
        find.byType(TinyLineChart),
        matchesGoldenFile('goldens/line/2.png'),
      );
    });

    testWidgets('with options', (tester) async {
      await tester.pumpWidget(
        TestStage(
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
            options: const TinyLineChartOptions(
              color: Color(0xFFC93B8C),
              lineWidth: 3,
              yMinLimit: -2,
              yMaxLimit: 27,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(TinyLineChart),
        matchesGoldenFile('goldens/line/3.png'),
      );
    });
  });
}
