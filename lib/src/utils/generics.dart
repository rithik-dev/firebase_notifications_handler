import 'dart:io';

import 'package:http/http.dart' as http;

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

@pragma('vm:entry-point')
Future<String> downloadImage({
  required String url,
  required String fileName,
}) async {
  final directory = await getTemporaryDirectory();
  final filePath = path.join(directory.path, fileName);
  final response = await http.get(Uri.parse(url));

  final file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);

  return filePath;
}
