import 'package:flutter/material.dart';

class CounterProvider extends ChangeNotifier {
  //
  int _count = 0; // 상태

  int get count => _count;

  add() {
    _count++; //상태 변경
    notifyListeners(); // 상태 변경 된 것을 알림
  }

  decrese() {
    _count--; //상태 변경
    notifyListeners(); // 상태 변경 된 것을 알림
  }
}
