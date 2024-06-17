import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  // 아니 반복설정 문제 있네
  // 글고 Refresh에서 반복설정 두번 클릭해서 취소해도 그냥 그대로 정보가 들어감.
  // 이거도 좀 이상한듯?

  /// day를 이렇게바꿧더니 선택 안하면 아예 안들어가는구나...
  /// 해결한듯.
  ///
  /// 알람 기능, 반복 기능, 리스트 삭제,
  /// 그래프, 통계
  /// 그리고 자기 id 일정만 보이게 하고
  /// 달력으로 변환해서 보여주는것도 만들어야하고.
  /// 할거많네..
  /// // 삭제하는거 꾹 누르면 삭제하는게 아니라 우측에 삭제 명단을 띄우자고
  ///
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
