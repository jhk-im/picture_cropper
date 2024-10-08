import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:picture_cropper/picture_cropper.dart';
import 'package:picture_cropper/src/controller/picture_cropper_controller.dart';
import 'package:picture_cropper/src/widgets/crop/camera_crop_guideline.dart';

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
  final double guideLineRatio;
  final Color? guideLineBackgroundColor;
  final Function onSetOriginalImage;

  const PicturePicker({
    super.key,
    required this.controller,
    this.guideLineRadius = 8,
    this.guideLineMargin = 16,
    this.guideLineRatio = 0.64,
    this.guideLineBackgroundColor,
    required this.onSetOriginalImage,
  });

  @override
  State<PicturePicker> createState() => _PicturePickerState();
}

class _PicturePickerState extends State<PicturePicker> {
  double _scale = 1.0;
  double _previousScale = 1.0;

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
    if (widget.controller.calledSetOriginalImage) {
      widget.onSetOriginalImage.call();
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
      future: widget.controller.initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            widget.controller.cameraController != null &&
            widget.controller.cameraController!.value.isInitialized) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final renderBoxSize = constraints.biggest;
              final previewSize =
                  widget.controller.cameraController!.value.previewSize!;
              final double aspectRatio = previewSize.width / previewSize.height;
              final double width = renderBoxSize.width;
              final double height = width * aspectRatio;

              widget.controller.initialCropData(
                renderBoxWidth: width,
                renderBoxHeight: height,
                guidelineMargin: widget.guideLineMargin,
                guidelineRadius: widget.guideLineRadius,
                guidelineRatio: widget.guideLineRatio,
              );

              return GestureDetector(
                onScaleStart: (details) {
                  widget.controller.setIsPinchZoom(true);
                  _previousScale = _scale;
                },
                onScaleUpdate: (details) {
                  final scale = _previousScale * details.scale;
                  if (scale < 1) {
                    _scale = 1.0;
                  } else if (scale > 5) {
                    _scale = 5.0;
                  } else {
                    _scale = scale;
                  }
                  widget.controller.setCameraZoom(_scale);
                },
                onScaleEnd: (details) {
                  widget.controller.setIsPinchZoom(false);
                  _previousScale = 1.0;
                },
                child: Stack(
                  children: [
                    CameraPreview(widget.controller.cameraController!),
                    SizedBox(
                      width: width,
                      height: height,
                      child: CameraCropGuideline(
                          cropGuideLineType:
                              widget.controller.cropGuidelineType,
                          cropAreaItem: widget.controller.cropAreaItem,
                          radius: widget.controller.guidelineRadius,
                          backgroundColor: widget.guideLineBackgroundColor ??
                              Colors.black.withAlpha(180)),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return Container();
        }
      });
}
