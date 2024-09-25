import 'flutter_qrcode_analysis_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An implementation of [FlutterQrcodeAnalysisPlatform] that uses method channels.
class MethodChannelFlutterQrcodeAnalysis extends FlutterQrcodeAnalysisPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_qrcode_analysis');

  @override
  Future<String?> analysisImage(String path) async {
    final version = await methodChannel.invokeMethod<String>('analysisImage', {
      "path": path,
    });
    return version;
  }
}
