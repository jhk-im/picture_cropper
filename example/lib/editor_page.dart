import 'package:example/widgets/custom_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:picture_cropper/picture_cropper.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final pictureCropperController = PictureCropperController();
  bool _isVisibleBottomSheet = false;

  @override
  void initState() {
    pictureCropperController.resetEditorData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (!_isVisibleBottomSheet) ...{
                Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.all(24),
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, true);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 32,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            pictureCropperController.toggleIrregularCrop(false);
                            //_isFreeCrop = false;
                          });
                        },
                        child: Icon(
                          Icons.crop_free,
                          color: !pictureCropperController.isIrregularCrop
                              ? Colors.blue
                              : Colors.black,
                          size: 32,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            pictureCropperController.toggleIrregularCrop(true);
                          });
                        },
                        child: Icon(
                          Icons.zoom_out_map,
                          color: pictureCropperController.isIrregularCrop
                              ? Colors.blue
                              : Colors.black,
                          size: 32,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showBottomSheet(context);
                        },
                        child: const Icon(
                          Icons.edit,
                          color: Colors.black,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              },
              PictureEditor(
                controller: pictureCropperController,
                onEditComplete: (bytes) {
                  Navigator.pushNamed(context, '/crop');
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: InkWell(
                  onTap: () {
                    pictureCropperController.resetEditorData();
                  },
                  child: const Text('Reset image',
                      style: TextStyle(color: Colors.blue)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: InkWell(
                  onTap: pictureCropperController.capturePng,
                  child: const Icon(
                    Icons.next_plan,
                    color: Colors.black,
                    size: 82,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Future _showBottomSheet(BuildContext context) async {
    setState(() {
      _isVisibleBottomSheet = true;
    });

    await showModalBottomSheet(
      barrierColor: Colors.transparent,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CustomBottomSheet(
          renderBoxWidth: pictureCropperController.renderBoxWidth,
          renderBoxHeight: pictureCropperController.renderBoxHeight,
          currentScaleValue: pictureCropperController.editImageScale,
          currentRotateValue: pictureCropperController.editImageRotate,
          currentOffset: pictureCropperController.editImageOffset,
          onScaleChanged: (scale) {
            pictureCropperController.changeEditImageScale(scale);
          },
          onRotateChanged: (rotate) {
            pictureCropperController.changeEditImageRotate(rotate);
          },
          onOffsetChanged: (offset) {
            pictureCropperController.changeEditImageOffset(offset);
          },
        );
      },
    );

    setState(() {
      _isVisibleBottomSheet = false;
    });
  }
}
