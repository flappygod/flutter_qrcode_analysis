import Flutter
import UIKit

public class FlutterQrcodeAnalysisPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_qrcode_analysis", binaryMessenger: registrar.messenger())
        let instance = FlutterQrcodeAnalysisPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "analysisImage":
            
            ///提取path地址
            guard let args = call.arguments as? [String: Any],
                  let filePath = args["path"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "File path is missing or invalid", details: nil))
                return
            }
            ///解析
            if let qrCodeData = messageFromImage(path: filePath) {
                result(qrCodeData)
            } else {
                result(nil)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    ///解析图像数据
    public func messageFromImage(path: String) -> String? {
        guard let image = UIImage(contentsOfFile: path),
              let cgImage = image.cgImage else {
            return nil
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // 1. 先检查二维码
        if let qrCodeMessage = detectQRCode(in: ciImage) {
            return qrCodeMessage
        }
        
        // 2. 如果没有二维码，检查条形码
        if let barcodeMessage = detectBarcode(in: ciImage) {
            return barcodeMessage
        }
        
        return nil
    }
    
    ///解析二维码数据
    private func detectQRCode(in ciImage: CIImage) -> String? {
        let context = CIContext()
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
        
        guard let features = detector?.features(in: ciImage) else {
            return nil
        }
        
        for feature in features {
            if let qrFeature = feature as? CIQRCodeFeature, let messageString = qrFeature.messageString {
                return messageString
            }
        }
        
        return nil
    }
    
    ///解析条形码数据
    private func detectBarcode(in ciImage: CIImage) -> String? {
        // 使用 AVFoundation 来检测条形码
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        guard let features = detector?.features(in: ciImage) else {
            return nil
        }
        for feature in features {
            if let barcodeFeature = feature as? CIQRCodeFeature, let messageString = barcodeFeature.messageString {
                return messageString
            }
        }
        return nil
    }
    
}
