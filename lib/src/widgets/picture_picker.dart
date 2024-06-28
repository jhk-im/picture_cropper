import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../controllers/picture_cropper_controller.dart';
import 'crop/camera_crop_guideline.dart';

class PicturePicker extends StatefulWidget {
  final PictureCropperController controller;
  final double radius;
  final double margin;
  final Color? cropBackgroundColor;

  const PicturePicker({
    super.key,
    required this.controller,
    this.radius = 8,
    this.margin = 16,
    this.cropBackgroundColor,
  });

  @override
  State<PicturePicker> createState() => _PicturePickerState();
}

class _PicturePickerState extends State<PicturePicker> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return FutureBuilder<void>(
        future: widget.controller.initializeControllerFuture,
        builder: (context, snapshot) {
          return Stack(
            children: [
              SizedBox(
                width: width,
                height: height,
                child: snapshot.connectionState == ConnectionState.done &&
                        widget.controller.cameraController != null &&
                        widget.controller.cameraController!.value.isInitialized
                    ? CameraPreview(widget.controller.cameraController!)
                    : Container(),
              ),
              CameraCropGuideline(
                cropGuideType: widget.controller.cropGuideType,
                radius: widget.radius,
                margin: widget.margin,
                backgroundColor:
                    widget.cropBackgroundColor ?? Colors.black.withAlpha(180),
                onUpdatePicturePathItem: (picturePathItem) {
                  widget.controller.setPicturePathItem(picturePathItem);
                },
              ),
            ],
          );
        });
  }
}
