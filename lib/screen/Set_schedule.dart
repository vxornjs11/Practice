import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:practice_01_app/provinder/count_provinder.dart';
import 'package:practice_01_app/provinder/widget_provinder.dart';
import 'package:practice_01_app/screen/Refresh.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Set_schedul extends StatefulWidget {
  const Set_schedul({super.key});

  @override
  State<Set_schedul> createState() => __Set_schedulState();
}

class __Set_schedulState extends State<Set_schedul> {
  // SureStlye sureStyle = SureStlye();
  late String schedule_Write;
  late TextEditingController titlecontroller;
  late String textdate;
  late bool _isSwitch;
  late bool _isCheck;
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedSeconds;

  final List<int> Hour = List<int>.generate(24, (int index) => index);
  final List<int> minute = List<int>.generate(60, (int index) => index);
  final List<int> seconds = List<int>.generate(60, (int index) => index);

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titlecontroller = TextEditingController();
    textdate = "";
    _isSwitch = false;
    _selectedHour = 0;
    _selectedMinute = 0;
    _selectedSeconds = 0;
    schedule_Write = "";
    _isCheck = false;
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
                      return isSameDay(selectedDate, date);
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
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            "알림 없음",
                            style: TextStyle(
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
                          // _isSwitch = !_isSwitch;
                          // if (_isSwitch == false) {
                          // } else {
                          //   AlertDialog();
                          // }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => (Repeat()),
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
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            "반복 안 함",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w100,
                              // fontFamily: 'roboto'
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      this.selectedDate = selectedDate;
      textdate =
          "${selectedDate.year.toString() + selectedDate.month.toString() + selectedDate.day.toString()}";
      context.read<CounterProvider>().ChangeText(
          newYear: selectedDate.year.toString(),
          newMonth: selectedDate.month.toString(),
          newDay: selectedDate.day.toString());
    });
  }

  Future<void> AlertDialog() {
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
                height: 200,
                width: 300,
                child: Column(
                  children: [
                    const Text(
                      "알림 시간 설정",
                      style: TextStyle(fontSize: 30),
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
                            child: CupertinoPicker(
                              scrollController:
                                  FixedExtentScrollController(initialItem: 0),
                              itemExtent: 30,
                              onSelectedItemChanged: (int index) {
                                setState(() {
                                  _selectedHour = Hour[index];
                                  print(_selectedHour);
                                });
                              },
                              children: Hour.map((int value) {
                                return Center(child: Text('$value'));
                              }).toList(),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: CupertinoPicker(
                              scrollController:
                                  FixedExtentScrollController(initialItem: 0),
                              itemExtent: 30,
                              onSelectedItemChanged: (int index) {
                                setState(() {
                                  _selectedMinute = minute[index];
                                  print(_selectedMinute);
                                });
                              },
                              children: minute.map((int value) {
                                return Center(child: Text('$value'));
                              }).toList(),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: CupertinoPicker(
                              scrollController:
                                  FixedExtentScrollController(initialItem: 0),
                              itemExtent: 30,
                              onSelectedItemChanged: (int index) {
                                setState(() {
                                  _selectedSeconds = seconds[index];
                                  print(_selectedSeconds);
                                });
                              },
                              children: seconds.map((int value) {
                                return Center(child: Text('$value'));
                              }).toList(),
                            ),
                          ),
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

  Future<void> AlertDialog_Refresh() {
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
                height: 500,
                width: 300,
                child: Column(
                  children: [
                    const Text(
                      "알림 시간 설정",
                      style: TextStyle(fontSize: 30),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text("반복 안함"),
                                Checkbox(
                                    checkColor: Colors.black,
                                    fillColor:
                                        MaterialStateProperty.resolveWith<
                                            Color>((Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return Colors.orange.withOpacity(.32);
                                      }
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return Colors.blue; // 선택 시 파란색 배경
                                      }
                                      return Colors.white; // 선택하지 않았을 때 하얀색 배경
                                    }),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    value: _isCheck,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _isCheck = value ?? false;
                                        print(_isCheck);
                                      });
                                    })
                              ],
                            ),
                            Row(
                              children: [
                                Text("매일"),
                                Checkbox(
                                    checkColor: Colors.black,
                                    fillColor:
                                        MaterialStateProperty.resolveWith<
                                            Color>((Set<MaterialState> states) {
                                      if (states
                                          .contains(MaterialState.disabled)) {
                                        return Colors.orange.withOpacity(.32);
                                      }
                                      if (states
                                          .contains(MaterialState.selected)) {
                                        return Colors.blue; // 선택 시 파란색 배경
                                      }
                                      return Colors.white; // 선택하지 않았을 때 하얀색 배경
                                    }),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    value: _isCheck,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _isCheck = value ?? false;
                                        print(_isCheck);
                                      });
                                    })
                              ],
                            ),
                            Text("매주"),
                            Text("주중"),
                            Text("주말"),
                            Text("한달"),
                            Text("1년"),
                          ],
                        )),
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
