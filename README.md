# Picture Cropper

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Github](https://img.shields.io/badge/github-jhk-orange?logo=github&logoColor=white)](https://github.com/jhk-im)

A Flutter package for cropping pictures, which includes features for capturing images from the camera or selecting images from the gallery.

Crop & Editor
<p>
  <img src="https://github.com/jhk-im/picture_cropper/blob/main/readme/readme_01.gif?raw=true" width="200" height="400"/>
  <img src="https://github.com/jhk-im/picture_cropper/blob/main/readme/readme_02.gif?raw=true" width="200" height="400"/>
</p>

Irregular Crop
<p>
  <img src="https://github.com/jhk-im/picture_cropper/blob/main/readme/readme_02.png?raw=true" width="200" height="400"/>
  <img src="https://github.com/jhk-im/picture_cropper/blob/main/readme/readme_03.png?raw=true" width="200" height="400"/>
</p>

Rectangle Crop
<p>
  <img src="https://github.com/jhk-im/picture_cropper/blob/main/readme/readme_04.png?raw=true" width="200" height="400"/>
  <img src="https://github.com/jhk-im/picture_cropper/blob/main/readme/readme_05.png?raw=true" width="200" height="400"/>
</p>

## Installation

To use Picture Cropper in your Flutter project, add picture_cropper as a dependency in your pubspec.yaml file.

```yaml
dependencies:
  picture_cropper: ^latest_version
```

Import it in your Dart code:

```dart
import 'package:picture_cropper/picture_cropper.dart';
```

### iOS Configuration
Add the following keys to your Info.plist file:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Describe why your app needs access to the photo library</string>
<key>NSCameraUsageDescription</key>
<string>Describe why your app needs access to the camera</string>
<key>NSMicrophoneUsageDescription</key>
<string>Describe why your app needs access to the microphone (if applicable)</string>
```

Or in text format add the key:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to demonstrate image picker plugin</string>
<key>NSCameraUsageDescription</key>
<string>Used to demonstrate image picker plugin</string>
<key>NSMicrophoneUsageDescription</key>
<string>Used to capture audio for image picker plugin</string>
```

### Android

No additional configuration required.

### Example - Capturing or Selecting an Image from the Gallery

`Stateful Widget Usage`

```dart
final pictureCropperController = PictureCropperController(isPicker: true);

@override
void dispose() {
  pictureEditorController.pictureEditorControllerDispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(  
      child: PicturePicker(
        controller: pictureEditorController,
        /// Callback when image select is complete after pickImageFromGallery or takePicture call
        onSetOriginalImage: () async {
          final result = await Navigator.pushNamed(context, '/editor');
          /// If return from pop method...
          if (result == true) {
            pictureCropperController.changeCropGuideLineType(
                pictureCropperController.cropGuidelineType);
          }
        },
      ),
    ),
  );
}
```

```dart
/// Method - pickImageFromGallery
InkWell(
  onTap: pictureEditorController.pickImageFromGallery,
  child: const Icon(
    Icons.photo,
    color: Colors.white,
    size: 32,
  ),
),

/// Method - takePicture
InkWell(
  onTap: pictureEditorController.takePicture
  child: const Icon(
    Icons.photo,
    color: Colors.white,
    size: 32,
  ),
),

/// Method - toggleCameraDirection
InkWell(
  onTap: pictureCropperController.toggleCameraDirection,
  child: const Icon(
    Icons.photo,
    color: Colors.white,
    size: 32,
  ),
),

/// Method - changeCropGuidelineType
InkWell(
  onTap: () {
    setState(() {
      _cropStatus = 0;
      /// qr, v-card, h-card, clear
      pictureCropperController
          .changeCropGuidelineType(CropGuideLineType.qr);
    });
  },
  child: Icon(
    Icons.crop_din,
    color: _cropStatus == 0 ? Colors.blue : Colors.black,
    size: 32,
  ),
),
```

### Example - Editing Image

```dart
final pictureCropperController = PictureCropperController();

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: PictureEditor(
        controller: pictureCropperController,
        /// Callback when image creation is complete after createCropImage call
        onCropComplete: (image) {
          /// Use cropped images
          Navigator.pushNamed(context, '/crop', arguments: image);
        },
      ),
    ),
  );
}
```

```dart
/// Method - createCropImage
InkWell(
  onTap: pictureCropperController.createCropImage,
child: const Icon(
    Icons.cut,
    color: Colors.white,
    size: 32,
  ),
),

/// Method - toggleIrregularCrop
InkWell(
  onTap: () async {
    setState(() {
      /// false = Rectangle Crop, true = Irregular Crop
      pictureEditorController.toggleIrregularCrop(false);
      _isIrregularCrop = false;
    });
  },
  child: const Icon(
    Icons.crop_free,
    color: Colors.white,
    size: 32,
  ),
),

/// Method - changeEditImageScale
pictureCropperController.changeEditImageScale(_scale);

/// Method - changeEditImageRotate
pictureCropperController.changeEditImageRotate(_rotate);

/// Method - changeEditImageOffset
pictureCropperController.changeEditImageOffset(_offset);

/// Method - changeEditImageFilter
/// grayscale, brightness, saturation, invert
pictureCropperController.changeEditImageFilter(
  _grayscale,
  _brightness,
  _saturation,
  _invert,
);

/// Method - resetEditorData
pictureCropperController.resetEditorData();
```

```txt
MIT License

Copyright (c) 2024 Jeonghun Kim

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
