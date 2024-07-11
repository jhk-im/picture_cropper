import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:picture_cropper/src/controllers/picture_cropper_controller.dart';

/// [PictureCrop] is a widget that displays the edited image as a [ui.Image] from [PictureEditor].
/// The [controller] is used to access the original image bytes and crop path information.
/// [isShowImage] is boolean value where it's not necessary to display the image.
/// The [progressColor] adds a color for the progress indicator when it's necessary during image loading. (default is transparent)
/// [onCropped] is used when the final [ui.Image] is needed.
class PictureCrop extends StatefulWidget {
  final PictureCropperController controller;
  final Future<void> Function(ui.Image) onCropped;
  final bool isShowImage;
  final Color? progressColor;

  PictureCrop({
    super.key,
    required this.controller,
    this.isShowImage = true,
    this.progressColor,
    required this.onCropped,
  });

  @override
  State<PictureCrop> createState() => _PictureCropState();
}

class _PictureCropState extends State<PictureCrop> {
  Path _cropAreaPath = Path();
  Color progressColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    final item = widget.controller.cropAreaItem;
    _cropAreaPath = Path()
      ..moveTo(item.leftTopX, item.leftTopY)
      ..lineTo(item.rightTopX, item.rightTopY)
      ..lineTo(item.rightBottomX, item.rightBottomY)
      ..lineTo(item.leftBottomX, item.leftBottomY)
      ..lineTo(item.leftTopX, item.leftTopY)
      ..close();

    if (widget.progressColor != null) {
      progressColor = widget.progressColor!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: widget.controller.isTakePicture
          ? _loadCropImage()
          : _loadSelectCropImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          ui.Image image = snapshot.data!;
          widget.onCropped(image);
          return widget.isShowImage
              ? Center(
                  child: RawImage(
                    width: widget.controller.renderBoxWidth,
                    height: widget.controller.renderBoxHeight,
                    image: image,
                    fit: BoxFit.contain,
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(
                  color: progressColor,
                ));
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: progressColor,
          ));
        }
      },
    );
  }

  /// This method converts [Uint8List] bytes to a [ui.Image] and image crop.
  /// takePictureImage
  Future<ui.Image> _loadCropImage() async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(widget.controller.imageBytes,
        (ui.Image image) async {
      /// STEP 1
      /// ui.image width, height
      final imageWidth = image.width.toDouble();
      final imageHeight = image.height.toDouble();

      /// renderBox width, height to match the ratio of _cropPathArea
      final renderBoxWidth = widget.controller.renderBoxWidth;
      final renderBoxHeight = widget.controller.renderBoxHeight;

      /// Create a PictureRecorder to record the drawing
      final ui.PictureRecorder recorder = ui.PictureRecorder();

      /// Create a canvas with the image size
      final Canvas canvas =
          Canvas(recorder, Rect.fromLTWH(0, 0, imageWidth, imageHeight));

      /// Scale x, y for the image size relative to renderBox size
      final double scaleX = imageWidth / renderBoxWidth;
      final double scaleY = imageHeight / renderBoxHeight;

      /// Create a matrix with the specified scale
      final Matrix4 scaleMatrix = Matrix4.identity()..scale(scaleX, scaleY);

      /// Apply _cropAreaPath to the scaleMatrix to create a new path
      final Path imageCropAreaPath =
          _cropAreaPath.transform(scaleMatrix.storage);

      /// Draw only the area within imageCropAreaPath
      canvas.clipPath(imageCropAreaPath);

      /// Set the source area of the original image
      final Rect srcRect = Rect.fromLTWH(0, 0, imageWidth, imageHeight);
      final Rect dstRect = Rect.fromLTWH(0, 0, imageWidth, imageHeight);

      /// Draw the clipped image
      canvas.drawImageRect(image, srcRect, dstRect, Paint());

      /// End recording and return the Picture representing the drawing
      final ui.Picture picture = recorder.endRecording();

      /// Convert the Picture object to a ui.Image
      final ui.Image fullImage =
          await picture.toImage(imageWidth.toInt(), imageHeight.toInt());

      /// STEP 2
      /// Create a Rect of the area corresponding to imageCropAreaPath in fullImage
      final ui.Rect bounds = imageCropAreaPath.getBounds();

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

  /// This method converts [Uint8List] bytes to a [ui.Image] and image crop.
  /// pickFromGallery
  Future<ui.Image> _loadSelectCropImage() async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(widget.controller.imageBytes,
        (ui.Image image) async {
      /// STEP 1
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

      /// Set the background color to grey
      canvas.drawRect(Rect.fromLTWH(0, 0, canvasWidth, canvasHeight), Paint());

      /// Create a matrix with the specified scale
      final Matrix4 scaleMatrix = Matrix4.identity()
        ..scale(canvasScaleX, canvasScaleY);

      /// Apply the scale matrix to the cropAreaPath
      final Path scaledCropAreaPath =
          _cropAreaPath.transform(scaleMatrix.storage);

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
}
