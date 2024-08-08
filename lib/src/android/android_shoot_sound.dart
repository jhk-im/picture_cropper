import 'android_shoot_sound_platform.dart';

class AndroidShootSound {
  static Future<void> play() {
    return AndroidShootSoundPlatform.instance.play();
  }
}
