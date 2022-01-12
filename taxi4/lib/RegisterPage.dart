// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernamecontroller = TextEditingController();
  final _firstnamecontroller = TextEditingController();
  final _secondnamecontroller = TextEditingController();
  final _logincontroller = TextEditingController();
  final _passcontroller = TextEditingController();

  _register(String username, String login, String firstname, String secondname, String password) async {
    String url = Config.ip + '/reg';
    Map data = {
      'username': username,
      'login': login,
      'firstname': firstname,
      'secondname': secondname,
      'password': password
    };
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(data)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();

    var jsonData = json.decode(reply);
    print(jsonData['message']);

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      toast.removeQueuedCustomToasts();
      showBottomToast("аккаунт зарегистрирован", true);
    }

    if (response.statusCode == 201) {
      toast.removeQueuedCustomToasts();
      showBottomToast("никнейм занят", false);
    }

    if (response.statusCode == 202) {
      toast.removeQueuedCustomToasts();
      showBottomToast("логин занят", false);
    }

    return reply;
  }

  bool _passVis = true;
  bool _nameError = false;
  bool _secondnameError = false;
  bool _usernameError = false;
  bool _loginError = false;
  bool _passwordError = false;
  final _globalkey = GlobalKey<FormState>();

  final toast = FToast();

  void initState() {
    super.initState();
    toast.init(context);
  }

  void showBottomToast(String text, bool ok) =>
      toast.showToast(child: buildToast(text, ok), gravity: ToastGravity.BOTTOM);

  Widget buildToast(String text, bool ok) => Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: ok ? Color.fromRGBO(0, 189, 15, 0.7) : Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ok ? Icons.check : Icons.clear, color: Colors.white),
          SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _globalkey,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 45, bottom: 5),
                      child: Text(
                        "Имя",
                        style: TextStyle(
                          color: Color.fromRGBO(77, 77, 77, 0.5),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 35, left: 35, bottom: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              _nameError = true;
                            } else {
                              _nameError = false;
                            }
                            setState(() {});
                            return null;
                          },
                          onChanged: (value) {
                            _nameError = false;
                          },
                          style: TextStyle(color: Colors.black),
                          cursorWidth: 1,
                          controller: _firstnamecontroller,
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
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(242, 242, 242, 1),
                        borderRadius: BorderRadius.circular(10),
                        border: _nameError ? Border.all(width: 1.0, color: Colors.red) : null,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 45, bottom: 5),
                      child: Text(
                        "Фамилия",
                        style: TextStyle(
                          color: Color.fromRGBO(77, 77, 77, 0.5),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 35, left: 35, bottom: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              _secondnameError = true;
                            } else {
                              _secondnameError = false;
                            }
                            setState(() {});
                            return null;
                          },
                          onChanged: (value) {
                            _secondnameError = false;
                          },
                          style: TextStyle(color: Colors.black),
                          cursorWidth: 1,
                          controller: _secondnamecontroller,
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
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(242, 242, 242, 1),
                        borderRadius: BorderRadius.circular(10),
                        border: _secondnameError ? Border.all(width: 1.0, color: Colors.red) : null,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 45, bottom: 5),
                      child: Text(
                        "Никнейм",
                        style: TextStyle(
                          color: Color.fromRGBO(77, 77, 77, 0.5),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 35, left: 35, bottom: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              _usernameError = true;
                            } else {
                              _usernameError = false;
                            }
                            setState(() {});
                            return null;
                          },
                          onChanged: (value) {
                            _usernameError = false;
                          },
                          style: TextStyle(color: Colors.black),
                          cursorWidth: 1,
                          controller: _usernamecontroller,
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
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(242, 242, 242, 1),
                        borderRadius: BorderRadius.circular(10),
                        border: _usernameError ? Border.all(width: 1.0, color: Colors.red) : null,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 45, bottom: 5),
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
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              _loginError = true;
                            } else {
                              _loginError = false;
                            }
                            setState(() {});
                            return null;
                          },
                          onChanged: (value) {
                            _loginError = false;
                          },
                          style: TextStyle(color: Colors.black),
                          cursorWidth: 1,
                          controller: _logincontroller,
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
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(242, 242, 242, 1),
                        borderRadius: BorderRadius.circular(10),
                        border: _loginError ? Border.all(width: 1.0, color: Colors.red) : null,
                      ),
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
                      margin: EdgeInsets.only(right: 35, left: 35, bottom: 10),
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        child: TextFormField(
                          obscureText: _passVis,
                          controller: _passcontroller,
                          validator: (value) {
                            if (value.isEmpty || value.length < 6) {
                              _passwordError = true;
                            } else {
                              _passwordError = false;
                            }
                            setState(() {});
                          },
                          onChanged: (value) {
                            _passwordError = false;
                          },
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
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(242, 242, 242, 1),
                        borderRadius: BorderRadius.circular(10),
                        border: _passwordError ? Border.all(width: 1.0, color: Colors.red) : null,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20, right: 35, left: 35),
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _globalkey.currentState.validate();
                          if (_nameError == false &&
                              _secondnameError == false &&
                              _usernameError == false &&
                              _loginError == false &&
                              _passwordError == false) {
                            _register(_usernamecontroller.text, _logincontroller.text, _firstnamecontroller.text,
                                _secondnamecontroller.text, _passcontroller.text);
                          }
                        },
                        child: Text(
                          'Зарегистрироваться',
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
