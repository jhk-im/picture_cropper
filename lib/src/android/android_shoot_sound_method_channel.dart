import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'android_shoot_sound_platform.dart';

/// An implementation of [AndroidShootSoundPlatform] that uses method channels.
class AndroidShootSoundMethodChannel extends AndroidShootSoundPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('android_shoot_sound');

  @override
  Future<void> play() {
    return methodChannel.invokeMethod<void>('play');
  }
}
