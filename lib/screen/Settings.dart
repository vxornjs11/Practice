import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  /// 달력은 했는데 밑에 리스트도 보여주는게 좋아보이긴하지/
  ///
  /// 스케줄 등록에서 달력 표시와 실제 입력값이 다른 문제 해결.
  /// Provider에 저장한 값을 초기화 안해서 생긴 문제.
  /// 이제 알람, 반복기능을 설정안하고 등록할때 생기는 문제나
  /// 글자수 제한 이런거 생각해보고
  /// 그거 문제없다고 판단되면 알람이랑 반복기능을 만들어야함.
  /// 존나어렵겟다 시발;
  /// 달력누르면 오늘의 일정 몇건 이거 안보이게 하던가 이달의 일정으로 바꾸던가 해야지 거슬리네.
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("SETTINGs"),
    );
  }
}
