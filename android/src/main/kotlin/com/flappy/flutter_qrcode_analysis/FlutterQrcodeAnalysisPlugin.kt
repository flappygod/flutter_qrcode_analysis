package com.flappy.flutter_qrcode_analysis

import com.google.zxing.common.HybridBinarizer
import com.google.zxing.RGBLuminanceSource
import com.google.zxing.MultiFormatReader
import com.google.zxing.DecodeHintType
import android.graphics.BitmapFactory
import com.google.zxing.BarcodeFormat
import com.google.zxing.BinaryBitmap

import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.withContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.FileInputStream
import java.util.Hashtable
import java.io.File

/** FlutterQrcodeAnalysisPlugin */
class FlutterQrcodeAnalysisPlugin : FlutterPlugin, MethodCallHandler {

    // 定义错误代码和消息常量
    private val ERROR_FILE_NOT_FOUND = "FILE_NOT_FOUND"
    private val ERROR_MESSAGE_TEMPLATE = "File not found. FilePath: %s"


    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_qrcode_analysis")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "analysisImage") {

            ///没有路径
            val filePath = call.argument<String>("path")
            if (filePath.isNullOrEmpty()) {
                result.error("FILE_NOT_FOUND", "File path is null or empty.", null)
                return
            }

            ///文件找不到
            val file = File(filePath)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "File not found. FilePath: $filePath", null)
                return
            }

            //使用协程在后台线程中处理解析
            CoroutineScope(Dispatchers.IO).launch {
                val decodeResult = decodeImage(file)
                withContext(Dispatchers.Main) {
                    if (decodeResult != null) {
                        result.success(decodeResult)
                    } else {
                        result.success(null)
                    }
                }
            }
        } else {
            result.notImplemented()
        }
    }

    ///解析图像
    private fun decodeImage(file: File): String? {
        return try {
            val fis = FileInputStream(file)
            val bitmap = BitmapFactory.decodeStream(fis)
            val w = bitmap.width
            val h = bitmap.height
            val pixels = IntArray(w * h)
            bitmap.getPixels(pixels, 0, w, 0, 0, w, h)
            val source = RGBLuminanceSource(w, h, pixels)
            val binaryBitmap = BinaryBitmap(HybridBinarizer(source))

            val hints = Hashtable<DecodeHintType, Any>()
            val decodeFormats = listOf(
                BarcodeFormat.QR_CODE,
                BarcodeFormat.DATA_MATRIX,
                BarcodeFormat.AZTEC,
                BarcodeFormat.PDF_417,
                BarcodeFormat.CODABAR,
                BarcodeFormat.CODE_39,
                BarcodeFormat.CODE_93,
                BarcodeFormat.CODE_128,
                BarcodeFormat.EAN_8,
                BarcodeFormat.EAN_13,
                BarcodeFormat.UPC_A,
                BarcodeFormat.UPC_E,
                BarcodeFormat.ITF
            )

            hints[DecodeHintType.POSSIBLE_FORMATS] = decodeFormats
            hints[DecodeHintType.CHARACTER_SET] = "utf-8"
            hints[DecodeHintType.TRY_HARDER] = true

            val reader = MultiFormatReader()
            val result = reader.decode(binaryBitmap, hints)
            result.text
        } catch (e: Exception) {
            null
        }
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
