import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class calendar extends StatefulWidget {
  const calendar({
    super.key,
  });
  @override
  State<calendar> createState() => _calendarState();
}

class _calendarState extends State<calendar> {
  List<FlSpot> _generateFlSpots2(List<QueryDocumentSnapshot> documents) {
    Map<int, int> Clear_dateCounts = {};

    for (var doc in documents) {
      for (var timestamp in doc['dates']) {
        DateTime fullDateTime = (timestamp as Timestamp).toDate();
        DateTime dates = fullDateTime;
        // 시간 부분을 제거하고 year, month, day만 사용합니다.
        // DateTime dates = (timestamp as Timestamp).toDate();
        print("dates${dates.month}");
        if (Clear_dateCounts.containsKey(dates.month)) {
          // 특정키가 map에 존재하는지 여부. ??
          Clear_dateCounts[dates.month] = Clear_dateCounts[dates.month]! + 1;
        } else {
          Clear_dateCounts[dates.month] = 1;
        }
        print("Clear_dateCounts$Clear_dateCounts");
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
    Map<DateTime, int> Clear_dateCounts = {};
    // 각 달의 문서 개수를 계산
    for (var doc in documents) {
      int month = doc['month'];
      if (monthCounts.containsKey(month)) {
        // 특정키가 map에 존재하는지 여부. ??
        monthCounts[month] = monthCounts[month]! + 1;
      } else {
        monthCounts[month] = 1;
      }
      print(monthCounts);
    }
    for (var doc in documents) {
      for (var timestamp in doc['dates']) {
        DateTime fullDateTime = (timestamp as Timestamp).toDate();
        DateTime dates = DateTime(fullDateTime.month);
        // 시간 부분을 제거하고 year, month, day만 사용합니다.
        // DateTime dates = (timestamp as Timestamp).toDate();
        if (Clear_dateCounts.containsKey(dates)) {
          // 특정키가 map에 존재하는지 여부. ??
          Clear_dateCounts[dates] = Clear_dateCounts[dates]! + 1;
        } else {
          Clear_dateCounts[dates] = 1;
        }
      }
    }
// // 각 달의 문서 개수를 계산
    // for (var doc in documents) {
    //   int month = doc['dates'];
    //   if (Clear_dateCounts.containsKey(month)) {
    //     // 특정키가 map에 존재하는지 여부. ??
    //     Clear_dateCounts[month] = Clear_dateCounts[month]! + 1;
    //   } else {
    //     Clear_dateCounts[month] = 1;
    //   }
    // }
    // FlSpot 리스트 생성
    List<FlSpot> spots = [];
    for (int i = 1; i <= 12; i++) {
      spots.add(FlSpot(i.toDouble(), (monthCounts[i] ?? 0).toDouble()));
    }
    print(spots);

    return spots;
  }

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
      child: Text(' ${value + 2}', style: style),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const cutOffYValue = 5.0;

    return Scaffold(
      appBar: AppBar(
        title: Title(color: Colors.black, child: Text("Line Chart")),
      ),
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

                  return Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 28,
                            top: 22,
                            bottom: 12,
                          ),
                          child: LineChart(
                            LineChartData(
                              lineTouchData:
                                  const LineTouchData(enabled: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots2,
                                  isCurved: true,
                                  color: Colors.red,
                                  barWidth: 3,
                                  belowBarData: BarAreaData(show: false),
                                ),
                                LineChartBarData(
                                  spots:
                                      // for (double i = 0; i < 12; i++)
                                      //  for (var doc in documents)
                                      //  if(i = doc['month'])
                                      spots
                                  // for (double i = 0; i < 12; i++)
                                  // FlSpot(i, 0 + i),
                                  // FlSpot(1, 3.5),
                                  // FlSpot(2, 4.5),
                                  // FlSpot(3, 1),
                                  // FlSpot(4, 4),
                                  // FlSpot(5, 6),
                                  // FlSpot(6, 6.5),
                                  // FlSpot(7, 6),
                                  // FlSpot(8, 4),
                                  // FlSpot(9, 6),
                                  // FlSpot(10, 6),
                                  // FlSpot(11, 7),
                                  ,
                                  isCurved: true,
                                  barWidth: 5,
                                  color: Colors.black,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.red,
                                    cutOffY: cutOffYValue,
                                    applyCutOffY: true,
                                  ),
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
                              minY: 0,
                              titlesData: FlTitlesData(
                                show: true,
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
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
                                    getTitlesWidget: bottomTitleWidgets,
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
                                    interval: 3,
                                    reservedSize: 40,
                                    getTitlesWidget: leftTitleWidgets,
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
                                checkToShowHorizontalLine: (double value) {
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
                      Text("${documents[0]["month"]}"),
                      Text("${documents[0].data()}"),
                      ElevatedButton(
                          onPressed: () {
                            print("spots");
                            print(spots);
                            print("spots");
                            print("spots2");
                            print(spots2);
                            print("spots2");
                          },
                          child: Text("test"))
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
}
