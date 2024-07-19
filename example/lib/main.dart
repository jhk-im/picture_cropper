import 'dart:ui' as ui;

import 'package:example/crop_image_page.dart';
import 'package:example/editor_page.dart';
import 'package:flutter/material.dart';
import 'package:picture_cropper/picture_cropper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Picture Editor Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/editor': (context) => const EditorPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/crop') {
          final image = settings.arguments as ui.Image;
          return MaterialPageRoute(
            builder: (context) {
              return CropImagePage(image: image);
            },
          );
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final pictureCropperController = PictureCropperController(isPicker: true);
  int _cropStatus = 0; // 0 = qr, 1 = vertical card, 2 = card, 3 = clear

  @override
  void dispose() {
    pictureCropperController.pictureEditorControllerDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: PicturePicker(
                controller: pictureCropperController,
                onSetOriginalImage: () async {
                  final result = await Navigator.pushNamed(context, '/editor');
                  if (result == true) {
                    pictureCropperController.changeCropGuidelineType(
                        pictureCropperController.cropGuidelineType);
                  }
                },
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              height: 80,
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _cropStatus = 0;
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
                  InkWell(
                    onTap: () {
                      setState(() {
                        _cropStatus = 1;
                        pictureCropperController.changeCropGuidelineType(
                            CropGuideLineType.verticalCard);
                      });
                    },
                    child: Icon(
                      Icons.crop_portrait,
                      color: _cropStatus == 1 ? Colors.blue : Colors.black,
                      size: 32,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _cropStatus = 2;
                        pictureCropperController
                            .changeCropGuidelineType(CropGuideLineType.card);
                      });
                    },
                    child: Icon(
                      Icons.crop_3_2,
                      color: _cropStatus == 2 ? Colors.blue : Colors.black,
                      size: 32,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _cropStatus = 3;
                        pictureCropperController
                            .changeCropGuidelineType(CropGuideLineType.clear);
                      });
                    },
                    child: Icon(
                      Icons.not_interested,
                      color: _cropStatus == 3 ? Colors.blue : Colors.black,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 130,
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: pictureCropperController.pickImageFromGallery,
                      child: const Icon(
                        Icons.photo,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    InkWell(
                      onTap: pictureCropperController.takePicture,
                      child: const Icon(
                        Icons.camera,
                        color: Colors.black,
                        size: 82,
                      ),
                    ),
                    InkWell(
                      onTap: pictureCropperController.toggleCameraDirection,
                      child: const Icon(
                        Icons.change_circle,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
