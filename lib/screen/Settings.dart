// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:intl/intl.dart';
// import 'package:practice_01_app/main.dart';
import 'package:practice_01_app/provinder/color_provinder.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  /// 이제 알람, 반복기능을 설정안하고 등록할때 생기는 문제나
  /// 글자수 제한 이런거 생각해보고.

  /// -- 반복설정 하고나면 텍스트필드 값이 사라지네 이것도 저장해서 파라미터로 넘겨야겟다.
  ///
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // ignore: non_constant_identifier_names
  bool color_select = false;
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
            return Container(
              height: cSize.height * 0.8,
              width: cSize.width * 1,
              decoration: BoxDecoration(
                color: colorProvider.backgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            color: colorProvider.backgroundColor)),
                    // GestureDetector(
                    //   onTap: () {
                    //     setState(() {
                    //       color_select = !color_select;
                    //       print(color_select);
                    //     });
                    //   },
                    //   child: Container(
                    //     height: cSize.height * 0.075,
                    //     width: cSize.width * 1,
                    //     decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         borderRadius: BorderRadius.circular(15)),
                    //     child: Row(
                    //       children: [
                    //         Icon(Icons.palette),
                    //         Text("색 메타"),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // GestureDetector(
                    //   onTap: () {
                    //     setState(() {
                    //       color_select = !color_select;
                    //       print(color_select);
                    //     });
                    //   },
                    //   child: AnimatedContainer(
                    //     duration: Duration(milliseconds: 300),
                    //     height: color_select
                    //         ? cSize.height * 0.3
                    //         : cSize.height * 0.1, // 애니메이션으로 등장할 높이
                    //     // 이거보다 그냥 색 메타 저기를 밀고 내려오는게 더 나을듯.
                    //     curve: Curves.easeInOut, // 부드러운 등장 효과
                    //     child: color_select
                    //         ? Column(
                    //             children: [
                    //               Container(
                    //                 height: cSize.height * 0.3,
                    //                 width: cSize.width * 1,
                    //                 decoration: BoxDecoration(
                    //                     color: Colors.white,
                    //                     borderRadius:
                    //                         BorderRadius.circular(15)),
                    //                 child: Column(
                    //                   children: [
                    //                     Row(
                    //                       children: [
                    //                         Icon(Icons.palette),
                    //                         Text("색 메타"),
                    //                       ],
                    //                     ),
                    //                     SizedBox(
                    //                       height: cSize.height * 0.05,
                    //                     ),
                    //                     _buildColorButton(Colors.amber,
                    //                         "yellow", colorProvider),
                    //                     _buildColorButton(
                    //                         Colors.blue, "blue", colorProvider),
                    //                     _buildColorButton(
                    //                         Color.fromARGB(255, 230, 242, 255),
                    //                         "기본 약하늘",
                    //                         colorProvider),
                    //                   ],
                    //                 ),
                    //               ),
                    //             ],
                    //           )
                    //         : Container(
                    //             height: cSize.height * 0.075,
                    //             width: cSize.width * 1,
                    //             decoration: BoxDecoration(
                    //                 color: Colors.white,
                    //                 borderRadius: BorderRadius.circular(15)),
                    //             child: Row(
                    //               children: [
                    //                 Icon(Icons.palette),
                    //                 Text("색 메타"),
                    //               ],
                    //             ),
                    //           ),
                    //   ),
                    // ),
                    // // color_select == false
                    // //     ? SizedBox()
                    // //     : Column(
                    // //         children: [
                    // //           _buildColorButton(
                    // //               Colors.amber, "yellow", colorProvider),
                    // //           _buildColorButton(
                    // //               Colors.blue, "blue", colorProvider),
                    // //           _buildColorButton(
                    // //               Color.fromARGB(255, 230, 242, 255),
                    // //               "기본 약하늘",
                    // //               colorProvider),
                    //         ],
                    //       )
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          color_select = !color_select;
                          // print(color_select);
                        });
                      },
                      child: color_select
                          ? Container(
                              height: cSize.height * 0.075,
                              width: cSize.width * 1,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Row(
                                children: [
                                  const Icon(Icons.palette),
                                  SizedBox(
                                    width: cSize.width * 0.015,
                                  ),
                                  const Text("색상 설정"),
                                  SizedBox(
                                    width: cSize.width * 0.65,
                                  ),
                                  const Icon(Icons.arrow_drop_down)
                                ],
                                //arrow_left_sharp
                              ),
                            )
                          : Container(
                              height: cSize.height * 0.275,
                              width: cSize.width * 1,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: cSize.height * 0.025,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.palette),
                                      SizedBox(
                                        width: cSize.width * 0.015,
                                      ),
                                      const Text("색상 설정"),
                                      SizedBox(
                                        width: cSize.width * 0.65,
                                      ),
                                      const Icon(Icons.arrow_left_sharp)
                                    ],
                                  ),
                                  SizedBox(
                                    height: cSize.height * 0.025,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildColorButton(
                                          const Color.fromARGB(
                                              255, 255, 242, 202),
                                          "연노랑",
                                          colorProvider),
                                      _buildColorButton(
                                          const Color.fromRGBO(
                                              200, 162, 200, 1.0),
                                          "라일락",
                                          colorProvider),
                                      _buildColorButton(
                                          const Color.fromARGB(
                                              255, 230, 242, 255),
                                          "하늘색",
                                          colorProvider),
                                      _buildColorButton(
                                          const Color.fromRGBO(
                                              245, 245, 220, 1.0),
                                          "베이지",
                                          colorProvider),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildColorButton(
                                          const Color.fromRGBO(
                                              230, 230, 250, 1.0),
                                          "연보라",
                                          colorProvider),
                                      _buildColorButton(
                                          const Color.fromRGBO(
                                              245, 222, 179, 1.0),
                                          "밀색",
                                          colorProvider),
                                      _buildColorButton(
                                          const Color.fromRGBO(
                                              240, 220, 130, 1.0),
                                          "버프",
                                          colorProvider),
                                      _buildColorButton(
                                          const Color.fromRGBO(
                                              210, 180, 140, 1.0),
                                          "브라운",
                                          colorProvider),
                                    ],
                                  )
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Container(
                    //   height: cSize.height * 0.075,
                    //   width: cSize.width * 1,
                    //   decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(15)),
                    //   child: const Row(
                    //     children: [
                    //       Icon(Icons.palette),
                    //       Text("색 메타"),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(
                      height: 10,
                    ),
                    // ElevatedButton(
                    //   onPressed: () async {

                    //     // 현재 등록된 알람 찾기
                    //     getScheduledNotifications();
                    //   },
                    //   child: Text("모든 알람 삭제"),
                    // ),
                    // Image.asset(
                    //   "images/small.png",
                    // ),
                    // Image.asset(
                    //   "images/Frame 1 3.png",
                    // ),
                  ],
                ),
              ),
            );
          }),
          // Text(" Text('User ID: ${UserManager.userId}'),"),
        ],
      ),
    );
  }

  // Future<void> getScheduledNotifications() async {
  //   // print("object");
  //   final pendingNotifications =
  //       await flutterLocalNotificationsPlugin.pendingNotificationRequests();

  //   // print("등록된 알림 개수: ${pendingNotifications.length}");

  //   for (var notification in pendingNotifications) {
  //     print(
  //         "알림 ID: ${notification.id}, 제목: ${notification.title}, 내용: ${notification.body}");
  //   }
  // }

  Widget _buildColorButton(Color color, String label, colorProvider) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        onPressed: () {
          // Example of changing the background color
          colorProvider.changeBackgroundColor(
            newColor: color,
          );
        },
        child: Text(label),
      ),
    );
  }
}
