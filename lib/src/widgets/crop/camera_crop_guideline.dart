import 'package:flutter/material.dart';
import 'package:picture_cropper/src/common/enums.dart';
import 'package:picture_cropper/src/widgets/crop/crop_area_clipper.dart';
import 'package:picture_cropper/src/widgets/crop/crop_area_item.dart';

typedef UpdatePicturePathItem = Function(CropAreaItem);

class CameraCropGuideline extends StatefulWidget {
  final PictureCropGuideLineType cropGuideLineType;
  final double backgroundWidth;
  final double backgroundHeight;
  final double radius;
  final double margin;
  final Color backgroundColor;
  final UpdatePicturePathItem onUpdatePicturePathItem;

  const CameraCropGuideline({
    required this.cropGuideLineType,
    required this.backgroundWidth,
    required this.backgroundHeight,
    required this.radius,
    required this.margin,
    required this.backgroundColor,
    required this.onUpdatePicturePathItem,
  });

  @override
  CameraCropGuidelineState createState() => CameraCropGuidelineState();
}

class CameraCropGuidelineState extends State<CameraCropGuideline> {
  CropAreaItem _picturePathItem = CropAreaItem();

  void _setScannerCropGuideline() {
    final width = widget.backgroundWidth;
    final height = widget.backgroundHeight;
    double qrWidth = width - (widget.margin * 2);
    double top = 0;
    double right = 0;
    double bottom = 0;

    if (widget.cropGuideLineType != PictureCropGuideLineType.card) {
      right = width - widget.margin;
      top = (height / 2) - (qrWidth / 2);
      bottom = top + qrWidth;
    } else {
      double qrHeight = qrWidth * 0.62;
      right = width - widget.margin;
      top = (height / 2) - (qrHeight / 2);
      bottom = top + qrHeight;
    }

    _picturePathItem = CropAreaItem(
      leftTopX: widget.margin,
      leftTopY: top,
      rightTopX: right,
      rightTopY: top,
      rightBottomX: right,
      rightBottomY: bottom,
      leftBottomX: widget.margin,
      leftBottomY: bottom,
    );

    widget.onUpdatePicturePathItem(_picturePathItem);
    setState(() {});
  }

  @override
  void didUpdateWidget(CameraCropGuideline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cropGuideLineType != oldWidget.cropGuideLineType) {
      _setScannerCropGuideline();
    }
  }

  @override
  Widget build(BuildContext context) {
    _setScannerCropGuideline();
    return Stack(
      children: [
        Visibility(
          visible: widget.cropGuideLineType != PictureCropGuideLineType.clear,
          child: IgnorePointer(
            child: ClipPath(
              clipper: CropAreaClipper(_picturePathItem, radius: widget.radius),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: widget.backgroundColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
