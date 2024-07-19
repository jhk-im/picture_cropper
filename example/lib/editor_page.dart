import 'package:flutter/material.dart';
import 'package:picture_cropper/picture_cropper.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final pictureCropperController = PictureCropperController();
  bool _isIrregularCrop = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: PictureEditor(
                controller: pictureCropperController,
                onCropComplete: (image) {
                  Navigator.pushNamed(
                    context,
                    '/crop',
                    arguments: image,
                  );
                },
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(24),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, true);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
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
                      color: !_isIrregularCrop ? Colors.blue : Colors.black,
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
                      color: _isIrregularCrop ? Colors.blue : Colors.black,
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
                        onTap: pictureCropperController.createCropImage,
                        child: ClipOval(
                          child: Container(
                            width: 68,
                            height: 68,
                            color: Colors.black,
                            child: const Icon(
                              Icons.cut,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
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
