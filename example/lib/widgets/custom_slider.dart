import 'package:flutter/material.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const CustomSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: GestureDetector(
          onPanUpdate: (details) {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            double localPosition = details.localPosition.dx;
            double width = renderBox.size.width;
            double newValue =
                (localPosition / width - 0.5) * (max - min) + (min + max) / 2;
            if (newValue < min) newValue = min;
            if (newValue > max) newValue = max;
            onChanged(newValue);
          },
          child: CustomPaint(
            size: const Size(100, 50),
            painter: SliderPainter(
              value: value,
              min: min,
              max: max,
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(context).primaryColor.withAlpha(30),
            ),
          ),
        ),
      );
}

class SliderPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final Color activeColor;
  final Color inactiveColor;

  SliderPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    double centerX = size.width / 2;
    double range = max - min;
    double normalizedValue = (value - (min + max) / 2) / range * size.width;
    double position = centerX + normalizedValue;

    // Draw the base line
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), paint..color = inactiveColor);

    // Draw the filled line
    canvas.drawLine(Offset(centerX, size.height / 2),
        Offset(position, size.height / 2), paint..color = activeColor);

    // Draw the thumb
    canvas.drawCircle(
        Offset(position, size.height / 2), 10.0, paint..color = activeColor);
  }

  @override
  bool shouldRepaint(SliderPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.min != min ||
        oldDelegate.max != max;
  }
}
