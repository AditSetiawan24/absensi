// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

Future<void> downloadFileWeb(List<int> bytes, String fileName) async {
  final base64data = base64Encode(bytes);
  final a = html.AnchorElement(href: 'data:application/octet-stream;base64,$base64data');
  a.download = fileName;
  a.click();
  a.remove();
}
