import 'package:flutter/material.dart';

class TestStage extends StatelessWidget {
  final Widget child;

  const TestStage({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ColoredBox(
          color: const Color(0xFFFF00FF),
          child: Center(
            child: RepaintBoundary(
              child: ColoredBox(
                color: const Color(0xFFFFFFFF),
                child: ClipRect(
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
