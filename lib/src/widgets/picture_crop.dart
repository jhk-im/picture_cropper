import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:picture_cropper/src/common/picture_path_item.dart';

import '../../picture_cropper.dart';

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
  Path _cropPath = Path();
  Color progressColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    final item = widget.controller.picturePathItem;
    _cropPath = Path()
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
      future: _loadCropImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          ui.Image image = snapshot.data!;
          widget.onCropped(image);
          return widget.isShowImage
              ? Center(
                  child: RawImage(
                    image: image,
                    fit: widget.controller.isTakePicture
                        ? BoxFit.fill
                        : BoxFit.contain,
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
  Future<ui.Image> _loadCropImage() async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(widget.controller.imageBytes,
        (ui.Image image) async {
      final width = widget.controller.renderBoxWidth;
      final height = widget.controller.renderBoxHeight;
      final size = ui.Size(width, height);

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas =
          Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
      final _CropPainter painter = _CropPainter(image, _cropPath, size);
      painter.paint(canvas, size);

      final ui.Picture picture = recorder.endRecording();
      final ui.Rect bounds = _cropPath.getBounds();
      final ui.Image fullImage =
          await picture.toImage(width.toInt(), height.toInt());

      final ui.PictureRecorder croppedRecorder = ui.PictureRecorder();
      final Canvas croppedCanvas = Canvas(
          croppedRecorder, Rect.fromLTWH(0, 0, bounds.width, bounds.height));

      final Rect srcRect =
          Rect.fromLTWH(bounds.left, bounds.top, bounds.width, bounds.height);

      final Rect dstRect = Rect.fromLTWH(0, 0, bounds.width, bounds.height);
      croppedCanvas.drawImageRect(fullImage, srcRect, dstRect, Paint());

      final ui.Picture croppedPicture = croppedRecorder.endRecording();
      final cropImage = await croppedPicture.toImage(
          bounds.width.toInt(), bounds.height.toInt());

      completer.complete(cropImage);
    });
    return completer.future;
  }
}

/// [_CropPainter] is a custom painter used for drawing an image with crop path applied.
/// [image] is an Image created from [Uint8List] bytes.
/// [scale] is the information about Zoom in and Zoom out during editing.
/// [cropPath] is the coordinate information for the crop.
/// [renderBoxSize] is the size of the drawn image.
class _CropPainter extends CustomPainter {
  final ui.Image image;
  final Path cropPath;
  final Size renderBoxSize;

  _CropPainter(this.image, this.cropPath, this.renderBoxSize);

  @override
  void paint(Canvas canvas, Size size) {
    final double imageWidth = image.width.toDouble();
    final double imageHeight = image.height.toDouble();

    final double scaleX = renderBoxSize.width / imageWidth;
    final double scaleY = renderBoxSize.height / imageHeight;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    final double scaledImageWidth = imageWidth * scale;
    final double scaledImageHeight = imageHeight * scale;

    final double offsetX = (renderBoxSize.width - scaledImageWidth) / 2;
    final double offsetY = (renderBoxSize.height - scaledImageHeight) / 2;

    final Path transformedPath = cropPath.transform(Matrix4.identity().storage);

    canvas.save();

    canvas.clipPath(transformedPath);

    final Rect srcRect = Rect.fromLTWH(0, 0, imageWidth, imageHeight);
    final Rect dstRect =
        Rect.fromLTWH(offsetX, offsetY, scaledImageWidth, scaledImageHeight);
    canvas.drawImageRect(image, srcRect, dstRect, Paint());

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
