import 'dart:ffi';
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
  // ignore: non_constant_identifier_names
  late int ListCount = 0;
  final today = DateTime.now();
  // ignore: non_constant_identifier_names
  late bool delete_list = false;
  // ignore: non_constant_identifier_names
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
    DateTime now = DateTime.now();

    Stream<QuerySnapshot> dailyStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('option', isEqualTo: "매일")
        .where('userid', isEqualTo: UserManager.userId)
        // .where('year', isLessThanOrEqualTo: now.year) // 연도가 현재 연도보다 크지 않음
        // .where('month', isLessThanOrEqualTo: now.month) // 월이 현재 월보다 크지 않음
        // .where('day', isLessThanOrEqualTo: now.day) // 일이 현재 일보다 크지 않음
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

    // "매주" 옵션 문서 가져오기 (특정 선택일을 주마다 반복)
    Stream<QuerySnapshot> weeklyStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('option', isEqualTo: "매주") // "매주" 옵션만 가져오기
        .where('userid', isEqualTo: UserManager.userId) // 사용자 필터
        .where('option_day',
            arrayContains: DateFormat('E', 'ko_KO').format(today)) // 현재 요일 일치
        .snapshots();

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
    return Rx.combineLatest7(
      dailyStream,
      weekdayStream,
      weekendStream,
      monthlyStream,
      yearlyStream,
      dateStream,
      weeklyStream, // 매주 옵션 스트림 추가
      (
        QuerySnapshot a,
        QuerySnapshot b,
        QuerySnapshot c,
        QuerySnapshot d,
        QuerySnapshot e,
        QuerySnapshot f,
        QuerySnapshot g, // 매주 옵션 스트림
      ) {
        // 모든 스트림의 문서를 결합
        List<DocumentSnapshot> combinedDocs = [
          ...a.docs,
          ...b.docs,
          ...c.docs,
          ...d.docs,
          ...e.docs,
          ...f.docs,
          ...g.docs, // 매주 옵션 문서 추가
        ];

        // 현재보다 미래인 날짜를 제외하는 필터링 작업
        List<DocumentSnapshot> filteredDocs = combinedDocs.where((doc) {
          DateTime dataDate = DateTime(doc["year"], doc["month"], doc["day"]);
          return dataDate.isBefore(now) || dataDate.isAtSameMomentAs(now);
        }).toList();

        return filteredDocs;
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

    // "매주" 옵션 문서 가져오기 (특정 선택일을 주마다 반복)
    Stream<QuerySnapshot> weeklyStream = FirebaseFirestore.instance
        .collection('Calender')
        .where('option', isEqualTo: "매주") // "매주" 옵션만 가져오기
        .where('userid', isEqualTo: UserManager.userId) // 사용자 필터
        .where('option_day',
            arrayContains:
                DateFormat('E', 'ko_KO').format(selectedDate_)) // 현재 요일 일치
        .snapshots();

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
    return Rx.combineLatest7(
      dailyStream,
      weekdayStream,
      weekendStream,
      monthlyStream,
      yearlyStream,
      dateStream,
      weeklyStream, // 매주 옵션 스트림 추가
      (
        QuerySnapshot a,
        QuerySnapshot b,
        QuerySnapshot c,
        QuerySnapshot d,
        QuerySnapshot e,
        QuerySnapshot f,
        QuerySnapshot g, // 매주 옵션 스트림
      ) {
        // 모든 스트림의 문서를 결합
        List<DocumentSnapshot> combinedDocs = [
          ...a.docs,
          ...b.docs,
          ...c.docs,
          ...d.docs,
          ...e.docs,
          ...f.docs,
          ...g.docs, // 매주 옵션 문서 추가
        ];

        //  DateTime now = DateTime.now();
        // 현재보다 미래인 날짜를 제외하는 필터링 작업
        List<DocumentSnapshot> filteredDocs = combinedDocs.where((doc) {
          DateTime dataDate = DateTime(doc["year"], doc["month"], doc["day"]);
          return dataDate.isBefore(selectedDate_) ||
              dataDate.isAtSameMomentAs(selectedDate_);
        }).toList();

        return filteredDocs;
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

      case '매주':
        if (optionDay.isNotEmpty && optionDay.length == 1) {
          // 선택된 단일 요일을 weekday로 변환
          final selectedWeekday = _convertDayToWeekday(optionDay.first);

          if (selectedWeekday != null) {
            DateTime currentDate = date;

            // 시작 날짜가 선택한 요일에 맞지 않으면, 해당 요일로 이동
            while (currentDate.weekday != selectedWeekday) {
              currentDate = currentDate.add(const Duration(days: 1));
            }

            // 매주 반복
            for (var i = 0; i < 52; i++) {
              // 최대 52주
              _addEvent(events, currentDate, event);
              currentDate =
                  currentDate.add(const Duration(days: 7)); // 다음 주로 이동
            }
          }
        }
        break;

      default:
        _addEvent(events, date, event);
        break;
    }
  }

// 요일 이름을 weekday 값으로 변환
  int? _convertDayToWeekday(String day) {
    switch (day) {
      case '월':
        return DateTime.monday;
      case '화':
        return DateTime.tuesday;
      case '수':
        return DateTime.wednesday;
      case '목':
        return DateTime.thursday;
      case '금':
        return DateTime.friday;
      case '토':
        return DateTime.saturday;
      case '일':
        return DateTime.sunday;
      default:
        return null; // 잘못된 입력 처리
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

  // ignore: slash_for_doc_comments
  /** 
     * titleText : 텍스트 내용 입력 
     * Size : 폰트 사이즈 double값 넣을것.
     * FontWeight.bold
    */
  // ignore: non_constant_identifier_names
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
    var cSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: cSize.height * 0.03,
            ),
            SizedBox(
              width: cSize.width * 1,
              height: cSize.height * 0.06,
              child: Row(
                children: [
                  SizedBox(
                    width: cSize.width * 1,
                    height: cSize.height * 0.05,
                    child: ListView.builder(
                        // 여기 오늘이 몇 요일인지 표시해주면 좋을듯?
                        // 빨간색 동그라미 띄우거나 아니면 글자 색을 바꾸거나.
                        scrollDirection: Axis.horizontal,
                        itemCount: week.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Consumer<ColorProvider>(
                                builder: (context, value, child) {
                              return Container(
                                // color: Colors.white,
                                decoration: BoxDecoration(
                                  color: week[index] == formattedWeekday
                                      ? value.backgroundColor
                                      : Colors.white, // 색 지정.
                                  border: Border.all(
                                    color: Colors.black, // 원하는 색상을 지정
                                    width: 1.0, // 원하는 선의 두께를 지정
                                  ),
                                ),
                                width: cSize.width * 0.135,
                                height: cSize.height * 0.1,
                                child: Text(
                                  week[index],
                                  style: TextStyle(
                                      color: week[index] == formattedWeekday
                                          ? Colors.red
                                          : Colors.black),
                                ),
                              );
                            }),
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
                  width: cSize.width * 1,
                  height: cSize.height * 0.85,
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
                                  width: cSize.width * 0.4,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      Calender_switch = !Calender_switch;
                                      // print("lldl");
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
                                                    isCheck: false,
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

                                      // print(uniqueDocuments);
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
                                          // print(data);
                                          // print(DateTime(data["year"],
                                          //     data["month"], data["day"]));
                                          // DateTime(data["year"],data["month"],data["day"]);
                                          // if (data[""])
                                          DateTime scheduleTime = DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            data['hour'] ?? 0,
                                            data['minit'] ?? 0,
                                          );
                                          bool showButton = false;
                                          DateTime ymdNow = DateTime(
                                              now.year, now.month, now.day);
                                          if (data['dates'] != null &&
                                              data['dates'].isNotEmpty) {
                                            for (var timestamp
                                                in data['dates']) {
                                              DateTime storedDate =
                                                  (timestamp as Timestamp)
                                                      .toDate();
                                              DateTime ymdStoredDate = DateTime(
                                                storedDate.year,
                                                storedDate.month,
                                                storedDate.day,
                                              );

                                              if (ymdStoredDate == ymdNow) {
                                                showButton = true;
                                                break;
                                              }
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
                                                          cSize.height * 0.1,
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
                                                              subtitle: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                          Icons
                                                                              .timer,
                                                                          size:
                                                                              16),
                                                                      const SizedBox(
                                                                          width:
                                                                              5),
                                                                      Text(
                                                                        '${data['hour'] ?? 'No Hour'}:${data['minit'] ?? 'No Minute'}',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                          Icons
                                                                              .restore_rounded,
                                                                          size:
                                                                              16),
                                                                      const SizedBox(
                                                                          width:
                                                                              5),
                                                                      Text(
                                                                        '${data['option'] ?? 'No Date'}',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
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
                                                                  Row(
                                                                    children: [
                                                                      Column(
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              const Icon(Icons.timer, size: 16),
                                                                              const SizedBox(width: 5),
                                                                              Text(
                                                                                '${data['hour'] ?? 'No Hour'}:${data['minit'] ?? 'No Minute'}',
                                                                                style: const TextStyle(fontSize: 12),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              const Icon(Icons.restore_rounded, size: 16),
                                                                              const SizedBox(width: 5),
                                                                              Text(
                                                                                '${data['option'] ?? 'No Date'}',
                                                                                style: const TextStyle(fontSize: 12),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  showButton
                                                                      ? const Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Icon(
                                                                              Icons.check,
                                                                              color: Colors.green,
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              width: 75,
                                                                              height: 30,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                              ),
                                                                              child: ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Colors.white,
                                                                                ),
                                                                                onPressed: () {
                                                                                  DateTime ymdNow;
                                                                                  ymdNow = DateTime(now.year, now.month, now.day);
                                                                                  firebase.collection("Calender").doc(uniqueDocuments[index].id).update({
                                                                                    'dates': FieldValue.arrayUnion([
                                                                                      ymdNow
                                                                                    ])
                                                                                  });
                                                                                  // print("${uniqueDocuments[index].id}");
                                                                                  // print(ymdNow);
                                                                                },
                                                                                child: const Text(
                                                                                  "완료",
                                                                                  style: TextStyle(fontSize: 13.5),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                ],
                                                              ),
                                                            ),
                                                    )
                                                  : Container(
                                                      height:
                                                          cSize.height * 0.1,
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
                                                          SizedBox(
                                                            width: cSize.width *
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
                                                              subtitle: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                          Icons
                                                                              .timer,
                                                                          size:
                                                                              16),
                                                                      const SizedBox(
                                                                          width:
                                                                              5),
                                                                      Text(
                                                                        '${data['hour'] ?? 'No Hour'}:${data['minit'] ?? 'No Minute'}',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                          Icons
                                                                              .restore_rounded,
                                                                          size:
                                                                              16),
                                                                      const SizedBox(
                                                                          width:
                                                                              5),
                                                                      Text(
                                                                        '${data['option'] ?? 'No Date'}',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                width: cSize
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
                                                                          // print(
                                                                          //     "1");
                                                                          // print(
                                                                          //     doc.id);
                                                                          // print(
                                                                          //     "2");
                                                                          AlertDialog(
                                                                              doc,
                                                                              data["uniqueID"],
                                                                              data['option'],
                                                                              uniqueDocuments.length);

                                                                          // FirebaseFirestore
                                                                          //     .instance
                                                                          //     .collection('Calender')
                                                                          //     .doc(doc.id)
                                                                          //     .delete()
                                                                          //     .then((_) {
                                                                          //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('일정이 삭제되었습니다')));
                                                                          // }).catchError((error) {
                                                                          //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('일정 삭제 실패: $error')));
                                                                          // });

                                                                          // invitaionList();
                                                                          // _loadEvents();
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
                                    width: cSize.width * 1,
                                    height: cSize.height * 0.75,
                                    decoration: BoxDecoration(
                                        // 달력순간이동
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        color: value.backgroundColor),
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              // 달력순간이동
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              color: Colors.white),
                                          child: TableCalendar(
                                            firstDay:
                                                DateTime.utc(2010, 10, 16),
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
                                                    right: 20,
                                                    bottom: 1,
                                                    child: _buildEventsMarker(
                                                        date, events),
                                                  );
                                                }
                                                return null;
                                              },
                                            ),
                                            calendarStyle: CalendarStyle(
                                              defaultDecoration: BoxDecoration(
                                                color: Colors.grey
                                                    .shade200, // 기본 날짜 셀 배경색
                                              ),
                                              weekendDecoration: BoxDecoration(
                                                color: Colors.red
                                                    .shade100, // 주말 날짜 셀 배경색
                                              ),
                                              selectedDecoration:
                                                  const BoxDecoration(
                                                color: Colors
                                                    .blueAccent, // 선택된 날짜 셀 배경색
                                                shape: BoxShape.circle,
                                              ),
                                              todayDecoration:
                                                  const BoxDecoration(
                                                color: Colors
                                                    .orangeAccent, // 오늘 날짜 셀 배경색
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
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
                                                      // print("아무데이터없을때?");
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Set_schedul(
                                                            option: '반복 안 함',
                                                            selectedDate_:
                                                                selectedDate_,
                                                            schedule_Write: "",
                                                            selectedHour: 0,
                                                            selectedMinute: 0,
                                                            isCheck: false,
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

                                              // print(uniqueDocuments);
                                              // 시간과 분을 기준으로 정렬
                                              uniqueDocuments.sort((a, b) {
                                                final dataA = a.data()
                                                    as Map<String, dynamic>;
                                                final dataB = b.data()
                                                    as Map<String, dynamic>;

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
                                                                        cSize.height *
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
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              const Icon(Icons.timer, size: 16),
                                                                              const SizedBox(width: 5),
                                                                              Text(
                                                                                '${data['hour'] ?? 'No Hour'}:${data['minit'] ?? 'No Minute'}',
                                                                                style: const TextStyle(fontSize: 12),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              const Icon(Icons.restore_rounded, size: 16),
                                                                              const SizedBox(width: 5),
                                                                              Text(
                                                                                '${data['option'] ?? 'No Date'}',
                                                                                style: const TextStyle(fontSize: 12),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    height:
                                                                        cSize.height *
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
                                                                        SizedBox(
                                                                          width:
                                                                              cSize.width * 0.85,
                                                                          child:
                                                                              ListTile(
                                                                            title:
                                                                                Text(
                                                                              data['Schedule'] ?? 'No Schedule',
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(fontSize: 25),
                                                                            ),
                                                                            subtitle:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    const Icon(Icons.timer, size: 16),
                                                                                    const SizedBox(width: 5),
                                                                                    Text(
                                                                                      '${data['hour'] ?? 'No Hour'}:${data['minit'] ?? 'No Minute'}',
                                                                                      style: const TextStyle(fontSize: 12),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    const Icon(Icons.restore_rounded, size: 16),
                                                                                    const SizedBox(width: 5),
                                                                                    Text(
                                                                                      '${data['option'] ?? 'No Date'}',
                                                                                      style: const TextStyle(fontSize: 12),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            SizedBox(
                                                                              width: cSize.width * 0.1,
                                                                              // height:
                                                                              //     c_size.height * 0.1,
                                                                              child: IconButton(
                                                                                  color: Colors.red,
                                                                                  onPressed: () {
                                                                                    AlertDialog(doc, data['uniqueID'], data['option'], uniqueDocuments.length);
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
                            // print("todo?");
                            // print("$selectedDate_");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Set_schedul(
                                    option: '반복 안 함',
                                    selectedDate_: selectedDate_,
                                    schedule_Write: "",
                                    selectedHour: 0,
                                    selectedMinute: 0,
                                    isCheck: false),
                              ),
                            );
                          },
                          tooltip: 'Add Schedule',
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(
              height: 3,
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names, avoid_types_as_parameter_names
  Future<void> AlertDialog(doc, uniqueID, String option, count) {
    // late String timeText_1 = "오전";
    return showDialog<Void>(
        // ignore: deprecated_member_use
        barrierColor: Colors.black.withOpacity(0.8),
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.white,
                    height: 300,
                    width: 500,
                    child: Column(children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      const Text(
                        "일정 삭제",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      const Text(
                        "정말로 일정을 삭제하시겠습니까?",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('Calender')
                                        .doc(doc.id)
                                        .delete()
                                        .then((_) {
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text('일정이 삭제되었습니다')));
                                    }).catchError((error) {
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content:
                                                  Text('일정 삭제 실패: $error')));
                                    });
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      context
                                          .read<ScheduleCountProvider>()
                                          .changeScheduleCount(
                                              initialCount: count - 1);
                                    });

                                    // if (option == "주중") {
                                    //   cancelNotification(uniqueID);
                                    //   for (int i = 1; i < 6; i++) {
                                    //     cancelNotification(uniqueID + i);
                                    //     print(uniqueID + i);
                                    //   }
                                    // }
                                    // print(uniqueID);
                                    // 매주 한달 1년은 어떻게 한다?
                                    switch (option) {
                                      case "주중":
                                        for (int i = 1; i < 6; i++) {
                                          cancelNotification(uniqueID + i);
                                          // print(uniqueID + i);
                                          // print("==156369270==");
                                        }
                                        break;

                                      case "주말":
                                        for (int i = 1; i < 3; i++) {
                                          cancelNotification(uniqueID + i);
                                          // print(uniqueID + i);
                                        }
                                        break;
                                      case "1년":
                                        // cancelNotification(uniqueID);
                                        cancelNotification(uniqueID + 1000);
                                        // print(uniqueID + 1000);
                                        break;
                                      case "매일":
                                        cancelNotification(uniqueID);
                                        // print(uniqueID);
                                        break;

                                      // 1년이면  data['uniqueID'] + 1000
                                      // 매일  data['uniqueID']
                                      //
                                      default:
                                        cancelNotification(uniqueID);
                                        break;
                                    }
                                    // cancelNotification(uniqueID);
                                    // 이건 왜 있는거야?

                                    invitaionList();
                                    _loadEvents();
                                    Navigator.pop(context);
                                    // 시간대 설정 메소드 들어가야한다.
                                  },
                                  child: const Text("삭제"),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // print("doc.id");
                                    // print(doc.id);
                                    // print("doc.id");
                                    Navigator.pop(context);
                                  },
                                  child: const Text("돌아가기"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]),
                  )));
        });
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blueAccent,
      ),
      width: 10.0,
      height: 15.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: const TextStyle().copyWith(
              color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> cancelNotification(int uniqueID) async {
    await flutterLocalNotificationsPlugin.cancel(uniqueID);
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(
    //         content:
    //             Text('uniqueId delete')));
  }
} //
