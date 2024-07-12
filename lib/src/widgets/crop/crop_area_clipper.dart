import 'package:flutter/material.dart';

import '../../model/crop_area_item.dart';

/// [CropAreaClipper] is used to clip the crop and guideline area by converting coordinate information to a [Path].
/// [item] is a [CropAreaItem] that contains the coordinate information.
/// [radius] determines the radius of the clip area.
class CropAreaClipper extends CustomClipper<Path> {
  CropAreaClipper(this.item, {this.radius = 0.0});

  final CropAreaItem item;
  final double radius;

  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(item.leftTopX + radius, item.leftTopY)
      ..lineTo(item.rightTopX - radius, item.rightTopY)
      ..arcToPoint(
        Offset(item.rightTopX, item.rightTopY + radius),
        radius: Radius.circular(radius),
      )
      ..lineTo(item.rightBottomX, item.rightBottomY - radius)
      ..arcToPoint(
        Offset(item.rightBottomX - radius, item.rightBottomY),
        radius: Radius.circular(radius),
      )
      ..lineTo(item.leftBottomX + radius, item.leftBottomY)
      ..arcToPoint(
        Offset(item.leftBottomX, item.leftBottomY - radius),
        radius: Radius.circular(radius),
      )
      ..lineTo(item.leftTopX, item.leftTopY + radius)
      ..arcToPoint(
        Offset(item.leftTopX + radius, item.leftTopY),
        radius: Radius.circular(radius),
      )
      ..close()
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
