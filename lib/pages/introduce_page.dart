import 'package:catchup/colors.dart';
import 'package:catchup/pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroducePage extends StatefulWidget {
  @override
  _IntroducePageState createState() => _IntroducePageState();
}

class _IntroducePageState extends State<IntroducePage> {

  int counter = 0;
  PageController _controller;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchupColors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 80,
                    right: 80,
                    top: 50,
                    bottom: 50,
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 200,
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    children:[
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 150 , left: 20 , right: 20),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/svg/cc1.png')
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 150, left: 20 , right: 20),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/svg/cc2.png')
                            ),
                          ),
                        ),
                      )
                    ]
                  ),
                ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: GestureDetector(
                onTap: () async{
                  if (counter == 1) {
                    SharedPreferences share = await SharedPreferences.getInstance();
                    await share.setBool('more_time', true);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  } else {
                    setState(() {
                      counter++;
                      _controller.animateToPage(counter , duration: Duration(milliseconds: 500) ,curve: Curves.ease);
                    });
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10 , horizontal: 10),
                  child: Text(
                    counter == 1 ? 'END' : 'NEXT',
                    style: TextStyle(color: CatchupColors.red),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
