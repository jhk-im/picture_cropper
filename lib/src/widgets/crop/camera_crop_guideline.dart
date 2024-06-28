import 'package:flutter/material.dart';

import '../../common/picture_path_item.dart';
import '../../common/enums.dart';
import 'crop_area_clipper.dart';

typedef UpdatePicturePathItem = Function(PicturePathItem);

class CameraCropGuideline extends StatefulWidget {
  final PictureCropGuideType cropGuideType;
  final double radius;
  final double margin;
  final Color backgroundColor;
  final UpdatePicturePathItem onUpdatePicturePathItem;

  const CameraCropGuideline({
    required this.cropGuideType,
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
  final GlobalKey _stackKey = GlobalKey();
  Size? _size;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_getStackSize);
  }

  void _getStackSize(_) {
    final RenderBox renderBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox;
    setState(() {
      _size = renderBox.size;
      _setScannerCropGuideline();
    });
  }

  void _setScannerCropGuideline() {
    if (_size == null) return;

    final width = _size!.width;
    final height = _size!.height;
    double left = 0;
    double top = 0;
    double right = 0;
    double bottom = 0;

    if (widget.cropGuideType != PictureCropGuideType.card) {
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
    if (widget.cropGuideType != oldWidget.cropGuideType) {
      _setScannerCropGuideline();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _stackKey,
      children: [
        Visibility(
          visible: widget.cropGuideType != PictureCropGuideType.clear,
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
