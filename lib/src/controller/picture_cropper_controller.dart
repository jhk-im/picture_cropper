import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picture_cropper/picture_cropper.dart';
import 'package:picture_cropper/src/common/enums.dart';
import 'package:picture_cropper/src/model/crop_area_item.dart';

/// This class includes methods for camera shooting, gallery picking, and editing.
/// It is mandatory to use it in [PicturePicker], [PictureEditor], and [PictureCrop] widgets.
class PictureCropperController extends ChangeNotifier {
  /// [onSelectedImage] callback is used only in the [PicturePicker] widget.
  /// [onCreateCropImage] callback is used only in the [PictureEditor] widget.
  /// If the callback is provided outside of [PicturePicker], the [cameraController] will be unnecessarily initialized.
  PictureCropperController({this.onSelectedImage, this.onCreateCropImage}) {
    if (onSelectedImage != null) {
      _renderBoxWidth = 0;
      initializeControllerFuture = _initializeCamera();
    } else if (onCreateCropImage != null) {
      resetEditorData();
    }
  }

  /// [PictureCropperController]------------------------------------------------
  /// Contains guide line and crop coordinate information and is used only within the package.
  /// It is used in [PicturePicker], [PictureEditor], and [PictureCrop] widgets.
  static CropAreaItem _cropAreaItem = CropAreaItem();
  CropAreaItem get cropAreaItem => _cropAreaItem;

  /// Contains the original pictures as Unit8List.
  static Uint8List _imageBytes = Uint8List(0);
  Uint8List get imageBytes => _imageBytes;

  /// Contains the edited pictures as Unit8List.
  static Uint8List _cropImageBytes = Uint8List(0);
  Uint8List get cropImageBytes => _cropImageBytes;

  /// Check take picture or pick from gallery,
  static bool _isTakePicture = false;
  bool get isTakePicture => _isTakePicture;

  /// Check camera direction
  static bool _isFrontCamera = false;
  bool get isFrontCamera => _isFrontCamera;

  /// Size of [PicturePicker], [PictureEditor], [PictureCrop] screens renderBox
  static double _renderBoxWidth = 0.0;
  double get renderBoxWidth => _renderBoxWidth;
  static double _renderBoxHeight = 0.0;
  double get renderBoxHeight => _renderBoxHeight;

  /// Guideline margin in [PicturePicker]
  static double _guidelineMargin = 0.0;

  /// Guideline radius in [PicturePicker]
  static double _guidelineRadius = 0.0;
  double get guidelineRadius => _guidelineRadius;

  /// Card Guideline ratio in [PicturePicker], [PictureEditor]
  static double _guidelineRatio = 0.0;

  /// Guideline backgroundColor in [PicturePicker], [PictureEditor]
  static Color _guideBackgroundColor = Colors.transparent;
  Color get guideBackgroundColor => _guideBackgroundColor;

  /// Edit image scale in [PictureEditor]
  static double _editImageScale = 1.0;
  double get editImageScale => _editImageScale;

  /// Edit image rotate in [PictureEditor]
  static double _editImageRotate = 0.0;
  double get editImageRotate => _editImageRotate;

  /// Edit image offset x,y in [PictureEditor]
  static Offset _editImageOffset = Offset.zero;
  Offset get editImageOffset => _editImageOffset;

  /// [PicturePicker]-----------------------------------------------------------
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

