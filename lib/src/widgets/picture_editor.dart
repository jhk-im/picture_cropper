import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:picture_cropper/src/controller/picture_cropper_controller.dart';
import 'package:picture_cropper/src/widgets/crop/irregular_crop.dart';
import 'package:picture_cropper/src/widgets/crop/rectangle_crop.dart';

/// [PictureEditor] is a widget used to edit the coordinates for cropping.
/// The [controller] is used to determine the crop type and access the crop path.
/// [cropBackgroundColor] determines the background color during cropping.
class PictureEditor extends StatefulWidget {
  final PictureCropperController controller;
  final Color imageBackgroundColor;
  final Function(Uint8List) onEditComplete;

  const PictureEditor({
    super.key,
    required this.controller,
    this.imageBackgroundColor = Colors.transparent,
    required this.onEditComplete,
  });

  @override
  State<PictureEditor> createState() => _PictureEditorState();
}

class _PictureEditorState extends State<PictureEditor> {
  final GlobalKey _globalKey = GlobalKey();

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
    if (widget.controller.calledCapturePng) {
      _capturePng();
    } else {
      setState(() {});
    }
  }

  Future<void> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      widget.controller.setCapturePng(pngBytes);
      widget.onEditComplete(pngBytes);
    } catch (e) {
      print(e);
    }
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
    return Stack(
      children: [
        RepaintBoundary(
          key: _globalKey,
          child: ClipRect(
            child: Container(
              color: widget.imageBackgroundColor,
              width: widget.controller.renderBoxWidth,
              height: widget.controller.renderBoxHeight,
              child: Transform(
                transform: Matrix4.identity()
                  ..scale(x, y)
                  ..translate(widget.controller.editImageOffset.dx,
                      widget.controller.editImageOffset.dy)
                  ..scale(widget.controller.editImageScale)
                  ..rotateZ(widget.controller.editImageRotate),
                alignment: Alignment.center,
                child: Image.memory(
                  widget.controller.imageBytes,
                  width: widget.controller.renderBoxWidth,
                  height: widget.controller.renderBoxHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        Container(
          color: widget.imageBackgroundColor,
          width: widget.controller.renderBoxWidth,
          height: widget.controller.renderBoxHeight,
          child: widget.controller.isIrregularCrop
              ? IrregularCrop(controller: widget.controller)
              : RectangleCrop(controller: widget.controller),
        ),
      ],
    );
  }
}
