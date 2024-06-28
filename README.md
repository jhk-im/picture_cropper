# Picture Cropper

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Github](https://img.shields.io/badge/github-jhk-orange?logo=github&logoColor=white)](https://github.com/jhk-im)

A Flutter package for cropping pictures, which includes features for capturing images from the camera or selecting images from the gallery.

### Rectangle Crop
<p>  
  <img src="https://github.com/jhk-im/picture_cropper/blob/main/readme/ex_01.png?raw=true" width="200" height="400"/>
  <img src="https://github.com/jhk-im/picture_cropper/blob/main/readme/ex_02.png?raw=true" width="200" height="400"/>
  <img src="https://github.com/jhk-im/picture_cropper/blob/main/readme/ex_03.png?raw=true" width="200" height="400"/>
</p>

### Irregurlar Crop
<p>  
  <img src="https://github.com/jhk-im/picture_cropper/blob/main/readme/ex_04.png?raw=true" width="200" height="400"/>
  <img src="https://github.com/jhk-im/picture_cropper/blob/main/readme/ex_05.png?raw=true" width="200" height="400"/>
  <img src="https://github.com/jhk-im/picture_cropper/blob/main/readme/ex_06.png?raw=true" width="200" height="400"/>
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

*Stateful Widget Usage

```dart
late PictureEditorController pictureEditorController;

@override
void initState() {
  super.initState();
  pictureEditorController = PictureEditorControllerFactory.createController(
    onSelectedImage: (Uint8List image) {
      // Callback after capturing or selecting an image
      // If you need image bytes...
    },
  );
}

@override
void dispose() {
  pictureEditorController.pictureEditorControllerDispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(  
      child: PicturePicker(controller: pictureEditorController),
    ),
  );
}
```
```dart
// Method - pickImageFromGallery
InkWell(
  onTap: pictureEditorController.pickImageFromGallery,
  child: const Icon(
    Icons.photo,
    color: Colors.white,
    size: 32,
  ),
),

// Method - takePicture
InkWell(
  onTap: pictureEditorController.takePicture
  child: const Icon(
    Icons.photo,
    color: Colors.white,
    size: 32,
  ),
),

// Method - toggleCameraDirection
InkWell(
  onTap: () async {
    await pictureEditorController.toggleCameraDirection();
    setState(() {}); // Update state after toggling camera
  },
  child: const Icon(
    Icons.photo,
    color: Colors.white,
    size: 32,
  ),
),
```

### Example - Editing Image Crop Area

```dart
final pictureEditorController = PictureEditorControllerFactory.createController();

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: PictureProEditor(controller: pictureEditorController),
    ),
  );
}
```
```dart
// Method - toggleIrregularCrop
// false = Ractangle Crop
// true = Irregular Crop
InkWell(
  onTap: () async {
    setState(() {
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
```

### Example -  Cropping Image

```dart
final pictureEditorController = PictureEditorControllerFactory.createController();

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: PictureCrop(
        controller: pictureEditorController,
        onCropped: (uiImage) {
          // If you need uiImage ...
        }
      ),
    ),
  );
}
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
