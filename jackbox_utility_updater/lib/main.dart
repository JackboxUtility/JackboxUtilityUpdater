import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:jackbox_utility_updater/services/downloader/auto_updater.dart';
import 'package:jackbox_utility_updater/services/downloader/downloader_service.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(150, 150);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blue,
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen() ? 2.0 : 0.0,
        ),
      ),
      localizationsDelegates: [
        FluentLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("en"),
        Locale("fr"),
        Locale("de"),
        Locale("es")
      ],
      themeMode: ThemeMode.dark,
      title: 'Jackbox Utility',
      home: HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  String? mainText;
  double progression = 0;

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (mainText == null) mainText = AppLocalizations.of(context)!.initializing;
    return NavigationView(
        content: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                LottieBuilder.asset("assets/lotties/QuiplashOutput.json",
                    width: 100, height: 100),
                Text(mainText!),
                SizedBox(height: 10),
                DownloaderService.isDownloading
                    ? ProgressBar(value: progression)
                    : Container()
              ],
            )));
  }

  void _load() async {
    try {
      await AutoUpdater.downloadUpdate(
          context,
          (s, d) => {
                setState(() {
                  mainText = s;
                  progression = d;
                })
              });
    } catch (e) {
      print(e);
    }
    mainText = AppLocalizations.of(context)!.initializing;
    setState(() {});
    if (Platform.isWindows) {
      Process.run("./app/jackbox_patcher.exe", []);
    }else{
      Process.run("./app/jackbox_patcher", []);
    }
    Future.delayed(Duration(seconds: 1), () {
      exit(0);
    });
  }
}
