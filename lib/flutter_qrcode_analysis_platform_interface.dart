import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_qrcode_analysis_method_channel.dart';

abstract class FlutterQrcodeAnalysisPlatform extends PlatformInterface {
  /// Constructs a FlutterQrcodeAnalysisPlatform.
  FlutterQrcodeAnalysisPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterQrcodeAnalysisPlatform _instance =
      MethodChannelFlutterQrcodeAnalysis();

  /// The default instance of [FlutterQrcodeAnalysisPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterQrcodeAnalysis].
  static FlutterQrcodeAnalysisPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterQrcodeAnalysisPlatform] when
  /// they register themselves.
  static set instance(FlutterQrcodeAnalysisPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> analysisImage(String path) {
    throw UnimplementedError('analysisImage() has not been implemented.');
  }
}
