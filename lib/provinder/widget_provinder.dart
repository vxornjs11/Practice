import 'package:flutter/material.dart';

class widget_Provider extends ChangeNotifier {
  String buttonText = "오전";

  widget_Provider({
    this.buttonText = "오전",
  });

  void ChangeWidget_Text({required String timeText}) async {
    buttonText = timeText;
    notifyListeners();
  }

  // void ChangeText({
  //   required String newYear,
  //   required String newMonth,
  //   required String newDay,
  // }) async {
  //   year = newYear;
  //   month = newMonth;
  //   day = newDay;
  //   notifyListeners();
  // }
}
