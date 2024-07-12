import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:picture_cropper/src/widgets/crop/crop_area_clipper.dart';
import 'package:picture_cropper/src/model/crop_area_item.dart';

void main() {
  test('CropAreaClipper generates correct path', () {
    /// Create CropAreaItem object
    final item = CropAreaItem(
      leftTopX: 10.0,
      leftTopY: 10.0,
      rightTopX: 100.0,
      rightTopY: 10.0,
      rightBottomX: 100.0,
      rightBottomY: 100.0,
      leftBottomX: 10.0,
      leftBottomY: 100.0,
    );

    /// Create CropAreaClipper object
    /// radius is used to draw the curve of the guideline during shooting
    final clipper = CropAreaClipper(item, radius: 10.0);

    /// Call the getClip method of the clipper to create a Path object
    final path = clipper.getClip(Size(200.0, 200.0));

    final expectedPath = Path()
      ..moveTo(20.0, 10.0) /// Starting point, a point radius away from the top-left corner
      ..lineTo(90.0, 10.0) /// Draw a line to a point radius away from the top-right corner
      ..arcToPoint( /// Draw an arc with a radius of 10 to move to the top-right corner
        Offset(100.0, 20.0),
        radius: Radius.circular(10.0),
      )
      ..lineTo(100.0, 90.0) /// Draw a line to a point radius away from the bottom-right corner
      ..arcToPoint( /// Draw an arc with a radius of 10 to move to the bottom-right corner
        Offset(90.0, 100.0),
        radius: Radius.circular(10.0),
      )
      ..lineTo(20.0, 100.0) /// Draw a line to a point radius away from the bottom-left corner
      ..arcToPoint( /// Draw an arc with a radius of 10 to move to the bottom-left corner
        Offset(10.0, 90.0),
        radius: Radius.circular(10.0),
      )
      ..lineTo(10.0, 20.0) /// Draw a line to a point radius away from the starting point
      ..arcToPoint(
        Offset(20.0, 10.0), /// Draw an arc with a radius of 10 to move back to the starting point
        radius: Radius.circular(10.0),
      )
      ..close() /// Close the path
      ..addRect(Rect.fromLTWH(0.0, 0.0, 200.0, 200.0)) /// Add the entire area to differentiate the clipping area
      ..fillType = PathFillType.evenOdd; /// Fill the outside area

    /// Compare path and expectedPath
    expect(path.getBounds(), expectedPath.getBounds());
  });
}