import 'package:flutter/material.dart';

class Set_schedul extends StatefulWidget {
  const Set_schedul({super.key});

  @override
  State<Set_schedul> createState() => __Set_schedulState();
}

class __Set_schedulState extends State<Set_schedul> {
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("일정 등록"),
      ),
      body: Text("HIHI"),
      // = 이렇게 글 적는 필드 해놓고
      // = 주마다 반복하는 일정인지 당일에만 하는 건지 설정? 아니면 입력칸을 분리?
      // = 이용자들이 가장 많이 한 것들 추천으로 보여줘도 될듯.[내가 제공한거 아니면 어렵겠다.]
      // = 파이어베이스로 반복적인 주간 일정. 당일 특별 일정 분리해서 관리해야 함.
      // = 알림설정 된 일정인지도 분리 해야 하나?
      // 일정 등록 칸 누르면 반복설정 여부. 반복 설정이라고 하면 평일에 몇번인지 주말 포함인지
      // 스크롤해서 선택할 수 있게.
      // 1. 일정 등록 페이지에서 [ 물 마시기 등록 ]
      // 2. 반복 일정으로 등록 한다 안한다 설정.
      // 3. 반복 일정 [월화수목금토일] 선택하게 함.
      // 4. 일정 등록 완료!
      // 5. 그러고나서 해당 일정 알람 설정까지?
      // 6. 그럼 월~금으로 일정 정한게 디폴트로 들어가고
      // 7. 다음으로 해당 날짜에만 정한 일정이 밑으로 들어가게
      // 8. 대충 이렇게 하면 될 거 같은데.
      // 9. 알람 설정된 일정은 앞에 시간도 나오게 하고.
      // 10. 근데 파이어베이스에 어케 등록하지.
      // 11. 월요일 : [일정 : 뭐뭐] 이렇게 하위로 또 만들어야 될 거 같은데?
      // 12. 아닌가 그럼 너무 많아. 1달 31일을 그렇게 설정 할 순 없어.
      // 13. 그냥 월화수목금토일 이렇게 7개 만들고
      // 14. 디폴트 일정은 저기 7개에 다 넣어버리면 달력에 표시가 될 거 같은데.
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
    );
  }
}
