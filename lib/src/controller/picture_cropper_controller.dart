import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:exif/exif.dart';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picture_cropper/picture_cropper.dart';
import 'package:picture_cropper/src/model/crop_area_item.dart';

/// This class includes methods for camera shooting, gallery picking, and editing.
/// It is mandatory to use it in [PicturePicker], [PictureEditor] widgets.
class PictureCropperController extends ChangeNotifier {
  /// If the callback is provided outside of [PicturePicker], the [cameraController] will be unnecessarily initialized.
  PictureCropperController(
      {bool isPicker = false,
      CropGuideLineType initCropGuideLine = CropGuideLineType.qr}) {
    if (isPicker) {
      _renderBoxWidth = 0;
      _initCropGuideLine = initCropGuideLine;
      initializeControllerFuture = _initializeCamera();
    } else {
      resetEditorData();
      if (!isTakePicture) {
        _setGalleryCropAreaItem();
      }
    }
  }

  /// [PictureCropperController]------------------------------------------------
  /// Contains guide line and crop coordinate information and is used only within the package.
  /// It is used in [PicturePicker], [PictureEditor] widgets.
  static CropAreaItem _cropAreaItem = CropAreaItem();
  CropAreaItem get cropAreaItem => _cropAreaItem;

  /// Contains the original pictures as Unit8List.
  static Uint8List _originalImageBytes = Uint8List(0);
  Uint8List get originalImageBytes => _originalImageBytes;

  /// Check take picture or pick from gallery,
  static bool _isTakePicture = false;
  bool get isTakePicture => _isTakePicture;

  /// Check camera direction
  static bool _isFrontCamera = false;
  bool get isFrontCamera => _isFrontCamera;

  /// Size of [PicturePicker], [PictureEditor] screens renderBox
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

