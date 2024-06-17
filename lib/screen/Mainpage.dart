import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_01_app/screen/Set_schedule.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Mainpage> {
  final List<String> week = ["월", "화", "수", "목", "금", "토", "일"];
  late int ListCount = 0;
  final today = DateTime.now();
  List<Map<String, dynamic>> list = [];

  final firebase = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    invitaionList();
    // 우측 상단이나 왼쪽에서 설정 칸 만들어서 알림 설정 같은거
    // 아니면 아래 빈칸에 3개 만들어서 메인화면, 설정, 프로필? 달력? 이렇게
    super.initState();
  }

  Future<void> invitaionList() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Calender')
        .where('day', isEqualTo: today.day)
        .where('month', isEqualTo: today.month)
        .where('year', isEqualTo: today.year)
        .get();
    setState(() {
      ListCount = querySnapshot.docs.length;
    });
  }

  /** 
     * titleText : 텍스트 내용 입력 
     * Size : 폰트 사이즈 double값 넣을것.
     * FontWeight.bold
    */
  Widget TitleText(String titleText, double Size) {
    return Text(
      titleText,
      style: TextStyle(fontSize: Size, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedWeekday = DateFormat('E', 'ko_KO').format(now);
    // CounterProvider counter = Provider.of<CounterProvider>(context);
    // print(formattedWeekday);
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
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 230, 242, 255),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              TitleText('오늘의 일정 ', 24),
                              TitleText("$ListCount건", 24),
                            ],
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Calender')
                                .where('day', isEqualTo: today.day)
                                .where('month', isEqualTo: today.month)
                                .where('year', isEqualTo: today.year)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Set_schedul(
                                            option: '반복 안 함',
                                            selectedDate_: DateTime.now(),
                                            schedule_Write: "",
                                            selectedHour: 0,
                                            selectedMinute: 0,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text("일정을 등록하세요"),
                                  ),
                                );
                              }

                              final documents = snapshot.data!.docs;

                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                // 리스트 윗 공간 채우기
                                itemCount: documents.length,
                                itemBuilder: (context, index) {
                                  final doc = documents[index];
                                  final data = documents[index].data()
                                      as Map<String, dynamic>;
                                  return Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: GestureDetector(
                                      onLongPress: () {
                                        // 파이어베이스에서 문서 삭제
                                        // 일정이 바로 삭제되는데.
                                        FirebaseFirestore.instance
                                            .collection('Calender')
                                            .doc(doc.id)
                                            .delete()
                                            .then((_) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content:
                                                      Text('일정이 삭제되었습니다')));
                                        }).catchError((error) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      '일정 삭제 실패: $error')));
                                        });
                                      },
                                      child: Container(
                                        height: c_size.height * 0.1,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            data['Schedule'] ?? 'No Schedule',
                                            style: TextStyle(fontSize: 25),
                                          ),
                                          subtitle: Text(
                                            'Date: ${data['year'] ?? 'No Date'}\nTime: ${data['hour'] ?? 'No Hour'}:${data['minit'] ?? 'No Minute'}',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 16.0,
                      right: 16.0,
                      child: FloatingActionButton(
                        backgroundColor: Colors.grey.shade100,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Set_schedul(
                                option: '반복 안 함',
                                selectedDate_: DateTime.now(),
                                schedule_Write: "",
                                selectedHour: 0,
                                selectedMinute: 0,
                              ),
                            ),
                          );
                        },
                        child: Icon(Icons.add),
                        tooltip: 'Add Schedule',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 5,
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
