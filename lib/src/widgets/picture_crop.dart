import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../picture_cropper.dart';

class PictureCrop extends StatefulWidget {
  final PictureCropperController controller;
  final void Function(ui.Image) onCropped;

  PictureCrop({
    super.key,
    required this.controller,
    required this.onCropped,
  });

  @override
  State<PictureCrop> createState() => _PictureCropState();
}

class _PictureCropState extends State<PictureCrop> {
  final GlobalKey _renderBoxKey = GlobalKey();
  Path _cropPath = Path();
  Size _renderBoxSize = ui.Size(0, 0);

  void _getStackSize(_) {
    final RenderBox renderBox =
        _renderBoxKey.currentContext?.findRenderObject() as RenderBox;
    setState(() {
      _renderBoxSize = renderBox.size;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_getStackSize);
    final item = widget.controller.picturePathItem;
    _cropPath = Path()
      ..moveTo(item.leftTopX, item.leftTopY)
      ..lineTo(item.rightTopX, item.rightTopY)
      ..lineTo(item.rightBottomX, item.rightBottomY)
      ..lineTo(item.leftBottomX, item.leftBottomY)
      ..lineTo(item.leftTopX, item.leftTopY)
      ..close();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      key: _renderBoxKey,
      future: _loadImage(widget.controller.imageBytes,
          widget.controller.picturePathItem.scale),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          ui.Image image = snapshot.data!;
          widget.onCropped(image);
          return Center(
            child: RawImage(
              image: image,
              fit: BoxFit.contain,
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<ui.Image> _loadImage(Uint8List img, double scale) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image image) async {
      // 스케일 적용
      final recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      final double scaledWidth = image.width * scale;
      final double scaledHeight = image.height * scale;

      final Rect srcRect =
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      final Rect dstRect = Rect.fromLTWH(0, 0, scaledWidth, scaledHeight);

      canvas.drawImageRect(image, srcRect, dstRect, Paint());

      final ui.Picture picture = recorder.endRecording();
      final ui.Image scaledImage =
          await picture.toImage(scaledWidth.toInt(), scaledHeight.toInt());
      final cropImage = await _getImageFromCustomPainter(scaledImage);
      completer.complete(cropImage);
    });
    return completer.future;
  }

  Future<ui.Image> _getImageFromCustomPainter(
    ui.Image image,
  ) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder,
        Rect.fromLTWH(0, 0, _renderBoxSize.width, _renderBoxSize.height));

    final CropPainter painter = CropPainter(image,
        widget.controller.picturePathItem.scale, _cropPath, _renderBoxSize);
    painter.paint(canvas, _renderBoxSize);

    final ui.Picture picture = recorder.endRecording();

    final ui.Rect bounds = _cropPath.getBounds();
    final ui.Image fullImage = await picture.toImage(
        _renderBoxSize.width.toInt(), _renderBoxSize.height.toInt());

    final ui.PictureRecorder croppedRecorder = ui.PictureRecorder();
    final Canvas croppedCanvas = Canvas(
        croppedRecorder, Rect.fromLTWH(0, 0, bounds.width, bounds.height));
    final Paint paint = Paint();
    final Rect srcRect =
        Rect.fromLTWH(bounds.left, bounds.top, bounds.width, bounds.height);
    final Rect dstRect = Rect.fromLTWH(0, 0, bounds.width, bounds.height);
    croppedCanvas.drawImageRect(fullImage, srcRect, dstRect, paint);

    final ui.Picture croppedPicture = croppedRecorder.endRecording();
    final ui.Image croppedImage = await croppedPicture.toImage(
        bounds.width.toInt(), bounds.height.toInt());

    return croppedImage;
  }
}

class CropPainter extends CustomPainter {
  final ui.Image image;
  final double scale;
  final Path cropPath;
  final Size renderBoxSize;

  CropPainter(this.image, this.scale, this.cropPath, this.renderBoxSize);

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

    // Save the current canvas state
    canvas.save();

    // Clip the canvas to the path
    canvas.clipPath(transformedPath);

    final Rect srcRect = Rect.fromLTWH(0, 0, imageWidth, imageHeight);
    final Rect dstRect =
        Rect.fromLTWH(offsetX, offsetY, scaledImageWidth, scaledImageHeight);
    canvas.drawImageRect(image, srcRect, dstRect, Paint());

    // Restore the canvas to remove the clipping
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
