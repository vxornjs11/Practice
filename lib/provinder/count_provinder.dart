import 'package:flutter/material.dart';

class CounterProvider extends ChangeNotifier {
  //
  // int _count = 0; // 상태
  String Text1 = "";

  String get Text_T => Text1;

  add(String Text) {
    // _count++; //상태 변경
    Text1 = Text;
    notifyListeners(); // 상태 변경 된 것을 알림
  }

  // decrese() {
  //   _count--; //상태 변경
  //   notifyListeners(); // 상태 변경 된 것을 알림
  // }
}
