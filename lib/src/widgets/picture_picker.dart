import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../controllers/picture_cropper_controller.dart';
import 'crop/camera_crop_guideline.dart';

/// [PicturePicker] is a widget used for taking photos and picking images from the gallery.
/// It is recommended to use a stateful widget to ensure the camera direction toggle method functions correctly.
/// The [controller] is used for taking photos, accessing the gallery, camera direction toggle, and changing the shooting guidelines.
/// [guideLineRadius] sets the radius of the shooting guideline.
/// [guideLineMargin] sets the margin of the shooting guideline.
/// [guideLineBackgroundColor] sets the background color of the shooting guideline.
class PicturePicker extends StatefulWidget {
  final PictureCropperController controller;
  final double guideLineRadius;
  final double guideLineMargin;
  final Color? guideLineBackgroundColor;

  const PicturePicker({
    super.key,
    required this.controller,
    this.guideLineRadius = 8,
    this.guideLineMargin = 16,
    this.guideLineBackgroundColor,
  });

  @override
  State<PicturePicker> createState() => _PicturePickerState();
}

class _PicturePickerState extends State<PicturePicker> {
  @override
  void initState() {
    widget.controller.addListener(_initializeCamera);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_initializeCamera);
    super.dispose();
  }

  void _initializeCamera() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: widget.controller.initializeControllerFuture,
        builder: (context, snapshot) {
          return Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: snapshot.connectionState == ConnectionState.done &&
                        widget.controller.cameraController != null &&
                        widget.controller.cameraController!.value.isInitialized
                    ? CameraPreview(widget.controller.cameraController!)
                    : Container(),
              ),
              CameraCropGuideline(
                cropGuideLineType: widget.controller.cropGuideType,
                radius: widget.guideLineRadius,
                margin: widget.guideLineMargin,
                backgroundColor: widget.guideLineBackgroundColor ??
                    Colors.black.withAlpha(180),
                onUpdatePicturePathItem: (picturePathItem) {
                  widget.controller.updatePicturePathItem(picturePathItem);
                },
              ),
            ],
          );
        });
  }
}
