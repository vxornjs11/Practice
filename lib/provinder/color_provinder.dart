import 'package:flutter/material.dart';

class ColorProvider extends ChangeNotifier {
  Color _backgroundColor = Color.fromARGB(255, 230, 242, 255);

  ColorProvider({Color initialColor = const Color.fromARGB(255, 230, 242, 255)})
      : _backgroundColor = initialColor;

  Color get backgroundColor => _backgroundColor;

  void changeBackgroundColor({required Color newColor}) {
    _backgroundColor = newColor;
    notifyListeners();
  }
}
