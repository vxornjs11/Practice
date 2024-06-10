import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  // 다햇는데 이제 머하지;;
  // 파이어 베이스나 넣을까.
  // 그거말고 할 거 없는듯? 머야 거의 다 햇네.
  // 그리고 만약 그거까지 한다면 달력에 표시도 되나 해야함.
  // 와 씨바 존나 힘드렀다.
  // 플러터 버전이랑 ios 버전이랑 firebase가 쌍으로 지랄해서 좆되는줄.
  // 내일은 와서 일정까지 등록하는 파이어베이스 쿼리 짜고
  // 만약 되면 뭐 알림까지 하죠.
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
