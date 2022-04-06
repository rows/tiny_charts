import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_charts/src/bar.dart';

import 'package:vector_math/vector_math.dart';

import 'utils.dart';

void main() {
  group('TinyBarChart', () {
    testWidgets('single', (tester) async {
      await tester.pumpWidget(
        TestStage(
          child: TinyBarChart.single(
            value: 68.12,
            max: 100,
            color: const Color(0xFF236536),
            width: 120,
            height: 28,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TinyBarChart),
        matchesGoldenFile('goldens/bar/1.png'),
      );
    });

    testWidgets('stacked', (tester) async {
      await tester.pumpWidget(
        TestStage(
          child: TinyBarChart.stacked(
            data: const <double>[24, 12, 4],
            width: 120,
            height: 28,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TinyBarChart),
        matchesGoldenFile('goldens/bar/2.png'),
      );
    });

    testWidgets('stacked from vectors', (tester) async {
      await tester.pumpWidget(
        TestStage(
          child: TinyBarChart.stackedFromDataVectors(
            dataPoints: <Vector2>[
              Vector2(1, 20),
              Vector2(2, 15),
              Vector2(0, 24),
              Vector2(4, 8),
            ],
            width: 120,
            height: 28,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TinyBarChart),
        matchesGoldenFile('goldens/bar/3.png'),
      );
    });

    group('options', () {
      testWidgets('custom colors', (tester) async {
        await tester.pumpWidget(
          TestStage(
            child: TinyBarChart.stacked(
              data: const <double>[24, 12, 4],
              options: const TinyBarChartOptions(
                colors: [
                  Color(0xFFFF0000),
                  Color(0xBEEE0260),
                  Color(0x97FF74AD),
                ],
              ),
              width: 120,
              height: 28,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(TinyBarChart),
          matchesGoldenFile('goldens/bar/4.png'),
        );
      });

      testWidgets('max capping', (tester) async {
        await tester.pumpWidget(
          TestStage(
            child: TinyBarChart.stackedFromDataVectors(
              dataPoints: <Vector2>[
                Vector2(1, 120),
                Vector2(2, 15),
                Vector2(0, 24),
                Vector2(4, 8),
              ],
              width: 120,
              height: 28,
              options: const TinyBarChartOptions(
                max: 100,
                colors: [
                  Color(0xFFFF0000),
                  Color(0xBEEE0260),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(
          find.byType(TinyBarChart),
          matchesGoldenFile('goldens/bar/5.png'),
        );
      });
    });
  });
}
