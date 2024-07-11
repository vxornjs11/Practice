import 'package:flutter/material.dart';

class ScheduleCountProvider extends ChangeNotifier {
  int _count = 0;

  ScheduleCountProvider({int initialCount = 0}) : _count = initialCount;

  int get count => _count;

  void changeScheduleCount({required int initialCount}) {
    _count = initialCount;
    notifyListeners();
  }
}
