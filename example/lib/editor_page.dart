import 'package:example/widgets/custom_slider.dart';
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

  double _scaleValue = 1.0;
  double _rotateValue = 0.0;
  Offset _offset = Offset.zero;

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
                          // _showBottomSheet(context);
                          setState(() {
                            _isVisibleBottomSheet = true;
                          });
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
                onCropComplete: (image) {
                  Navigator.pushNamed(
                    context,
                    '/crop',
                    arguments: image,
                  );
                },
              ),
              if (!_isVisibleBottomSheet) ...{
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: InkWell(
                    onTap: pictureCropperController.createCropImage,
                    child: const Icon(
                      Icons.next_plan,
                      color: Colors.black,
                      size: 82,
                    ),
                  ),
                ),
              } else ...{
                _editController()
              }
            ],
          ),
        ),
      );

  Widget _editController() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              const SizedBox(width: 80, child: Text('Scale')),
              Expanded(
                child: CustomSlider(
                  value: _scaleValue,
                  min: 0.3,
                  max: 1.7,
                  onChanged: (value) {
                    setState(() {
                      _scaleValue = value;
                    });
                    pictureCropperController.changeEditImageScale(value);
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 80, child: Text('Rotate')),
              Expanded(
                child: CustomSlider(
                  value: _rotateValue,
                  min: -3.15,
                  max: 3.15,
                  onChanged: (value) {
                    setState(() {
                      _rotateValue = value;
                    });
                    pictureCropperController.changeEditImageRotate(value);
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 80, child: Text('OffsetX')),
              Expanded(
                child: CustomSlider(
                  value: _offset.dx,
                  min: -pictureCropperController.renderBoxWidth,
                  max: pictureCropperController.renderBoxWidth,
                  onChanged: (value) {
                    setState(() {
                      _offset = Offset(value, _offset.dy);
                    });
                    pictureCropperController.changeEditImageOffset(_offset);
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 80, child: Text('OffsetY')),
              Expanded(
                child: CustomSlider(
                  value: _offset.dy,
                  min: -pictureCropperController.renderBoxHeight,
                  max: pictureCropperController.renderBoxHeight,
                  onChanged: (value) {
                    setState(() {
                      _offset = Offset(_offset.dx, value);
                    });
                    pictureCropperController.changeEditImageOffset(_offset);
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _rotateValue = 0.0;
                        _scaleValue = 1.0;
                        _offset = Offset.zero;
                      });
                      pictureCropperController.resetEditorData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).hintColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Image Reset',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isVisibleBottomSheet = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
