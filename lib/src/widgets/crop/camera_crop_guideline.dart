import 'package:flutter/material.dart';

import '../../common/picture_path_item.dart';
import '../../common/enums.dart';
import 'crop_area_clipper.dart';

typedef UpdatePicturePathItem = Function(PicturePathItem);

class CameraCropGuideline extends StatefulWidget {
  final PictureCropGuideLineType cropGuideLineType;
  final double radius;
  final double margin;
  final Size renderBoxSize;
  final Color backgroundColor;
  final UpdatePicturePathItem onUpdatePicturePathItem;

  const CameraCropGuideline({
    required this.cropGuideLineType,
    required this.renderBoxSize,
    required this.radius,
    required this.margin,
    required this.backgroundColor,
    required this.onUpdatePicturePathItem,
  });

  @override
  CameraCropGuidelineState createState() => CameraCropGuidelineState();
}

class CameraCropGuidelineState extends State<CameraCropGuideline> {
  PicturePathItem _picturePathItem = PicturePathItem();

  void _setScannerCropGuideline() {
    final width = widget.renderBoxSize.width;
    final height = widget.renderBoxSize.height;
    double left = 0;
    double top = 0;
    double right = 0;
    double bottom = 0;

    if (widget.cropGuideLineType != PictureCropGuideLineType.card) {
      double qrWidth = width - (widget.margin * 2);
      left = widget.margin;
      right = width - widget.margin;
      top = (height / 2) - (qrWidth / 2);
      bottom = top + qrWidth;
    } else {
      double qrWidth = width - (widget.margin * 2);
      double qrHeight = qrWidth * 0.62;
      left = widget.margin;
      right = width - widget.margin;
      top = (height / 2) - (qrHeight / 2);
      bottom = top + qrHeight;
    }

    _picturePathItem = PicturePathItem(
      leftTopX: left,
      leftTopY: top,
      rightTopX: right,
      rightTopY: top,
      rightBottomX: right,
      rightBottomY: bottom,
      leftBottomX: left,
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
