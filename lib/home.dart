import 'package:flutter/material.dart';
import 'package:practice_01_app/Mainpage.dart';
import 'package:practice_01_app/Settings.dart';

// class home extends StatelessWidget {
//   final int tf = 1;
//   const home({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Mainpage();
//   }
// }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
              Icons.home,
            ),
            label: 'home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings,
            ),
            label: 'setting',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person,
            ),
            label: 'Quiz',
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
        const Mainpage(),
        const Settings(),
        // const ChatListPage(),
        // const MyPage(),
      ][currentPageIndex],
    );
  }
}
