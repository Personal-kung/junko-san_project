// lib/web_download_helper.dart
import 'dart:html' as html;

void downloadWebFile(String csvData, String fileName) {
  final bytes = Uri.encodeComponent(csvData);
  final anchor = html.AnchorElement(href: "data:text/csv;charset=utf-8,$bytes")
    ..setAttribute("download", fileName)
    ..click();
}