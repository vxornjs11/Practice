import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:practice_01_app/firebase_options.dart';
import 'package:practice_01_app/home.dart';
import 'package:practice_01_app/provinder/count_provinder.dart';
import 'package:practice_01_app/provinder/scheduleCount_provinder.dart';
import 'package:practice_01_app/provinder/timer_provinder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (BuildContext context) => CounterProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => Timer_Provider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => ScheduleCountProvider()),
      ],
      child: const GetMaterialApp(
        title: 'Flutter Provider Demo',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // 자신에게 필요한 언어 locale을 모두 추가
        supportedLocales: [
          Locale('en'), // 영어
          Locale('es'), // 스페인어
          Locale('ko'), // 한국어
          Locale('ja'), // 일본어
        ],
        home: home(),
      ),
    );
  }
}
