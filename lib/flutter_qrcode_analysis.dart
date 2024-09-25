import 'flutter_qrcode_analysis_platform_interface.dart';

///Analysis qrcode image
class FlutterQrcodeAnalysis {
  ///Analysis qrcode image to data str by image path
  static Future<String?> analysisImage(String path) {
    return FlutterQrcodeAnalysisPlatform.instance.analysisImage(path);
  }
}
