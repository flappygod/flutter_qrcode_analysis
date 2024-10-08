import Flutter
import UIKit
import AVFoundation
import Vision


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
            DispatchQueue.global(qos: .userInitiated).async {
                let qrCodeData = self.messageFromImage(path: filePath)
                DispatchQueue.main.async {
                    if let data = qrCodeData {
                        result(data)
                    } else {
                        result(nil)
                    }
                }
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
        
        let uiImage = UIImage(cgImage: cgImage)
        //2. 如果没有二维码，检查条形码
        if let barcodeMessage = detectBarcodes(in: uiImage) {
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
    
    ///解析条形码
    func detectBarcodes(in image: UIImage) -> String? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        var detectedBarcodes = [String]()
        let request = VNDetectBarcodesRequest { request, error in
            if let error = error {
                print("Error detecting barcodes: \(error)")
                return
            }
            guard let results = request.results as? [VNBarcodeObservation] else {
                return
            }
            for result in results {
                if let payloadString = result.payloadStringValue {
                    detectedBarcodes.append(payloadString)
                }
            }
        }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform barcode detection: \(error)")
        }
        // 返回第一个检测到的条形码或 nil
        return detectedBarcodes.first
    }
    
}
