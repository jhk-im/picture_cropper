import 'package:flutter/material.dart';

import '../../common/constants.dart';

class CropControlPoint extends StatelessWidget {
  final Color color;
  final int
      pointShape; // 0 = default, 1 = leftTop, 2 = rightTop, 3 = rightBottom, 4 = leftBottom

  const CropControlPoint({
    super.key,
    this.color = Colors.white,
    this.pointShape = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: controlPointSize,
      height: controlPointSize,
      child: pointShape == 0
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                color: color,
              ),
            )
          : _rectanglePoint(),
    );
  }

  Widget _rectanglePoint() {
    final radius = 12.0;

    return Transform.translate(
      offset: pointShape == 1
          ? Offset(10, 10)
          : pointShape == 2
              ? Offset(-10, 10)
              : pointShape == 3
                  ? Offset(-10, -10)
                  : Offset(10, -10),
      child: Container(
        padding: pointShape == 2 || pointShape == 3
            ? EdgeInsets.only(top: 4, right: 4, bottom: 4, left: 8)
            : EdgeInsets.only(top: 4, right: 8, bottom: 4, left: 4),
        child: Stack(
          children: [
            Align(
              alignment: pointShape == 1
                  ? Alignment.topCenter
                  : pointShape == 2
                      ? Alignment.topCenter
                      : Alignment.bottomCenter,
              child: Container(
                width: 20,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.all(Radius.circular(radius)),
                ),
              ),
            ),
            Align(
              alignment: pointShape == 1
                  ? Alignment.topLeft
                  : pointShape == 2
                      ? Alignment.topRight
                      : pointShape == 3
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft,
              child: Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.all(Radius.circular(radius)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
