import 'package:flutter/material.dart';
import 'package:picture_cropper/src/common/constants.dart';
import 'package:picture_cropper/src/widgets/crop/crop_area_clipper.dart';
import 'package:picture_cropper/src/widgets/crop/crop_area_item.dart';
import 'package:picture_cropper/src/widgets/crop/crop_control_point.dart';

class RectangleCrop extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final CropAreaItem? picturePathItem;
  final ValueChanged<CropAreaItem> onUpdatePicturePathItem;

  RectangleCrop({
    super.key,
    required this.width,
    required this.height,
    required this.backgroundColor,
    this.picturePathItem,
    required this.onUpdatePicturePathItem,
  });

  @override
  Widget build(BuildContext context) {
    return _RectangleCorpEditor(
      onUpdateCrop: onUpdatePicturePathItem,
      clipBehavior: Clip.hardEdge,
      initCropItem: picturePathItem,
      backgroundColor: backgroundColor,
    );
  }
}

class _RectangleCorpEditor extends StatefulWidget {
  final ValueChanged<CropAreaItem> onUpdateCrop;
  final Clip clipBehavior;
  final CropAreaItem? initCropItem;
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
  CropAreaItem _cropItem = CropAreaItem();

  @override
  void initState() {
    if (widget.initCropItem != null) {
      _cropItem = widget.initCropItem!;
    }
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
                  _cropItem.rightTopX - dx < rectangleCropItemLimit ||
                      dx < cropLimit;
              final limitMinY =
                  _cropItem.leftBottomY - dy < rectangleCropItemLimit ||
                      dy < cropLimit;

              final update = CropAreaItem(
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
                  dx - _cropItem.leftTopX < rectangleCropItemLimit ||
                      dx > box.size.width - cropLimit;
              final limitMinY =
                  _cropItem.rightBottomY - dy < rectangleCropItemLimit ||
                      dy < cropLimit;

              final update = CropAreaItem(
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
                  dx - _cropItem.leftBottomX < rectangleCropItemLimit ||
                      dx > box.size.width - cropLimit;
              final limitMinY =
                  dy - _cropItem.rightTopY < rectangleCropItemLimit ||
                      dy > box.size.height - cropLimit;

              final update = CropAreaItem(
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
                  _cropItem.rightBottomX - dx < rectangleCropItemLimit ||
                      dx < cropLimit;
              final limitMinY =
                  dy - _cropItem.leftTopY < rectangleCropItemLimit ||
                      dy > box.size.height - cropLimit;

              final update = CropAreaItem(
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
