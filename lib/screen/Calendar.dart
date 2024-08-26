import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:practice_01_app/provinder/color_provinder.dart';
import 'package:provider/provider.dart';

class calendar extends StatefulWidget {
  const calendar({
    super.key,
  });
  @override
  State<calendar> createState() => _calendarState();
}

class _calendarState extends State<calendar> {
  double count = 1;

  double monthCount1 = 0;

  void _updateMonthCount(scheduleCounts2, scheduleCounts) {
    int value21 = count.toInt();
    double value2 = scheduleCounts2[value21];
    double value = scheduleCounts[value21];

    if (value > 0) {
      monthCount1 = (value2 / value) * 100;
    } else {
      monthCount1 = 0.0;
    }

    setState(() {
      monthCount1 = double.parse(monthCount1.toStringAsFixed(1));
    });
  }

  List<FlSpot> _generateFlSpots2(List<QueryDocumentSnapshot> documents) {
    Map<int, int> Clear_dateCounts = {};

    for (var doc in documents) {
      for (var timestamp in doc['dates']) {
        DateTime fullDateTime = (timestamp as Timestamp).toDate();
        DateTime dates = fullDateTime;
        // 시간 부분을 제거하고 year, month, day만 사용합니다.
        // DateTime dates = (timestamp as Timestamp).toDate();
        // print("dates${dates.month}");
        if (Clear_dateCounts.containsKey(dates.month)) {
          // 특정키가 map에 존재하는지 여부. ??
          Clear_dateCounts[dates.month] = Clear_dateCounts[dates.month]! + 1;
        } else {
          Clear_dateCounts[dates.month] = 1;
        }
        // print("Clear_dateCounts$Clear_dateCounts");
      }
    }
    // FlSpot 리스트 생성
    List<FlSpot> spots2 = [];
    for (int i = 1; i <= 12; i++) {
      spots2.add(FlSpot(i.toDouble(), (Clear_dateCounts[i] ?? 0).toDouble()));
    }
    return spots2;
  }

