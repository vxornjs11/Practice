import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  // 반복 설정하면 화면 이동 하는데 이전에 설정한게 날라가는듯?
  // - 알림설정이랑, 일정 텍스트가 날라가네 시발;
  // 그리고 뭐 잇나?
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
