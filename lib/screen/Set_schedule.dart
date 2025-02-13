import 'dart:ffi';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:practice_01_app/home.dart';
import 'package:practice_01_app/main.dart';
import 'package:practice_01_app/provinder/color_provinder.dart';
import 'package:practice_01_app/provinder/count_provinder.dart';
import 'package:practice_01_app/provinder/timer_provinder.dart';
import 'package:practice_01_app/screen/Refresh.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

// ignore: camel_case_types
class Set_schedul extends StatefulWidget {
  final DateTime selectedDate_;
  // ignore: non_constant_identifier_names
  final String schedule_Write;
  final int selectedHour;
  final int selectedMinute;
  final String option;
  final bool isCheck;
  const Set_schedul({
    super.key,
    required this.option,
    required this.selectedDate_,
    // ignore: non_constant_identifier_names
    required this.schedule_Write,
    required this.selectedHour,
    required this.selectedMinute,
    required this.isCheck,
  });
  @override
  State<Set_schedul> createState() => __Set_schedulState();
}

// ignore: camel_case_types
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
    titlecontroller = TextEditingController(text: schedule_Write);
    textdate = "";
    _isSwitch = false;
    _isCheck = widget.isCheck;
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

  Future<void> _scheduleNotification(int randomtimestampPart, DateTime dateTime,
      String message, String option) async {
    // tz.initializeTimeZones();
    // tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
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

    // tz.TZDateTime scheduledDate = tz.TZDateTime(
    //   tz.local,
    //   dateTime.year,
    //   dateTime.month,
    //   dateTime.day,
    //   dateTime.hour,
    //   dateTime.minute,
    // );
    // final pendingNotifications =
    //     await flutterLocalNotificationsPlugin.pendingNotificationRequests();
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
          randomtimestampPart,
          '',
          //??수정??
          message,
          schedule,
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          // androidAllowWhileIdle: true,
          matchDateTimeComponents:
              DateTimeComponents.dateAndTime, // 매일 같은 시간에 알림.
        );
        break;
      case '주중':
        // print("일정 알림 주중 0");
        tz.TZDateTime schedule = tz.TZDateTime(
          tz.local,
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
        );
        // print("일정 알림 주중 0.5");
        await flutterLocalNotificationsPlugin.zonedSchedule(
          randomtimestampPart,
          '',
          message,
          schedule,
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          // androidAllowWhileIdle: true,
          matchDateTimeComponents:
              DateTimeComponents.dateAndTime, // 매일 같은 시간에 알림.
        );
        // print("일정 알림 주중 1");
        break;
      case '주말':
        tz.TZDateTime schedule = tz.TZDateTime(
          tz.local,
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
        );
        await flutterLocalNotificationsPlugin.zonedSchedule(
          randomtimestampPart,
          '',
          message,
          schedule,
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          // androidAllowWhileIdle: true,
          matchDateTimeComponents:
              DateTimeComponents.dateAndTime, // 매일 같은 시간에 알림.
        );
        break;
      case '한달':
        await flutterLocalNotificationsPlugin.zonedSchedule(
          randomtimestampPart,
          '',
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
        tz.TZDateTime schedule = tz.TZDateTime(
          tz.local,
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
        );
        await flutterLocalNotificationsPlugin.zonedSchedule(
          randomtimestampPart,
          '',
          message,
          schedule,
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          // androidAllowWhileIdle: true,
          matchDateTimeComponents:
              DateTimeComponents.dateAndTime, // 매일 같은 시간에 알림.
        );

        break;

      case '매주':
        tz.TZDateTime schedule = tz.TZDateTime(
          tz.local,
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
        );
        await flutterLocalNotificationsPlugin.zonedSchedule(
          randomtimestampPart,
          '',
          message,
          schedule,
          platformChannelSpecifics,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          // androidAllowWhileIdle: true,
          matchDateTimeComponents:
              DateTimeComponents.dateAndTime, // 매일 같은 시간에 알림.
        );
        break;

      default:
        await flutterLocalNotificationsPlugin.zonedSchedule(
          randomtimestampPart,
          '',
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
          // androidAllowWhileIdle: true,
        );
        // print("Scheduled default notification at ${tz.TZDateTime(
        //   tz.local,
        //   dateTime.year,
        //   dateTime.month,
        //   dateTime.day,
        //   dateTime.hour,
        //   dateTime.minute,
        // )}");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // String textdate = "";
    var size = MediaQuery.of(context).size;
    // TextEditingController text_title;
    // var styles = TextStyle(
    //     fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500);
    return Consumer<ColorProvider>(builder: (context, value, child) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: value.backgroundColor,
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
              padding: const EdgeInsets.all(1.0),
              child: Consumer<ColorProvider>(builder: (context, value, child) {
                return Container(
                  width: size.width * 1,
                  height: size.height * 1,
                  decoration: BoxDecoration(
                    color: value.backgroundColor,
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            // 달력순간이동
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.white),
                        child: TableCalendar(
                          onDaySelected: onDaySelected,
                          selectedDayPredicate: (date) {
                            return isSameDay(selectedDate_, date);
                          },
                          firstDay: DateTime.utc(2010, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: DateTime.now(),
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, events) {
                              if (events.isNotEmpty) {
                                return Positioned(
                                  right: 20,
                                  bottom: 1,
                                  child: _buildEventsMarker(date, events),
                                );
                              }
                              return null;
                            },
                          ),
                          calendarStyle: CalendarStyle(
                            defaultDecoration: BoxDecoration(
                              color: Colors.grey.shade200, // 기본 날짜 셀 배경색
                            ),
                            weekendDecoration: BoxDecoration(
                              color: Colors.red.shade100, // 주말 날짜 셀 배경색
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: Colors.blueAccent, // 선택된 날짜 셀 배경색
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: const BoxDecoration(
                              color: Colors.orangeAccent, // 오늘 날짜 셀 배경색
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white),
                        width: size.width * 1,
                        height: size.height * 0.05,
                        child: context.watch<CounterProvider>().day != ""
                            ? Consumer<CounterProvider>(
                                builder: (context, value, child) {
                                  return Center(
                                      child:
                                          Text("${value.month}월${value.day}일"));
                                },
                              )
                            : Center(
                                child: Text(
                                    "${selectedDate_.month}월${selectedDate_.day}일")),
                      ),
                      // Text(schedule_Write),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white),
                        width: size.width * 1,
                        height: size.height * 0.05,
                        child: TextField(
                          // textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 10.0),
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
                          const Icon(
                            Icons.notifications_outlined,
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
                                child:
                                    // _selectedHour == 0
                                    //     ? const Text(
                                    //         "알림 없음",
                                    //         style: TextStyle(
                                    //             fontSize: 20,
                                    //             fontWeight: FontWeight.w200,
                                    //             color: Colors.black
                                    //             // fontFamily: 'roboto'
                                    //             ),
                                    //       )
                                    //     :
                                    _isCheck
                                        ? Text(
                                            "$_selectedHour시 $_selectedMinute분",
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black
                                                // fontFamily: 'roboto'
                                                ),
                                          )
                                        : const Text(
                                            "알람 없음",
                                            style: TextStyle(
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
                                        selectedMinute: _selectedMinute,
                                        isCheck: _isCheck)),
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
                                padding: const EdgeInsets.all(4.0),
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
                            final random = Random();
                            int randomPart = random.nextInt(1000); // 0~999 난수
                            int timestampPart =
                                DateTime.now().millisecondsSinceEpoch; // 타임스탬프

                            // 고유 ID 생성: 해시 기반 또는 Modulo 기반으로 선택 가능
                            String combined = "$timestampPart$randomPart";

                            String day = context.read<CounterProvider>().day;
                            String year = context.read<CounterProvider>().year;
                            String month =
                                context.read<CounterProvider>().month;
                            // _addNewSchedule();
                            DateTime today = DateTime.now();

                            // 오늘 날짜에서 시간 정보(시, 분, 초)를 제외한 날짜만 비교
                            DateTime todayWithoutTime = DateTime(
                                today.year,
                                today.month,
                                today.day,
                                today.hour,
                                today.minute);
                            DateTime selectedDateWithoutTime = DateTime(
                                selectedDate_.year,
                                selectedDate_.month,
                                selectedDate_.day,
                                _selectedHour,
                                _selectedMinute);

                            // 비교: selectedDate_가 오늘 이전인지 확인
                            //
                            if (selectedDateWithoutTime
                                    .isBefore(todayWithoutTime) ||
                                _isCheck == false) {
                              // print("========================.");
                              // print("1$selectedDate_.");
                              // print("2$schedule_Write.");
                              // print("3$_selectedHour 시$_selectedMinute}.");
                              // print("========================.");
                              // bool error_message = false;
                              AlertDialog_Calendar(_selectedHour);
                            } else {
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
                                    "day": day == ""
                                        ? selectedDate.day
                                        : int.parse(day),
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
                                    "userid": UserManager.userId,
                                    "dates": [],
                                    "uniqueID": combined.hashCode & 0x7FFFFFFF,
                                  },
                                );
                                Get.offAll(
                                    const home()); // 홈 페이지로 이동, 이전 페이지 스택을 모두 제거
                              } catch (e) {}
                              setState(() {
                                // print("+++++++++++++++++option$option");
                                context.read<CounterProvider>().ChangeText(
                                    newYear: '', newMonth: '', newDay: '');

                                _selectedDate = DateTime(
                                  year == ""
                                      ? selectedDate.year
                                      : int.parse(year),
                                  month == ""
                                      ? selectedDate.month
                                      : int.parse(month),
                                  day == "" ? selectedDate.day : int.parse(day),
                                  _selectedHour,
                                  _selectedMinute,
                                );
                              });
                              _scheduleNotification(
                                  combined.hashCode & 0x7FFFFFFF,
                                  _selectedDate,
                                  schedule_Write,
                                  option);
                            }
                          },
                          child: const Text("등록하기")),
                    ],
                  ),
                );
              }),
            ),
          ));
    });
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      this.selectedDate = selectedDate;
      selectedDate_ = selectedDate;
      // print("selectedDate$selectedDate");
      textdate = selectedDate.year.toString() +
          selectedDate.month.toString() +
          selectedDate.day.toString();
      context.read<CounterProvider>().ChangeText(
          newYear: selectedDate.year.toString(),
          newMonth: selectedDate.month.toString(),
          newDay: selectedDate.day.toString());
    });
  }

  // ignore: non_constant_identifier_names
  Future<void> AlertDialog() {
    // late String timeText_1 = "오전";
    return showDialog<Void>(
        // ignore: deprecated_member_use
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
                      height: MediaQuery.of(context).size.height * 0.04,
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
                                  // print(_selectedHour);
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
                            setState(() {
                              _isCheck = true;
                            });
                          },
                          child: const Text("확인"),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // setState(() {
                            //   _isCheck = false;
                            // });
                          },
                          child: const Text("돌아가기"),
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

  Widget _buildEventsMarker(DateTime date, List events) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blueAccent,
      ),
      width: 10.0,
      height: 15.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: const TextStyle().copyWith(
              color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Future<void> AlertDialog_Calendar(int selectedHour) {
    // late String timeText_1 = "오전";
    return showDialog<Void>(
        // ignore: deprecated_member_use
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
                    child: Column(children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      const Text(
                        "일정 등록 불가",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      _isCheck
                          ? const Text(
                              "일정 등록 날짜가 잘못되었습니다",
                              style: TextStyle(fontSize: 20),
                            )
                          : const Text(
                              "알람 시간대를 선택하십시오",
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
                              height:
                                  MediaQuery.of(context).size.height * 0.005,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("돌아가기"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]),
                  )));
        });
  }
} // end

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
