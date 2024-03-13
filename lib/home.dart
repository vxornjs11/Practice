import 'package:flutter/material.dart';
import 'package:practice_01_app/screen/Calendar.dart';
import 'package:practice_01_app/screen/Mainpage.dart';
import 'package:practice_01_app/screen/Settings.dart';

// class home extends StatelessWidget {
//   final int tf = 1;
//   const home({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Mainpage();
//   }
// }

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<home> {
  late int currentPageIndex;
  late TabController controller;

  @override
  void initState() {
    super.initState();
    currentPageIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    var c_size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.calendar_month,
            ),
            label: 'calendar',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.home,
            ),
            label: 'home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings,
            ),
            label: 'settings',
          ),
        ],
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        height: 44,
        backgroundColor: Colors.white,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        elevation: 1,
      ),
      body: <Widget>[
        const calendar(),
        const Mainpage(),
        const Settings(),
        // const ChatListPage(),
        // const MyPage(),
      ][currentPageIndex],
    );
  }
}
