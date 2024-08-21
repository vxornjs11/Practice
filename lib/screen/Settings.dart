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

// 완료 누르는 버튼 존재 자체는 만들 수 있는데
// 완료된지 아닌지 구분하려면 체크된걸 만들어야하고
// 또 그게 반복 설정이 아닌거면 상관없는데 반복설정 되어있는거면
// 내일이랑 어제랑 여튼 다른 날짜랑 구분이 되어야하니까 완료 누른 DATETIME을 저장해야 할거같은데.
// 완료 누르면 오늘은 사라져야됨. 계속 있으면 안됨.... 생각보다 쉬울수도. 일단 집가자.
// 그리고 또 뭐가 있었는데 기억이 안나네. 몰라싲말.
// DateTIme이 아니네 시발; 8.5일 모르겟당 ㅎㅎ

// 달성률을 어떻게 계산해야 할까. 그날에 일정이 있고 그날에 완료가 있으면 달성인거지.
// 이렇게 굴리면 어떻게 될까.
// 근데 완료를 안누르면 어떻게 처리하지;;;;; 그거 그대로 내일까지 남아있을거같은데.

// 지금 해당하는 달에 몇개의 완료를 눌럿는지는 나옴.
// 근데 이걸 어떻게 퍼센트로 짜야할지 모르겟네
// 그리고 이전에 존재하던 달에 몇개의 일정이 있냐 이것도 문제인게
// 매일이나 매달이나 이런거 구분을 안한거라서 시발;
// ++++ 8/16일 ++++
// 목표 달성 차트 그래프로는 거의 다 한거같고
// 일단 넘어가서 달성률 퍼센트로 원형차트나 그냥 숫자로 보여주면 될듯.
// 여기서 더 업그레이드 하는건 좀 뇌절인듯.
// 그럼 이제 다음주에는 디버깅 특히 알람쪽 수정하고 ui좀 다듬고 출시하면 될듯합니다.

// provider로 월별 달성률 할수 있을듯. for문 대충 어떻게 만져서 그냥 for말고 글자를 1넣는 식으로 하면 될거샅음.
// 내일 이거 하고 이제 진짜 대충 디버깅해서 넘기자.
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
