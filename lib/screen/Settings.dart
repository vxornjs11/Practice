import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  // 6월7일 알림설정 오전오후를 프로바인더로 해결했음
  // 근데 이거 클래스명이 ㅂㅅ같아서 바꿔야함.
  // 그리고 시간를 0~24로 해놧는데 오전오후로 할거면 이거도 0~12로 하고
  // 분도 0~60으로 되어있는데 이거 0~59로 바꿔야할듯.
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
