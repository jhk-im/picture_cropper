import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:picture_cropper/src/common/enums.dart';
import 'package:picture_cropper/src/widgets/crop/crop_area_clipper.dart';
import 'package:picture_cropper/src/model/crop_area_item.dart';

class CameraCropGuideline extends StatelessWidget {
  final CropGuideLineType cropGuideLineType;
  final CropAreaItem cropAreaItem;
  final double radius;
  final Color backgroundColor;
  const CameraCropGuideline({
    super.key,
    required this.cropGuideLineType,
    required this.cropAreaItem,
    required this.radius,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Visibility(
            visible: cropGuideLineType != CropGuideLineType.clear,
            child: IgnorePointer(
              child: ClipPath(
                clipper: CropAreaClipper(cropAreaItem, radius: radius),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: backgroundColor,
                ),
              ),
            ),
          ),
        ],
      );
}
