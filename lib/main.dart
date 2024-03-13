import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:practice_01_app/home.dart';
import 'package:practice_01_app/provinder/count_provinder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
      home: ChangeNotifierProvider(
        create: (BuildContext context) => CounterProvider(),
        child: home(),
      ),
    );
  }
}
