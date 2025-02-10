import 'package:flutter/material.dart';

// ignore: camel_case_types
class Timer_Provider extends ChangeNotifier {
  // ignore: non_constant_identifier_names
  String TimerText = "오전";

  Timer_Provider({
    // ignore: non_constant_identifier_names
    this.TimerText = "오전",
  });

  // ignore: non_constant_identifier_names
  void ChangeTimer_Text({required String timeText}) async {
    TimerText = timeText;
    notifyListeners();
  }
}
