import 'package:cloud_firestore/cloud_firestore.dart';
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

// import 'package:timezone/data/latest.dart' as tz;
// 특정 날짜에 매주 반복 알람을 설정하려면
// 지금 바로 DateTimeComponents.dayOfWeekAndTime를 활용하는것이 아니라:
// 특정 날짜에 알람이 발동되고 난 이후
// 그 알람 메세지 내용을 동일하게 DateTimeComponents.dayOfWeekAndTime으로 실행시켜서
// 그 날짜 이후부터 자동 반복되게 만들면 된다
// 지금 안되고 있는 것은. 특정날짜 알람이 발동된후 알람을 클릭하지 않아도 자동으로 백그라운드에서
// 알람이 울리자마자 그 해당 데이터를 가지고 DateTimeComponents.dayOfWeekAndTime를 실행시키는게 안되는거임.
// 방법을 알아해
// djfdll..
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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Flutter Native Splash 유지
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  DarwinInitializationSettings iosInitializationSettings =
      const DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: iosInitializationSettings);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      print('알림 클릭됨: ${details.payload}');
    },
  );

  /////// Set_schedule.dart에서 알람 실행시 발동하는 함수 옮겨왔음. 여기에 있는게 맞는듯
  ////// 그럼 Set_~~에 있는거는 어떻게 해야 할지 생각.. 없어도 되나?

  // 사용자 ID 초기화
  await UserManager.initializeUserId();

  // 백그라운드 작업 초기화
  // initBackgroundFetch();
  print('백그라운드 앞');
  // Background Fetch 초기화
  BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 3, // 최소 실행 간격
      stopOnTerminate: false, // 앱 종료 후에도 유지
      enableHeadless: true, // 헤드리스 모드 활성화
      startOnBoot: true, // 디바이스 재부팅후 다시 작업.
      forceAlarmManager: true,
    ),
    (taskId) async {
      print('포그라운드에서 BackgroundFetch 실행: $taskId');
      await scheduleWeeklyNotification(); // 알림 예약 작업
      BackgroundFetch.finish(taskId); // 항상 호출
      print('finally b');
    },
    (taskId) async {
      print('헤드리스 모드에서 BackgroundFetch 실행: $taskId');
      await scheduleWeeklyNotification();
      print('finally 1');
      BackgroundFetch.finish(taskId);
      print('finally 2');
    },
  );

  // 헤드리스 작업 등록

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  print('백그라운드 뒤');

  // 앱 실행
  runApp(MyApp());

  // Splash 제거
  FlutterNativeSplash.remove();
} // main /////=======

void backgroundFetchHeadlessTask(String taskId) async {
  print('백그라운드에서 알람 설정 작업 수행');
  await scheduleWeeklyNotification(); // 반복 알람 예약
  BackgroundFetch.finish(taskId);
}

Future<void> scheduleWeeklyNotification() async {
  print("메인실행시발동하는건가");
  // 만약 12월 11일 수요일 오후 6시에 매일 반복 알람이면
  // 내 아이디랑 그 알람 정보를 가져와서
  // 새로 대체하면 그알람은 삭제되고 이거로 된다는건데 그럼 상관없네 오히려 좋네 ...
  // 그럼 내 UID랑 게시글의 UID 비교해서 내거만 가져오고
  // 그걸로 오늘
  // 12월 11일 수요일 내용 정리
  // ==== 백그라운드에서 날짜에 맞는 알람이 있는지 그날 탐색해서
  // 그날 알람이 만약 반복설정되는게 있다면 그걸 덮어씌워 알람이 울리던 말던 덮어씌우면 됨
  // 그러면 이게 15분마다 반복이던 말던 알람이 울릴꺼 같은데?
  // 근데 이제 문제는 시간이 되면 그만되게 만들어야 하나?
  // 그날 하루종일 반복할 수도 있잖아.
  // 백그라운드 작업이 어떻게 되는건지 모르겠네 계속 반복하는건지 먼지
  // 시간까지 일치하는게 맞는거 같긴해.
  // 그렇게 해보고 안되면 바꾸는게 맞다;
  // 근데 이제 6시 다 되어 가니까 집에 갈까.
  // 이게 제발 되어야 할텐데
  // 이번주 금요일 까지는 끝내자.
  print('[scheduleWeeklyNotification] 실행 시작');

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('Calender')
        .where('userid', isEqualTo: UserManager.userId)
        .where('option', isNotEqualTo: null)
        // .where('day', isEqualTo: DateTime.now().day)
        .get();

    if (snapshot.docs.isEmpty) {
      print('[scheduleWeeklyNotification] Firestore 결과 없음');
      return;
    }

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      print('[scheduleWeeklyNotification] 데이터: $data');
      print('[scheduleWeeklyNotification] 데이터 옵션: ${data['option']}');
      print(
          '[scheduleWeeklyNotification] 데이터 option_day: ${data['option_day']}');
      print('[scheduleWeeklyNotification] 데이터 userid: ${data['userid']}');
      print('[scheduleWeeklyNotification] 데이터 스케쥴: ${data['Schedule']}');
      // 필요한 작업 수행
      tz.TZDateTime schedule = tz.TZDateTime(
        tz.local,
        data['year'],
        data['month'],
        data['day'],
        data['hour'],
        data['minute'],
      );

      /// 아 이거 요일별로 하는거 있지 않았나>?????????
      /// 날짜로 하는거 아니라 흐미ㅣㅣㅣㅣ;아ㅏ아아아아ㅏㅣ;;;
// if(data['option'] == "주중"){
//   for (int weekday = DateTime.monday; weekday <= DateTime.friday; weekday++) {
//     print("print(weekday); $weekday");
//     print("print(data['uniqueID'] + weekday); ${data['uniqueID'] + weekday}");
//   await flutterLocalNotificationsPlugin.zonedSchedule(
//           data['uniqueID'] + weekday, // 각 요일에 고유 ID 사용, // 반복 알람 ID
//           '반복 알람',
//           data['Schedule'],
//           schedule,
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               'channel_id',
//               'channel_name',
//               channelDescription: '반복 알람 채널 설명',
//               importance: Importance.high,
//               priority: Priority.high,
//             ),
//           ),
//           androidAllowWhileIdle: true,
//           uiLocalNotificationDateInterpretation:
//               UILocalNotificationDateInterpretation.absoluteTime,
//           matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // 매주 반복
//         );
//   }
// }
    }
  } catch (e) {
    print('[scheduleWeeklyNotification] 오류: $e');
  } finally {
    print('[scheduleWeeklyNotification] 실행 완료');
  }

  //   for (var doc in snapshot.docs) {
  //   final data = doc.data();
  //   final date = DateTime(data['year'], data['month'], data['day']);
  //   final event = data['Schedule'];
  //   final option = data['option'];
  //   final optionDay =
  //       data.containsKey('option_day') ? data['option_day'] : null;

  // }

  // 안드로이드에서는 설정칸이 픽셀에러 뜬다. 좀 더 여유 두게 해야할듯.
  // ㅇㅅㅇ...
