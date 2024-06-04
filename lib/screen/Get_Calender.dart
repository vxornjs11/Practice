import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarController extends GetxController {
  var selectedDate = DateTime.now().obs;

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }
}
