import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:jackbox_utility_updater/services/downloader/downloader_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AutoUpdater {
  static const shouldSearchPrerelease = true;
  static const _updateUrl =
      'https://api.github.com/repos/AlexisL61/jackboxutility/releases';

  static Future<dynamic> getLatestRelease() async {
    try {
      final response = await get(Uri.parse(_updateUrl));
      if (response.statusCode == 200) {
        var dataReceived = jsonDecode(response.body);
        if (dataReceived is List) {
          var searchedReleases = dataReceived.where((release) {
            return release["prerelease"] == shouldSearchPrerelease;
          });
          if (searchedReleases.isEmpty) {
            return null;
          } else {
            var latestRelease = searchedReleases.first;
            return latestRelease;
          }
        }
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  // Compare latest release with current release
  static Future<String?> isUpdateAvailable() async {
    final latestRelease = await getLatestRelease();

    if (latestRelease != null) {
      if (!await utilityInFiles()) {
        return _updateUrl + "/" + latestRelease["id"].toString();
      } else {
        String currentVersion = "";
        if (await File("./app/" + getPatcherVersionFile()).exists()) {
          currentVersion =
              await File("./app/" + getPatcherVersionFile()).readAsString();
        } else {
          currentVersion =
              await File("./" + getPatcherVersionFile()).readAsString();
        }
        print(latestRelease["name"] + " " + currentVersion);
        if (latestRelease["name"] != currentVersion &&
            latestRelease["name"] != currentVersion.split("+")[0]) {
          return _updateUrl + "/" + latestRelease["id"].toString();
        }
      }
    }
    return null;
  }

  static String getPlatformName() {
    if (Platform.isWindows) {
      return "Windows";
    } else if (Platform.isMacOS) {
      return "Macos";
    } else if (Platform.isLinux) {
      return "Linux";
    } else {
      return "unknown";
    }
  }

  static String getPatcherVersionFile() {
    return "jackbox_patcher.version";
  }

  static Future<bool> utilityInFiles() async {
    return await File("./${getPatcherVersionFile()}").exists() ||
        await File("./app/${getPatcherVersionFile()}").exists();
  }

  // Download update if an update is available
  static Future<void> downloadUpdate(
      context, Function(String s, double d) callback) async {
    String? latestUpdateURL = null;

    latestUpdateURL = await isUpdateAvailable();

    if (latestUpdateURL != null) {
      var data = await get(Uri.parse(latestUpdateURL));
      var jsonData = jsonDecode(data.body);
      var thisPlatformUrl = jsonData["assets"].where((dynamic a) {
        bool found = a["name"].contains(getPlatformName());
        return found;
      }).first["browser_download_url"];
      await DownloaderService.downloadPatch(
          context, "./app", thisPlatformUrl, callback);
      await File("./app/jackbox_patcher.version").writeAsString(jsonData["name"]);
    }
  }
}
