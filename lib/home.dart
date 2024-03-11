import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size c_size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.purple.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
              width: c_size.width * 1,
              height: c_size.height * 0.1,
              color: Colors.white,
              child: Center(
                child: Text(
                  "coffe beans",
                  style: TextStyle(color: Colors.purple, fontSize: 40),
                ),
              ),
            ),
            Container(
              width: c_size.width * 1,
              height: c_size.height * 0.9,
              color: Colors.purple.shade100,
              child: Column(
                children: [
                  SizedBox(
                    height: c_size.height * 0.03,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // 아래 컨테이너를 3개 만들지말고 1개의 메소드로 만들 수 있을듯.
                        // 그리고 이게 좌우로 스크롤해서 이동이 되면 좋겠는데.
                        // Listveiw 쓰면 되넹
                        Container(
                          width: c_size.width * 0.25,
                          height: c_size.height * 0.15,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: c_size.width * 0.03,
                        ),
                        Container(
                          width: c_size.width * 0.25,
                          height: c_size.height * 0.15,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: c_size.width * 0.03,
                        ),
                        Container(
                          width: c_size.width * 0.25,
                          height: c_size.height * 0.15,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: c_size.width * 0.03,
                        ),
                        Container(
                          width: c_size.width * 0.25,
                          height: c_size.height * 0.15,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: c_size.width * 0.03,
                        ),
                        Container(
                          width: c_size.width * 0.25,
                          height: c_size.height * 0.15,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: c_size.width * 0.03,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
