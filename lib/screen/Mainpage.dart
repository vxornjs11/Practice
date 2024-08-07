import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice_01_app/main.dart';
import 'package:practice_01_app/provinder/color_provinder.dart';
import 'package:practice_01_app/provinder/scheduleCount_provinder.dart';
import 'package:practice_01_app/screen/Set_schedule.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:table_calendar/table_calendar.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Mainpage> {
  List<DocumentSnapshot> combinedResults = [];
  late DateTime selectedDate_;
  bool _isMounted = false;
  final List<String> week = ["월", "화", "수", "목", "금", "토", "일"];
  late int ListCount = 0;
  final today = DateTime.now();
  late bool delete_list = false;
  late bool Calender_switch = false;
  List<Map<String, dynamic>> list = [];
  // Map<DateTime, List<String>> _events = {};
  late Map<DateTime, List<String>> _events;

  final firebase = FirebaseFirestore.instance;
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  @override
  void initState() {
    // TODO: implement initState
    _isMounted = true;
    selectedDate_ = DateTime.now();
    invitaionList();
    _events = {};
    _loadEvents();
    _combineStreams();
    // 우측 상단이나 왼쪽에서 설정 칸 만들어서 알림 설정 같은거
    // 아니면 아래 빈칸에 3개 만들어서 메인화면, 설정, 프로필? 달력? 이렇게
    super.initState();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Stream<List<DocumentSnapshot>> _combineStreams() {
    // "매일" 옵션 문서 가져오기
    Stream<QuerySnapshot> dailyStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('option', isEqualTo: "매일")
        .where('userid', isEqualTo: UserManager.userId)
        .snapshots();

    // "주중" 옵션 문서 가져오기 (월요일부터 금요일까지)
    Stream<QuerySnapshot> weekdayStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('option', isEqualTo: "주중")
        .where('userid', isEqualTo: UserManager.userId)
        .where('option_day', arrayContainsAny: [
      DateFormat('E', 'ko_KO').format(today)
    ]).snapshots();

    // "주말" 옵션 문서 가져오기 (토요일과 일요일)
    Stream<QuerySnapshot> weekendStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('option', isEqualTo: "주말")
        .where('userid', isEqualTo: UserManager.userId)
        .where('option_day', arrayContainsAny: [
      DateFormat('E', 'ko_KO').format(today)
    ]).snapshots();

    // "한달" 옵션 문서 가져오기 (현재 달)
    Stream<QuerySnapshot> monthlyStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('option', isEqualTo: "한달")
        .where('userid', isEqualTo: UserManager.userId)
        .where('day', isEqualTo: today.day)
        .snapshots();

    // "1년" 옵션 문서 가져오기 (현재 연도)
    Stream<QuerySnapshot> yearlyStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('option', isEqualTo: "1년")
        .where('userid', isEqualTo: UserManager.userId)
        .where('month', isEqualTo: today.month)
        .where('day', isEqualTo: today.day)
        .snapshots();

    // 날짜와 일치하는 문서 가져오기 (특정 날짜)
    Stream<QuerySnapshot> dateStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('userid', isEqualTo: UserManager.userId)
        .where('day', isEqualTo: today.day)
        .where('month', isEqualTo: today.month)
        .where('year', isEqualTo: today.year)
        .snapshots();

    // 모든 스트림을 결합하여 반환
    return Rx.combineLatest6(
      dailyStream,
      weekdayStream,
      weekendStream,
      monthlyStream,
      yearlyStream,
      dateStream,
      (QuerySnapshot a, QuerySnapshot b, QuerySnapshot c, QuerySnapshot d,
          QuerySnapshot e, QuerySnapshot f) {
        List<DocumentSnapshot> combinedDocs = [
          ...a.docs,
          ...b.docs,
          ...c.docs,
          ...d.docs,
          ...e.docs,
          ...f.docs
        ];
        return combinedDocs;
      },
    );
  }

  Stream<List<DocumentSnapshot>> select_combineStreams() {
    // "매일" 옵션 문서 가져오기
    // List<String> weekendDays = ['토', '일'];
    Stream<QuerySnapshot> dailyStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('option', isEqualTo: "매일")
        .where('userid', isEqualTo: UserManager.userId)
        .snapshots();

    // "주중" 옵션 문서 가져오기 (월요일부터 금요일까지)
    Stream<QuerySnapshot> weekdayStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('option', isEqualTo: "주중")
        .where('userid', isEqualTo: UserManager.userId)
        .where('option_day', arrayContainsAny: [
      DateFormat('E', 'ko_KO').format(selectedDate_)
    ]).snapshots();

    // "주말" 옵션 문서 가져오기 (토요일과 일요일)
    Stream<QuerySnapshot> weekendStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('option', isEqualTo: "주말")
        .where('userid', isEqualTo: UserManager.userId)
        .where('option_day', arrayContainsAny: [
      DateFormat('E', 'ko_KO').format(selectedDate_)
    ]).snapshots();

    // "한달" 옵션 문서 가져오기 (현재 달)
    Stream<QuerySnapshot> monthlyStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('userid', isEqualTo: UserManager.userId)
        .where('option', isEqualTo: "한달")
        .where('day', isEqualTo: selectedDate_.day)
        .snapshots();

    // "1년" 옵션 문서 가져오기 (현재 연도)
    Stream<QuerySnapshot> yearlyStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('userid', isEqualTo: UserManager.userId)
        .where('option', isEqualTo: "1년")
        .where('month', isEqualTo: selectedDate_.month)
        .where('day', isEqualTo: selectedDate_.day)
        .snapshots();

    // 날짜와 일치하는 문서 가져오기 (특정 날짜)
    Stream<QuerySnapshot> dateStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('userid', isEqualTo: UserManager.userId)
        .where('day', isEqualTo: selectedDate_.day)
        .where('month', isEqualTo: selectedDate_.month)
        .where('year', isEqualTo: selectedDate_.year)
        .snapshots();

    // 모든 스트림을 결합하여 반환
    return Rx.combineLatest6(
      dailyStream,
      weekdayStream,
      weekendStream,
      monthlyStream,
      yearlyStream,
      dateStream,
      (QuerySnapshot a, QuerySnapshot b, QuerySnapshot c, QuerySnapshot d,
          QuerySnapshot e, QuerySnapshot f) {
        List<DocumentSnapshot> combinedDocs = [
          ...a.docs,
          ...b.docs,
          ...c.docs,
          ...d.docs,
          ...e.docs,
          ...f.docs
        ];
        return combinedDocs;
      },
    );
  }

  Future<void> _loadEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Calender')
        .where('userid', isEqualTo: UserManager.userId)
        .get();
    final events = <DateTime, List<String>>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = DateTime(data['year'], data['month'], data['day']);
      final event = data['Schedule'];
      final option = data['option'];
      final optionDay =
          data.containsKey('option_day') ? data['option_day'] : null;

      _addEventToMap(events, date, event, option, optionDay);
    }

    setState(() {
      _events = events;
      // print(_events);
    });

    // print(_events); // 이벤트 로드 결과 확인
  }

  void _addEventToMap(Map<DateTime, List<String>> events, DateTime date,
      String event, String option, List<dynamic> optionDay) {
    // print("optionDay");
    // print(optionDay as List<String>);
    // print("optionDay");
    switch (option) {
      case '매일':
        for (var i = 0; i < 365; i++) {
          _addEvent(events, date.add(Duration(days: i)), event);
        }
        break;
      case '주중':
        for (var i = 0; i < 365; i++) {
          final currentDate = date.add(Duration(days: i));
          if ((currentDate.weekday >= 1 && currentDate.weekday <= 5)) {
            _addEvent(events, currentDate, event);
          }
        }
        break;
      case '주말':
        for (var i = 0; i < 365; i++) {
          final currentDate = date.add(Duration(days: i));
          if ((currentDate.weekday == 6 || currentDate.weekday == 7)) {
            _addEvent(events, currentDate, event);

            // 365일 돌리는건데 그중에
          }
        }
        break;

      case '한달':
        for (var i = 0; i < 12; i++) {
          _addEvent(
              events, DateTime(date.year, date.month + i, date.day), event);
        }
        break;
      case '1년':
        for (var i = 0; i < 10; i++) {
          _addEvent(
              events, DateTime(date.year + i, date.month, date.day), event);
        }
        break;
      default:
        _addEvent(events, date, event);
        break;
    }
  }

  void _addEvent(
      Map<DateTime, List<String>> events, DateTime date, String event) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (events.containsKey(dateOnly)) {
      events[dateOnly]!.add(event);
    } else {
      events[dateOnly] = [event];
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate_ = selectedDay;
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // 시간을 제거한 날짜만 사용
    final dateOnly = DateTime(day.year, day.month, day.day);
    return _events[dateOnly] ?? [];
  }

  Future<void> invitaionList() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Calender')
        .where('day', isEqualTo: today.day)
        .where('month', isEqualTo: today.month)
        .where('year', isEqualTo: today.year)
        .get();
    if (_isMounted) {
      setState(() {
        ListCount = querySnapshot.docs.length;
      });
    }
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      this.selectedDate = selectedDate;
      selectedDate_ = selectedDate;
      // print("selectedDate$selectedDate");
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
              child: Consumer<ColorProvider>(builder: (context, value, child) {
                return Container(
                  width: c_size.width * 1,
                  height: c_size.height * 0.8,
                  decoration: BoxDecoration(
                    color: value.backgroundColor,
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
                                Consumer<ScheduleCountProvider>(
                                  builder: (context, value, child) {
                                    return Center(
                                        child:
                                            TitleText("${value.count}건", 24));
                                  },
                                ),
                                SizedBox(
                                  width: c_size.width * 0.4,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      Calender_switch = !Calender_switch;
                                    });
                                  },
                                  icon: const Icon(Icons.calendar_month),
                                ),
                              ],
                            ),
                          ),
                          Calender_switch == false
                              ? Expanded(
                                  child: StreamBuilder<List<DocumentSnapshot>>(
                                    stream: _combineStreams(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }

                                      if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return Center(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Set_schedul(
                                                    option: '반복 안 함',
                                                    selectedDate_:
                                                        DateTime.now(),
                                                    schedule_Write: "",
                                                    selectedHour: 0,
                                                    selectedMinute: 0,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text("일정을 등록하세요"),
                                          ),
                                        );
                                      }

                                      // 두 쿼리의 결과 병합
                                      List<DocumentSnapshot> documents =
                                          snapshot.data!;
                                      // context
                                      //     .read<ScheduleCountProvider>()
                                      //     .changeScheduleCount(
                                      //         initialCount: documents.length);
                                      // 필요시 중복 문서 제거
                                      final uniqueDocuments = {
                                        for (var doc in documents) doc.id: doc
                                      }.values.toList();
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        context
                                            .read<ScheduleCountProvider>()
                                            .changeScheduleCount(
                                                initialCount:
                                                    uniqueDocuments.length);
                                      });
                                      // 시간과 분을 기준으로 정렬
                                      uniqueDocuments.sort((a, b) {
                                        final dataA =
                                            a.data() as Map<String, dynamic>;
                                        final dataB =
                                            b.data() as Map<String, dynamic>;

                                        final scheduleHourA =
                                            dataA['hour'] ?? 0;
                                        final scheduleMinuteA =
                                            dataA['minit'] ?? 0;
                                        final scheduleTimeA =
                                            scheduleHourA * 60 +
                                                scheduleMinuteA;

                                        final scheduleHourB =
                                            dataB['hour'] ?? 0;
                                        final scheduleMinuteB =
                                            dataB['minit'] ?? 0;
                                        final scheduleTimeB =
                                            scheduleHourB * 60 +
                                                scheduleMinuteB;

                                        return scheduleTimeA
                                            .compareTo(scheduleTimeB);
                                      });

                                      return ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: uniqueDocuments.length,
                                        itemBuilder: (context, index) {
                                          final doc = uniqueDocuments[index];
                                          final data = doc.data()
                                              as Map<String, dynamic>;
                                          DateTime now = DateTime.now();
                                          DateTime scheduleTime = DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            data['hour'] ?? 0,
                                            data['minit'] ?? 0,
                                          );
                                          bool showButton = false;
                                          if (data['dates'] != null &&
                                              data['dates'].isNotEmpty) {
                                            DateTime storedDate =
                                                (data['dates'][0] as Timestamp)
                                                    .toDate();
                                            DateTime ymdStoredDate = DateTime(
                                                storedDate.year,
                                                storedDate.month,
                                                storedDate.day);

                                            if (ymdStoredDate ==
                                                DateTime(now.year, now.month,
                                                    now.day)) {
                                              showButton = true;
                                            }
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: GestureDetector(
                                              onDoubleTap: () {
                                                // 파이어베이스에서 문서 삭제
                                                setState(() {
                                                  delete_list = !delete_list;
                                                });
                                              },
                                              child: delete_list == false
                                                  ? Container(
                                                      height:
                                                          c_size.height * 0.1,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 255, 255, 255),
                                                      ),
                                                      child: DateTime.now()
                                                              .isBefore(
                                                                  scheduleTime)
                                                          ? ListTile(
                                                              title: Text(
                                                                data['Schedule'] ??
                                                                    'No Schedule',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            25),
                                                              ),
                                                              subtitle: Text(
                                                                'Date: ${data['option'] ?? 'No Date'}\nTime: ${data['hour'] ?? 'No Hour'}:${data['minit'] ?? 'No Minute'}',
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                              ),
                                                            )
                                                          : ListTile(
                                                              title: Text(
                                                                data['Schedule'] ??
                                                                    'No Schedule',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            25),
                                                              ),
                                                              subtitle: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    'Date: ${data['option'] ?? 'No Date'}\nTime: ${data['hour'] ?? 'No Hour'}:${data['minit'] ?? 'No Minute'}',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                  showButton
                                                                      ? Text(
                                                                          "축하합니다")
                                                                      : Container(
                                                                          width:
                                                                              80,
                                                                          height:
                                                                              30,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                          ),
                                                                          child:
                                                                              ElevatedButton(
                                                                            style:
                                                                                ElevatedButton.styleFrom(
                                                                              backgroundColor: Colors.white,
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              DateTime YMD_now;
                                                                              YMD_now = DateTime(now.year, now.month, now.day);
                                                                              firebase.collection("Calender").doc(uniqueDocuments[index].id).update({
                                                                                'dates': FieldValue.arrayUnion([
                                                                                  YMD_now
                                                                                ])
                                                                              });
                                                                              print("${uniqueDocuments[index].id}");
                                                                              print(YMD_now);
                                                                            },
                                                                            child:
                                                                                Text(
                                                                              "완료",
                                                                              style: TextStyle(fontSize: 18),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                ],
                                                              ),
                                                            ),
                                                    )
                                                  : Container(
                                                      height:
                                                          c_size.height * 0.1,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 255, 255, 255),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width:
                                                                c_size.width *
                                                                    0.85,
                                                            child: ListTile(
                                                              title: Text(
                                                                data['Schedule'] ??
                                                                    'No Schedule',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            25),
                                                              ),
                                                              subtitle: Text(
                                                                'Date: ${data['year'] ?? 'No Date'}\nTime: ${data['hour'] ?? 'No Hour'}:${data['minit'] ?? 'No Minute'}',
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                              ),
                                                            ),
                                                          ),
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                width: c_size
                                                                        .width *
                                                                    0.1,
                                                                // height:
                                                                //     c_size.height * 0.1,
                                                                child:
                                                                    IconButton(
                                                                        color: Colors
                                                                            .red,
                                                                        onPressed:
                                                                            () {
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('Calender')
                                                                              .doc(doc.id)
                                                                              .delete()
                                                                              .then((_) {
                                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('일정이 삭제되었습니다')));
                                                                          }).catchError((error) {
                                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('일정 삭제 실패: $error')));
                                                                          });

                                                                          invitaionList();
                                                                          _loadEvents();
                                                                        },
                                                                        icon: const Icon(
                                                                            Icons.close)),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Container(
                                    width: c_size.width * 1,
                                    height: c_size.height * 0.7,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        color: Colors.grey.shade200),
                                    child: Column(
                                      children: [
                                        TableCalendar(
                                          firstDay: DateTime.utc(2010, 10, 16),
                                          lastDay: DateTime.utc(2030, 3, 14),
                                          focusedDay: selectedDate_,
                                          selectedDayPredicate: (date) =>
                                              isSameDay(selectedDate_, date),
                                          onDaySelected: _onDaySelected,
                                          eventLoader: _getEventsForDay,
                                          calendarBuilders: CalendarBuilders(
                                            markerBuilder:
                                                (context, date, events) {
                                              if (events.isNotEmpty) {
                                                return Positioned(
                                                  right: 1,
                                                  bottom: 1,
                                                  child: _buildEventsMarker(
                                                      date, events),
                                                );
                                              }
                                              return null;
                                            },
                                          ),
                                          // calendarStyle: CalendarStyle(
                                          //   todayDecoration: BoxDecoration(
                                          //     color: Colors.blue,
                                          //     shape: BoxShape.circle,
                                          //   ),
                                          //   selectedDecoration: BoxDecoration(
                                          //     color: Colors.red,
                                          //     shape: BoxShape.circle,
                                          //   ),
                                          //   markerDecoration: BoxDecoration(
                                          //     color: Colors.orange,
                                          //     shape: BoxShape.circle,
                                          //   ),
                                          // ),
                                        ),
                                        // Expanded(
                                        //   child: ListView(
                                        //     children: _getEventsForDay(
                                        //             selectedDate_)
                                        //         .map((event) => Padding(
                                        //               padding:
                                        //                   const EdgeInsets.all(
                                        //                       4.0),
                                        //               child: Container(
                                        //                 height:
                                        //                     c_size.height * 0.1,
                                        //                 // width: c_size.width * 0.1,
                                        //                 decoration: BoxDecoration(
                                        //                   borderRadius:
                                        //                       BorderRadius
                                        //                           .circular(10.0),
                                        //                   color: const Color
                                        //                       .fromARGB(
                                        //                       255, 255, 255, 255),
                                        //                 ),
                                        //                 child: ListTile(
                                        //                   title: Text(
                                        //                       event.toString(),
                                        //                       overflow:
                                        //                           TextOverflow
                                        //                               .ellipsis,
                                        //                       style:
                                        //                           const TextStyle(
                                        //                               fontSize:
                                        //                                   25)),
                                        //                 ),
                                        //               ),
                                        //             ))
                                        //         .toList(),
                                        //   ),
                                        // ),
                                        Expanded(
                                          child: StreamBuilder<
                                              List<DocumentSnapshot>>(
                                            stream: select_combineStreams(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              }

                                              if (!snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return Center(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Set_schedul(
                                                            option: '반복 안 함',
                                                            selectedDate_:
                                                                DateTime.now(),
                                                            schedule_Write: "",
                                                            selectedHour: 0,
                                                            selectedMinute: 0,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child:
                                                        const Text("일정을 등록하세요"),
                                                  ),
                                                );
                                              }

                                              // 두 쿼리의 결과 병합
                                              List<DocumentSnapshot> documents =
                                                  snapshot.data!;
                                              // 필요시 중복 문서 제거
                                              final uniqueDocuments = {
                                                for (var doc in documents)
                                                  doc.id: doc
                                              }.values.toList();

                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                context
                                                    .read<
                                                        ScheduleCountProvider>()
                                                    .changeScheduleCount(
                                                        initialCount:
                                                            uniqueDocuments
                                                                .length);
                                              });

                                              return ListView.builder(
                                                padding: EdgeInsets.zero,
                                                itemCount:
                                                    uniqueDocuments.length,
                                                itemBuilder: (context, index) {
                                                  final doc =
                                                      uniqueDocuments[index];
                                                  final data = doc.data()
                                                      as Map<String, dynamic>;

                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    child: GestureDetector(
                                                        onDoubleTap: () {
                                                          // 파이어베이스에서 문서 삭제
                                                          setState(() {
                                                            delete_list =
                                                                !delete_list;
                                                          });
                                                        },
                                                        child:
                                                            delete_list == false
                                                                ? Container(
                                                                    height:
                                                                        c_size.height *
                                                                            0.1,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                      color: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          255),
                                                                    ),
                                                                    child:
                                                                        ListTile(
                                                                      title:
                                                                          Text(
                                                                        data['Schedule'] ??
                                                                            'No Schedule',
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                25),
                                                                      ),
                                                                      subtitle:
                                                                          Text(
                                                                        'Date: ${data['option'] ?? 'No Date'}\nTime: ${data['hour'] ?? 'No Hour'}:${data['minit'] ?? 'No Minute'}',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    height:
                                                                        c_size.height *
                                                                            0.1,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                      color: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          255),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              c_size.width * 0.85,
                                                                          child:
                                                                              ListTile(
                                                                            title:
                                                                                Text(
                                                                              data['Schedule'] ?? 'No Schedule',
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(fontSize: 25),
                                                                            ),
                                                                            subtitle:
                                                                                Text(
                                                                              'Date: ${data['year'] ?? 'No Date'}\nTime: ${data['hour'] ?? 'No Hour'}:${data['minit'] ?? 'No Minute'}',
                                                                              style: const TextStyle(fontSize: 12),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            SizedBox(
                                                                              width: c_size.width * 0.1,
                                                                              // height:
                                                                              //     c_size.height * 0.1,
                                                                              child: IconButton(
                                                                                  color: Colors.red,
                                                                                  onPressed: () {
                                                                                    FirebaseFirestore.instance.collection('Calender').doc(doc.id).delete().then((_) {
                                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('일정이 삭제되었습니다')));
                                                                                    }).catchError((error) {
                                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('일정 삭제 실패: $error')));
                                                                                    });

                                                                                    invitaionList();
                                                                                    _loadEvents();
                                                                                  },
                                                                                  icon: const Icon(Icons.close)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        )
                                      ],
                                    ),
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
                );
              }),
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

  Widget _buildEventsMarker(DateTime date, List events) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
} //
