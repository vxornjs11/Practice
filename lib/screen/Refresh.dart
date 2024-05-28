import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Refresh extends StatefulWidget {
  const Refresh({super.key});

  @override
  State<Refresh> createState() => _RefreshState();
}

class _RefreshState extends State<Refresh> {
  late bool _isCheck;

  @override
  void initState() {
    // TODO: implement initState

    _isCheck = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
    );
  }
}
