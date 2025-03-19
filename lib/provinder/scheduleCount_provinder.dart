import 'package:flutter/material.dart';

class ScheduleCountProvider extends ChangeNotifier {
  int _count = 0;
  String _locale = 'ko_KR'; // 새로운 변수 추가

  ScheduleCountProvider({int initialCount = 0, String initialLocale = 'ko_KR'})
      : _count = initialCount,
        _locale = initialLocale;

  int get count => _count;
  String get locale => _locale; // 현재 언어 가져오기

  // 일정 개수 변경
  void changeScheduleCount({required int initialCount}) {
    _count = initialCount;
    notifyListeners();
  }

  // 언어 변경 함수
  void toggleLocale(String newLocale) {
    _locale = newLocale;
    // _locale == 'ko_KR' ? 'en_US' : 'ko_KR';
    notifyListeners(); // 상태 변경 알림
  }

  //  void ChangeTimer_Text({required String timeText}) async {
  //   TimerText = timeText;
  //   notifyListeners();
  // }
}
