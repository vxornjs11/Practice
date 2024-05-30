import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Repeat extends StatefulWidget {
  const Repeat({super.key});

  @override
  State<Repeat> createState() => _RepeatState();
}

class _RepeatState extends State<Repeat> {
  late bool _isCheck;
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
                _isCheck = value ?? false;
                // print(repaetCheck);
                // print("_isCheck$_isCheck");
              });
            })
      ],
    );
  }
} // end
