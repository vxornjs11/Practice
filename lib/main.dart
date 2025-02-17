import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/services.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';

class UserManager {
  static String? userId;
// final FirebaseAuth _auth = FirebaseAuth.instance;
//   User? _user;
//   // 유저 아이디를 SharedPreferences에 저장
//   static Future<void> saveUserId(String id) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('userId', id);
//     userId = id;
//   }

//   // 유저 아이디를 SharedPreferences에서 불러오기
//   static Future<void> loadUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     userId = prefs.getString('userId');
//   }

//   // 유저 아이디를 생성 (없을 경우)
//   static Future<void> initializeUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? id = prefs.getString('userId');
//     if (id == null) {
//       // print("id = null");
//       id = const Uuid().v4();
//       await saveUserId(id);
//     } else {
//       // print("id not null");
//       userId = id;
//     }
//   }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 익명로그인
  await Firebase.initializeApp();

  // 익명 로그인 실행
  await FirebaseAuth.instance.signInAnonymously();
  // 익명 로그인
  UserCredential userCredential =
      await FirebaseAuth.instance.signInAnonymously();
  UserManager.userId = userCredential.user?.uid; // UserManager에 저장
  print("UserManager.userId");
  print("${UserManager.userId}");
  print("UserManager.userId");
  saveUserToFirestore();
  // 파이어베이스 익명 로그인 추가
  // Flutter Native Splash 유지
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones(); // 시간대 데이터 초기화
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
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
      // print('알림 클릭됨: ${details.payload}');
    },
  );

  /////// Set_schedule.dart에서 알람 실행시 발동하는 함수 옮겨왔음. 여기에 있는게 맞는듯
  ////// 그럼 Set_~~에 있는거는 어떻게 해야 할지 생각.. 없어도 되나?

  // // 사용자 ID 초기화
  // await UserManager.initializeUserId();
  // 캘린더 쪽에 버튼 누를때마다 ui 엄청 반짝거리는데 별로임 눈아픔
  // 백그라운드 작업 초기화
  // initBackgroundFetch();
  // print('백그라운드 앞');
  // Background Fetch 초기화
  BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 2, // 최소 실행 간격
      stopOnTerminate: false, // 앱 종료 후에도 유지
      enableHeadless: true, // 헤드리스 모드 활성화
      startOnBoot: true, // 디바이스 재부팅후 다시 작업.
      forceAlarmManager: true,
    ),
    (taskId) async {
      // print('포그라운드에서 BackgroundFetch 실행: $taskId');
      await scheduleWeeklyNotification(); // 알림 예약 작업
      BackgroundFetch.finish(taskId); // 항상 호출
      // print('finally b');
    },
    // ahfnfprtjddy.
    // 매일 옵션이 현재시간보다 이전이면 제대로 작동 안하는듯.
    (taskId) async {
      // print('헤드리스 모드에서 BackgroundFetch 실행: $taskId');
      await scheduleWeeklyNotification();
      // print('finally 1');
      BackgroundFetch.finish(taskId);
      // print('finally 2');
    },
  );
// 🔹 백그라운드 작업 강제 시작
  BackgroundFetch.start();
  // 헤드리스 작업 등록

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  // print('백그라운드 뒤');

  // Splash 제거
  const Duration(seconds: 2);
  FlutterNativeSplash.remove();
  // 앱 실행
  runApp(const MyApp());
} // main /////=======

void backgroundFetchHeadlessTask(String taskId) async {
  // print("헤드리스 작업 실행: $taskId");

  // 백그라운드 작업 실행
  try {
    await scheduleWeeklyNotification(); // 사용자 작업
  } catch (e) {
    // print("헤드리스 작업 오류: $e");
  }

  // 작업 완료 알림
  BackgroundFetch.finish(taskId);
}

///// 권한설정 ./////
Future<void> requestExactAlarmsPermission() async {
  const MethodChannel platform =
      MethodChannel('dexterous.com/flutter/local_notifications');

  try {
    final bool granted =
        await platform.invokeMethod<bool>('requestExactAlarmsPermission') ??
            false;
    if (granted) {
      // print("정확한 알람 권한이 허용되었습니다.");
    } else {
      // print("정확한 알람 권한이 거부되었습니다.");
    }
  } on PlatformException catch (e) {
    // print("정확한 알람 권한 요청 중 오류 발생: ${e.message}");
  }
}

void openAppSettings() {
  AppSettings.openAppSettings();
}

Future<void> requestNotificationsPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

void saveUserToFirestore() async {
  // void saveUserToFirestore() async {
  User? user = FirebaseAuth.instance.currentUser;
  print("1 2 3!");
  if (user != null) {
    await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
      "userid": user.uid, // ✅ 사용자 인증 ID
      // "email": "익명 사용자",
      // "name": "익명 유저" // 필요시 사용자 정보 추가 가능
    }, SetOptions(merge: true)); // 기존 데이터가 있으면 업데이트
    print("✅ Firestore에 사용자 정보 저장 완료!");
  } else {
    print("🚨 로그인되지 않음!");
  }
  print("1 2  4443!");
