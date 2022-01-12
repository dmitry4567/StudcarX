// ignore_for_file: file_names
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/Menu.dart';
import 'package:flutter_application_3/RegisterPage.dart';
import 'package:flutter_application_3/UserProvider.dart';
import 'package:flutter_application_3/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

import 'Lenta.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _logincontroller = TextEditingController();
  final TextEditingController _passcontroller = TextEditingController();

  final toast = FToast();
  bool _passVis = true;

  void initState() {
    super.initState();
    toast.init(context);
  }

  void showBottomToast(String text) => toast.showToast(child: buildToast(text), gravity: ToastGravity.BOTTOM);

  Widget buildToast(String text) => Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.clear, color: Colors.white),
          SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ));

  _login(String login, String password) async {
    String url = Config.ip + '/login';
    Map data = {'login': login, 'password': password};
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(data)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();

    var jsonData = json.decode(reply);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if (response.statusCode == 200) {
      setState(() {
        context.read<UserProvider>().changeData(jsonData['user']['username'], jsonData['user']['firstname'],
            jsonData['user']['secondname'], jsonData['grade']);

        sharedPreferences.setString("username", jsonData['user']['username']);
        sharedPreferences.setString("firstname", jsonData['user']['firstname']);
        sharedPreferences.setString("secondname", jsonData['user']['secondname']);
        sharedPreferences.setInt("grade", jsonData['grade']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Menu()),
        );
      });
    }
    if (response.statusCode == 201) {
      toast.removeQueuedCustomToasts();
      showBottomToast("неверный пароль");
    }

    return reply;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Image.asset(
                      'assets/icon3.png',
                    )),
                Container(
                  padding: EdgeInsets.only(top: 60, left: 45, bottom: 5),
                  child: Text(
                    "Логин",
                    style: TextStyle(
                      color: Color.fromRGBO(77, 77, 77, 0.5),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 35, left: 35, bottom: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: _logincontroller,
                      style: TextStyle(color: Colors.black),
                      cursorWidth: 1,
                      cursorColor: Color.fromARGB(255, 255, 40, 0),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Color.fromRGBO(77, 77, 77, 1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  decoration:
                      BoxDecoration(color: Color.fromRGBO(242, 242, 242, 1), borderRadius: BorderRadius.circular(10)),
                ),
                Container(
                  padding: EdgeInsets.only(left: 45, bottom: 5),
                  child: Text(
                    "Пароль",
                    style: TextStyle(
                      color: Color.fromRGBO(77, 77, 77, 0.5),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 35, left: 35),
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: TextField(
                      obscureText: _passVis,
                      controller: _passcontroller,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: Colors.black),
                      cursorWidth: 1,
                      cursorColor: Color.fromARGB(255, 255, 40, 0),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          splashRadius: 1.0,
                          icon: _passVis
                              ? Icon(
                                  Icons.visibility_off,
                                  color: Colors.grey,
                                )
                              : Icon(
                                  Icons.visibility,
                                  color: Colors.grey,
                                ),
                          onPressed: () {
                            setState(() {
                              _passVis = !_passVis;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Color.fromRGBO(77, 77, 77, 1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  decoration:
                      BoxDecoration(color: Color.fromRGBO(242, 242, 242, 1), borderRadius: BorderRadius.circular(10)),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20, right: 35, left: 35),
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _login(_logincontroller.text, _passcontroller.text);
                    },
                    child: Text(
                      'Войти',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 255, 40, 0),
                      onPrimary: Color.fromRGBO(197, 30, 10, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 35, left: 35),
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      'Регистрация',
                      style:
                          TextStyle(color: Color.fromRGBO(77, 77, 77, 0.5), fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      onPrimary: Color.fromRGBO(242, 242, 242, 1.0),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
