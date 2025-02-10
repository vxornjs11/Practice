import 'package:flutter/material.dart';

class CounterProvider extends ChangeNotifier {
  //
  // int _count = 0; // 상태
  String year = "";
  String month = "";
  String day = "";
  // DateTime selectedDate = DateTime.now();

  // String get Text_T => Text1;

  CounterProvider({
    this.year = "",
    this.month = "",
    this.day = "",
    // this.selectedDate=DateTime.now();
  });

  // ignore: non_constant_identifier_names
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

  void resetText() {
    year = '';
    month = '';
    day = '';
    notifyListeners();
  }
  // void resetText() {}

  // decrese() {
  //   _count--; //상태 변경
  //   notifyListeners(); // 상태 변경 된 것을 알림
  // }
}
