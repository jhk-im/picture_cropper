import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:picture_cropper/src/controller/picture_cropper_controller.dart';
import 'package:picture_cropper/src/widgets/crop/irregular_crop.dart';
import 'package:picture_cropper/src/widgets/crop/rectangle_crop.dart';

/// [PictureEditor] is a widget used to edit the coordinates for cropping.
/// The [controller] is used to determine the crop type and access the crop path.
/// [imageBackgroundColor] determines the background color during cropping.
class PictureEditor extends StatefulWidget {
  final PictureCropperController controller;
  final Color imageBackgroundColor;
  final Color? cropImageBackgroundColor;
  final void Function(ui.Image) onCropComplete;

  const PictureEditor({
    super.key,
    required this.controller,
    this.imageBackgroundColor = Colors.transparent,
    this.cropImageBackgroundColor,
    required this.onCropComplete,
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
    if (widget.controller.calledCreateCropImage) {
      _cropImage();
    } else {
      setState(() {});
    }
  }

  Future<void> _cropImage() async {
    // Widget Capture
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final cropImage = await _loadCropImage(pngBytes);
      widget.onCropComplete(cropImage);
    } catch (e) {
      print(e);
    }

    // Original Image
    //final cropImage = await _loadCropImage(widget.controller.originalImageBytes);
    //widget.onCropComplete(cropImage);
  }

  /// This method converts [Uint8List] bytes to a [ui.Image] and image crop.
  Future<ui.Image> _loadCropImage(Uint8List imageBytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageBytes, (ui.Image image) async {
      /// STEP 1
      /// cropAreaPath
      final item = widget.controller.cropAreaItem;
      final cropAreaPath = Path()
        ..moveTo(item.leftTopX, item.leftTopY)
        ..lineTo(item.rightTopX, item.rightTopY)
        ..lineTo(item.rightBottomX, item.rightBottomY)
        ..lineTo(item.leftBottomX, item.leftBottomY)
        ..lineTo(item.leftTopX, item.leftTopY)
        ..close();

      /// ui.image width, height
      final imageWidth = image.width.toDouble();
      final imageHeight = image.height.toDouble();

      /// renderBox width, height to match the ratio of _cropPathArea
      final renderBoxWidth = widget.controller.renderBoxWidth;
      final renderBoxHeight = widget.controller.renderBoxHeight;

      /// Calculate the scale factors to fit the image within the render box
      final double scaleX = renderBoxWidth / imageWidth;
      final double scaleY = renderBoxHeight / imageHeight;
      final double scale = scaleX < scaleY ? scaleX : scaleY;

      /// Calculate the new dimensions for the image based on the scale
      final double fittedWidth = imageWidth * scale;
      final double fittedHeight = imageHeight * scale;

      /// Calculate the offsets to center the image within the render box
      final double offsetX = (renderBoxWidth - fittedWidth) / 2;
      final double offsetY = (renderBoxHeight - fittedHeight) / 2;

      /// Calculate the margins relative to the original image size
      final double imageOffsetX = offsetX / scale;
      final double imageOffsetY = offsetY / scale;

      /// Calculate the canvas size
      final canvasWidth = imageWidth + (imageOffsetX * 2);
      final canvasHeight = imageHeight + (imageOffsetY * 2);

      /// Calculate the scale factors from renderBox to canvas
      final double canvasScaleX = canvasWidth / renderBoxWidth;
      final double canvasScaleY = canvasHeight / renderBoxHeight;

      /// Create a PictureRecorder to record the drawing
      final ui.PictureRecorder recorder = ui.PictureRecorder();

      /// Create a canvas with the image size
      final Canvas canvas =
          Canvas(recorder, Rect.fromLTWH(0, 0, canvasWidth, canvasHeight));

      /// Set the background color
      final paint = Paint()
        ..color = widget.cropImageBackgroundColor ?? Colors.transparent;
      canvas.drawRect(Rect.fromLTWH(0, 0, canvasWidth, canvasHeight), paint);

      /// Create a matrix with the specified scale
      final Matrix4 scaleMatrix = Matrix4.identity()
        ..scale(canvasScaleX, canvasScaleY);

      /// Apply the scale matrix to the cropAreaPath
      final Path scaledCropAreaPath =
          cropAreaPath.transform(scaleMatrix.storage);

      /// Clip the canvas to the scaled and shifted crop area path
      canvas.clipPath(scaledCropAreaPath);

      /// Set the source area of the original image
      final Rect srcRect = Rect.fromLTWH(0, 0, imageWidth, imageHeight);
      final Rect dstRect =
          Rect.fromLTWH(imageOffsetX, imageOffsetY, imageWidth, imageHeight);

      /// Draw the clipped image
      canvas.drawImageRect(image, srcRect, dstRect, Paint());

      /// End recording and return the Picture representing the drawing
      final ui.Picture picture = recorder.endRecording();

      /// Convert the Picture object to a ui.Image
      final ui.Image fullImage =
          await picture.toImage(canvasWidth.toInt(), canvasHeight.toInt());

      /// STEP 2
      /// Create a Rect of the area corresponding to scaledCropAreaPath in fullImage
      final ui.Rect bounds = scaledCropAreaPath.getBounds();

      /// Create a PictureRecorder to record the drawing
      final ui.PictureRecorder croppedRecorder = ui.PictureRecorder();

      /// Create a canvas with the size of the drawn area
      final Canvas croppedCanvas = Canvas(
          croppedRecorder, Rect.fromLTWH(0, 0, bounds.width, bounds.height));

      /// Full area
      final Rect croppedSrcRect =
          Rect.fromLTWH(bounds.left, bounds.top, bounds.width, bounds.height);

      /// Drawing area
      final Rect croppedDstRect =
          Rect.fromLTWH(0, 0, bounds.width, bounds.height);

      /// Draw the cropped image
      croppedCanvas.drawImageRect(
          fullImage, croppedSrcRect, croppedDstRect, Paint());

      /// End recording and return the Picture representing the drawing
      final ui.Picture croppedPicture = croppedRecorder.endRecording();

      /// Convert the Picture object to a ui.Image
      final cropImage = await croppedPicture.toImage(
          bounds.width.toInt(), bounds.height.toInt());

      /// Complete
      completer.complete(cropImage);
    });
    return completer.future;
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
                  widget.controller.originalImageBytes,
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
