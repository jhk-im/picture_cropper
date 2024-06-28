import 'package:flutter/material.dart';

import '../../../picture_cropper.dart';
import '../../common/constants.dart';
import '../../common/picture_path_item.dart';
import 'crop_area_clipper.dart';
import 'crop_control_point.dart';

class RectangleCrop extends StatelessWidget {
  final Clip clipBehavior;
  final double width;
  final double height;
  final Color backgroundColor;
  final bool isToggled;
  final PicturePathItem? picturePathItem;
  final ValueChanged<PicturePathItem> onUpdatePicturePathItem;

  RectangleCrop({
    super.key,
    required this.clipBehavior,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.isToggled,
    this.picturePathItem,
    required this.onUpdatePicturePathItem,
  });

  @override
  Widget build(BuildContext context) {
    double qrWidth = width - (16 * 2);
    double left = 16;
    double right = width - 16;
    double top = (height / 2) - (qrWidth / 2);
    double bottom = top + qrWidth;

    final initCropItem = PicturePathItem(
      leftTopX: left,
      leftTopY: top,
      rightTopX: right,
      rightTopY: top,
      rightBottomX: right,
      rightBottomY: bottom,
      leftBottomX: left,
      leftBottomY: bottom,
    );

    if (isToggled) {
      final controller = PictureCropperControllerFactory.createController();
      controller.setPicturePathItem(initCropItem);
    }

    return _RectangleCorpEditor(
      onUpdateCrop: onUpdatePicturePathItem,
      clipBehavior: clipBehavior,
      initCropItem: picturePathItem == null || isToggled
          ? initCropItem
          : picturePathItem!,
      backgroundColor: backgroundColor,
    );
  }
}

class _RectangleCorpEditor extends StatefulWidget {
  final ValueChanged<PicturePathItem> onUpdateCrop;
  final Clip clipBehavior;
  final PicturePathItem initCropItem;
  final Color backgroundColor;

  const _RectangleCorpEditor({
    required this.onUpdateCrop,
    required this.clipBehavior,
    required this.initCropItem,
    required this.backgroundColor,
  });

  @override
  _RectangleCorpEditorState createState() => _RectangleCorpEditorState();
}

class _RectangleCorpEditorState extends State<_RectangleCorpEditor> {
  PicturePathItem _cropItem = PicturePathItem();

