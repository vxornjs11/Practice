import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:practice_01_app/firebase_options.dart';
import 'package:practice_01_app/home.dart';
import 'package:practice_01_app/provinder/color_provinder.dart';
import 'package:practice_01_app/provinder/count_provinder.dart';
import 'package:practice_01_app/provinder/scheduleCount_provinder.dart';
import 'package:practice_01_app/provinder/timer_provinder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class UserManager {
  static String? userId;

  // 유저 아이디를 SharedPreferences에 저장
  static Future<void> saveUserId(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    userId = id;
  }

  // 유저 아이디를 SharedPreferences에서 불러오기
  static Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
  }

  // 유저 아이디를 생성 (없을 경우)
  static Future<void> initializeUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('userId');
    if (id == null) {
      print("id = null");
      id = Uuid().v4();
      await saveUserId(id);
    } else {
      print("id not null");
      userId = id;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  initBackgroundFetch(); // 백그라운드 페치 초기화
  // 사용자 아이디 저장
  await UserManager.initializeUserId();
  // initBackgroundFetch(); // 백그라운드 페치 초기화
  runApp(MyApp());
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (BuildContext context) => ColorProvider()),
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

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
// 백그라운드 페치 초기화
void initBackgroundFetch() {
  BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 15, // 15분마다 실행
      stopOnTerminate: false, // 앱이 종료되어도 실행
      enableHeadless: true, // 앱이 완전히 종료된 상태에서 실행 가능
    ),
    (String taskId) async {
      print("[BackgroundFetch] 백그라운드 작업 실행됨: $taskId");

      // payload 확인 후 "주중" 알람만 처리
      if (taskId == 'weekday') {
        print('주중 알람 처리');

        // 주간 반복 알람 설정 함수 (월~금)
        Future<void> _setWeekdayAlarms() async {
          const List<int> weekdays = [
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday
          ];

          for (int weekday in weekdays) {
            final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

            await flutterLocalNotificationsPlugin.zonedSchedule(
              weekday, // 각 요일에 고유한 ID 사용
              '주중 반복 알람', // 알람 제목
              '주중 반복 알람입니다.', // 알람 내용
              now,
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'weekday_repeat_channel_id',
                  'Weekday Repeat Alarm',
                  channelDescription: '주중 반복 알람 채널',
                  importance: Importance.max,
                  priority: Priority.high,
                ),
              ),
              androidAllowWhileIdle: true,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents:
                  DateTimeComponents.dayOfWeekAndTime, // 요일에 맞춰 반복 알람 설정
            );
            print('주중 알람 처리$weekday ㅏㅏㅏㅏ ');
          }
        }
        // 주중 알람 처리 로직 추가
      }

      // 작업 종료
      BackgroundFetch.finish(taskId);
    },
  ).then((int status) {
    print("[BackgroundFetch] 초기화 성공: $status");
  }).catchError((e) {
    print("[BackgroundFetch] 초기화 에러: $e");
  });

  // 강제로 백그라운드 작업 실행 (테스트용)
  BackgroundFetch.start();
}