  /// Crop Guideline data set in [PicturePicker]
  void initialCropData(
      {required double renderBoxWidth,
      required double renderBoxHeight,
      required double guidelineMargin,
      required double guidelineRadius,
      required double guidelineRatio,
      Color? guideBackgroundColor}) {
    if (_renderBoxWidth > 0) return;
    _renderBoxWidth = renderBoxWidth;
    _renderBoxHeight = renderBoxHeight;
    _guidelineMargin = guidelineMargin;
    _guidelineRadius = guidelineRadius;
    _guidelineRatio = guidelineRatio;
    _guideBackgroundColor = guideBackgroundColor ?? Colors.black.withAlpha(180);
    changeCropGuideLineType(CropGuideLineType.qr, isInitial: true);
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

  /// [CropGuideLineType] includes four types: qr, v-card, h-card, clear.
  CropGuideLineType _cropGuidelineType = CropGuideLineType.qr;
  CropGuideLineType get cropGuidelineType => _cropGuidelineType;

  /// This method changes the type of camera guideline in [PicturePicker].
  void changeCropGuideLineType(CropGuideLineType type,
      {bool isInitial = false}) {
    _cropGuidelineType = type;

    double qrWidth = renderBoxWidth - (_guidelineMargin * 2);
    double shortLine = qrWidth * _guidelineRatio;
    double left = 0;
    double top = 0;
    double right = 0;
    double bottom = 0;

    switch (_cropGuidelineType) {
      case CropGuideLineType.qr:
        left = _guidelineMargin;
        right = renderBoxWidth - _guidelineMargin;
        top = (renderBoxHeight - qrWidth) / 2;
        bottom = top + qrWidth;
      case CropGuideLineType.verticalCard:
        left = (renderBoxWidth - shortLine) / 2;
        right = left + shortLine;
        top = (renderBoxHeight - qrWidth) / 2;
        bottom = top + qrWidth;
      case CropGuideLineType.card:
        left = _guidelineMargin;
        right = renderBoxWidth - _guidelineMargin;
        top = (renderBoxHeight - shortLine) / 2;
        bottom = top + shortLine;
      default:
        left = _guidelineMargin;
        right = renderBoxWidth - _guidelineMargin;
        top = _guidelineMargin;
        bottom = renderBoxHeight - _guidelineMargin;
    }

    _cropAreaItem = CropAreaItem(
      leftTopX: left,
      leftTopY: top,
      rightTopX: right,
      rightTopY: top,
      rightBottomX: right,
      rightBottomY: bottom,
      leftBottomX: left,
      leftBottomY: bottom,
    );

    print('_cropAreaItem -> $_cropAreaItem');

    if (!isInitial) notifyListeners();
  }

  /// [PictureEditor]-----------------------------------------------------------
  /// Used in [PictureEditor] for capture edit image.
  bool _calledCreateCropImage = false;
  bool get calledCapturePng => _calledCreateCropImage;
  final void Function(Uint8List)? onCreateCropImage;

  /// Do not call this method from outside the package.
  /// Calling this method from outside the package may cause the package to not work properly.
  /// This method update the crop area item in [PictureEditor]
  void updateCropAreaItem(CropAreaItem cropAreaItem) {
    _cropAreaItem = cropAreaItem;
  }

  /// Do not call this method from outside the package.
  /// Calling this method from outside the package may cause the package to not work properly.
  /// This method set the edit image bytes in [PictureEditor]
  void setCropImageBytes(Uint8List pngBytes) {
    _cropImageBytes = pngBytes;
    onCreateCropImage?.call(pngBytes);
  }

  /// This method changes the scale of image in [PictureEditor].
  void changeEditImageScale(double scale) {
    if (scale <= 3 || scale >= 0.3) {
      _editImageScale = scale;
      notifyListeners();
    }
  }

  /// This method changes the rotate of image in [PictureEditor].
  void changeEditImageRotate(double rotate) {
    if (rotate <= 3.15 || rotate >= -3.15) {
      _editImageRotate = rotate;
      notifyListeners();
    }
  }

  /// This method changes the offset of image in [PictureEditor].
  void changeEditImageOffset(Offset offset) {
    _editImageOffset = offset;
    notifyListeners();
  }

  /// this method is used for create crop png image in [PictureEditor]
  void createCropImage() {
    _calledCreateCropImage = true;
    notifyListeners();
    _calledCreateCropImage = false;
  }

  /// This method reset the editor data
  void resetEditorData() {
    _editImageScale = 1.0;
    _editImageRotate = 0.0;
    _editImageOffset = Offset.zero;
    notifyListeners();
  }

  bool _isIrregularCrop = false;
  bool get isIrregularCrop => _isIrregularCrop;

  /// This method changes the type of crop in [PictureEditor].
  void toggleIrregularCrop(bool isOn) {
    _isIrregularCrop = isOn;
    changeCropGuideLineType(CropGuideLineType.qr);
  }

  /// This method disposes of the [_cameraController] used in [PicturePicker].
  void pictureEditorControllerDispose() {
    _cameraController?.dispose();
  }

  /// [Utils]-------------------------------------------------------------------
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
