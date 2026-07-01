import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/speed_provider.dart';
import 'providers/radar_provider.dart';
import 'providers/alert_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpeedProvider()..init()),
        ChangeNotifierProvider(create: (_) => RadarProvider()..init()),
        ChangeNotifierProxyProvider2<SpeedProvider, RadarProvider,
            AlertProvider>(
          create: (_) => AlertProvider(),
          update: (_, speed, radar, alert) => alert!..update(speed, radar),
        ),
      ],
      child: const RadarAlertApp(),
    ),
  );
}
