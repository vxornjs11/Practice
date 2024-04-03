import 'package:flutter/material.dart';
import 'package:practice_01_app/style/style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

class Set_schedul extends StatefulWidget {
  const Set_schedul({super.key});

  @override
  State<Set_schedul> createState() => __Set_schedulState();
}

class __Set_schedulState extends State<Set_schedul> {
  // SureStlye sureStyle = SureStlye();
  late TextEditingController titlecontroller;

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titlecontroller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // TextEditingController text_title;
    var styles = TextStyle(
        fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500);
    return Scaffold(
        appBar: AppBar(
          title: Text("일정 등록"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TableCalendar(
                  onDaySelected: onDaySelected,
                  selectedDayPredicate: (date) {
                    return isSameDay(selectedDate, date);
                  },
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: DateTime.now(),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.grey.shade200),
                  width: size.width * 1,
                  height: size.height * 0.05,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '예) 채소 사오기',
                    ),
                    controller: titlecontroller,
                    onChanged: (value) {
                      setState(() {
                        // StaticUserName.title = titlecontroller.text;
                        // checkDuplicateTitle(); // 중복 확인 함수 호출
                      });
                    },
                  ),
                ),
                //
              ],
            ),
          ),
        ));
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      this.selectedDate = selectedDate;
    });
  }
}


// {
//     "user_id": {
//       "schedule_id": {
// 연도 : 선택한 연도
// 달 : 달,일,요일
// 요일 :
// 할일 : [걍 리스트로 하면 됨.]
// 근데 할일을 반복으로 할 거라면?
// 반복일정은 따로 빼놔서 그 일정에 싹다 add로 수정해서 넣어버리면 안되나?
// 알림설정 : 트루/펄스
// - 트루로 설정시 따로 알림설정 만들어서 해당 화면에서 완료 누르면
// - 알림설정 관련 메소드 발동하게 하면 될듯.
//
//         "title": "물을 마신다."
//         "day": 1. 이런식으로 날짜 - 요일이 같이 자동으로 들어가게 하면 되겠는디.
//         "repeat": "Monday-Friday",
//         "time": "09:00",
//         "exceptional": {"title": "여행을 가다", "repeat": "Monday"}
//       }
// 이렇게 하면 1월 1일(월) 약먹기랑 1월 11일(월) 여행가기 을 어떻게 구분하지.
//     }
//   }

/// 흠... 데이터가 자기 uid가 없는데 어떻게 구분하는거지.
/// 애초에 구글 플레이스토어에서 다운 받는거니까 자기 계정 연동이 되어 있나? 일단 해보죠..
