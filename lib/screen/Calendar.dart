import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
// import 'package:get/get_utils/get_utils.dart';
import 'package:practice_01_app/main.dart';
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
  // ignore: non_constant_identifier_names
  bool change_Chart = false;

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
      if (doc["year"] == DateTime.now().year) {
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
      } else {
        print("해당 년도에는 데이터가 없습니다.");
      }
    }
    // FlSpot 리스트 생성
    List<FlSpot> spots2 = [];
    for (int i = 1; i <= 12; i++) {
      spots2.add(FlSpot(i.toDouble(), (Clear_dateCounts[i] ?? 0).toDouble()));
    }
    print("======spots2222");
    print(spots2);
    print("======spots222");
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
      print("시작입니다 $YMD_now $options");
      if (options != null &&
              monthCounts != null &&
              YMD_now != null &&
              YMD_now.year == DateTime.now().year &&
              YMD_now.isBefore(DateTime.now()) ||
          YMD_now.isAtSameMomentAs(DateTime.now())) {
        bool hasMonthChanged =
            //  DateTime.now().year != YMD_now.year ||
            DateTime.now().month != YMD_now.month;
        // print("DateTime.now().month != YMD_now.month; $month");

        print("매일 첫번째 $month // ${monthCounts[month]}");
        print("hasMonthChanged $hasMonthChanged");
        // 그니까 이건 데이터상 달과 현재의 달이 같냐 다르냐 묻는거고
        // 지금 8월 일정은 현재 달과 다르잖아. 그니까 트루야.
        // 아하 8월 매일이 없지 이제 ㅋㅋ;;
        print(DateTime.now().month != YMD_now.month);
        if (options == "매일") {
          // '매일' 일정에서 현재 날짜와 남은 날짜 계산
          int dayCount = 0;

          // 현재 월의 마지막 날짜 계산
          DateTime lastDayOfMonth =
              DateTime(YMD_now.year, YMD_now.month + 1, 0);

          // 현재 월의 '매일' 일정 계산
          if (month == DateTime.now().month) {
            for (DateTime date = YMD_now;
                !date
                    .isAfter(DateTime(YMD_now.year, month, DateTime.now().day));
                date = date.add(Duration(days: 1))) {
              dayCount++;
            }
            monthCounts[month] = (monthCounts[month] ?? 0) + dayCount;
          }

          // 다음 달 이상으로 넘어가는 경우
          if (month != DateTime.now().month) {
            for (; month != DateTime.now().month; month++) {
              if (month > 12) month = 1;

              // 다음 달의 날짜 범위 계산
              DateTime firstDayOfNextMonth = DateTime(YMD_now.year, month, 1);
              DateTime lastDayOfNextMonth =
                  DateTime(YMD_now.year, month + 1 > 12 ? 1 : month + 1, 0);

              int nextMonthDayCount = 0;

              for (DateTime date = firstDayOfNextMonth;
                  !date.isAfter(lastDayOfNextMonth);
                  date = date.add(Duration(days: 1))) {
                nextMonthDayCount++;
              }

              // 다음 달 날짜 카운트
              monthCounts[month] =
                  (monthCounts[month] ?? 0) + nextMonthDayCount;
            }
          }

          // 최종 결과 출력
          print("매일 계산 완료: $month => ${monthCounts[month]}");
        }

        // int weeksElapsed =
        //     (lastDayOfMonth.difference(YMD_now).inDays / 7).floor();
        // print('마지막 날: $lastDayOfMonth'); // 예: 2024-07-31
        // print('주 차이: $weeksElapsed'); //
        // print(
        //     '날짜 차이: ${lastDayOfMonth.difference(YMD_now).inDays / 7}'); // 예: 16일

        // 평일 카운트를 위한 변수

        else if (options == "주중") {
          int weekdayCount = 0;

          // 현재 월의 마지막 날짜 계산
          DateTime lastDayOfMonth =
              DateTime(YMD_now.year, YMD_now.month, DateTime.now().day);

          // 현재 달 평일 계산
          if (month == DateTime.now().month) {
            for (DateTime date = YMD_now;
                !date.isAfter(lastDayOfMonth);
                date = date.add(Duration(days: 1))) {
              if (date.weekday >= DateTime.monday &&
                  date.weekday <= DateTime.friday) {
                weekdayCount++;
              }
            }
            monthCounts[month] = (monthCounts[month] ?? 0) + weekdayCount;
          }

          // 다음 달 이상으로 넘어가는 경우
          if (month != DateTime.now().month) {
            for (; month != DateTime.now().month; month++) {
              if (month > 12) month = 1;

              // 다음 달의 범위 계산
              DateTime lastDayOfNextMonth =
                  DateTime(YMD_now.year, month + 1 > 12 ? 1 : month + 1, 0);
              DateTime firstDayOfNextMonth = DateTime(YMD_now.year, month, 1);

              int nextMonthWeekdayCount = 0;

              for (DateTime date = firstDayOfNextMonth;
                  !date.isAfter(lastDayOfNextMonth);
                  date = date.add(Duration(days: 1))) {
                if (date.weekday >= DateTime.monday &&
                    date.weekday <= DateTime.friday) {
                  nextMonthWeekdayCount++;
                }
              }

              monthCounts[month] =
                  (monthCounts[month] ?? 0) + nextMonthWeekdayCount;
            }
          }

          print("최종 주중 평일 계산: $month => ${monthCounts[month]}");
        }

// ====== "주말" 옵션 ======
        else if (options == "주말") {
          int weekendCount = 0;

          // 현재 월의 마지막 날짜 계산
          DateTime lastDayOfMonth =
              DateTime(YMD_now.year, YMD_now.month, DateTime.now().day);

          // 현재 달 주말 계산
          if (month == DateTime.now().month) {
            for (DateTime date = YMD_now;
                !date.isAfter(lastDayOfMonth);
                date = date.add(Duration(days: 1))) {
              if (date.weekday == DateTime.saturday ||
                  date.weekday == DateTime.sunday) {
                weekendCount++;
              }
            }
            monthCounts[month] = (monthCounts[month] ?? 0) + weekendCount;
          }

          // 다음 달 이상으로 넘어가는 경우
          if (month != DateTime.now().month) {
            for (; month != DateTime.now().month; month++) {
              if (month > 12) month = 1;

              DateTime lastDayOfNextMonth =
                  DateTime(YMD_now.year, month + 1 > 12 ? 1 : month + 1, 0);
              DateTime firstDayOfNextMonth = DateTime(YMD_now.year, month, 1);

              int nextMonthWeekendCount = 0;

              for (DateTime date = firstDayOfNextMonth;
                  !date.isAfter(lastDayOfNextMonth);
                  date = date.add(Duration(days: 1))) {
                if (date.weekday == DateTime.saturday ||
                    date.weekday == DateTime.sunday) {
                  nextMonthWeekendCount++;
                }
              }

              monthCounts[month] =
                  (monthCounts[month] ?? 0) + nextMonthWeekendCount;
            }
          }

          print("최종 주말 계산: $month => ${monthCounts[month]}");
        }

// ====== "매주" 옵션 ======
        else if (options == "매주") {
          int weeklyCount = 0;

          // 현재 달의 특정 요일(알람 요일)을 반복 계산
          if (month == DateTime.now().month) {
            for (DateTime date = YMD_now;
                !date
                    .isAfter(DateTime(YMD_now.year, month, DateTime.now().day));
                date = date.add(Duration(days: 7))) {
              if (date.weekday == YMD_now.weekday) {
                weeklyCount++;
              }
            }
            monthCounts[month] = (monthCounts[month] ?? 0) + weeklyCount;
          }

          // 다음 달 이상으로 넘어가는 경우
          if (month != DateTime.now().month) {
            for (; month != DateTime.now().month; month++) {
              if (month > 12) month = 1;

              DateTime firstDayOfNextMonth = DateTime(YMD_now.year, month, 1);
              DateTime lastDayOfNextMonth =
                  DateTime(YMD_now.year, month + 1 > 12 ? 1 : month + 1, 0);

              int nextMonthWeeklyCount = 0;

              for (DateTime date = firstDayOfNextMonth;
                  !date.isAfter(lastDayOfNextMonth);
                  date = date.add(Duration(days: 7))) {
                if (date.weekday == YMD_now.weekday) {
                  nextMonthWeeklyCount++;
                }
              }

              monthCounts[month] =
                  (monthCounts[month] ?? 0) + nextMonthWeeklyCount;
            }
          }

          print("최종 매주 계산: $month => ${monthCounts[month]}");
        }

        // ====== "한달" 옵션 ======
        else if (options == "한달") {
          int monthlyCount = 0;
          print("1 한달 계산: $month => ${monthCounts[month]}");
          // 한 달에 지정된 날짜를 반복
          if (month == DateTime.now().month) {
            print("2 한달 계산: $month => => ${monthCounts[month]}");
            if (DateTime.now().day >= YMD_now.day) {
              monthlyCount++;
              print("2-1 한달 계산:  $monthlyCount}");
            }
            monthCounts[month] = (monthCounts[month] ?? 0) + monthlyCount;
            print("3 한달 계산: $month => => ${monthCounts[month]}");
          }

          // 다음 달 이상으로 넘어가는 경우
          if (month != DateTime.now().month) {
            print("4 한달 계산: $month => => ${monthCounts[month]}");
            for (; month != DateTime.now().month; month++) {
              if (month > 12) month = 1;
              print("4-1 한달 계산: $month => => ${monthCounts[month]}");
              int nextMonthDay = YMD_now.day;
              if (nextMonthDay <=
                  DateTime(YMD_now.year, month + 1 > 12 ? 1 : month + 1, 0)
                      .day) {
                monthCounts[month] = (monthCounts[month] ?? 0) + 1;
                print("4-3 한달 계산: $month => => ${monthCounts[month]}");
              }
            }
          }

          print("최종 한달 계산: $month => ${monthCounts[month]}");
        } else if (options == "1년") {
          print("1년 $month");
          print("1년 $month ${monthCounts[month]}");
          // 매년 반복 - 현재 달에 추가
          monthCounts[month] = (monthCounts[month] ?? 0) + 1;
          print("1년 2 $month");
          print("1년 2 $month ${monthCounts[month]}");
        } else if (options == "반복 없음") {
          print("반복 없음 처리 중: $month");
          monthCounts[month] =
              (monthCounts[month] ?? 0) + 1; // 값이 없으면 1, 있으면 누적
          print("반복 없음 완료: $month => ${monthCounts[month]}");
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
    print("======spots");
    print(spots);
    return spots;
  }
  // 아니 나 병신인가 월별 달성률은 차트에 보이잖아?

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 1:
        text = 'Jan';
        break;
      case 2:
        text = 'Feb';
        break;
      case 3:
        text = 'Mar';
        break;
      case 4:
        text = 'Apr';
        break;
      case 5:
        text = 'May';
        break;
      case 6:
        text = 'Jun';
        break;
      case 7:
        text = 'Jul';
        break;
      case 8:
        text = 'Aug';
        break;
      case 9:
        text = 'Sep';
        break;
      case 10:
        text = 'Oct';
        break;
      case 11:
        text = 'Nov';
        break;
      case 12:
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
        .where('userid', isEqualTo: UserManager.userId)
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
    // TODO: implement initStatedouble.parse
    count = DateTime.now().month.toDouble() - 1;
    // _updateMonthCount(scheduleCounts2, scheduleCounts);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // const cutOffYValue = 5.0;

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
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Consumer<ColorProvider>(
                            builder: (context, value, child) {
                          var c_size = MediaQuery.of(context).size;
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
                                Stack(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.35,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(60),
                                        color: Colors.white,
                                      ),
                                      child: change_Chart
                                          ? AspectRatio(
                                              aspectRatio: 2,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 15,
                                                  right: 28,
                                                  top: 30,
                                                  bottom: 10,
                                                ),
                                                child: LineChart(
                                                  LineChartData(
                                                    minY: 0,
                                                    maxY: 5,
                                                    lineTouchData:
                                                        const LineTouchData(
                                                            enabled: false),
                                                    lineBarsData: [
                                                      // 추가 데이터
                                                      LineChartBarData(
                                                        spots: const [
                                                          FlSpot(1.0, 0.0),
                                                          FlSpot(2.0, 0.0),
                                                          FlSpot(3.0, 0.0),
                                                          FlSpot(4.0, 0.0),
                                                          FlSpot(5.0, 0.0),
                                                          FlSpot(6.0, 0.0),
                                                          FlSpot(7.0, 0.0),
                                                          FlSpot(8.0, 0.0),
                                                          FlSpot(9.0, 0.0),
                                                          FlSpot(10.0, 0.0),
                                                          FlSpot(11.0, 0.0),
                                                          FlSpot(12.0, 0.0)
                                                        ],
                                                        isCurved: true,
                                                        color: Colors.red,
                                                        barWidth: 4,
                                                        belowBarData:
                                                            BarAreaData(
                                                                show: false),
                                                      ),
                                                      LineChartBarData(
                                                        spots: const [
                                                          FlSpot(1.0, 0.0),
                                                          FlSpot(2.0, 0.0),
                                                          FlSpot(3.0, 0.0),
                                                          FlSpot(4.0, 0.0),
                                                          FlSpot(5.0, 0.0),
                                                          FlSpot(6.0, 0.0),
                                                          FlSpot(7.0, 0.0),
                                                          FlSpot(8.0, 0.0),
                                                          FlSpot(9.0, 0.0),
                                                          FlSpot(10.0, 0.0),
                                                          FlSpot(11.0, 0.0),
                                                          FlSpot(12.0, 0.0)
                                                        ],
                                                        isCurved: true,
                                                        barWidth: 4,
                                                        color: Colors.black,
                                                        dotData:
                                                            const FlDotData(
                                                          show: false,
                                                        ),
                                                      ),
                                                    ],
                                                    titlesData: FlTitlesData(
                                                      show: true,
                                                      topTitles:
                                                          const AxisTitles(
                                                        sideTitles: SideTitles(
                                                            showTitles: false),
                                                      ),
                                                      rightTitles:
                                                          const AxisTitles(
                                                        sideTitles: SideTitles(
                                                            showTitles: false),
                                                      ),
                                                      bottomTitles: AxisTitles(
                                                        axisNameWidget: Text(
                                                          " ${DateTime.now().year}",
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                        axisNameWidget:
                                                            const Text(
                                                          '일정갯수',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        sideTitles: SideTitles(
                                                          showTitles: true,
                                                          interval: 5,
                                                          reservedSize: 40,
                                                          getTitlesWidget:
                                                              (double value,
                                                                  TitleMeta
                                                                      meta) {
                                                            if (value % 5 ==
                                                                0) {
                                                              // 5의 배수인 경우에만 표시
                                                              return Text(
                                                                  value
                                                                      .toInt()
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        15,
                                                                  ));
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
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                left: 15,
                                                right: 28,
                                                top: 30,
                                                bottom: 10,
                                              ),
                                              child: BarChart(
                                                // 작동안하는 바차트
                                                BarChartData(
                                                  maxY: 5,
                                                  minY: 0,
                                                  barGroups: [
                                                    // 추가 데이터
                                                    for (int i = 1; i < 12; i++)
                                                      BarChartGroupData(
                                                        x: i,
                                                        barRods: [
                                                          BarChartRodData(
                                                            toY: 0,
                                                            color: Colors.red,
                                                            width: 6,
                                                          ),
                                                          BarChartRodData(
                                                            toY: 0,
                                                            color: Colors.black,
                                                            width: 6,
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                  titlesData: FlTitlesData(
                                                    show: true,
                                                    topTitles: const AxisTitles(
                                                      sideTitles: SideTitles(
                                                          showTitles: false),
                                                    ),
                                                    rightTitles:
                                                        const AxisTitles(
                                                      sideTitles: SideTitles(
                                                          showTitles: false),
                                                    ),
                                                    bottomTitles: AxisTitles(
                                                      axisNameWidget: Text(
                                                        " ${DateTime.now().year}",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      sideTitles: SideTitles(
                                                        showTitles: true,
                                                        reservedSize: 18,
                                                        interval: 2,
                                                        getTitlesWidget:
                                                            bottomTitleWidgets,
                                                      ),
                                                    ),
                                                    leftTitles: AxisTitles(
                                                      axisNameSize: 20,
                                                      axisNameWidget:
                                                          const Text(
                                                        '일정갯수',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      sideTitles: SideTitles(
                                                        showTitles: true,
                                                        interval: 5,
                                                        reservedSize: 40,
                                                        getTitlesWidget: (double
                                                                value,
                                                            TitleMeta meta) {
                                                          if (value % 5 == 0) {
                                                            return Text(
                                                                value
                                                                    .toInt()
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        15));
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
                                    Positioned(
                                      top: 1.0,
                                      left: 85,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // 빨간색 범례
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 11,
                                                      height: 11,
                                                      color: Colors.red, // 빨간색
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Text('완료된 일정',
                                                        style: TextStyle(
                                                            fontSize: 10)),
                                                  ],
                                                ),
                                                const SizedBox(width: 20),
                                                // 검은색 범례
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 11,
                                                      height: 11,
                                                      color:
                                                          Colors.black, // 검은색
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Text('전체 일정',
                                                        style: TextStyle(
                                                            fontSize: 10)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      // bottom: 1.0,
                                      right: 1.0,
                                      child: FloatingActionButton(
                                        backgroundColor: Colors.white,
                                        onPressed: () {
                                          setState(() {
                                            change_Chart = !change_Chart;
                                          });
                                          print(change_Chart);
                                        },
                                        child: change_Chart
                                            ? Icon(
                                                Icons.bar_chart_outlined,
                                                size: 50,
                                              )
                                            : Icon(
                                                Icons.line_axis_rounded,
                                                size: 50,
                                                // color: Colors.lightBlue[59],
                                              ),
                                        tooltip: 'Add Schedule',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      height:
                                          MediaQuery.of(context).size.height *
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
                                                0.035,
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
                                            "0",
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
                                      height:
                                          MediaQuery.of(context).size.height *
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
                                                0.035,
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
                                                      // _updateMonthCount(
                                                      //     scheduleCounts2,
                                                      //     scheduleCounts);
                                                    });
                                                  },
                                                  icon: Icon(
                                                      Icons.arrow_back_ios)),
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
                                                      // _updateMonthCount(
                                                      //     scheduleCounts2,
                                                      //     scheduleCounts
                                                      //     );
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
                  }
                  // final documents = snapshot.data!.docs;
                  final documents = snapshot.data!.docs;
                  // FlSpot 리스트 생성
                  List<FlSpot> spots = _generateFlSpots(documents);
                  List<FlSpot> spots2 = _generateFlSpots2(documents);
                  List<double> scheduleCounts =
                      spots.map((spot) => spot.y).toList();
                  // print("a10101010101 //${spots2[0].y}");
                  // print("b10101010101 // ${spots[0].y}");
                  double totalSchedules =
                      scheduleCounts.reduce((a, b) => a + b);
                  List<double> scheduleCounts2 =
                      spots2.map((spot) => spot.y).toList();
/////////////////////////// 이번 달 퍼센트 구하기 =/////
                  int value21 = count.toInt();
                  double value2 = scheduleCounts2[value21];
                  double value = scheduleCounts[value21];

                  if (value > 0) {
                    monthCount1 = (value2 / value) * 100;
                  } else {
                    monthCount1 = 0.0;
                  }

                  monthCount1 = double.parse(monthCount1.toStringAsFixed(1));
                  ///////////////////////////
                  // _updateMonthCount(scheduleCounts2, scheduleCounts);
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
                              Stack(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      color: Colors.white,
                                    ),
                                    child: change_Chart
                                        ? AspectRatio(
                                            aspectRatio: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 15,
                                                right: 28,
                                                top: 30,
                                                bottom: 10,
                                              ),
                                              child: LineChart(
                                                LineChartData(
                                                  minY: 0,
                                                  maxY: maxYValue + 5,
                                                  lineTouchData:
                                                      const LineTouchData(
                                                          enabled: false),
                                                  lineBarsData: [
                                                    // 추가 데이터
                                                    LineChartBarData(
                                                      spots: spots2,
                                                      isCurved: true,
                                                      color: Colors.red,
                                                      barWidth: 4,
                                                      belowBarData: BarAreaData(
                                                          show: false),
                                                    ),
                                                    LineChartBarData(
                                                      spots: spots,
                                                      isCurved: true,
                                                      barWidth: 4,
                                                      color: Colors.black,
                                                      dotData: const FlDotData(
                                                        show: false,
                                                      ),
                                                    ),
                                                  ],
                                                  titlesData: FlTitlesData(
                                                    show: true,
                                                    topTitles: const AxisTitles(
                                                      sideTitles: SideTitles(
                                                          showTitles: false),
                                                    ),
                                                    rightTitles:
                                                        const AxisTitles(
                                                      sideTitles: SideTitles(
                                                          showTitles: false),
                                                    ),
                                                    bottomTitles: AxisTitles(
                                                      axisNameWidget: Text(
                                                        " ${DateTime.now().year}",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                      axisNameWidget:
                                                          const Text(
                                                        '일정갯수',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      sideTitles: SideTitles(
                                                        showTitles: true,
                                                        interval: 5,
                                                        reservedSize: 40,
                                                        getTitlesWidget: (double
                                                                value,
                                                            TitleMeta meta) {
                                                          if (value % 5 == 0) {
                                                            // 5의 배수인 경우에만 표시
                                                            return Text(
                                                                value
                                                                    .toInt()
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 15,
                                                                ));
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
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                              right: 28,
                                              top: 30,
                                              bottom: 10,
                                            ),
                                            child: BarChart(
                                              // 작동안하는 바차트
                                              BarChartData(
                                                maxY: maxYValue + 5,
                                                minY: 0,
                                                barGroups: [
                                                  // 추가 데이터
                                                  for (int i = 1;
                                                      i < spots2.length;
                                                      i++)
                                                    BarChartGroupData(
                                                      x: i,
                                                      barRods: [
                                                        BarChartRodData(
                                                          toY: spots2[i - 1].y,
                                                          color: Colors.red,
                                                          width: 6,
                                                        ),
                                                        BarChartRodData(
                                                          toY: spots[i - 1].y,
                                                          color: Colors.black,
                                                          width: 6,
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                                titlesData: FlTitlesData(
                                                  show: true,
                                                  topTitles: const AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false),
                                                  ),
                                                  rightTitles: const AxisTitles(
                                                    sideTitles: SideTitles(
                                                        showTitles: false),
                                                  ),
                                                  bottomTitles: AxisTitles(
                                                    axisNameWidget: Text(
                                                      " ${DateTime.now().year}",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    sideTitles: SideTitles(
                                                      showTitles: true,
                                                      reservedSize: 18,
                                                      interval: 2,
                                                      getTitlesWidget:
                                                          bottomTitleWidgets,
                                                    ),
                                                  ),
                                                  leftTitles: AxisTitles(
                                                    axisNameSize: 20,
                                                    axisNameWidget: const Text(
                                                      '일정갯수',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    sideTitles: SideTitles(
                                                      showTitles: true,
                                                      interval: 5,
                                                      reservedSize: 40,
                                                      getTitlesWidget:
                                                          (double value,
                                                              TitleMeta meta) {
                                                        if (value % 5 == 0) {
                                                          return Text(
                                                              value
                                                                  .toInt()
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      15));
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
                                  Positioned(
                                    top: 1.0,
                                    left: 85,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // 빨간색 범례
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 11,
                                                    height: 11,
                                                    color: Colors.red, // 빨간색
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text('완료된 일정',
                                                      style: TextStyle(
                                                          fontSize: 10)),
                                                ],
                                              ),
                                              const SizedBox(width: 20),
                                              // 검은색 범례
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 11,
                                                    height: 11,
                                                    color: Colors.black, // 검은색
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text('전체 일정',
                                                      style: TextStyle(
                                                          fontSize: 10)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    // bottom: 1.0,
                                    right: 1.0,
                                    child: FloatingActionButton(
                                      backgroundColor: Colors.white,
                                      onPressed: () {
                                        setState(() {
                                          change_Chart = !change_Chart;
                                        });
                                        print(change_Chart);
                                      },
                                      child: change_Chart
                                          ? Icon(
                                              Icons.bar_chart_outlined,
                                              size: 50,
                                            )
                                          : Icon(
                                              Icons.line_axis_rounded,
                                              size: 50,
                                              // color: Colors.lightBlue[59],
                                            ),
                                      tooltip: 'Add Schedule',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
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
                                              0.035,
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
                                          // null 또는 0 체크
                                          totalSchedules == 0 ||
                                                  totalSchedules == null ||
                                                  totalSchedules2 == null
                                              ? "0%"
                                              : "${((totalSchedules2 / totalSchedules) * 100).toStringAsFixed(1)}%",
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
                                              0.035,
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
