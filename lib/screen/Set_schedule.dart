import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:practice_01_app/home.dart';
import 'package:practice_01_app/main.dart';
import 'package:practice_01_app/provinder/count_provinder.dart';
import 'package:practice_01_app/provinder/timer_provinder.dart';
import 'package:practice_01_app/screen/Refresh.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Set_schedul extends StatefulWidget {
  final DateTime selectedDate_;
  final String schedule_Write;
  final int selectedHour;
  final int selectedMinute;
  final String option;
  const Set_schedul(
      {super.key,
      required this.option,
      required this.selectedDate_,
      required this.schedule_Write,
      required this.selectedHour,
      required this.selectedMinute});
  @override
  State<Set_schedul> createState() => __Set_schedulState();
}

class __Set_schedulState extends State<Set_schedul> {
  // String get timeText {
  //   return _selectedHour < 12 ? "오전" : "오후";
  // }
  DateTime _selectedDate = DateTime.now();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // SureStlye sureStyle = SureStlye();
  late DateTime selectedDate_;
  late String option = "";
  // late String option;
  late String schedule_Write;
  late TextEditingController titlecontroller;
  late String textdate;
  late bool _isSwitch;
  late bool _isCheck;
  late int _selectedHour;
  late int _selectedMinute;
  // late int _selectedSeconds;
  String timeText_1 = "오전";
  late String timeText_2;

