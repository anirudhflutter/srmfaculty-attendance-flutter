import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common/constants.dart' as cnst;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin{

  AnimationController animationController;
  Animation<Offset> animation;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: false);
    animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1, 0.0),
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.elasticIn,
    )
    );

    Timer(Duration(milliseconds: 4000), () async {
      SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
      var id = sharedPreferences.getString(cnst.id);
      print(id);
      if(id!=null){
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/homeScreen', (Route<dynamic> route) => false);
      }
      else {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/loginScreen', (Route<dynamic> route) => false);
      }});
    // TODO: implement initState
    super.initState();
  }

  @override
  dispose() {
    animationController.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height*0.3,
          ),
          Image.asset('assets/images/srm-logo.png',
          fit: BoxFit.fill,),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 150,
              child: Center(
                child: Text(
                  "STAFF ATTENDANCE SYSTEM",
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  textAlign: TextAlign.justify, // or Alignment.topLeft
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