//==================================================//
  // final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  // final tz.TZDateTime nextWeek =
  //     now.add(Duration(days: 7 - now.weekday)); // 다음 주 동일 시간

  // await flutterLocalNotificationsPlugin.zonedSchedule(
  //   1, // 반복 알람 ID
  //   '반복 알람',
  //   '매주 동일 시간에 울립니다!',
  //   nextWeek,
  //   const NotificationDetails(
  //     android: AndroidNotificationDetails(
  //       'channel_id',
  //       'channel_name',
  //       channelDescription: '반복 알람 채널 설명',
  //       importance: Importance.high,
  //       priority: Priority.high,
  //     ),
  //   ),
  //   androidAllowWhileIdle: true,
  //   uiLocalNotificationDateInterpretation:
  //       UILocalNotificationDateInterpretation.absoluteTime,
  //   matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // 매주 반복
  // );
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

// late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
// 백그라운드 페치 초기화
// void initBackgroundFetch() {
//   BackgroundFetch.configure(
//     BackgroundFetchConfig(
//       minimumFetchInterval: 15, // 15분마다 실행
//       stopOnTerminate: false, // 앱이 종료되어도 실행
//       enableHeadless: true, // 앱이 완전히 종료된 상태에서 실행 가능
//     ),
//     (String taskId) async {
//       print("[BackgroundFetch] 백그라운드 작업 실행됨: $taskId");

//       // payload 확인 후 "주중" 알람만 처리
//       if (taskId == 'weekday') {
//         print('주중 알람 처리');

//         // 주간 반복 알람 설정 함수 (월~금)
//         Future<void> _setWeekdayAlarms() async {
//           const List<int> weekdays = [
//             DateTime.monday,
//             DateTime.tuesday,
//             DateTime.wednesday,
//             DateTime.thursday,
//             DateTime.friday
//           ];

//           for (int weekday in weekdays) {
//             final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

//             await flutterLocalNotificationsPlugin.zonedSchedule(
//               weekday, // 각 요일에 고유한 ID 사용
//               '주중 반복 알람', // 알람 제목
//               '주중 반복 알람입니다.', // 알람 내용
//               now,
//               const NotificationDetails(
//                 android: AndroidNotificationDetails(
//                   'weekday_repeat_channel_id',
//                   'Weekday Repeat Alarm',
//                   channelDescription: '주중 반복 알람 채널',
//                   importance: Importance.max,
//                   priority: Priority.high,
//                 ),
//               ),
//               androidAllowWhileIdle: true,
//               uiLocalNotificationDateInterpretation:
//                   UILocalNotificationDateInterpretation.absoluteTime,
//               matchDateTimeComponents:
//                   DateTimeComponents.dayOfWeekAndTime, // 요일에 맞춰 반복 알람 설정
//             );
//             print('주중 알람 처리$weekday ㅏㅏㅏㅏ ');
//           }
//         }
//         // 주중 알람 처리 로직 추가
//       }

//       // 작업 종료
//       BackgroundFetch.finish(taskId);
//     },
//   ).then((int status) {
//     print("[BackgroundFetch] 초기화 성공: $status");
//   }).catchError((e) {
//     print("[BackgroundFetch] 초기화 에러: $e");
//   });

//   // 강제로 백그라운드 작업 실행 (테스트용)
//   BackgroundFetch.start();
// }
