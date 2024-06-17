import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:practice_01_app/provinder/count_provinder.dart';
import 'package:practice_01_app/provinder/timer_provinder.dart';
import 'package:practice_01_app/screen/Mainpage.dart';
import 'package:practice_01_app/screen/Refresh.dart';
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
  }

  Future<void> _addNewDocument(String newTitle) async {
    try {
      await _firestore.collection('newCollection').add({
        'title': newTitle,
        // 'created_at': Timestamp.now(),
      });
      print('새 문서가 성공적으로 추가되었습니다.');
    } catch (e) {
      print('문서 추가 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String textdate = "";
    var size = MediaQuery.of(context).size;
    TextEditingController text_title;
    var styles = TextStyle(
        fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500);
    return Scaffold(
        appBar: AppBar(
          title: Text("일정 등록"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                context
                    .read<CounterProvider>()
                    .ChangeText(newYear: '', newMonth: '', newDay: '');
              });

              // 커스텀 동작을 수행하거나 원하는 페이지로 이동
              Get.offAll(const Mainpage()); // 홈 페이지로 이동, 이전 페이지 스택을 모두 제거
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
                      // 근데 textdate는 항상 ""아닌가?
                      // 프로바이더로 바꿔도 얘가 그걸 어케암.
                      ? Consumer<CounterProvider>(
                          builder: (context, value, child) {
                            return Column(
                              children: [
                                Text(value.month + "월" + value.day + "일")
                              ],
                            );
                          },
                        )
                      : Text(context.watch<CounterProvider>().day),
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
                      int day = context.read<CounterProvider>().day as int;
                      int year = context.read<CounterProvider>().year as int;
                      int month = context.read<CounterProvider>().month as int;
                      // print(
                      //   selectedDate.day,
                      // );

                      // String day = context.watch<CounterProvider>().day;
                      try {
                        await _firestore.collection("Calender").doc().set(
                          {
                            "Schedule": schedule_Write,
                            "year": year == "" ? selectedDate.year : year,
                            "month": month == "" ? selectedDate.month : month,
                            "day": day == "" ? selectedDate.day : day,
                            "hour": _selectedHour,
                            "minit": _selectedMinute,
                            "option": option
                          },
                        );
                        print('새 문서가 성공적으로 추가되었습니다.');
                        print(selectedDate.day);
                        print(day);
                        Get.offAll(Mainpage());
                      } catch (e) {
                        print('문서 추가 중 오류가 발생했습니다: $e');
                      }
                    },
                    child: Text("등록하기"))
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
