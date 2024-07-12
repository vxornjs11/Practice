import 'package:flutter/material.dart';

class Timer_Provider extends ChangeNotifier {
  String TimerText = "오전";

  Timer_Provider({
    this.TimerText = "오전",
  });

  void ChangeTimer_Text({required String timeText}) async {
    TimerText = timeText;
    notifyListeners();
  }
}
