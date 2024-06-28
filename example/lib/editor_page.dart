import 'package:flutter/material.dart';
import 'package:picture_cropper/picture_cropper.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final pictureCropperController =
      PictureCropperControllerFactory.createController();
  bool _isIrregularCrop = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PictureProEditor(controller: pictureCropperController),
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(24),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
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
                        _isIrregularCrop = false;
                      });
                    },
                    child: Icon(
                      Icons.crop_free,
                      color: !_isIrregularCrop ? Colors.blue : Colors.white,
                      size: 32,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        pictureCropperController.toggleIrregularCrop(true);
                        _isIrregularCrop = true;
                      });
                    },
                    child: Icon(
                      Icons.zoom_out_map,
                      color: _isIrregularCrop ? Colors.blue : Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/crop');
                        },
                        child: const Icon(
                          Icons.radio_button_checked,
                          color: Colors.white,
                          size: 82,
                        ),
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
