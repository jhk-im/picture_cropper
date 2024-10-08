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

  double _blur = 0.0;
  double _temperature = 0.0;
  double _lighten = 0.0;

  double _grayscale = 0.0;
  double _brightness = 0.0;
  double _saturation = 1.0;
  bool _invert = false;

  double _scaleValue = 1.0;
  double _rotateValue = 0.0;
  Offset _offset = Offset.zero;

  bool _isLoading = false;

  void isLoading(bool value) {
    _isLoading = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: PictureEditor(
                  controller: pictureCropperController,
                  onCropComplete: (image) {
                    isLoading(false);
                    Navigator.pushNamed(
                      context,
                      '/crop',
                      arguments: image,
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
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
                            : Colors.white,
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
                            : Colors.white,
                        size: 32,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // _showBottomSheet(context);
                        setState(() {
                          _isVisibleBottomSheet = !_isVisibleBottomSheet;
                        });
                      },
                      child: Icon(
                        Icons.edit,
                        color:
                            _isVisibleBottomSheet ? Colors.blue : Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _isVisibleBottomSheet
                    ? _editController()
                    : Container(
                        width: 64,
                        height: 64,
                        margin: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, // 원형 배경
                          color: Colors.white, // 원하는 배경색 설정
                        ),
                        child: InkWell(
                          onTap: () {
                            isLoading(true);
                            pictureCropperController.createCropImage();
                          },
                          child: const Icon(
                            Icons.cut,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                      ),
              ),
              Visibility(
                visible: _isLoading,
                child: Stack(
                  children: <Widget>[
                    Opacity(
                      opacity: 0.5,
                      child: Container(
                        color: Colors.black,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _editController() {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 200,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 90, child: Text('Blur')),
                        Expanded(
                          child: Slider(
                            value: _blur,
                            min: 0,
                            max: 25,
                            onChanged: (value) {
                              setState(() {
                                _blur = value;
                              });
                              pictureCropperController
                                  .changeEditImageBlur(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 90, child: Text('Grayscale')),
                        Expanded(
                          child: Slider(
                            value: _grayscale,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (value) {
                              setState(() {
                                _grayscale = value;
                              });
                              pictureCropperController.changeEditImageFilter(
                                  _grayscale,
                                  _brightness,
                                  _saturation,
                                  _invert);
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 90, child: Text('Saturation')),
                        Expanded(
                          child: Slider(
                            value: _saturation,
                            min: 1.0,
                            max: 10.0,
                            onChanged: (value) {
                              setState(() {
                                _saturation = value;
                              });
                              pictureCropperController.changeEditImageFilter(
                                  _grayscale,
                                  _brightness,
                                  _saturation,
                                  _invert);
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 90, child: Text('Lighten')),
                        Expanded(
                          child: CustomSlider(
                            value: _lighten,
                            min: -20,
                            max: 20,
                            onChanged: (value) {
                              setState(() {
                                _lighten = value;
                              });
                              pictureCropperController
                                  .changeEditImageLighten(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 90, child: Text('Temperature')),
                        Expanded(
                          child: CustomSlider(
                            value: _temperature,
                            min: -0.5,
                            max: 0.5,
                            onChanged: (value) {
                              setState(() {
                                _temperature = value;
                              });
                              pictureCropperController
                                  .changeEditImageTemperature(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 90, child: Text('Brightness')),
                        Expanded(
                          child: CustomSlider(
                            value: _brightness,
                            min: -1.0,
                            max: 1.0,
                            onChanged: (value) {
                              setState(() {
                                _brightness = value;
                              });
                              pictureCropperController.changeEditImageFilter(
                                  _grayscale,
                                  _brightness,
                                  _saturation,
                                  _invert);
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 90, child: Text('Scale')),
                        Expanded(
                          child: CustomSlider(
                            value: _scaleValue,
                            min: 0.3,
                            max: 1.7,
                            onChanged: (value) {
                              setState(() {
                                _scaleValue = value;
                              });
                              pictureCropperController
                                  .changeEditImageScale(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 90, child: Text('Rotate')),
                        Expanded(
                          child: CustomSlider(
                            value: _rotateValue,
                            min: -3.15,
                            max: 3.15,
                            onChanged: (value) {
                              setState(() {
                                _rotateValue = value;
                              });
                              pictureCropperController
                                  .changeEditImageRotate(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 90, child: Text('OffsetX')),
                        Expanded(
                          child: CustomSlider(
                            value: _offset.dx,
                            min: -pictureCropperController.renderBoxWidth,
                            max: pictureCropperController.renderBoxWidth,
                            onChanged: (value) {
                              setState(() {
                                _offset = Offset(value, _offset.dy);
                              });
                              pictureCropperController
                                  .changeEditImageOffset(_offset);
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 90, child: Text('OffsetY')),
                        Expanded(
                          child: CustomSlider(
                            value: _offset.dy,
                            min: -pictureCropperController.renderBoxHeight,
                            max: pictureCropperController.renderBoxHeight,
                            onChanged: (value) {
                              setState(() {
                                _offset = Offset(_offset.dx, value);
                              });
                              pictureCropperController
                                  .changeEditImageOffset(_offset);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
                        _blur = 0.0;
                        _temperature = 0.0;
                        _lighten = 0.0;

                        _brightness = 0.0;
                        _grayscale = 0.0;
                        _saturation = 1.0;
                        _invert = false;

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
                      'Reset',
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
                        _invert = !_invert;
                      });
                      pictureCropperController.changeEditImageFilter(
                          _grayscale, _brightness, _saturation, _invert);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _invert
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).hintColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Invert',
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
