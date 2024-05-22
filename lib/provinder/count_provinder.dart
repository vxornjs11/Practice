import 'package:flutter/material.dart';

class CounterProvider extends ChangeNotifier {
  //
  // int _count = 0; // 상태
  String year = "";
  String month = "";
  String day = "";

  // String get Text_T => Text1;

  CounterProvider({
    this.year = "",
    this.month = "",
    this.day = "",
  });

  void ChangeText({
    required String newYear,
    required String newMonth,
    required String newDay,
  }) async {
    year = newYear;
    month = newMonth;
    day = newDay;
    notifyListeners();
  }

  // decrese() {
  //   _count--; //상태 변경
  //   notifyListeners(); // 상태 변경 된 것을 알림
  // }
}