  List<FlSpot> _generateFlSpots(List<QueryDocumentSnapshot> documents) {
    Map<int, int> monthCounts = {};
    // 각 달의 문서 개수를 계산
    // 8월은 오늘 4개 추가했고 7월에 시작하는 매일 일정이 4개니까
//     ++++ 14곱하기 4 로 56에 +4로 60개여야함.
//    ++++ 14일 기준으로 어 쉬발 뭐지 된건가.
//    ++++ 주말 주중 1년 1달을 +1로만 처리해서 정확하진 않음.
//    ++++ 근데 지금 매일만 처리하는 기준으로는 된듯.
// 지금 true면 차이나는 일수만큼 그냥 더해버리는데
// 근데 다음달은 초기화 해서 1이 되버리고 7월에만 계속 추가됨. 골떄리는데?
// 달이 바뀌었나 이거는 써도 되는데 차이나는 일수 이게 그냥 joat네 쓰면안됨.
// 달이 바뀌었나? 이거 true면 그냥 now에서 month빼면 day만 남을거아님 그거 넣으면 되겟다.
// 그럼 안바뀌었으면 해당 달에서 - day하면되네.
    for (var doc in documents) {
      // 다음 달의 첫 번째 날에서 하루를 빼면 현재 월의 마지막 날이 나옵니다.
      DateTime YMD_now = DateTime(doc['year'], doc['month'], doc['day']);
      String options = doc['option'];
      int month = doc['month'];

      // print("===================");
      // print("options: $options");
      // print("===================");

      if (options != null && monthCounts != null && YMD_now != null) {
        bool hasMonthChanged = DateTime.now().year != YMD_now.year ||
            DateTime.now().month != YMD_now.month;
        // print("hasMonthChanged: $hasMonthChanged");

        if (options == "매일") {
          if (hasMonthChanged) {
            // print('달이 바뀐 경우 (true): $hasMonthChanged');
            // print('현재 달의 일정 개수: ${monthCounts[month]}');

            // 다음 달 계산 (현재 달이 12월이면 다음 달은 1월이 됩니다)
            int nextMonth = (month % 12) + 1;
            int daysInMonth =
                DateTime(YMD_now.year, YMD_now.month + 1, 0).day; // 현재 월의 일 수
            int differenceDays = daysInMonth - YMD_now.day + 1; // 남은 일 수 계산

            // print("현재 달 매일 일정: $differenceDays");
            monthCounts[month] = (monthCounts[month] ?? 0) + differenceDays;

            // 다음 달에 데이터 추가
            // print('다음 달 (nextMonth): $nextMonth');
            monthCounts[nextMonth] =
                (monthCounts[nextMonth] ?? 0) + DateTime.now().day;
            print('다음 달의 일정 개수: ${monthCounts[nextMonth]}');
          } else {
            int differenceDays = DateTime.now().day;
            // print("현재 달 매일 일정: $differenceDays");

            monthCounts[month] = (monthCounts[month] ?? 0) + differenceDays;
            // print('달이 바뀌지 않은 경우 (false): ${monthCounts[month]}');
          }
        } else if (options == "주중") {
          int weeksElapsed =
              (DateTime.now().difference(YMD_now).inDays / 7).floor();
          int daysToAdd = 5 * (weeksElapsed + 1); // 매주 5일씩 추가

          if (YMD_now.weekday >= DateTime.monday &&
              YMD_now.weekday <= DateTime.friday) {
            monthCounts[month] = (monthCounts[month] ?? 0) + daysToAdd;
            // print("주중 일정 추가: $daysToAdd 일");
          }
        } else if (options == "주말") {
          // 만약
          if (YMD_now.weekday == DateTime.saturday ||
              YMD_now.weekday == DateTime.sunday) {
            int weeksElapsed =
                (DateTime.now().difference(YMD_now).inDays / 7).floor();
            int daysToAdd = 2 * (weeksElapsed + 1); // 매주 2일씩 추가
            monthCounts[month] = (monthCounts[month] ?? 0) + daysToAdd;
          }
        } else if (options == "한달") {
          // 매월 반복 - 현재 달과 다음 달 모두 추가
          monthCounts[month] = (monthCounts[month] ?? 0) + 1;
          int nextMonth = (month % 12) + 1;
          monthCounts[nextMonth] = (monthCounts[nextMonth] ?? 0) + 1;
        } else if (options == "1년") {
          // 매년 반복 - 현재 달에 추가
          monthCounts[month] = (monthCounts[month] ?? 0) + 1;
        } else {
          monthCounts[month] = 1;
        }
      } else {
        // print("options, monthCounts 또는 YMD_now가 null입니다.");
      }
      // print(monthCounts);
    }

    List<FlSpot> spots = [];
    for (int i = 1; i <= 12; i++) {
      spots.add(FlSpot(i.toDouble(), (monthCounts[i] ?? 0).toDouble()));
    }
    // print("======spots");
    // print(spots);
    return spots;
  }
  // 아니 나 병신인가 월별 달성률은 차트에 보이잖아?

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Jan';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Apr';
        break;
      case 4:
        text = 'May';
        break;
      case 5:
        text = 'Jun';
        break;
      case 6:
        text = 'Jul';
        break;
      case 7:
        text = 'Aug';
        break;
      case 8:
        text = 'Sep';
        break;
      case 9:
        text = 'Oct';
        break;
      case 10:
        text = 'Nov';
        break;
      case 11:
        text = 'Dec';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.red,
      fontSize: 12,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(' ${value + 5}', style: style),
    );
  }

  Stream invitaionList() async* {
    yield* FirebaseFirestore.instance
        .collection('Calender')
        .where('day')
        .where('month')
        .where('year')
        .snapshots();
  }
  // Future MonthCounts(scheduleCounts2, scheduleCounts){

  //    for (int i = 0; i < scheduleCounts2.length; i++) {
  //                   double value2 = scheduleCounts2[i];
  //                   double value = scheduleCounts[i];
  //                   double monthCount1 = ((value2 / value) * 100).toStringAsFixed(1) as double;
  //                   // print(value2);
  //                   // print(
  //                   //     "Month ${i + 1}: ${((value2 / value) * 100).toStringAsFixed(1)}");
  //                 }
  //   return monthCount1;
  //   //
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const cutOffYValue = 5.0;

    return Scaffold(
      // appBar: AppBar(
      //   title: Title(color: Colors.black, child: Text("목표 달성률")),
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
                stream: invitaionList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text("데이터가 읍서용.");
                  }
                  // final documents = snapshot.data!.docs;
                  final documents = snapshot.data!.docs;
                  // FlSpot 리스트 생성
                  List<FlSpot> spots = _generateFlSpots(documents);
                  List<FlSpot> spots2 = _generateFlSpots2(documents);
                  List<double> scheduleCounts =
                      spots.map((spot) => spot.y).toList();
                  double totalSchedules =
                      scheduleCounts.reduce((a, b) => a + b);
                  List<double> scheduleCounts2 =
                      spots2.map((spot) => spot.y).toList();
                  // for (int i = 0; i < scheduleCounts2.length; i++) {
                  //   double value2 = scheduleCounts2[i];
                  //   double value = scheduleCounts[i];
                  //   // print(value2);
                  //   // print(
                  //   //     "Month ${i + 1}: ${((value2 / value) * 100).toStringAsFixed(1)}");
                  // }
                  double totalSchedules2 =
                      scheduleCounts2.reduce((a, b) => a + b);
                  // print(
                  // "${((scheduleCounts2 / totalSchedules) * 100).toStringAsFixed(1)}");
                  double maxYValue = spots
                      .map((spot) => spot.y)
                      .reduce((a, b) => a > b ? a : b);
                  var c_size = MediaQuery.of(context).size;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Consumer<ColorProvider>(builder: (context, value, child) {
                        return Container(
                          width: c_size.width * 1,
                          height: c_size.height * 1,
                          decoration: BoxDecoration(
                            color: value.backgroundColor,
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: c_size.height * 0.07),
                              Text(
                                "목표달성률",
                                style: TextStyle(fontSize: 35),
                              ),
                              SizedBox(
                                height: c_size.height * 0.01,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60),
                                  color: Colors.white,
                                ),
                                child: AspectRatio(
                                  aspectRatio: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 15,
                                      right: 28,
                                      top: 22,
                                      bottom: 10,
                                    ),
                                    child: LineChart(
                                      LineChartData(
                                        minY: 0,
                                        maxY: maxYValue + 5,
                                        lineTouchData:
                                            const LineTouchData(enabled: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: spots2,
                                            isCurved: true,
                                            color: Colors.red,
                                            barWidth: 4,
                                            belowBarData:
                                                BarAreaData(show: false),
                                          ),
                                          LineChartBarData(
                                            spots: spots,
                                            isCurved: true,
                                            barWidth: 4,
                                            color: Colors.black,
                                            // belowBarData: BarAreaData(
                                            //   show: true,
                                            //   color: Colors.red,
                                            //   cutOffY: cutOffYValue,
                                            //   applyCutOffY: true,
                                            // ),
                                            // aboveBarData: BarAreaData(
                                            //   show: true,
                                            //   color: Colors.blue,
                                            //   cutOffY: cutOffYValue,
                                            //   applyCutOffY: true,
                                            // ),
                                            dotData: const FlDotData(
                                              show: false,
                                            ),
                                          ),
                                        ],
                                        titlesData: FlTitlesData(
                                          show: true,
                                          topTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            axisNameWidget: Text(
                                              '2024',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 18,
                                              interval: 1,
                                              getTitlesWidget:
                                                  bottomTitleWidgets,
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            axisNameSize: 20,
                                            axisNameWidget: const Text(
                                              'Value',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 5,
                                              reservedSize: 40,
                                              getTitlesWidget: (double value,
                                                  TitleMeta meta) {
                                                if (value % 5 == 0) {
                                                  // 5의 배수인 경우에만 표시
                                                  return Text(
                                                      value.toInt().toString(),
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12));
                                                }
                                                return Container();
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                          show: true,
                                          border: Border.all(
                                            color: Colors.green,
                                          ),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                          horizontalInterval: 1,
                                          checkToShowHorizontalLine:
                                              (double value) {
                                            return value == 1 ||
                                                value == 6 ||
                                                value == 4 ||
                                                value == 5;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // ElevatedButton(
                              //     onPressed: () {
                              //       print("spots");
                              //       print(totalSchedules);
                              //       print("spots");
                              //       print("spots2");
                              //       print(totalSchedules2);
                              //       print("spots2");
                              //     },
                              //     child: Text(
                              //         "달성률 ${(totalSchedules2 / totalSchedules) * 100}")),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    height: MediaQuery.of(context).size.height *
                                        0.23,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        Text(
                                          "년/달성률",
                                          style: TextStyle(fontSize: 30),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        Text(
                                          " ${((totalSchedules2 / totalSchedules) * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(fontSize: 40),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.05,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    height: MediaQuery.of(context).size.height *
                                        0.23,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    count = (count > 0)
                                                        ? count - 1
                                                        : 11;
                                                    _updateMonthCount(
                                                        scheduleCounts2,
                                                        scheduleCounts);
                                                  });
                                                },
                                                icon:
                                                    Icon(Icons.arrow_back_ios)),
                                            Text(
                                              "${(count + 1).toInt()}월",
                                              style: TextStyle(fontSize: 30),
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    count = (count < 11)
                                                        ? count + 1
                                                        : 0;
                                                    _updateMonthCount(
                                                        scheduleCounts2,
                                                        scheduleCounts);
                                                  });
                                                },
                                                icon: Icon(
                                                    Icons.arrow_forward_ios)),
                                          ],
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        Text(
                                          " ${monthCount1 >= 0 ? double.parse(monthCount1.toStringAsFixed(1)) : monthCount1 = 0}%",
                                          style: TextStyle(fontSize: 40),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
}
