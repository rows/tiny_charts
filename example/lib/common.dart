import 'package:flutter/widgets.dart';

class DemoStage extends StatelessWidget {
  final Widget child;

  const DemoStage({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFFFFF),
      child: Center(
        child: ColoredBox(
          color: const Color(0xFFFFFFFF),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ClipRect(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
