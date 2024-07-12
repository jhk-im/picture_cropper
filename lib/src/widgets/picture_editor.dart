import 'package:flutter/material.dart';
import 'package:picture_cropper/src/controller/picture_cropper_controller.dart';
import 'package:picture_cropper/src/widgets/crop/irregular_crop.dart';
import 'package:picture_cropper/src/widgets/crop/rectangle_crop.dart';

/// [PictureEditor] is a widget used to edit the coordinates for cropping.
/// The [controller] is used to determine the crop type and access the crop path.
/// [cropBackgroundColor] determines the background color during cropping.
class PictureEditor extends StatefulWidget {
  final PictureCropperController controller;
  final Color imageBackgroundColor;

  const PictureEditor({
    super.key,
    required this.controller,
    this.imageBackgroundColor = Colors.transparent,
  });

  @override
  State<PictureEditor> createState() => _PictureEditorState();
}

class _PictureEditorState extends State<PictureEditor> {
  double _scale = 1.0;
  double _baseScale = 1.0;

  @override
  void initState() {
    widget.controller.addListener(_controllerListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    super.dispose();
  }

  void _controllerListener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Front Camera Horizontal Flip
    double x = 1.0;
    double y = 1.0;
    if (widget.controller.isFrontCamera && widget.controller.isTakePicture) {
      x = -1.0;
      y = 1.0;
    }

    return GestureDetector(
      onScaleStart: (ScaleStartDetails details) {
        // _baseRotation = _rotation;
        _baseScale = _scale;
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        setState(() {
          final updateScale = _baseScale * details.scale;
          if (updateScale < 5 && updateScale > 0.5) {
            _scale = updateScale;
            // widget.controller.cropAreaItem.scale = _scale;
          }
          // _rotation = _baseRotation + details.rotation;
        });
      },
      child: Container(
        color: widget.imageBackgroundColor,
        width: widget.controller.renderBoxWidth,
        height: widget.controller.renderBoxHeight,
        child: Stack(
          children: [
            Transform(
              transform: Matrix4.identity()..scale(x, y),
              //..rotateZ(_rotation)
              //..scale(_scale),
              alignment: Alignment.center,
              child: Image.memory(
                widget.controller.imageBytes,
                width: widget.controller.renderBoxWidth,
                height: widget.controller.renderBoxHeight,
                fit: BoxFit.contain,
              ),
            ),
            widget.controller.isIrregularCrop
                ? IrregularCrop(controller: widget.controller)
                : RectangleCrop(controller: widget.controller),
          ],
        ),
      ),
    );
  }
}