  /// [PicturePicker]-----------------------------------------------------------
  /// Used in [PicturePicker] for camera shooting.
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;
  CameraLensDirection _direction = CameraLensDirection.back;
  Future<void>? initializeControllerFuture;

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
      enableAudio: false,
    );

    await _cameraController!.initialize();
    notifyListeners(); // camera toggle notification
  }

  CropGuideLineType _initCropGuideLine = CropGuideLineType.qr;

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
    changeCropGuidelineType(_initCropGuideLine, isInitial: true);
  }

  /// This method toggles the camera direction in [PicturePicker].
  Future<void> toggleCameraDirection() async {
    _direction = (_direction == CameraLensDirection.back)
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    await _initializeCamera();
  }

  /// this method is used for create crop png image in [PictureEditor]
  bool _calledSetOriginalImage = false;
  bool get calledSetOriginalImage => _calledSetOriginalImage;
  void setOriginalImage() {
    _calledSetOriginalImage = true;
    notifyListeners();
    _calledSetOriginalImage = false;
  }

  /// This method is used for taking pictures in [PicturePicker].
  Future<void> takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      final Directory directory = await getTemporaryDirectory();
      final String newPath = '${directory.path}/picture_cropper_capture.jpg';
      final File capturedImage = File(image.path);
      await capturedImage.rename(newPath);
      final File newImage = File(newPath);
      final bytes = await newImage.readAsBytes();
      _originalImageBytes = bytes;
      _isTakePicture = true;
      setOriginalImage();
    } catch (e) {
      print(e);
    }
  }

  /// This method is used to pick images from the gallery in [PicturePicker].
  Future<void> pickImageFromGallery() async {
    _originalImageBytes = Uint8List(0);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      img.Image? image;
      if (pickedFile.path.endsWith('.gif')) {
        image = img.decodeGif(Uint8List.fromList(bytes), frame: 0);
        if (image != null) {
          final imageBytes = img.encodeJpg(image);
          _originalImageBytes = imageBytes;
        }
      } else {
        _originalImageBytes = bytes;
      }
      _isTakePicture = false;
      changeCropGuidelineType(CropGuideLineType.clear);
      setOriginalImage();
      await _deleteImageAndDirectory(pickedFile);
    }
  }

  /// This method delete image in cache
  Future<void> _deleteImageAndDirectory(XFile pickedFile) async {
    try {
      final file = File(pickedFile.path);
      if (await file.exists()) {
        await file.delete();
      }

      final directory = file.parent;

      if (await directory.exists()) {
        final contents = directory.listSync();
        if (contents.isEmpty) {
          await directory.delete();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  /// This method is used to set images from user image in [PicturePicker].
  void setOriginalImageBytes(Uint8List bytes) async {
    _originalImageBytes = bytes;
    setOriginalImage();
  }

  /// [CropGuideLineType] includes four types: qr, v-card, h-card, clear.
  CropGuideLineType _cropGuidelineType = CropGuideLineType.qr;
  CropGuideLineType get cropGuidelineType => _cropGuidelineType;

  /// This method changes the type of camera guideline in [PicturePicker].
  void changeCropGuidelineType(CropGuideLineType type,
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
        left = 5;
        right = renderBoxWidth - 5;
        top = 5;
        bottom = renderBoxHeight - 5;
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

    if (!isInitial) notifyListeners();
  }

  /// Check camera pinch zoom
  static bool _isPinchZoom = false;
  bool get isPinchZoom => _isPinchZoom;

  /// This method changes the pinchZoom in [PicturePicker].
  void setIsPinchZoom(bool value) {
    _isPinchZoom = value;
  }

  /// This method changes the cameraZoom in [PicturePicker].
  Future<void> setCameraZoom(double level) async {
    await cameraController?.setZoomLevel(level);
  }

  /// [PictureEditor]-----------------------------------------------------------
  /// Edit image scale in [PictureEditor]
  double _editImageScale = 1.0;
  double get editImageScale => _editImageScale;

  /// Edit image rotate in [PictureEditor]
  double _editImageRotate = 0.0;
  double get editImageRotate => _editImageRotate;

  /// Edit image blur in [PictureEditor]
  double _editImageBlur = 0.0;
  double get editImageBlur => _editImageBlur;

  /// Edit image temperature in [PictureEditor]
  double _editImageTemperature = 0.0;
  double get editImageTemperature => _editImageTemperature;

  /// Edit image lighten in [PictureEditor]
  double _editImageLighten = 0.0;
  double get editImageLighten => _editImageLighten;

  /// Edit image color matrix in [PictureEditor]
  ColorFilter _editImageColorFilter = ColorFilter.matrix([
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);
  ColorFilter get editImageColorFilter => _editImageColorFilter;

  /// Edit image offset x,y in [PictureEditor]
  Offset _editImageOffset = Offset.zero;
  Offset get editImageOffset => _editImageOffset;

  /// Do not call this method from outside the package.
  /// Calling this method from outside the package may cause the package to not work properly.
  /// This method update the crop area item in [PictureEditor]
  void updateCropAreaItem(CropAreaItem cropAreaItem) {
    _cropAreaItem = cropAreaItem;
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

  /// This method changes the blur of image in [PictureEditor].
  void changeEditImageBlur(double blur) {
    if (blur < 0 || blur > 25) return;
    _editImageBlur = blur;
    notifyListeners();
  }

  /// This method changes the temperature of image in [PictureEditor].
  void changeEditImageTemperature(double temperature) {
    if (temperature < -0.5 || temperature > 0.5) return;
    _editImageTemperature = temperature;
    notifyListeners();
  }

  /// This method changes the lighten of image in [PictureEditor].
  void changeEditImageLighten(double lighten) {
    if (lighten < -20 || lighten > 20) return;
    _editImageLighten = lighten;
    notifyListeners();
  }

  void changeEditImageFilter(
      double grayscale, double brightness, double saturation, bool invert) {
    if (grayscale < 0 || grayscale > 1) return;
    if (brightness < -1 || brightness > 1) return;
    if (saturation < 1 || saturation > 10) return;

    final invGrayscale = 1 - grayscale;
    final invSaturation = 1 - saturation;
    final r = 0.2126 * invSaturation;
    final g = 0.7152 * invSaturation;
    final b = 0.0722 * invSaturation;

    List<double> colorMatrix = [
      invGrayscale * (r + saturation) + grayscale * 0.2126,
      invGrayscale * g + grayscale * 0.7152,
      invGrayscale * b + grayscale * 0.0722,
      0,
      brightness * 255,
      invGrayscale * r + grayscale * 0.2126,
      invGrayscale * (g + saturation) + grayscale * 0.7152,
      invGrayscale * b + grayscale * 0.0722,
      0,
      brightness * 255,
      invGrayscale * r + grayscale * 0.2126,
      invGrayscale * g + grayscale * 0.7152,
      invGrayscale * (b + saturation) + grayscale * 0.0722,
      0,
      brightness * 255,
      0,
      0,
      0,
      1,
      0,
    ];

    if (invert) {
      colorMatrix = [
        -colorMatrix[0],
        -colorMatrix[1],
        -colorMatrix[2],
        0,
        255 - colorMatrix[4],
        -colorMatrix[5],
        -colorMatrix[6],
        -colorMatrix[7],
        0,
        255 - colorMatrix[9],
        -colorMatrix[10],
        -colorMatrix[11],
        -colorMatrix[12],
        0,
        255 - colorMatrix[14],
        colorMatrix[15],
        colorMatrix[16],
        colorMatrix[17],
        1,
        colorMatrix[19],
      ];
    }

    _editImageColorFilter = ColorFilter.matrix(colorMatrix);
    notifyListeners();
  }

  /// this method is used for create crop png image in [PictureEditor]
  bool _calledCreateCropImage = false;
  bool get calledCreateCropImage => _calledCreateCropImage;
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
    _editImageBlur = 0.0;
    _editImageTemperature = 0.0;
    _editImageLighten = 0.0;
    _editImageColorFilter = ColorFilter.matrix([
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);
    notifyListeners();
  }

  bool _isIrregularCrop = false;
  bool get isIrregularCrop => _isIrregularCrop;

  /// This method changes the type of crop in [PictureEditor].
  void toggleIrregularCrop(bool isOn) {
    _isIrregularCrop = isOn;
    changeCropGuidelineType(CropGuideLineType.qr);
  }

  /// This method disposes of the [_cameraController] used in [PicturePicker].
  void pictureEditorControllerDispose() {
    _cameraController?.dispose();
  }

  /// This method is used for set CropAreaItem in [PictureEditor].
  Future<void> setManualCropAreaItem(double imageWidth, double imageHeight,
      double left, double right, double top, double bottom) async {
    final scaleX = renderBoxWidth / imageWidth;
    final scaleY = renderBoxHeight / imageHeight;

    final leftTopX = left * scaleX;
    final leftTopY = top * scaleY;
    final rightTopX = right * scaleX;
    final rightTopY = top * scaleY;
    final rightBottomX = right * scaleX;
    final rightBottomY = bottom * scaleY;
    final leftBottomX = left * scaleX;
    final leftBottomY = bottom * scaleY;

    _cropAreaItem = CropAreaItem(
      leftTopX: leftTopX,
      leftTopY: leftTopY,
      rightTopX: rightTopX,
      rightTopY: rightTopY,
      rightBottomX: rightBottomX,
      rightBottomY: rightBottomY,
      leftBottomX: leftBottomX,
      leftBottomY: leftBottomY,
    );
    notifyListeners();
  }

  /// This method is used to set crop area from gallery image in [PictureEditor].
  void _setGalleryCropAreaItem() async {
    ui.Image image = await decodeImageFromList(_originalImageBytes);

    double imageWidth = image.width.toDouble();
    double imageHeight = image.height.toDouble();

    double imageAspectRatio = imageWidth / imageHeight;
    double boxAspectRatio = renderBoxWidth / renderBoxHeight;

    double scaledImageWidth, scaledImageHeight;
    double left = 0, right = 0, top = 0, bottom = 0;
    double margin = 2.5;

    if (imageAspectRatio > boxAspectRatio) {
      scaledImageWidth = renderBoxWidth;
      scaledImageHeight = renderBoxWidth / imageAspectRatio;
      top = (renderBoxHeight - scaledImageHeight) / 2 + margin;
      bottom = top + scaledImageHeight - (margin * 2);
      left = margin;
      right = renderBoxWidth - margin;
    } else {
      scaledImageHeight = renderBoxHeight;
      scaledImageWidth = renderBoxHeight * imageAspectRatio;
      left = (renderBoxWidth - scaledImageWidth) / 2 + margin;
      right = left + scaledImageWidth - (margin * 2);
      top = margin;
      bottom = renderBoxHeight - margin;
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
    notifyListeners();
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

  /// Takes a Uint8List and returns the image dpi.
  Future<int> getImageDpi(Uint8List data) async {
    Map<String, IfdTag> exifData = await readExifFromBytes(data);
    int dpi = 0;
    if (exifData.containsKey('XResolution') &&
        exifData.containsKey('YResolution')) {
      var xResolution = exifData['XResolution'];
      var yResolution = exifData['YResolution'];
      if (xResolution != null && yResolution != null) {
        dpi = xResolution.printable.contains('/')
            ? (int.parse(xResolution.printable.split('/')[0]) /
                    int.parse(xResolution.printable.split('/')[1]))
                .round()
            : int.parse(xResolution.printable);
      }
    }

    return dpi;
  }

  /// Takes a Uint8List and returns the image pixel.
  Size getImagePixel(Uint8List data) {
    img.Image? image = img.decodeImage(data);
    if (image == null) return Size(0, 0);
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  /// Returns image editor data
  String getImageEditInfo() {
    return 'Scale: ${editImageScale.toStringAsFixed(1)}\n'
        'Rotate: ${editImageRotate.toStringAsFixed(1)}\n'
        'Offset: x=${editImageOffset.dx.toStringAsFixed(1)}, y=${editImageOffset.dy.toStringAsFixed(1)}\n'
        'Blur: ${editImageBlur.toStringAsFixed(1)}\n'
        'Temperature: ${editImageTemperature.toStringAsFixed(1)}\n'
        'Lighten: ${editImageLighten.toStringAsFixed(1)}\n';
  }
}
