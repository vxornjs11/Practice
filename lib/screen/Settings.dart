import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  /// 이제 알람, 반복기능을 설정안하고 등록할때 생기는 문제나
  /// 글자수 제한 이런거 생각해보고
  /// 그거 문제없다고 판단되면 알람이랑 반복기능을 만들어야함.
  /// 존나어렵겟다 시발;
  /// 달력누르면 오늘의 일정 몇건 이거 안보이게 하던가 이달의 일정으로 바꾸던가 해야지 거슬리네.
  ///
  /// 리스트 삭제한거 달력에 반영이 안되네.
  /// -- 반복설정 하고나면 텍스트필드 값이 사라지네 이것도 저장해서 파라미터로 넘겨야겟다.
  ///
  /// 알람기능이 됨. 이제 버그있는지 체크하는거 생각만 해놓고
  /// 반복기능을 어떻게 구현할지 생각해보자. 반복설정을 알람도 포함하려면 좀 빡셀거같긴해.
  /// 달력에 보여주는건 흠..... 어렵진않을듯.
  /// 그럼 반복까지 하면 진짜 끝인데 다음주에는 끝내보자고!!!!
  ///오늘은 암것도안햇네 ㅎㅎ;;ㄴ
  const Settings({super.key});

  //  개시발 반복설정 좆같아서 토,일 선택하면 주중 못하게막고
  // 평일 선택하면 주말 반복 못하게 막아버림.
  // 사실 되는게 말이 안되는거야 싯팔.
  // 이럼 이제 달력리스트말고 메인 리스트만 만져구고
  // 알람설정 연결해주고
  // 삭제하면 달력에 마커 안사라지는거 해결하면된다.
  // 개시발 좆같아 해결이안돼.
  // 리스트 코드도 바뀌었도 오늘의 일정 이것도 방식이 바뀌어서 다시해야함.

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