  final List<int> Hour = List<int>.generate(24, (int index) => index + 1);
  // final List<int> minute = List<int>.generate(60, (int index) => index);
  final List<int> seconds = List<int>.generate(60, (int index) => index);
  final List<String> minute = List<String>.generate(
      60, (int index) => index.toString().padLeft(2, '0'));

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // selectedDate_ = widget.selectedDate_;
    selectedDate_ = widget.selectedDate_;
    option = widget.option;
    schedule_Write = widget.schedule_Write;
    _selectedHour = widget.selectedHour;
    _selectedMinute = widget.selectedMinute;
    titlecontroller = TextEditingController();
    textdate = "";
    _isSwitch = false;
    _isCheck = false;
    timeText_1 = "오전";
    timeText_2 = "오후";

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: iosInitializationSettings);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // _fetchAndScheduleNotifications();
  }

  // Future<void> _fetchAndScheduleNotifications() async {
  //   final snapshot =
  //       await FirebaseFirestore.instance.collection('Calender').get();

  //   for (var doc in snapshot.docs) {
  //     final data = doc.data();
  //     final DateTime date = DateTime(data['year'], data['month'], data['day'],
  //         data['hour'], data['minute']);
  //     final String message = data['Schedule'];

  //     if (date.isAfter(DateTime.now())) {
  //       _scheduleNotification(date, message);
  //     }
  //   }
  // }

  Future<void> _scheduleNotification(
      DateTime dateTime, String message, String option) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
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
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );
    final pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print('Pending notifications: ${pendingNotifications.length}');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 1));
    switch (option.trim()) {
      case '매일':
        tz.TZDateTime schedule = tz.TZDateTime(
          tz.local,
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
        );
        await flutterLocalNotificationsPlugin.zonedSchedule(
          8,
          '일정 알림',
          message,
          schedule,
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          // androidAllowWhileIdle: true,
          matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간에 알림.
        );
        break;
      case '주중':
        for (int i = 1; i <= 5; i++) {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            i, // 고유한 ID
            '일정 알림', // 알림 제목
            message, // 알림 메시지
            _nextInstanceOfWeekday(dateTime, i), // 다음 주중 날짜 계산
            platformChannelSpecifics,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true,
            matchDateTimeComponents:
                DateTimeComponents.dayOfWeekAndTime, // 매주 특정 요일에 반복
          );
        }
        break;
      case '주말':
        for (int i = 6; i <= 7; i++) {
          // 토요일(6)과 일요일(7)
          await flutterLocalNotificationsPlugin.zonedSchedule(
            i + 5, // 고유한 ID 설정 (주중 알림 ID와 겹치지 않도록 5를 더함)
            '일정 알림', // 알림 제목
            message, // 알림 메시지
            _nextInstanceOfWeekend(dateTime, i), // 다음 주말 날짜 계산
            platformChannelSpecifics,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true,
            matchDateTimeComponents:
                DateTimeComponents.dayOfWeekAndTime, // 매주 특정 요일에 반복
          );
        }
        break;
      case '한달':
        await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          '일정 알림',
          message,
          tz.TZDateTime(
            tz.local,
            dateTime.year,
            dateTime.month,
            dateTime.day,
            dateTime.hour,
            dateTime.minute,
          ),
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
        );
        break;
      case '1년':
        for (var i = 0; i < 10; i++) {
          final id = i + 1; // 고유한 ID 설정
          await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            '일정 알림',
            message,
            tz.TZDateTime(
              tz.local,
              dateTime.year + i,
              dateTime.month,
              dateTime.day,
              dateTime.hour,
              dateTime.minute,
            ),
            platformChannelSpecifics,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true,
          );
          print("Scheduled yearly notification $id for ${tz.TZDateTime(
            tz.local,
            dateTime.year + i,
            dateTime.month,
            dateTime.day,
            dateTime.hour,
            dateTime.minute,
          )}");
        }
        break;

      default:
        await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          '일정 알림',
          message,
          tz.TZDateTime(
            tz.local,
            dateTime.year,
            dateTime.month,
            dateTime.day,
            dateTime.hour,
            dateTime.minute,
          ),
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidAllowWhileIdle: true,
        );
        print("Scheduled default notification at ${tz.TZDateTime(
          tz.local,
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
        )}");
        break;
    }
  }

  /// 다음 주중 날짜를 계산하는 함수
  tz.TZDateTime _nextInstanceOfWeekday(DateTime dateTime, int weekday) {
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }

  /// 다음 주말 날짜를 계산하는 함수
  tz.TZDateTime _nextInstanceOfWeekend(DateTime dateTime, int weekendDay) {
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );
    while (scheduledDate.weekday != weekendDay) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }

  // makeDate(){
  //   var now =tz.TZDateTime.now(tz.local);
  //   var when = tz.TZDateTime(tz.local,now.year)
  // }

  // Future<void> _addNewDocument(String newTitle) async {
  //   try {
  //     await _firestore.collection('newCollection').add({
  //       'title': newTitle,
  //       // 'created_at': Timestamp.now(),
  //     });
  //     print('새 문서가 성공적으로 추가되었습니다.');
  //   } catch (e) {
  //     print('문서 추가 중 오류가 발생했습니다: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    String textdate = "";
    var size = MediaQuery.of(context).size;
    TextEditingController text_title;
    var styles = TextStyle(
        fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500);
    return Scaffold(
        appBar: AppBar(
          title: const Text("일정 등록"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                context
                    .read<CounterProvider>()
                    .ChangeText(newYear: '', newMonth: '', newDay: '');
              });

              // 커스텀 동작을 수행하거나 원하는 페이지로 이동
              Get.offAll(const home()); // 홈 페이지로 이동, 이전 페이지 스택을 모두 제거
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.grey.shade200),
                  child: TableCalendar(
                    onDaySelected: onDaySelected,
                    selectedDayPredicate: (date) {
                      return isSameDay(selectedDate_, date);
                    },
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: DateTime.now(),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.grey.shade200),
                  width: size.width * 1,
                  height: size.height * 0.05,
                  child: context.watch<CounterProvider>().day != ""
                      ? Consumer<CounterProvider>(
                          builder: (context, value, child) {
                            return Center(
                                child: Text("${value.month}월${value.day}일"));
                          },
                        )
                      : Center(
                          child: Text(
                              "${selectedDate_.month}월${selectedDate_.day}일")),
                ),
                // -- 구분 --
                // 처음에 아무것도 없는 빈칸이다가
                // 일정 하나 등록하면 1줄씩 생기는거임.
                // 그리고 밑으로 하나씩 밀어.
                // 대충 5개정도가 최대치로?
                // 아니면 몇줄 이상이면 스크롤 뷰로 해도될듯.
                Text(schedule_Write),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.grey.shade200),
                  width: size.width * 1,
                  height: size.height * 0.05,
                  child: TextField(
                    // textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      hintText: '일정을 등록하세요',
                      border: InputBorder.none,
                      // suffixIcon: IconButton(
                      //     onPressed: () {
                      //       setState(() {
                      //         _isSwitch = !_isSwitch;
                      //         if (_isSwitch == false) {
                      //         } else {
                      //           AlertDialog();
                      //         }
                      //       });
                      //     },
                      //     style: ElevatedButton.styleFrom(
                      //         backgroundColor: _isSwitch
                      //             ? Colors.grey.shade200
                      //             : Colors.grey.shade200),
                      //     icon: _isSwitch
                      //         ? Icon(Icons.notifications_active_outlined)
                      //         : Icon(Icons.notifications_off_outlined)
                      //     //  Text(_isSwitch ? "ON" : "OFF"),
                      //     ),
                    ),
                    controller: titlecontroller,
                    onChanged: (value) {
                      setState(() {
                        schedule_Write = titlecontroller.text;
                        // checkDuplicateTitle(); // 중복 확인 함수 호출
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 5,
                    ),
                    _isSwitch
                        ? const Icon(
                            Icons.notifications_active_outlined,
                            size: 25,
                            color: Colors.black54,
                          )
                        : const Icon(
                            Icons.notifications_off_outlined,
                            size: 25,
                            color: Colors.black54,
                          ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSwitch = !_isSwitch;
                          if (_isSwitch == false) {
                          } else {
                            AlertDialog();
                          }
                        });
                      },
                      child: Container(
                        width: size.width * 0.8,
                        height: size.height * 0.045,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: _selectedHour == 0
                              ? const Text(
                                  "알림 없음",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200,
                                      color: Colors.black
                                      // fontFamily: 'roboto'
                                      ),
                                )
                              : Text(
                                  "$_selectedHour시$_selectedMinute분",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black
                                      // fontFamily: 'roboto'
                                      ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.refresh,
                      size: 25,
                      color: Colors.black54,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => (Repeat(
                                  selectedDate_: selectedDate_,
                                  schedule_Write: schedule_Write,
                                  selectedHour: _selectedHour,
                                  selectedMinute: _selectedMinute)),
                            ),
                          );
                          // AlertDialog_Refresh();
                        });
                      },
                      child: Container(
                        width: size.width * 0.8,
                        height: size.height * 0.045,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white),
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: option == ""
                              ? const Text(
                                  "반복 안 함",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w100,
                                    // fontFamily: 'roboto'
                                  ),
                                )
                              : Text(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w100,
                                    // fontFamily: 'roboto'
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      // _addNewSchedule();
                      String day = context.read<CounterProvider>().day;
                      String year = context.read<CounterProvider>().year;
                      String month = context.read<CounterProvider>().month;
                      // print(
                      //   selectedDate.day,
                      // );

                      // int day_init_fire = int.parse(day);

                      // String day = context.watch<CounterProvider>().day;
                      try {
                        await _firestore.collection("Calender").add(
                          {
                            "Schedule": schedule_Write,
                            "year": year == ""
                                ? selectedDate.year
                                : int.parse(year),
                            "month": month == ""
                                ? selectedDate.month
                                : int.parse(month),
                            "day":
                                day == "" ? selectedDate.day : int.parse(day),
                            "hour": _selectedHour,
                            "minit": _selectedMinute,
                            "option": option,
                            "option_day": option == "주말"
                                ? ["토", "일"]
                                : option == "주중"
                                    ? ["월", "화", "수", "목", "금"]
                                    : [
                                        DateFormat('E', 'ko_KO')
                                            .format(selectedDate_)
                                      ],
                            "userid": UserManager.userId
                          },
                        );
                        Get.offAll(const home()); // 홈 페이지로 이동, 이전 페이지 스택을 모두 제거
                      } catch (e) {}
                      setState(() {
                        context
                            .read<CounterProvider>()
                            .ChangeText(newYear: '', newMonth: '', newDay: '');

                        _selectedDate = DateTime(
                          year == "" ? selectedDate.year : int.parse(year),
                          month == "" ? selectedDate.month : int.parse(month),
                          day == "" ? selectedDate.day : int.parse(day),
                          _selectedHour,
                          _selectedMinute,
                        );
                      });
                      print("_selectedDate");
                      print(option);
                      print("_selectedDate");
                      _scheduleNotification(
                          _selectedDate, schedule_Write, option);
                    },
                    child: Text("등록하기")),
                ElevatedButton(
                    onPressed: () async {
                      flutterLocalNotificationsPlugin.cancelAll();
                      final pendingNotifications =
                          await flutterLocalNotificationsPlugin
                              .pendingNotificationRequests();
                      print(
                          'Pending notifications: ${pendingNotifications.length}');
                    },
                    child: Text("test")),
              ],
            ),
          ),
        ));
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      this.selectedDate = selectedDate;
      selectedDate_ = selectedDate;
      print("selectedDate$selectedDate");
      textdate =
          "${selectedDate.year.toString() + selectedDate.month.toString() + selectedDate.day.toString()}";
      context.read<CounterProvider>().ChangeText(
          newYear: selectedDate.year.toString(),
          newMonth: selectedDate.month.toString(),
          newDay: selectedDate.day.toString());
    });
  }

  Future<void> AlertDialog() {
    // late String timeText_1 = "오전";
    return showDialog<Void>(
        barrierColor: Colors.black.withOpacity(0.8),
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.white,
                height: 300,
                width: 500,
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    const Text(
                      "알림 추가",
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 80,
                              child: Text(
                                  context.watch<Timer_Provider>().TimerText)),
                          SizedBox(
                            width: 80,
                            height: 100,
                            child: CupertinoPicker(
                              backgroundColor: Colors.white,
                              scrollController:
                                  FixedExtentScrollController(initialItem: 1),
                              itemExtent: 50,
                              onSelectedItemChanged: (int index) {
                                setState(() {
                                  _selectedHour = Hour[index];
                                  print(_selectedHour);
                                  if (_selectedHour > 12) {
                                    timeText_1 = "오후";
                                    context
                                        .read<Timer_Provider>()
                                        .ChangeTimer_Text(timeText: timeText_1);
                                  } else {
                                    timeText_1 = "오전";
                                    context
                                        .read<Timer_Provider>()
                                        .ChangeTimer_Text(timeText: timeText_1);
                                  }
                                });
                              },
                              children: Hour.map((int value) {
                                return Center(child: Text('$value'));
                              }).toList(),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            height: 100,
                            child: CupertinoPicker(
                              scrollController:
                                  FixedExtentScrollController(initialItem: 1),
                              itemExtent: 50,
                              onSelectedItemChanged: (int index) {
                                setState(() {
                                  _selectedMinute = index % minute.length;
                                });
                              },
                              children: List<Widget>.generate(120, (index) {
                                return Center(
                                    child: Text(minute[index % minute.length]));
                              }),
                            ),
                          ),
                          // SizedBox(
                          //   width: 80,
                          //   child: CupertinoPicker(
                          //     scrollController:
                          //         FixedExtentScrollController(initialItem: 0),
                          //     itemExtent: 30,
                          //     onSelectedItemChanged: (int index) {
                          //       setState(() {
                          //         _selectedSeconds = seconds[index];
                          //         print(_selectedSeconds);
                          //       });
                          //     },
                          //     children: seconds.map((int value) {
                          //       return Center(child: Text('$value'));
                          //     }).toList(),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.005,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // 시간대 설정 메소드 들어가야한다.
                          },
                          child: Text("OK"),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("back"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  // Future<void> _addNewSchedule(String newTitle) async {
  //   try {
  //     await _firestore.collection('newCollection').add({
  //       'title': newTitle,
  //       // 'created_at': Timestamp.now(),
  //     });
  //     print('새 문서가 성공적으로 추가되었습니다.');
  //   } catch (e) {
  //     print('문서 추가 중 오류가 발생했습니다: $e');
  //   }
  // }
}// end


// {
//     "user_id": {
//       "schedule_id": {
// 연도 : 선택한 연도
// 달 : 달,일,요일
// 요일 :
// 할일 : [걍 리스트로 하면 됨.]
// 근데 할일을 반복으로 할 거라면?
// 반복일정은 따로 빼놔서 그 일정에 싹다 add로 수정해서 넣어버리면 안되나?
// 알림설정 : 트루/펄스
// - 트루로 설정시 따로 알림설정 만들어서 해당 화면에서 완료 누르면
// - 알림설정 관련 메소드 발동하게 하면 될듯.
//
//         "title": "물을 마신다."
//         "day": 1. 이런식으로 날짜 - 요일이 같이 자동으로 들어가게 하면 되겠는디.
//         "repeat": "Monday-Friday",
//         "time": "09:00",
//         "exceptional": {"title": "여행을 가다", "repeat": "Monday"}
//       }
// 이렇게 하면 1월 1일(월) 약먹기랑 1월 11일(월) 여행가기 을 어떻게 구분하지.
//     }
//   }

/// 흠... 데이터가 자기 uid가 없는데 어떻게 구분하는거지.
/// 애초에 구글 플레이스토어에서 다운 받는거니까 자기 계정 연동이 되어 있나? 일단 해보죠..
