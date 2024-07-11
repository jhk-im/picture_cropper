import 'package:flutter/material.dart';
import 'package:picture_cropper/src/common/constants.dart';
import 'package:picture_cropper/src/widgets/crop/crop_area_clipper.dart';
import 'package:picture_cropper/src/widgets/crop/crop_area_item.dart';
import 'package:picture_cropper/src/widgets/crop/crop_control_point.dart';

class IrregularCrop extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final CropAreaItem? picturePathItem;
  final ValueChanged<CropAreaItem> onUpdatePicturePathItem;

  IrregularCrop({
    super.key,
    required this.width,
    required this.height,
    required this.backgroundColor,
    this.picturePathItem,
    required this.onUpdatePicturePathItem,
  });

  @override
  Widget build(BuildContext context) {
    return _IrregularCorpEditor(
      onUpdateCrop: onUpdatePicturePathItem,
      clipBehavior: Clip.hardEdge,
      initCropItem: picturePathItem,
      backgroundColor: backgroundColor,
    );
  }
}

class _IrregularCorpEditor extends StatefulWidget {
  final ValueChanged<CropAreaItem> onUpdateCrop;
  final Clip clipBehavior;
  final CropAreaItem? initCropItem;
  final Color backgroundColor;

  const _IrregularCorpEditor({
    required this.onUpdateCrop,
    required this.clipBehavior,
    required this.initCropItem,
    required this.backgroundColor,
  });

  @override
  _IrregularCorpEditorState createState() => _IrregularCorpEditorState();
}

class _IrregularCorpEditorState extends State<_IrregularCorpEditor> {
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

              print(localPosition);

              final dx = localPosition.dx;
              final dy = localPosition.dy;
              final screenWidth = box.size.width - irregularCropItemLimit;
              final screenHeight = box.size.height - irregularCropItemLimit;
              final limitX = _cropItem.rightTopX - irregularCropItemLimit;
              final limitY = _cropItem.leftBottomY - irregularCropItemLimit;
              final crossLimitX =
                  _cropItem.rightBottomX - irregularCropItemLimit;
              final crossLimitY =
                  _cropItem.rightBottomY - irregularCropItemLimit;

              final limitLeftTop =
                  dx < irregularCropItemLimit || dy < irregularCropItemLimit;
              final limitRightBottom = dx > screenWidth || dy > screenHeight;
              final limitMax = dx >= limitX || dy >= limitY;
              final crossMax = dx >= crossLimitX || dy >= crossLimitY;

              if (limitLeftTop || limitRightBottom || limitMax || crossMax) {
                return;
              }

              final update = CropAreaItem(
                leftTopX: dx,
                leftTopY: dy,
                rightTopX: _cropItem.rightTopX,
                rightTopY: _cropItem.rightTopY,
                rightBottomX: _cropItem.rightBottomX,
                rightBottomY: _cropItem.rightBottomY,
                leftBottomX: _cropItem.leftBottomX,
                leftBottomY: _cropItem.leftBottomY,
              );

              setState(() {
                _cropItem = update;
                widget.onUpdateCrop(update);
              });
            },
            child: CropControlPoint(),
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
              final screenWidth = box.size.width - irregularCropItemLimit;
              final screenHeight = box.size.height - irregularCropItemLimit;
              final limitX = _cropItem.leftTopX + irregularCropItemLimit;
              final limitY = _cropItem.rightBottomY - irregularCropItemLimit;
              final crossLimitX =
                  _cropItem.leftBottomX + irregularCropItemLimit;
              final crossLimitY = _cropItem.leftBottomY;

              final limitLeftTop =
                  dx < irregularCropItemLimit || dy < irregularCropItemLimit;
              final limitRightBottom = dx > screenWidth || dy > screenHeight;
              final limitMax = dx <= limitX || dy >= limitY;
              final crossMax = dx <= crossLimitX || dy >= crossLimitY;

              if (limitLeftTop || limitRightBottom || limitMax || crossMax) {
                return;
              }

              final update = CropAreaItem(
                leftTopX: _cropItem.leftTopX,
                leftTopY: _cropItem.leftTopY,
                rightTopX: dx,
                rightTopY: dy,
                rightBottomX: _cropItem.rightBottomX,
                rightBottomY: _cropItem.rightBottomY,
                leftBottomX: _cropItem.leftBottomX,
                leftBottomY: _cropItem.leftBottomY,
              );

              setState(() {
                _cropItem = update;
                widget.onUpdateCrop(update);
              });
            },
            child: CropControlPoint(),
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
              final screenWidth = box.size.width - irregularCropItemLimit;
              final screenHeight = box.size.height - irregularCropItemLimit;
              final limitX = _cropItem.leftBottomX + irregularCropItemLimit;
              final limitY = _cropItem.rightTopY + irregularCropItemLimit;
              final crossLimitX = _cropItem.leftTopX + irregularCropItemLimit;
              final crossLimitY = _cropItem.leftTopY + irregularCropItemLimit;

              final limitLeftTop =
                  dx < irregularCropItemLimit || dy < irregularCropItemLimit;
              final limitRightBottom = dx > screenWidth || dy > screenHeight;
              final limitMax = dx <= limitX || dy <= limitY;
              final crossMax = dx <= crossLimitX || dy <= crossLimitY;

              if (limitLeftTop || limitRightBottom || limitMax || crossMax) {
                return;
              }

              final update = CropAreaItem(
                leftTopX: _cropItem.leftTopX,
                leftTopY: _cropItem.leftTopY,
                rightTopX: _cropItem.rightTopX,
                rightTopY: _cropItem.rightTopY,
                rightBottomX: dx,
                rightBottomY: dy,
                leftBottomX: _cropItem.leftBottomX,
                leftBottomY: _cropItem.leftBottomY,
              );

              setState(() {
                _cropItem = update;
                widget.onUpdateCrop(update);
              });
            },
            child: CropControlPoint(),
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
              final screenWidth = box.size.width - irregularCropItemLimit;
              final screenHeight = box.size.height - irregularCropItemLimit;
              final limitX = _cropItem.rightBottomX - irregularCropItemLimit;
              final limitY = _cropItem.leftTopY + irregularCropItemLimit;
              final crossLimitX = _cropItem.rightTopX - irregularCropItemLimit;
              final crossLimitY = _cropItem.rightTopY + irregularCropItemLimit;

              final limitLeftTop =
                  dx < irregularCropItemLimit || dy < irregularCropItemLimit;
              final limitRightBottom = dx > screenWidth || dy > screenHeight;
              final limitMax = dx >= limitX || dy <= limitY;
              final crossMax = dx >= crossLimitX || dy <= crossLimitY;

              if (limitLeftTop || limitRightBottom || limitMax || crossMax) {
                return;
              }

              final update = CropAreaItem(
                leftTopX: _cropItem.leftTopX,
                leftTopY: _cropItem.leftTopY,
                rightTopX: _cropItem.rightTopX,
                rightTopY: _cropItem.rightTopY,
                rightBottomX: _cropItem.rightBottomX,
                rightBottomY: _cropItem.rightBottomY,
                leftBottomX: dx,
                leftBottomY: dy,
              );

              setState(() {
                _cropItem = update;
                widget.onUpdateCrop(update);
              });
            },
            child: CropControlPoint(),
          ),
        ),
      ],
    );
  }
}
