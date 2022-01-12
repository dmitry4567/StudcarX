import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/LoginPage.dart';
import 'package:flutter_application_3/Menu.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UserProvider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProvider>(
      create: (context) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    checkLogin();
    Timer(Duration(seconds: 1), () {
      if (pref.getString("username") != null) {
        context.read<UserProvider>().changeData(pref.getString("username"), pref.getString("firstname"),
            pref.getString("secondname"), pref.getInt("grade"));
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => Menu()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
      }
    });
  }

  checkLogin() async {
    pref = await SharedPreferences.getInstance();
  }

  SharedPreferences pref;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            child: Center(
              child: Image.asset(
                'assets/icon.png',
                height: 200,
                width: 200,
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              child: Container(
                margin: EdgeInsets.only(bottom: 20),
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Text(
                  'TaxiX',
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w300),
                ),
              ))
        ],
      ),
    );
  }
}
