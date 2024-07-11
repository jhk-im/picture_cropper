import 'package:flutter/material.dart';
import 'package:picture_cropper/src/common/constants.dart';

/// [CropControlPoint] is used as a [GestureDetector] point when editing the crop area and to indicate the guideline area.
/// [color] determines the color of the point.
/// [pointShape] determines the shape of the point.
/// [pointShape = 0]: Default, used when editing the crop area.
/// [pointShape = 1]: Top-left point.
/// [pointShape = 2]: Top-right point.
/// [pointShape = 3]: Bottom-right point.
/// [pointShape = 4]: Bottom-left point.
class CropControlPoint extends StatelessWidget {
  final Color color;
  final int pointShape;

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
          ? Offset(20, 20)
          : pointShape == 2
              ? Offset(-20, 20)
              : pointShape == 3
                  ? Offset(-20, -20)
                  : Offset(20, -20),
      child: Container(
        padding: pointShape == 2 || pointShape == 3
            ? EdgeInsets.only(top: 8, right: 8, bottom: 8, left: 32)
            : EdgeInsets.only(top: 8, right: 32, bottom: 8, left: 8),
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
