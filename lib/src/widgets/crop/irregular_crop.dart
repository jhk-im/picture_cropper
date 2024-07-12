import 'package:flutter/material.dart';
import 'package:picture_cropper/src/common/constants.dart';
import 'package:picture_cropper/src/controller/picture_cropper_controller.dart';
import 'package:picture_cropper/src/widgets/crop/crop_area_clipper.dart';
import 'package:picture_cropper/src/model/crop_area_item.dart';
import 'package:picture_cropper/src/widgets/crop/crop_control_point.dart';

class IrregularCrop extends StatefulWidget {
  final PictureCropperController controller;
  const IrregularCrop({
    super.key,
    required this.controller,
  });

  @override
  State<IrregularCrop> createState() => _IrregularCropState();
}

class _IrregularCropState extends State<IrregularCrop> {
  @override
  Widget build(BuildContext context) {
    CropAreaItem cropItem = widget.controller.cropAreaItem;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        IgnorePointer(
          child: ClipPath(
            clipper: CropAreaClipper(cropItem),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: widget.controller.guideBackgroundColor,
            ),
          ),
        ),
        Positioned(
          // leftTop
          left: cropItem.leftTopX - (controlPointSize / 2),
          top: cropItem.leftTopY - (controlPointSize / 2),
          child: GestureDetector(
            onPanUpdate: (details) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset localPosition = box.globalToLocal(details.globalPosition);

              final dx = localPosition.dx;
              final dy = localPosition.dy;
              final screenWidth = box.size.width - irregularCropItemLimit;
              final screenHeight = box.size.height - irregularCropItemLimit;
              final limitX = cropItem.rightTopX - irregularCropItemLimit;
              final limitY = cropItem.leftBottomY - irregularCropItemLimit;
              final crossLimitX =
                  cropItem.rightBottomX - irregularCropItemLimit;
              final crossLimitY =
                  cropItem.rightBottomY - irregularCropItemLimit;

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
                rightTopX: cropItem.rightTopX,
                rightTopY: cropItem.rightTopY,
                rightBottomX: cropItem.rightBottomX,
                rightBottomY: cropItem.rightBottomY,
                leftBottomX: cropItem.leftBottomX,
                leftBottomY: cropItem.leftBottomY,
              );

              setState(() {
                cropItem = update;
                widget.controller.updateCropAreaItem(update);
              });
            },
            child: CropControlPoint(),
          ),
        ),
        Positioned(
          // rightTop
          left: cropItem.rightTopX - (controlPointSize / 2),
          top: cropItem.rightTopY - (controlPointSize / 2),
          child: GestureDetector(
            onPanUpdate: (details) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset localPosition = box.globalToLocal(details.globalPosition);

              final dx = localPosition.dx;
              final dy = localPosition.dy;
              final screenWidth = box.size.width - irregularCropItemLimit;
              final screenHeight = box.size.height - irregularCropItemLimit;
              final limitX = cropItem.leftTopX + irregularCropItemLimit;
              final limitY = cropItem.rightBottomY - irregularCropItemLimit;
              final crossLimitX = cropItem.leftBottomX + irregularCropItemLimit;
              final crossLimitY = cropItem.leftBottomY;

              final limitLeftTop =
                  dx < irregularCropItemLimit || dy < irregularCropItemLimit;
              final limitRightBottom = dx > screenWidth || dy > screenHeight;
              final limitMax = dx <= limitX || dy >= limitY;
              final crossMax = dx <= crossLimitX || dy >= crossLimitY;

              if (limitLeftTop || limitRightBottom || limitMax || crossMax) {
                return;
              }

              final update = CropAreaItem(
                leftTopX: cropItem.leftTopX,
                leftTopY: cropItem.leftTopY,
                rightTopX: dx,
                rightTopY: dy,
                rightBottomX: cropItem.rightBottomX,
                rightBottomY: cropItem.rightBottomY,
                leftBottomX: cropItem.leftBottomX,
                leftBottomY: cropItem.leftBottomY,
              );

              setState(() {
                cropItem = update;
                widget.controller.updateCropAreaItem(update);
              });
            },
            child: CropControlPoint(),
          ),
        ),
        Positioned(
          // rightBottom
          left: cropItem.rightBottomX - (controlPointSize / 2),
          top: cropItem.rightBottomY - (controlPointSize / 2),
          child: GestureDetector(
            onPanUpdate: (details) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset localPosition = box.globalToLocal(details.globalPosition);

              final dx = localPosition.dx;
              final dy = localPosition.dy;
              final screenWidth = box.size.width - irregularCropItemLimit;
              final screenHeight = box.size.height - irregularCropItemLimit;
              final limitX = cropItem.leftBottomX + irregularCropItemLimit;
              final limitY = cropItem.rightTopY + irregularCropItemLimit;
              final crossLimitX = cropItem.leftTopX + irregularCropItemLimit;
              final crossLimitY = cropItem.leftTopY + irregularCropItemLimit;

              final limitLeftTop =
                  dx < irregularCropItemLimit || dy < irregularCropItemLimit;
              final limitRightBottom = dx > screenWidth || dy > screenHeight;
              final limitMax = dx <= limitX || dy <= limitY;
              final crossMax = dx <= crossLimitX || dy <= crossLimitY;

              if (limitLeftTop || limitRightBottom || limitMax || crossMax) {
                return;
              }

              final update = CropAreaItem(
                leftTopX: cropItem.leftTopX,
                leftTopY: cropItem.leftTopY,
                rightTopX: cropItem.rightTopX,
                rightTopY: cropItem.rightTopY,
                rightBottomX: dx,
                rightBottomY: dy,
                leftBottomX: cropItem.leftBottomX,
                leftBottomY: cropItem.leftBottomY,
              );

              setState(() {
                cropItem = update;
                widget.controller.updateCropAreaItem(update);
              });
            },
            child: CropControlPoint(),
          ),
        ),
        Positioned(
          // leftBottom
          left: cropItem.leftBottomX - (controlPointSize / 2),
          top: cropItem.leftBottomY - (controlPointSize / 2),
          child: GestureDetector(
            onPanUpdate: (details) {
              RenderBox box = context.findRenderObject() as RenderBox;
              Offset localPosition = box.globalToLocal(details.globalPosition);

              final dx = localPosition.dx;
              final dy = localPosition.dy;
              final screenWidth = box.size.width - irregularCropItemLimit;
              final screenHeight = box.size.height - irregularCropItemLimit;
              final limitX = cropItem.rightBottomX - irregularCropItemLimit;
              final limitY = cropItem.leftTopY + irregularCropItemLimit;
              final crossLimitX = cropItem.rightTopX - irregularCropItemLimit;
              final crossLimitY = cropItem.rightTopY + irregularCropItemLimit;

              final limitLeftTop =
                  dx < irregularCropItemLimit || dy < irregularCropItemLimit;
              final limitRightBottom = dx > screenWidth || dy > screenHeight;
              final limitMax = dx >= limitX || dy <= limitY;
              final crossMax = dx >= crossLimitX || dy <= crossLimitY;

              if (limitLeftTop || limitRightBottom || limitMax || crossMax) {
                return;
              }

              final update = CropAreaItem(
                leftTopX: cropItem.leftTopX,
                leftTopY: cropItem.leftTopY,
                rightTopX: cropItem.rightTopX,
                rightTopY: cropItem.rightTopY,
                rightBottomX: cropItem.rightBottomX,
                rightBottomY: cropItem.rightBottomY,
                leftBottomX: dx,
                leftBottomY: dy,
              );

              setState(() {
                cropItem = update;
                widget.controller.updateCropAreaItem(update);
              });
            },
            child: CropControlPoint(),
          ),
        ),
      ],
    );
  }
}
