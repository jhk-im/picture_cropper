import 'package:camera/camera.dart';

class CameraUtils {
  static Future<CameraDescription> getCamera(
      CameraLensDirection direction) async {
    try {
      final cameras = await availableCameras();
      return cameras.firstWhere((camera) => camera.lensDirection == direction);
    } catch (e) {
      throw Exception('Failed to get camera: $e');
    }
  }
}
