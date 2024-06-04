import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:intl/intl.dart';
import 'package:practice_01_app/provinder/count_provinder.dart';
import 'package:practice_01_app/screen/Set_schedule.dart';
import 'package:provider/provider.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Mainpage> {
  final List<String> week = ["월", "화", "수", "목", "금", "토", "일"];
  final int ListCount = 1;

  @override
  void initState() {
    // TODO: implement initState
    // 우측 상단이나 왼쪽에서 설정 칸 만들어서 알림 설정 같은거
    // 아니면 아래 빈칸에 3개 만들어서 메인화면, 설정, 프로필? 달력? 이렇게
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedWeekday = DateFormat('E', 'ko_KO').format(now);
    // CounterProvider counter = Provider.of<CounterProvider>(context);
    print(formattedWeekday);
    var c_size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: c_size.height * 0.06,
            ),
            SizedBox(
              width: c_size.width * 1,
              height: c_size.height * 0.06,
              child: Row(
                children: [
                  SizedBox(
                    width: c_size.width * 1,
                    height: c_size.height * 0.05,
                    child: ListView.builder(
                        // 여기 오늘이 몇 요일인지 표시해주면 좋을듯?
                        // 빨간색 동그라미 띄우거나 아니면 글자 색을 바꾸거나.
                        scrollDirection: Axis.horizontal,
                        itemCount: week.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              // color: Colors.white,
                              decoration: BoxDecoration(
                                color: week[index] == formattedWeekday
                                    ? Colors.blue.shade100
                                    : Colors.white, // 색 지정.
                                border: Border.all(
                                  color: Colors.black, // 원하는 색상을 지정
                                  width: 1.0, // 원하는 선의 두께를 지정
                                ),
                              ),
                              width: c_size.width * 0.135,
                              height: c_size.height * 0.1,
                              child: Text(
                                week[index],
                                style: TextStyle(
                                    color: week[index] == formattedWeekday
                                        ? Colors.red
                                        : Colors.black),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ), // Row 끝
            ),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Container(
                width: c_size.width * 1,
                height: c_size.height * 0.6,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, // 원하는 색상을 지정
                    width: 1.0, // 원하는 선의 두께를 지정
                  ),
                ),
                child: ListCount > 1
                    ? ListView.builder(
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                              height: c_size.height * 0.1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.blue.shade100,
                              ),
                            ),
                          );
                        },
                        itemCount: 5,
                      )
                    : Center(
                        child: Container(
                          // decoration: BoxDecoration(
                          //   border: Border.all(
                          //     color: Colors.red, // 원하는 색상을 지정
                          //     width: 1.0, // 원하는 선의 두께를 지정
                          //   ),
                          // ),
                          child: ElevatedButton(
                              onPressed: () {
                                // Future.delayed(Duration(seconds: 1), () {
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => Set_schedul()),
                                //   );
                                // });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Set_schedul(
                                              option: '',
                                              selectedDate_: DateTime.now(),
                                              // 넘어가야 할 정보.
                                            )));
                              },
                              child: Text("일정을 등록하세요")),
                        ),
                      )
                // Text("오늘 체크리스트 할일")
                ,
                // 여기가 문제임.
                // 리스트로 짝짝 들어가야 되는데
                // 할일 설정을 어떻게 할지 정해야 함.
                // ListView로 컨테이너 쌓아서 체크리스트 처럼 만들지
                // 그게 또 재밌게 움직이면 좋겠지만 그건 일단 보류
                // 일정 만들기 < 있어야 되고
                // 만약 아무것도 설정 안해놧으면 [ 일정 설정하기 ] 띄우고
                // 설정된게 있으면 리스트 뷰로 나오는거임.
                // 거기서 일정 예시 보여주고 하나하나 등록하면
                // 오늘 일정이 나오는거지.
                // 매일 매일 할 것이랑 특정 날짜만 할 것들 정해서 보여주면 좋을듯.
                // 이거 매일매일 일정 설정하면 귀찮을거 같은데.
                // 이번 주 일정 정하기 이렇게 해서 매주 일요일마다 새로 하게 만들자.
                // 반복 일정, 특별 일정 이렇게 정하고
                // 알람 설정도 할 수 있음 좋은데 일단 보류하고.
                // 금요일의 나야 반갑다.
              ),
            ),
            Row(
              children: [
                Container(
                  width: c_size.width * 0.5,
                  height: c_size.height * 0.2,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // 원하는 색상을 지정
                      width: 1.0, // 원하는 선의 두께를 지정
                    ),
                  ),
                  child: Text("그래프"),
                ),
                Container(
                  width: c_size.width * 0.5,
                  height: c_size.height * 0.2,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // 원하는 색상을 지정
                      width: 1.0, // 원하는 선의 두께를 지정
                    ),
                  ),
                  child: Text("통계"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
