import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picture_cropper/picture_cropper.dart';

class CropImagePage extends StatefulWidget {
  const CropImagePage({super.key});

  @override
  State<CropImagePage> createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  PictureCropperController pictureCropperController =
      PictureCropperController();
  ui.Image? _image;

  Future<void> saveImage() async {
    try {
      final ByteData? byteData =
          await _image?.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List? buffer = byteData?.buffer.asUint8List();

      DateTime now = DateTime.now();
      DateFormat formatter = DateFormat('yyyyMMddHHmmss');
      String fileName = formatter.format(now);

      final Directory directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/$fileName.png';
      final File file = File(filePath);
      await file.writeAsBytes(buffer!);

      await ImageGallerySaver.saveFile(filePath);
      const snackBar = SnackBar(
        content: Text('Image saved to gallery'),
      );

      // Find the ScaffoldMessenger in the widget tree and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PictureCrop(
              controller: pictureCropperController,
              onCropped: (uiImage) async {
                /// If you need uiImage ...
                _image = uiImage;
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 130,
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32, height: 32),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: const Icon(
                        Icons.refresh,
                        size: 82,
                      ),
                    ),
                    InkWell(
                      onTap: saveImage,
                      child: const Icon(
                        Icons.save_alt,
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
