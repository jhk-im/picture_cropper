import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picture_cropper/picture_cropper.dart';

import '../common/picture_path_item.dart';

/// This class includes methods for camera shooting, gallery picking, and editing.
/// It is mandatory to use it in [PicturePicker], [PictureEditor], and [PictureCrop] widgets.
class PictureCropperController extends ChangeNotifier {
  /// [onSelectedImage] callback is used only in the [PicturePicker] widget.
  /// If the callback is provided outside of [PicturePicker], the [cameraController] will be unnecessarily initialized.
  PictureCropperController({this.onSelectedImage}) {
    if (onSelectedImage != null) {
      initializeControllerFuture = _initializeCamera();
    }
    _isToggled = false;
  }

  /// [_picturePathItem] contains guide line and crop coordinate information and is used only within the package.
  /// It is used in [PicturePicker], [PictureEditor], and [PictureCrop] widgets.
  static PicturePathItem _picturePathItem = PicturePathItem();
  PicturePathItem get picturePathItem => _picturePathItem;

  /// Do not call this method from outside the package.
  /// Calling this method from outside the package may cause the package to not work properly.
  updatePicturePathItem(PicturePathItem picturePathItem) {
    _picturePathItem = picturePathItem;
  }

  /// [_imageBytes] contains the original and edited pictures as Unit8List.
  static Uint8List _imageBytes = Uint8List(0);
  Uint8List get imageBytes => _imageBytes;

  /// [_isTakePicture] check take picture or pick from gallery,
  static bool _isTakePicture = false;
  bool get isTakePicture => _isTakePicture;

  /// [_isTakePicture] check camera direction
  static bool _isFrontCamera = false;
  bool get isFrontCamera => _isFrontCamera;

  /// Used in [PicturePicker] for camera shooting.
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;
  CameraLensDirection _direction = CameraLensDirection.back;
  Future<void>? initializeControllerFuture;
  final void Function(Uint8List)? onSelectedImage;

  /// This method initializes variables related to camera shooting in [PicturePicker].
  Future<void> _initializeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }
    final cameras = await availableCameras();
    final cameraDescription = cameras.firstWhere(
      (description) => description.lensDirection == _direction,
    );
    _isFrontCamera = _direction == CameraLensDirection.front;
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
    );
    await _cameraController!.initialize();
    notifyListeners();
  }

  /// This method toggles the camera direction in [PicturePicker].
  Future<void> toggleCameraDirection() async {
    _direction = (_direction == CameraLensDirection.back)
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    await _initializeCamera();
  }

  /// This method is used for taking pictures in [PicturePicker].
  Future<void> takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      final bytes = await File(image.path).readAsBytes();
      _imageBytes = bytes;
      _isTakePicture = true;
      onSelectedImage?.call(bytes);
    } catch (e) {
      print(e);
    }
  }

  /// This method is used to pick images from the gallery in [PicturePicker].
  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      _imageBytes = bytes;
      _isTakePicture = false;
      onSelectedImage?.call(bytes);
    }
  }

  /// [PictureCropGuideLineType] includes three types: qr, card, clear.
  PictureCropGuideLineType _cropGuideType = PictureCropGuideLineType.qr;
  PictureCropGuideLineType get cropGuideType => _cropGuideType;

  /// This method changes the type of camera guideline in [PicturePicker].
  void changeCropGuideLineType(PictureCropGuideLineType type) {
    _cropGuideType = type;
  }

  bool _isIrregularCrop = false;
  bool get isIrregularCrop => _isIrregularCrop;
  bool _isToggled = false;
  bool get isToggled => _isToggled;

  /// This method changes the type of crop in [PictureEditor].
  void toggleIrregularCrop(bool isOn) {
    _isIrregularCrop = isOn;
    _isToggled = true;
  }

  /// This method disposes of the [_cameraController] used in [PicturePicker].
  void pictureEditorControllerDispose() {
    _cameraController?.dispose();
  }
}
