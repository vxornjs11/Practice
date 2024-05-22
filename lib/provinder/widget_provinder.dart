import 'package:flutter/material.dart';

class widget_Provider extends ChangeNotifier {
  String buttonText = "";

  widget_Provider({
    this.buttonText = "",
  });

  void ChangeWidget_button({required String pressButtonText}) async {
    buttonText = pressButtonText;
    notifyListeners();
  }
}
