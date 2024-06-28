import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picture_cropper/picture_cropper.dart';

import '../common/enums.dart';
import '../common/picture_path_item.dart';

class PictureCropperControllerFactory {
  static PictureCropperController createController({
    void Function(Uint8List)? onSelectedImage,
  }) {
    return PictureCropperController._(onSelectedImage: onSelectedImage);
  }
}

class PictureCropperController extends ChangeNotifier {
  /// Constructor
  PictureCropperController._({this.onSelectedImage}) {
    if (onSelectedImage != null) {
      initializeControllerFuture = _initializeCamera();
    }
    _isToggled = false;
  }

  /// Common
  static PicturePathItem _picturePathItem = PicturePathItem();
  PicturePathItem get picturePathItem => _picturePathItem;

  setPicturePathItem(PicturePathItem picturePathItem) {
    _picturePathItem = picturePathItem;
  }

  static Uint8List _imageBytes = Uint8List(0);
  Uint8List get imageBytes => _imageBytes;

  setImageBytes(Uint8List bytes) {
    _imageBytes = bytes;
  }

  /// Picker
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;
  CameraLensDirection _direction = CameraLensDirection.back;
  Future<void>? initializeControllerFuture;
  final void Function(Uint8List)? onSelectedImage;

  Future<void> _initializeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }
    final cameras = await availableCameras();
    final cameraDescription = cameras.firstWhere(
      (description) => description.lensDirection == _direction,
    );
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
    );
    await _cameraController!.initialize();
  }

  Future<void> toggleCameraDirection() async {
    _direction = (_direction == CameraLensDirection.back)
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    await _initializeCamera();
  }

  Future<void> takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      final bytes = await File(image.path).readAsBytes();
      _imageBytes = bytes;
      onSelectedImage?.call(bytes);
    } catch (e) {
      print(e);
    }
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      _imageBytes = bytes;
      onSelectedImage?.call(bytes);
    }
  }

  PictureCropGuideType _cropGuideType = PictureCropGuideType.qr;
  PictureCropGuideType get cropGuideType => _cropGuideType;
  void changeCropGuideLineType(PictureCropGuideType type) {
    _cropGuideType = type;
  }

  /// Editor
  bool _isIrregularCrop = false;
  bool get isIrregularCrop => _isIrregularCrop;
  bool _isToggled = false;
  bool get isToggled => _isToggled;
  void toggleIrregularCrop(bool isOn) {
    _isIrregularCrop = isOn;
    _isToggled = true;
  }

  void pictureEditorControllerDispose() {
    _cameraController?.dispose();
  }
}
