import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String base64Content;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.base64Content,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Clean the string (Remove data:application/pdf;base64, if it exists)
    String cleanBase64 = base64Content.contains(',') 
        ? base64Content.split(',').last 
        : base64Content;
    
    // Remove any whitespace or newlines that might break the decoder
    cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');

    try {
      // 2. Decode the base64 string into bytes
      final Uint8List bytes = base64Decode(cleanBase64);

      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.blue,
        ),
        body: SfPdfViewer.memory(
          bytes,
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            // This will show us why it's failing
            print("PDF Load Failed: ${details.error}");
            print("Description: ${details.description}");
          },
        ),
      );
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: Text("Error")),
        body: Center(child: Text("Invalid PDF data: $e")),
      );
    }
  }
}
