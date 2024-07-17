import 'package:flutter/material.dart';
import 'package:practice_01_app/main.dart';
import 'package:practice_01_app/provinder/color_provinder.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  /// 이제 알람, 반복기능을 설정안하고 등록할때 생기는 문제나
  /// 글자수 제한 이런거 생각해보고.

  /// -- 반복설정 하고나면 텍스트필드 값이 사라지네 이것도 저장해서 파라미터로 넘겨야겟다.
  ///
  const Settings({super.key});

// 리스트 아래로 정렬, 그 뭐야 달력 리스트는 안했음
// 그리고 색깔 전환하는거 세팅에 만들어노므 프로바이더는 신임.
// 이제 진짜 머하지. 통계랑 완료설정 까지 하면
// 로그인으로 구분하는거 이거 하고 그냥 끝인데?
// ㄹㅇ 마무리 단계다 이제.

// 이거 일정을 내일로 잡고 매일로 하면  ===
// 매일매일은 조건문이 존나 널널해서 리스트에 나온다 문제가 있네/
// -- 통계 그래프 만들고, 자기 아이디만 리스트 보이게 회원가입? 비슷한거 만들고 -

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    Size cSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: cSize.height * 0.08,
          ),
          Consumer<ColorProvider>(builder: (context, colorProvider, child) {
            return Column(
              children: [
                Container(
                    width: 100,
                    height: 100,
                    decoration:
                        BoxDecoration(color: colorProvider.backgroundColor)),
                Container(
                  color: Colors.amber,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Example of changing the background color
                        colorProvider.changeBackgroundColor(
                          newColor: Colors.amber,
                        );
                      },
                      child: Text('노랑색'),
                    ),
                  ),
                ),
                Container(
                  color: Colors.blue,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Example of changing the background color
                        colorProvider.changeBackgroundColor(
                          newColor: Colors.blue,
                        );
                      },
                      child: Text('blue'),
                    ),
                  ),
                ),
                Container(
                  color: Color.fromARGB(255, 230, 242, 255),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Example of changing the background color
                        colorProvider.changeBackgroundColor(
                          newColor: Color.fromARGB(255, 230, 242, 255),
                        );
                      },
                      child: Text('기본 약하늘색'),
                    ),
                  ),
                ),
              ],
            );
          }),
          Text(" Text('User ID: ${UserManager.userId}'),"),
        ],
      ),
    );
  }
}
