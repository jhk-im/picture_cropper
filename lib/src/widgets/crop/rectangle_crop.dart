import 'package:flutter/material.dart';
import 'package:picture_cropper/src/common/constants.dart';
import 'package:picture_cropper/src/controller/picture_cropper_controller.dart';
import 'package:picture_cropper/src/widgets/crop/crop_area_clipper.dart';
import 'package:picture_cropper/src/model/crop_area_item.dart';
import 'package:picture_cropper/src/widgets/crop/crop_control_point.dart';

class RectangleCrop extends StatefulWidget {
  final PictureCropperController controller;
  const RectangleCrop({
    super.key,
    required this.controller,
  });

  @override
  State<RectangleCrop> createState() => _RectangleCropState();
}

class _RectangleCropState extends State<RectangleCrop> {
  @override
  Widget build(BuildContext context) {
    CropAreaItem cropItem = widget.controller.cropAreaItem;
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        GestureDetector(
          onPanUpdate: (details) {
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset localPosition = box.globalToLocal(details.globalPosition);

            final dx = localPosition.dx;
            final dy = localPosition.dy;

            if (cropItem.leftTopX < dx &&
                cropItem.leftTopY < dy &&
                cropItem.rightBottomX > dx &&
                cropItem.rightBottomY > dy) {
              final limitRightX = box.size.width - cropLimit;
              final limitBottomY = box.size.height - cropLimit;

              final update = CropAreaItem(
                leftTopX: cropItem.leftTopX + details.delta.dx,
                leftTopY: cropItem.leftTopY + details.delta.dy,
                rightTopX: cropItem.rightTopX + details.delta.dx,
                rightTopY: cropItem.rightTopY + details.delta.dy,
                rightBottomX: cropItem.rightBottomX + details.delta.dx,
                rightBottomY: cropItem.rightBottomY + details.delta.dy,
                leftBottomX: cropItem.leftBottomX + details.delta.dx,
                leftBottomY: cropItem.leftBottomY + details.delta.dy,
              );

              if (update.leftTopX > cropLimit &&
                  update.leftTopY > cropLimit &&
                  update.rightBottomX < limitRightX &&
                  update.rightBottomY < limitBottomY) {
                setState(() {
                  cropItem = update;
                  widget.controller.updateCropAreaItem(update);
                });
              }
            }
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
          ),
        ),
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

              final limitMinX =
                  cropItem.rightTopX - dx < rectangleCropItemLimit ||
                      dx < cropLimit;
              final limitMinY =
                  cropItem.leftBottomY - dy < rectangleCropItemLimit ||
                      dy < cropLimit;

              final update = CropAreaItem(
                leftTopX: limitMinX ? cropItem.leftTopX : dx,
                leftTopY: limitMinY ? cropItem.leftTopY : dy,
                rightTopX: cropItem.rightTopX,
                rightTopY: limitMinY ? cropItem.rightTopY : dy,
                rightBottomX: cropItem.rightBottomX,
                rightBottomY: cropItem.rightBottomY,
                leftBottomX: limitMinX ? cropItem.leftBottomX : dx,
                leftBottomY: cropItem.leftBottomY,
              );

              setState(() {
                cropItem = update;
                widget.controller.updateCropAreaItem(update);
              });
            },
            child: CropControlPoint(pointShape: 1),
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

              final limitMinX =
                  dx - cropItem.leftTopX < rectangleCropItemLimit ||
                      dx > box.size.width - cropLimit;
              final limitMinY =
                  cropItem.rightBottomY - dy < rectangleCropItemLimit ||
                      dy < cropLimit;

              final update = CropAreaItem(
                leftTopX: cropItem.leftTopX,
                leftTopY: limitMinY ? cropItem.leftTopY : dy,
                rightTopX: limitMinX ? cropItem.rightTopX : dx,
                rightTopY: limitMinY ? cropItem.rightTopY : dy,
                rightBottomX: limitMinX ? cropItem.rightBottomX : dx,
                rightBottomY: cropItem.rightBottomY,
                leftBottomX: cropItem.leftBottomX,
                leftBottomY: cropItem.leftBottomY,
              );

              setState(() {
                cropItem = update;
                widget.controller.updateCropAreaItem(update);
              });
            },
            child: CropControlPoint(pointShape: 2),
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

              final limitMinX =
                  dx - cropItem.leftBottomX < rectangleCropItemLimit ||
                      dx > box.size.width - cropLimit;
              final limitMinY =
                  dy - cropItem.rightTopY < rectangleCropItemLimit ||
                      dy > box.size.height - cropLimit;

              final update = CropAreaItem(
                leftTopX: cropItem.leftTopX,
                leftTopY: cropItem.leftTopY,
                rightTopX: limitMinX ? cropItem.rightTopX : dx,
                rightTopY: cropItem.rightTopY,
                rightBottomX: limitMinX ? cropItem.rightBottomX : dx,
                rightBottomY: limitMinY ? cropItem.rightBottomY : dy,
                leftBottomX: cropItem.leftBottomX,
                leftBottomY: limitMinY ? cropItem.leftBottomY : dy,
              );

              setState(() {
                cropItem = update;
                widget.controller.updateCropAreaItem(update);
              });
            },
            child: CropControlPoint(pointShape: 3),
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

              final limitMinX =
                  cropItem.rightBottomX - dx < rectangleCropItemLimit ||
                      dx < cropLimit;
              final limitMinY =
                  dy - cropItem.leftTopY < rectangleCropItemLimit ||
                      dy > box.size.height - cropLimit;

              final update = CropAreaItem(
                leftTopX: limitMinX ? cropItem.leftTopX : dx,
                leftTopY: cropItem.leftTopY,
                rightTopX: cropItem.rightTopX,
                rightTopY: cropItem.rightTopY,
                rightBottomX: cropItem.rightBottomX,
                rightBottomY: limitMinY ? cropItem.rightBottomY : dy,
                leftBottomX: limitMinX ? cropItem.leftBottomX : dx,
                leftBottomY: limitMinY ? cropItem.leftBottomY : dy,
              );

              setState(() {
                cropItem = update;
                widget.controller.updateCropAreaItem(update);
              });
            },
            child: CropControlPoint(pointShape: 4),
          ),
        ),
      ],
    );
  }
}
