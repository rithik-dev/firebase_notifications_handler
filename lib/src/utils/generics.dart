import 'dart:io';

import 'package:firebase_notifications_handler/src/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

@pragma('vm:entry-point')
Future<String?> downloadImage({
  required String url,
  required String fileName,
}) async {
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      log(
        msg: 'Failed to download "$url": HTTP ${response.statusCode}',
        id: 'downloadImage',
      );

      return null;
    }

    final directory = await getTemporaryDirectory();
    final filePath = path.join(directory.path, fileName);

    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return filePath;
  } catch (e, s) {
    log(
      msg: 'Failed to download "$url"',
      error: e,
      stackTrace: s,
      id: 'downloadImage',
    );

    return null;
  }
}
