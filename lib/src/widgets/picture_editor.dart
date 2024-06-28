import 'package:flutter/material.dart';

import '../../picture_cropper.dart';
import 'crop/irregular_crop.dart';
import 'crop/rectangle_crop.dart';

class PictureProEditor extends StatefulWidget {
  final PictureCropperController controller;
  final Clip clipBehavior;
  final Color? cropBackgroundColor;

  const PictureProEditor({
    super.key,
    required this.controller,
    this.clipBehavior = Clip.hardEdge,
    this.cropBackgroundColor,
  });

  @override
  State<PictureProEditor> createState() => _PictureProEditorState();
}

class _PictureProEditorState extends State<PictureProEditor> {
  final GlobalKey _stackKey = GlobalKey();
  Size? _size;
  double _scale = 1.0;
  double _baseScale = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_getStackSize);
  }

  void _getStackSize(_) {
    final RenderBox renderBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox;
    setState(() {
      _size = renderBox.size;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            widget.controller.picturePathItem.scale = _scale;
          }
          // _rotation = _baseRotation + details.rotation;
        });
      },
      child: Stack(
        key: _stackKey,
        children: [
          Transform(
            transform: Matrix4.identity(),
            //..rotateZ(_rotation)
            //..scale(_scale),
            alignment: Alignment.center,
            child: Image.memory(
              widget.controller.imageBytes,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.contain,
            ),
          ),
          if (_size != null) ...{
            widget.controller.isIrregularCrop
                ? IrregularCrop(
                    clipBehavior: widget.clipBehavior,
                    width: _size?.width ?? 0,
                    height: _size?.height ?? 0,
                    picturePathItem: widget.controller.picturePathItem,
                    backgroundColor: widget.cropBackgroundColor ??
                        Colors.black.withAlpha(180),
                    isToggled: widget.controller.isToggled,
                    onUpdatePicturePathItem: (cropAreaClipItem) {
                      cropAreaClipItem.scale = _scale;
                      widget.controller.setPicturePathItem(cropAreaClipItem);
                    },
                  )
                : RectangleCrop(
                    clipBehavior: widget.clipBehavior,
                    width: _size?.width ?? 0,
                    height: _size?.height ?? 0,
                    picturePathItem: widget.controller.picturePathItem,
                    backgroundColor: widget.cropBackgroundColor ??
                        Colors.black.withAlpha(180),
                    isToggled: widget.controller.isToggled,
                    onUpdatePicturePathItem: (cropAreaClipItem) {
                      cropAreaClipItem.scale = _scale;
                      widget.controller.setPicturePathItem(cropAreaClipItem);
                    },
                  ),
          }
        ],
      ),
    );
  }
}
