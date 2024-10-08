import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class CropImagePage extends StatefulWidget {
  final ui.Image image;
  const CropImagePage({super.key, required this.image});

  @override
  State<CropImagePage> createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  final logger = Logger();
  bool _isLoading = false;

  void isLoading(bool value) {
    _isLoading = value;
    setState(() {});
  }

  Future<void> saveImage(BuildContext ctx) async {
    isLoading(true);
    try {
      final ByteData? byteData =
          await widget.image.toByteData(format: ui.ImageByteFormat.png);
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
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(snackBar);
      }
    } catch (e) {
      logger.e(e);
    }
    isLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white10,
                width: double.maxFinite,
                height: 500,
                child: RawImage(
                  image: widget.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      saveImage(context);
                    },
                    child: const Icon(
                      Icons.file_download,
                      color: Colors.white,
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
                child: Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: ClipOval(
                      child: Container(
                        width: 68,
                        height: 68,
                        color: Colors.white,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _isLoading,
              child: Stack(
                children: <Widget>[
                  Opacity(
                    opacity: 0.5,
                    child: Container(
                      color: Colors.black,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