// }
}

///dd
Future<void> scheduleWeeklyNotification() async {
  //// 알람권한 그냥 애뮬레이터에 있는 앱 설정 열어서 하니까 되던데 다시 해볼까?
  await requestExactAlarmsPermission(); // 정확한 알람 권한 요청
  await requestNotificationsPermission(); // 알림 권한 요청
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'high_importance_channel', // channelId
    'High Importance Notifications', // channelName
    channelDescription:
        'This channel is used for important notifications.', // channelDescription
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  // alarms&reminders에서 테스트어플의 Allow setting alarms and reminders 버튼이 비활성화
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: 1));
  // print("메인실행시발동하는건가");
  // day로 하면 아닌 날에도 반복되는건 멈출거야.
  // 하지만 그날 내내 알람을 재설정 하는 개찐빠가 벌어지겠지
  // 어쩌면 기존알람과 함께 2번 울릴지도.
  //
  // print('[scheduleWeeklyNotification] 실행 시작');

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('Calender')
        .where('userid', isEqualTo: UserManager.userId)
        .where('option', isNotEqualTo: null)
        // .where('day', isEqualTo: DateTime.now().day)
        .get();

    if (snapshot.docs.isEmpty) {
      // print('[scheduleWeeklyNotification] Firestore 결과 없음');
      return;
    }

    for (var doc in snapshot.docs) {
      // ignore: unnecessary_cast
      final data = doc.data() as Map<String, dynamic>;
      // print('[scheduleWeeklyNotification] 데이터: $data');
      // print('[scheduleWeeklyNotification] 데이터 옵션: ${data['option']}');
      // print(
      //     '[scheduleWeeklyNotification] 데이터 option_day: ${data['option_day']}');
      // print('[scheduleWeeklyNotification] 데이터 uniqueID: ${data['uniqueID']}');
      // print('===========================');

      /// 아 이거 요일별로 하는거 있지 않았나>?????????
      /// 날짜로 하는거 아니라 흐미ㅣㅣㅣㅣ;아ㅏ아아아아ㅏㅣ;;;
      /// // 그래프가 이상한데 휴대폰으로 테스트한거에서 목표치 25 달성 5가 될수가 없는데.
      /// 그래프 주중이 근야 전체일정을 10씩 증가시키는데 뭐냐 ㅋㅋ
      switch (data['option']) {
        // if가없음.
        case "주중":
          if (DateTime.now().year == data['year'] &&
              DateTime.now().month == data['month'] &&
              DateTime.now().day == data['day']) {
            for (int weekday = DateTime.monday;
                weekday <= DateTime.friday;
                weekday++) {
              int weekday2 = weekday;
              int hour = data['hour'];
              int minit = data['minit'];

              // 알림 ID와 예약 시간 디버깅
              try {
                final notificationId = data['uniqueID'] + weekday2;
                // print("알림 ID: $notificationId");

                final scheduledTime = _nextInstanceOfWeekday(
                  weekday2,
                  hour,
                  minit,
                );
                // print("예약된 시간: $scheduledTime");

                // 알림 예약
                await flutterLocalNotificationsPlugin.zonedSchedule(
                  notificationId,
                  '',
                  data['Schedule'],
                  scheduledTime,
                  platformChannelSpecifics,
                  androidAllowWhileIdle: true,
                  uiLocalNotificationDateInterpretation:
                      UILocalNotificationDateInterpretation.absoluteTime,
                  matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
                );

                // print("알림 예약 성공: $notificationId");
              } catch (e) {
                // print("zonedSchedule 실행 중 오류 발생: $e");
              }
            }
          }
          {
            break;
          }
        case "주말":
          // if가없음. 그래서 그날 알림 +
          // 미리 포그라운드에서 발동해버려서 만들어진 알람 2개 해서 주말에 알람이 3개네
          if (DateTime.now().year == data['year'] &&
              DateTime.now().month == data['month'] &&
              DateTime.now().day == data['day']) {
            for (int weekday = DateTime.saturday;
                weekday <= DateTime.sunday;
                weekday++) {
              int hour = data['hour'];
              int minit = data['minit'];

              // 알림 ID와 예약 시간 디버깅
              try {
                final notificationId = data['uniqueID'] + weekday;
                // print("알림 ID: $notificationId");

                final scheduledTime = _nextInstanceOfWeekday(
                  weekday,
                  hour,
                  minit,
                );
                // print("예약된 시간: $scheduledTime");

                // 알림 예약
                await flutterLocalNotificationsPlugin.zonedSchedule(
                  notificationId,
                  '',
                  data['Schedule'],
                  scheduledTime,
                  platformChannelSpecifics,
                  // androidAllowWhileIdle: true,
                  uiLocalNotificationDateInterpretation:
                      UILocalNotificationDateInterpretation.absoluteTime,
                  matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
                );

                // print("알림 예약 성공: $notificationId");
              } catch (e) {
                // print("zonedSchedule 실행 중 오류 발생: $e");
              }
            }
          }
          {
            break;
          }
        case "매주":
          int hour = data['hour'];
          int minit = data['minit'];
          int day = data['day'];
          int month = data['month']; // 반복할 특정 월

          if (DateTime.now().year == data['year'] &&
              DateTime.now().month == data['month'] &&
              DateTime.now().day == data['day']) {
            final notificationId = data['uniqueID']; // 고유 ID 생성
            // print("알림 ID: $notificationId");

            final now = tz.TZDateTime.now(tz.local);

            // 1년 뒤 알림 예약
            final scheduledTime = tz.TZDateTime(
              tz.local,
              now.year, // 1년 뒤
              month,
              day,
              hour,
              minit,
            );

            // print("예약된 시간 (매주): $scheduledTime");

            try {
              await flutterLocalNotificationsPlugin.zonedSchedule(
                notificationId,
                '',
                data['Schedule'],
                scheduledTime,
                platformChannelSpecifics,
                // androidAllowWhileIdle: true,
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime,
                matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
              );
              // print("매주 반복 알림 예약 성공: $scheduledTime");
            } catch (e) {
              // print("매주 반복 알림 예약 실패: $e");
            }
          }
          break;
        case "한달":
// print("매달반복은 이거 필요없다.");

          break;

        case "1년":
          if (DateTime.now().month == data['month'] &&
              DateTime.now().day == data['day']) {
            try {
              int hour = data['hour'];
              int minit = data['minit'];
              int day = data['day'];
              int month = data['month']; // 반복할 특정 월

              final notificationId = data['uniqueID'] + 1000; // 고유 ID 생성
              // print("알림 ID: $notificationId");

              final now = tz.TZDateTime.now(tz.local);

              // 1년 뒤 알림 예약
              final scheduledTime = tz.TZDateTime(
                tz.local,
                now.year + 1, // 1년 뒤
                month,
                day,
                hour,
                minit,
              );

              // print("예약된 시간 (1년 반복): $scheduledTime");
//dd
              await flutterLocalNotificationsPlugin.zonedSchedule(
                notificationId,
                '',
                data['Schedule'],
                scheduledTime,
                platformChannelSpecifics,
                // androidAllowWhileIdle: true,
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime,
              );

              // print("1년 반복 알림 예약 성공: $notificationId");
            } catch (e) {
              // print("1년 반복 zonedSchedule 실행 중 오류 발생: $e");
            }
          } else {
            // 1년 반복 실행할 필요 없는 경우.
          }

          break;
        case "매일":
          // print("매일매일");
          if (DateTime.now().year == data['year'] &&
              DateTime.now().month == data['month'] &&
              DateTime.now().day == data['day']) {
            // "매일"옵션이 1월31일 금요일이라서 2월1일 토요일에는 작동을 안한듯?
            // 근데 그래도 1월31일 금요일에 DateTimeComponents.time으로 작동해서
            // 매일알람이 되어야 하는거 아닌감?
            final now = tz.TZDateTime.now(tz.local);
            // print("매일매일$now");

            // 알림 예약 시간 계산 (현재 시간보다 이후로 설정)
            final scheduledTime = tz.TZDateTime(tz.local, now.year, now.month,
                now.day, data['hour'], data['minit']);
            await flutterLocalNotificationsPlugin.zonedSchedule(
              data['uniqueID'], // 알림 ID
              '',
              data['Schedule'],
              scheduledTime,
              platformChannelSpecifics,
              // androidAllowWhileIdle: true,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간 반복
            );
          }
          break;

        default:
          // 반복없음 인데 이거는 상관없고...
          // 여기 넣을게 없는데?
          // 흠....?
          // 매주 추가하면 어떻게 될까.

          break;
      }
    }
  } catch (e) {
    // print('[scheduleWeeklyNotification] 오류: $e');
  } finally {
    // print('[scheduleWeeklyNotification] 실행 완료');
  }
}
// 237318673
//593466206

_nextInstanceOfWeekday(int weekday, int hour, int minute) {
  // print("디버디버깅: now");
  final now = DateTime.now();
  // print("디버디버깅: now222");
  // print("디버디버깅111 : ${tz.local}");

  tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  // print("디버디버깅: $scheduledDate");
  // 현재 시간이 예약 시간보다 늦은 경우, 다음 주로 이동
  if (scheduledDate.isBefore(now) || scheduledDate.weekday != weekday) {
    // print("디버디버깅: 이프문 통과");
    scheduledDate = scheduledDate.add(const Duration(days: 1));
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
  }
  // print("ㅡ끄끄끝>");
  return scheduledDate;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
