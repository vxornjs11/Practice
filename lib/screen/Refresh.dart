// import 'dart:ffi';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:practice_01_app/screen/Set_schedule.dart';

class Repeat extends StatefulWidget {
  final DateTime selectedDate_;
  // ignore: non_constant_identifier_names
  final String schedule_Write;
  final int selectedHour;
  final int selectedMinute;
  final bool isCheck;
  const Repeat(
      {super.key,
      required this.selectedDate_,
      // ignore: non_constant_identifier_names
      required this.schedule_Write,
      required this.selectedHour,
      required this.selectedMinute,
      required this.isCheck});

  @override
  State<Repeat> createState() => _RepeatState();
}

class _RepeatState extends State<Repeat> {
  late DateTime selectedDate_ = widget.selectedDate_;
  // ignore: non_constant_identifier_names
  late String schedule_Write = widget.schedule_Write;
  late final int _selectedHour = widget.selectedHour;
  late final int _selectedMinute = widget.selectedMinute;
  late final bool _isCheck = widget.isCheck;

  // late bool _isCheck;
  String option = "";
  // 평일
  // ignore: non_constant_identifier_names
  List<String> repeatOptions_Weekday = [
    "반복 안함",
    "매일",
    "주중",
    "매주",
    "한달",
    "1년",
  ];
//주말
  // ignore: non_constant_identifier_names
  List<String> repeatOptions_Weekend = [
    "반복 안함",
    "매일",
    "주말",
    "매주",
    "한달",
    "1년",
  ];

  late List<bool> repeatCheckList = [];

  @override
  void initState() {
    // TODO: implement initState
    repeatCheckList = List.filled(6, false);

    // _isCheck = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "반복",
          style: TextStyle(fontSize: 30),
        ),
      ),
      body: Column(
        children: [
          // SizedBox(
          //   height: MediaQuery.of(context).size.height * 0.05,
          // ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: ListView.builder(
                  itemCount: repeatOptions_Weekday.length,
                  itemBuilder: (context, index) {
                    return row_Repeat(index);
                  },
                ),
              ),
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
                  // Get.off(Set_schedul(option: option));
                  Get.off(() => Set_schedul(
                      option: option,
                      selectedDate_: selectedDate_,
                      schedule_Write: schedule_Write,
                      selectedHour: _selectedHour,
                      selectedMinute: _selectedMinute,
                      isCheck: _isCheck));
                  // 야 이거 페이지 이동으로 해놧더니 달력이 그대로 돌아간다.
                  // 다행이 저장해놓은건 남는데 보기가 이상하구만. - 해결.
                  // Get
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => Set_schedul(option: option)));
                  // // 시간대 설정 메소드 들어가야한다.
                },
                child: const Text("OK"),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("back"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget row_Repeat(int index) {
    List<String> weekdays = ["월", "화", "수", "목", "금"];
    String selectedDay = DateFormat('E', 'ko_KO').format(selectedDate_);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        weekdays.contains(selectedDay)
            ? Text(
                repeatOptions_Weekday[index],
                style: const TextStyle(fontSize: 20),
              )
            : Text(
                repeatOptions_Weekend[index],
                style: const TextStyle(fontSize: 20),
              ),
        weekdays.contains(selectedDay)
            ? Checkbox(
                checkColor: Colors.black,
                fillColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                    return Colors.orange.withOpacity(.32);
                  }
                  if (states.contains(MaterialState.selected)) {
                    return Colors.blue; // 선택 시 파란색 배경
                  }
                  return Colors.white; // 선택하지 않았을 때 하얀색 배경
                }),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                value: repeatCheckList[index],
                onChanged: (bool? value) {
                  setState(() {
                    // 모든 체크박스를 해제하고 선택한 체크박스만 true로 설정
                    for (int i = 0; i < repeatCheckList.length; i++) {
                      repeatCheckList[i] =
                          (i == index) ? (value ?? false) : false;
                    }
                    // 그리고 이제 체크한게 뭔지 저장해서 넘기면 됨.
                    option = repeatOptions_Weekday[index];
                    if (value == false) {
                      option = repeatOptions_Weekday[0];
                      repeatCheckList[0] = true;
                    }
                    // print("option : $option /n value : $value");
                  });
                })
            : Checkbox(
                checkColor: Colors.black,
                fillColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                    return Colors.orange.withOpacity(.32);
                  }
                  if (states.contains(MaterialState.selected)) {
                    return Colors.blue; // 선택 시 파란색 배경
                  }
                  return Colors.white; // 선택하지 않았을 때 하얀색 배경
                }),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                value: repeatCheckList[index],
                onChanged: (bool? value) {
                  setState(() {
                    // 모든 체크박스를 해제하고 선택한 체크박스만 true로 설정
                    for (int i = 0; i < repeatCheckList.length; i++) {
                      repeatCheckList[i] =
                          (i == index) ? (value ?? false) : false;
                    }
                    // 그리고 이제 체크한게 뭔지 저장해서 넘기면 됨.
                    option = repeatOptions_Weekend[index];
                    if (value == false) {
                      option = repeatOptions_Weekend[0];
                      repeatCheckList[0] = true;
                    }
                    // print("option : $option /n value : $value");
                  });
                })
      ],
    );
  }
} // end
