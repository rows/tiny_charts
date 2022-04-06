import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math.dart';

const kIterableVectorEquality = IterableEquality<Vector2>();
const kIterableColorEquality = IterableEquality<Color>();

/// Position [dataPoint] on [physicalExtent] given its value compared to
/// [dataSpaceStart] and [dataSpaceEnd].
double calculatePhysicalPositionFromDataPosition({
  required double dataPoint,
  required double dataSpaceStart,
  required double dataSpaceEnd,
  required double physicalExtent,
}) {
  if (dataSpaceEnd == dataSpaceStart) {
    return physicalExtent / 2;
  }

  final relative =
      ((dataPoint - dataSpaceStart) / (dataSpaceEnd - dataSpaceStart))
          .clamp(0.0, 1.0);

  return physicalExtent * relative;
}

/// Define the actual size of a tiny chart widget given the constraints and
/// [width] and [height] passed to the widget.
///
/// Tries to keep aspect ratio when both [width] and [height] are specified.
Size defineTinyChartSize({
  required BoxConstraints constraints,
  required double? width,
  required double? height,
}) {
  final localConstraints = BoxConstraints.tightFor(
    width: width,
    height: height,
  ).enforce(constraints);

  if (width == null || height == null) {
    // since localConstraints is tight,
    // smallest is the same as biggest.
    return localConstraints.smallest;
  }

  return localConstraints.constrainSizeAndAttemptToPreserveAspectRatio(
    Size(width, height),
  );
}

/// Create an [Aabb2] that represents a rectangle that includes all [vectors]
/// in the most compact way possible.
///
/// Returns null if [vectors] is empty.
Aabb2? aabb2FromVectors(Iterable<Vector2> vectors) {
  if (vectors.isEmpty) {
    return null;
  }
  final firstVector = vectors.first;
  return vectors.fold<Aabb2>(
    Aabb2.minMax(firstVector, firstVector),
    (previousValue, nextVector) {
      final previousMin = previousValue.min;
      final previousMax = previousValue.max;
      return Aabb2.minMax(
        Vector2(
          min(previousMin.x, nextVector.x),
          min(previousMin.y, nextVector.y),
        ),
        Vector2(
          max(previousMax.x, nextVector.x),
          max(previousMax.y, nextVector.y),
        ),
      );
    },
  );
}
