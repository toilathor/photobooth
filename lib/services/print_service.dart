import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintService {
  /// In ảnh dưới dạng bytes.
  /// Sử dụng thư viện [Printing.layoutPdf] để hiển thị hộp thoại in hệ thống.
  static Future<bool> printImage(
    Uint8List imageBytes, {
    String name = 'photobooth_photo',
  }) async {
    try {
      final image = pw.MemoryImage(imageBytes);

      final result = await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final printDoc = pw.Document();
          printDoc.addPage(
            pw.Page(
              pageFormat: format,
              margin: const pw.EdgeInsets.all(
                0,
              ), // Không lề để ảnh hiển thị tối đa kích thước giấy
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                );
              },
            ),
          );
          return printDoc.save();
        },
        name: name,
      );
      return result;
    } catch (e) {
      debugPrint('Lỗi trong PrintService.printImage: $e');
      return false;
    }
  }
}
