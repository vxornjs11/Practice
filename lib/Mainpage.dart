import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:practice_01_app/provinder/count_provinder.dart';
import 'package:provider/provider.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Mainpage> {
  final List<String> week = ["월", "화", "수", "목", "금", "토", "일"];
  @override
  void initState() {
    // TODO: implement initState
    // 우측 상단이나 왼쪽에서 설정 칸 만들어서 알림 설정 같은거
    // 아니면 아래 빈칸에 3개 만들어서 메인화면, 설정, 프로필? 달력? 이렇게
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CounterProvider counter = Provider.of<CounterProvider>(context);
    var c_size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: c_size.height * 0.06,
            ),
            Container(
              width: c_size.width * 1,
              height: c_size.height * 0.06,
              child: Row(
                children: [
                  SizedBox(
                    width: c_size.width * 1,
                    height: c_size.height * 0.05,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: week.length,
                        itemBuilder: (context, index) {
                          print("week.length");
                          print(week.length);
                          return Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              // color: Colors.white,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black, // 원하는 색상을 지정
                                  width: 1.0, // 원하는 선의 두께를 지정
                                ),
                              ),
                              child: Text("${week[index]}"),
                              width: c_size.width * 0.135,
                              height: c_size.height * 0.1,
                            ),
                          );
                        }),
                  ),
                ],
              ), // Row 끝
            ),
            Container(
              width: c_size.width * 1,
              height: c_size.height * 0.6,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // 원하는 색상을 지정
                  width: 1.0, // 원하는 선의 두께를 지정
                ),
              ),
              child: Text("오늘 체크리스트 할일"),
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
                  child: Text("달력"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
