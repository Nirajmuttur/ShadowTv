import 'package:flutter/material.dart';
import 'package:movieapp/Pages/Navigation.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Animation<double> opacity;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(milliseconds: 3500), vsync: this);
    opacity = Tween<double>(begin: 1.0, end: 0.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward().then((_) {
      navigationPage();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void navigationPage() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => Navigation()));
  }

  Widget build(BuildContext context) {
    return Container(
      child: Container(
        decoration: BoxDecoration(color: Color(0xff222831)),
        child: SafeArea(
          child: new Scaffold(
            backgroundColor: Color(0xff222831),
            body: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 150,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(150),
                    child: Opacity(
                        opacity: opacity.value,
                        child: new Image.asset(
                          'assets/logo.png',
                        )),
                  ),
                  SizedBox(
                    height: 200,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3.2,
                      ),
                      Text(
                        'Powered By ',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'TECAIDA',
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Alaska',
                            color: Colors.white),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
