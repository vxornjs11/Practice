import 'package:flutter/material.dart';

class CounterProvider extends ChangeNotifier {
  //
  // int _count = 0; // 상태
  String Text1 = "2";

  // String get Text_T => Text1;

  CounterProvider({
    this.Text1 = "2",
  });

  void ChangeText({
    required String newText1,
  }) async {
    Text1 = newText1;
    notifyListeners();
  }

  // decrese() {
  //   _count--; //상태 변경
  //   notifyListeners(); // 상태 변경 된 것을 알림
  // }
}
