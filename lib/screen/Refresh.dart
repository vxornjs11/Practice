// import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:practice_01_app/screen/Set_schedule.dart';

class Repeat extends StatefulWidget {
  const Repeat({super.key});

  @override
  State<Repeat> createState() => _RepeatState();
}

class _RepeatState extends State<Repeat> {
  late bool _isCheck;
  String option = "";
  List<String> repeatOptions = [
    "반복 안함",
    "매일",
    "주중",
    "주말",
    "한달",
    "1년",
  ];
  late List<bool> repeatCheckList = [];

  @override
  void initState() {
    // TODO: implement initState
    repeatCheckList = List.filled(6, false);

    _isCheck = false;
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
                  itemCount: repeatOptions.length,
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
                  Get.off(Set_schedul(option: option));
                  // 야 이거 페이지 이동으로 해놧더니 달력이 그대로 돌아간다.
                  // 다행이 저장해놓은건 남는데 보기가 이상하구만.
                  // Get
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => Set_schedul(option: option)));
                  // // 시간대 설정 메소드 들어가야한다.
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
    );
  }

  Widget row_Repeat(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          repeatOptions[index],
          style: TextStyle(fontSize: 20),
        ),
        Checkbox(
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            value: repeatCheckList[index],
            onChanged: (bool? value) {
              setState(() {
                // 모든 체크박스를 해제하고 선택한 체크박스만 true로 설정
                for (int i = 0; i < repeatCheckList.length; i++) {
                  repeatCheckList[i] = (i == index) ? (value ?? false) : false;
                }
                // 그리고 이제 체크한게 뭔지 저장해서 넘기면 됨.
                option = repeatOptions[index];
                print(option);
              });
            })
      ],
    );
  }
} // end