  @override
  void initState() {
    setState(() {
      _cropItem = widget.initCropItem;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: widget.clipBehavior,
      children: [
        IgnorePointer(
          child: ClipPath(
            clipper: CropAreaClipper(_cropItem),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: widget.backgroundColor,
            ),
          ),
        ),
        Positioned(
          // leftTop
          left: _cropItem.leftTopX - (controlPointSize / 2),
          top: _cropItem.leftTopY - (controlPointSize / 2),
          child: GestureDetector(
            onPanUpdate: (details) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset localPosition = box.globalToLocal(details.globalPosition);

              final dx = localPosition.dx;
              final dy = localPosition.dy;

              final limitMinX =
                  _cropItem.rightTopX - dx < rectangleCropItemLimit;
              final limitMinY =
                  _cropItem.leftBottomY - dy < rectangleCropItemLimit;

              final update = PicturePathItem(
                leftTopX: limitMinX ? _cropItem.leftTopX : dx,
                leftTopY: limitMinY ? _cropItem.leftTopY : dy,
                rightTopX: _cropItem.rightTopX,
                rightTopY: limitMinY ? _cropItem.rightTopY : dy,
                rightBottomX: _cropItem.rightBottomX,
                rightBottomY: _cropItem.rightBottomY,
                leftBottomX: limitMinX ? _cropItem.leftBottomX : dx,
                leftBottomY: _cropItem.leftBottomY,
              );

              setState(() {
                _cropItem = update;
                widget.onUpdateCrop(update);
              });
            },
            child: CropControlPoint(pointShape: 1),
          ),
        ),
        Positioned(
          // rightTop
          left: _cropItem.rightTopX - (controlPointSize / 2),
          top: _cropItem.rightTopY - (controlPointSize / 2),
          child: GestureDetector(
            onPanUpdate: (details) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset localPosition = box.globalToLocal(details.globalPosition);

              final dx = localPosition.dx;
              final dy = localPosition.dy;

              final limitMinX =
                  dx - _cropItem.leftTopX < rectangleCropItemLimit;
              final limitMinY =
                  _cropItem.rightBottomY - dy < rectangleCropItemLimit;

              final update = PicturePathItem(
                leftTopX: _cropItem.leftTopX,
                leftTopY: limitMinY ? _cropItem.leftTopY : dy,
                rightTopX: limitMinX ? _cropItem.rightTopX : dx,
                rightTopY: limitMinY ? _cropItem.rightTopY : dy,
                rightBottomX: limitMinX ? _cropItem.rightBottomX : dx,
                rightBottomY: _cropItem.rightBottomY,
                leftBottomX: _cropItem.leftBottomX,
                leftBottomY: _cropItem.leftBottomY,
              );

              setState(() {
                _cropItem = update;
                widget.onUpdateCrop(update);
              });
            },
            child: CropControlPoint(pointShape: 2),
          ),
        ),
        Positioned(
          // rightBottom
          left: _cropItem.rightBottomX - (controlPointSize / 2),
          top: _cropItem.rightBottomY - (controlPointSize / 2),
          child: GestureDetector(
            onPanUpdate: (details) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset localPosition = box.globalToLocal(details.globalPosition);

              final dx = localPosition.dx;
              final dy = localPosition.dy;

              final limitMinX =
                  dx - _cropItem.leftBottomX < rectangleCropItemLimit;
              final limitMinY =
                  dy - _cropItem.rightTopY < rectangleCropItemLimit;

              final update = PicturePathItem(
                leftTopX: _cropItem.leftTopX,
                leftTopY: _cropItem.leftTopY,
                rightTopX: limitMinX ? _cropItem.rightTopX : dx,
                rightTopY: _cropItem.rightTopY,
                rightBottomX: limitMinX ? _cropItem.rightBottomX : dx,
                rightBottomY: limitMinY ? _cropItem.rightBottomY : dy,
                leftBottomX: _cropItem.leftBottomX,
                leftBottomY: limitMinY ? _cropItem.leftBottomY : dy,
              );

              setState(() {
                _cropItem = update;
                widget.onUpdateCrop(update);
              });
            },
            child: CropControlPoint(pointShape: 3),
          ),
        ),
        Positioned(
          // leftBottom
          left: _cropItem.leftBottomX - (controlPointSize / 2),
          top: _cropItem.leftBottomY - (controlPointSize / 2),
          child: GestureDetector(
            onPanUpdate: (details) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset localPosition = box.globalToLocal(details.globalPosition);

              final dx = localPosition.dx;
              final dy = localPosition.dy;

              final limitMinX =
                  _cropItem.rightBottomX - dx < rectangleCropItemLimit;
              final limitMinY =
                  dy - _cropItem.leftTopY < rectangleCropItemLimit;

              final update = PicturePathItem(
                leftTopX: limitMinX ? _cropItem.leftTopX : dx,
                leftTopY: _cropItem.leftTopY,
                rightTopX: _cropItem.rightTopX,
                rightTopY: _cropItem.rightTopY,
                rightBottomX: _cropItem.rightBottomX,
                rightBottomY: limitMinY ? _cropItem.rightBottomY : dy,
                leftBottomX: limitMinX ? _cropItem.leftBottomX : dx,
                leftBottomY: limitMinY ? _cropItem.leftBottomY : dy,
              );

              setState(() {
                _cropItem = update;
                widget.onUpdateCrop(update);
              });
            },
            child: CropControlPoint(pointShape: 4),
          ),
        ),
      ],
    );
  }
}
