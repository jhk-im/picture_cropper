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

  /// [_renderBoxSize] include width and height of shoot, edit, crop screens
  // static ui.Size _renderBoxSize = ui.Size(0, 0);
  // ui.Size get renderBoxSize => _renderBoxSize;

  static double _renderBoxWidth = 0;
  double get renderBoxWidth => _renderBoxWidth;

  static double _renderBoxHeight = 0;
  double get renderBoxHeight => _renderBoxHeight;

  /// [_guidelineMargin] Guideline margin in [PicturePicker]
  static double _guidelineMargin = 0;
  double get guidelineMargin => _guidelineMargin;

  void setRenderBoxSizeAndGuidelineMargin(
      double width, double height, double margin) {
    _renderBoxWidth = width;
    _renderBoxHeight = height;
    _guidelineMargin = margin;
  }

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
      ResolutionPreset.max,
    );

    await _cameraController!.initialize();
    notifyListeners(); // camera toggle notification
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

  /// Whether the [toggleIrregularCrop] method was called in the [PictureEditor].
  bool _isToggled = false;
  bool get isToggled => _isToggled;

  /// This method changes the type of crop in [PictureEditor].
  void toggleIrregularCrop(bool isOn, {bool isToggled = true}) {
    _isIrregularCrop = isOn;
    _isToggled = isToggled;
  }

  /// This method disposes of the [_cameraController] used in [PicturePicker].
  void pictureEditorControllerDispose() {
    _cameraController?.dispose();
  }

  /// This method initialize of the [PictureCropperController].
  void resetController() {
    _isToggled = false;
    _isIrregularCrop = false;
    _cropGuideType = PictureCropGuideLineType.qr;

    double qrWidth = renderBoxWidth - (guidelineMargin * 2);
    double left = guidelineMargin;
    double right = renderBoxWidth - guidelineMargin;
    double top = (renderBoxHeight / 2) - (qrWidth / 2);
    double bottom = top + qrWidth;

    _picturePathItem = PicturePathItem(
      leftTopX: left,
      leftTopY: top,
      rightTopX: right,
      rightTopY: top,
      rightBottomX: right,
      rightBottomY: bottom,
      leftBottomX: left,
      leftBottomY: bottom,
    );
  }

  /// Takes a Uint8List and returns the image extension type.
  String getImageTypeFromBytes(Uint8List data) {
    if (data[0] == 0x89 &&
        data[1] == 0x50 &&
        data[2] == 0x4E &&
        data[3] == 0x47 &&
        data[4] == 0x0D &&
        data[5] == 0x0A &&
        data[6] == 0x1A &&
        data[7] == 0x0A) {
      return 'png';
    }

    if (data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF) {
      return 'jpg';
    }

    if (data[0] == 0x47 &&
        data[1] == 0x49 &&
        data[2] == 0x46 &&
        (data[3] == 0x38 &&
            (data[4] == 0x39 || data[4] == 0x37) &&
            data[5] == 0x61)) {
      return 'gif';
    }

    if (data[0] == 0x42 && data[1] == 0x4D) {
      return 'bmp';
    }

    if (data[0] == 0x49 &&
        data[1] == 0x49 &&
        data[2] == 0x2A &&
        data[3] == 0x00) {
      return 'tiff';
    }

    if (data[0] == 0x4D &&
        data[1] == 0x4D &&
        data[2] == 0x00 &&
        data[3] == 0x2A) {
      return 'TIFF';
    }

    if (data[0] == 0x52 &&
        data[1] == 0x49 &&
        data[2] == 0x46 &&
        data[3] == 0x46 &&
        data[8] == 0x57 &&
        data[9] == 0x45 &&
        data[10] == 0x42 &&
        data[11] == 0x50) {
      return 'webp';
    }

    if (data[4] == 0x66 &&
        data[5] == 0x74 &&
        data[6] == 0x79 &&
        data[7] == 0x70 &&
        data[8] == 0x68 &&
        data[9] == 0x65 &&
        data[10] == 0x69 &&
        data[11] == 0x63) {
      return 'heif';
    }

    if (data[4] == 0x66 &&
        data[5] == 0x74 &&
        data[6] == 0x79 &&
        data[7] == 0x70 &&
        data[8] == 0x6D &&
        data[9] == 0x69 &&
        data[10] == 0x66 &&
        data[11] == 0x31) {
      return 'heic';
    }

    return 'unknown';
  }
}
