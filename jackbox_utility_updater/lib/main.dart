import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:jackbox_utility_updater/services/downloader/auto_updater.dart';
import 'package:jackbox_utility_updater/services/downloader/downloader_service.dart';
import 'package:lottie/lottie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
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
  String mainText = "Initializing";
  double progression = 0;

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content:Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Column(
      children: [
        LottieBuilder.asset("assets/lotties/QuiplashOutput.json",
            width: 100, height: 100),
        Text(mainText),
        SizedBox(height: 10),
        DownloaderService.isDownloading
            ? ProgressBar(value: progression)
            : Container()
      ],
    )));
  }

  void _load() async {
    await AutoUpdater.downloadUpdate(
        context,
        (s, d) => {
              setState(() {
                mainText = s;
                progression = d;
              })
            });
    mainText = "Launching";
    setState(() {
      
    });
    await Process.run("./app/jackbox_patcher.exe", []);
    exit(0);
  }
}
