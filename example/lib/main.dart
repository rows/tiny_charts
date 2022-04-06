import 'package:dashbook/dashbook.dart';
import 'package:flutter/material.dart';

import 'bar.dart';
import 'column.dart';
import 'line.dart';

void main() {
  runApp(
    Builder(
      builder: (context) {
        final dashbook = Dashbook(
          title: 'Tiny charts stories',
        );
        addLineChartStories(dashbook);
        addBarChartStories(dashbook);
        addColumnChartStories(dashbook);
        return dashbook;
      },
    ),
  );
}
