import 'package:archive/archive_io.dart';

import '../api/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DownloaderService {
  static bool isDownloading = false;

  /// Downloads a patch from [patchUrl] and extracts it to [uri]
  static Future<void> downloadPatch(context, String uri, String updateUri,
      void Function(String, double) callback) async {
    try {
      isDownloading = true;
      callback(AppLocalizations.of(context)!.downloading, 0);
      String filePath = await APIService().downloadUpdate(updateUri,
          (double progress, double max) {
        callback(
            AppLocalizations.of(context)!.downloading,
            (progress / max) * 90);
      });
      callback(AppLocalizations.of(context)!.extracting,
          95);
      await extractFileToDisk(filePath, uri, asyncWrite: false);
      callback(AppLocalizations.of(context)!.finalizing,
          100);
      isDownloading = false;
      //File(filePath).deleteSync(recursive: true);
    } on Exception catch (e) {
      isDownloading = false;
      rethrow;
    }
  }
}
