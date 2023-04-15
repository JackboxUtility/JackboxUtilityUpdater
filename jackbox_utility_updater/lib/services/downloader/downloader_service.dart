import 'package:archive/archive_io.dart';

import '../api/api_service.dart';

class DownloaderService {
  static bool isDownloading = false;

  /// Downloads a patch from [patchUrl] and extracts it to [uri]
  static Future<void> downloadPatch(String uri, String updateUri,
      void Function(String, double) callback) async {
    try {
      isDownloading = true;
      callback("Downloading", 0);
      String filePath = await APIService().downloadUpdate(updateUri,
          (double progress, double max) {
        callback(
            "Downloading",
            (progress / max) * 90);
      });
      callback("Extracting",
          95);
      await extractFileToDisk(filePath, uri, asyncWrite: false);
      callback("Finalizing",
          100);
      isDownloading = false;
      //File(filePath).deleteSync(recursive: true);
    } on Exception catch (e) {
      isDownloading = false;
      rethrow;
    }
  }
}
