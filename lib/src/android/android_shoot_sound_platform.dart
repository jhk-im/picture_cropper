import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'android_shoot_sound_method_channel.dart';

abstract class AndroidShootSoundPlatform extends PlatformInterface {
  /// Constructs a AndroidShootSoundPlatform.
  AndroidShootSoundPlatform() : super(token: _token);

  static final Object _token = Object();

  static AndroidShootSoundMethodChannel _instance =
      AndroidShootSoundMethodChannel();

  /// The default instance of [AndroidShootSoundMethodChannel] to use.
  ///
  /// Defaults to [AndroidShootSoundMethodChannel].
  static AndroidShootSoundMethodChannel get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AndroidShootSoundMethodChannel] when
  /// they register themselves.
  static set instance(AndroidShootSoundMethodChannel instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> play() {
    throw UnimplementedError('play() has not been implemented.');
  }
}
