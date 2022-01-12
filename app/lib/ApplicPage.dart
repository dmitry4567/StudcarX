// ignore_for_file: file_names, prefer_const_constructors
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/Lenta.dart';
import 'package:flutter_application_3/Menu.dart';
import 'package:flutter_application_3/UserProvider.dart';
import 'package:flutter_application_3/config.dart';
import 'package:provider/provider.dart';

class ApplicPage extends StatefulWidget {
  const ApplicPage({Key key}) : super(key: key);

  @override
  _ApplicPageState createState() => _ApplicPageState();
}

class Palette {
  static const MaterialColor Default = const MaterialColor(
    0xffff2800,
    const <int, Color>{
      50: const Color(0xffe62400),
      100: const Color(0xffcc2000),
      200: const Color(0xffb31c00),
      300: const Color(0xff991800),
      400: const Color(0xff801400),
      500: const Color(0xff661000),
      600: const Color(0xff4c0c00),
      700: const Color(0xff330800),
      800: const Color(0xff190400),
      900: const Color(0xff000000),
    },
  );
}

class _ApplicPageState extends State<ApplicPage> {
  _reg_event2() async {
    String url = Config.ip + '/reg_event';
    Map data = {
      'time': _selectedTime,
      'place': _place.text,
      'route': _dropDownWhere_1.toString() + "-" + _dropDownWhere_2.toString(),
      'max_people': _selectedpeople.toInt(),
      'price': _price.text,
      'usercreate': Provider.of<UserProvider>(context, listen: false).get_username
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
      print('ok');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => Menu()));
    }
    if (response.statusCode == 202) {}

    return reply;
  }

  Future<void> _show() async {
    final TimeOfDay result = await showTimePicker(
      helpText: "ВЫБЕРИТЕ ВРЕМЯ",
      cancelText: "Отмена",
      confirmText: "ОК",
      useRootNavigator: false,
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(
            primarySwatch: Palette.Default,
            timePickerTheme: TimePickerThemeData(
              hourMinuteColor: Colors.white, //???
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              hourMinuteShape: CircleBorder(),
            ),
          ),
          child: child,
        );
      },
    );
    if (result != null) {
      setState(() {
        _selectedTime = result.format(context);
      });
    }
  }

  @override
  String _selectedTime = "00:00";
  final TextEditingController _price = TextEditingController();
  final TextEditingController _place = TextEditingController();
  int _selectedpeople = 4;
  int _price_int = 0;
  String _dropDownWhere_1;
  String _dropDownWhere_2;

  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.only(top: 50, left: 30, right: 30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Новое событие",
              style: TextStyle(
                  color: Color.fromRGBO(77, 77, 77, 1),
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic),
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              "время",
              style: TextStyle(color: Color.fromRGBO(77, 77, 77, 0.5)),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _show();
                });
              },
              child: Container(
                padding: EdgeInsets.only(top: 3),
                child: Text(
                  _selectedTime.toString(),
                  style: TextStyle(fontSize: 42, color: Color.fromRGBO(77, 77, 77, 1), fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              "место сбора",
              style: TextStyle(color: Color.fromRGBO(77, 77, 77, 0.5)),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 50.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: _place,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    color: Color.fromRGBO(77, 77, 77, 1),
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'место',
                    hintStyle: TextStyle(
                      color: Color.fromRGBO(77, 77, 77, 0.5),
                      fontSize: 16,
                    ),
                  ),
                  cursorColor: Color.fromARGB(255, 255, 40, 0),
                  onChanged: (value) {},
                ),
              ),
              decoration:
                  BoxDecoration(color: Color.fromRGBO(242, 242, 242, 1), borderRadius: BorderRadius.circular(10)),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "маршрут",
              style: TextStyle(color: Color.fromRGBO(77, 77, 77, 0.5)),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButton(
                borderRadius: BorderRadius.circular(10),
                underline: Container(
                  height: 1.0,
                  decoration:
                      const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.transparent, width: 0.0))),
                ),
                elevation: 1,
                hint: _dropDownWhere_1 == null
                    ? Text(
                        'откуда',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(77, 77, 77, 0.5),
                        ),
                      )
                    : Text(
                        _dropDownWhere_1,
                        style: TextStyle(
                          color: Color.fromRGBO(77, 77, 77, 1),
                        ),
                      ),
                isExpanded: true,
                icon: Icon(
                  Icons.expand_more,
                  color: Color.fromRGBO(77, 77, 77, 0.5),
                ),
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 40, 0),
                  fontSize: 16,
                ),
                items: ['ДГТУ', 'ШАПКА', 'Сельмаш'].where((element) => element != _dropDownWhere_2).map(
                  (val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(
                        val,
                      ),
                    );
                  },
                ).toList(),
                onChanged: (val) {
                  setState(
                    () {
                      _dropDownWhere_1 = val;
                    },
                  );
                },
              ),
              decoration:
                  BoxDecoration(color: Color.fromRGBO(242, 242, 242, 1), borderRadius: BorderRadius.circular(10)),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButton(
                borderRadius: BorderRadius.circular(10),
                underline: Container(
                  height: 1.0,
                  decoration:
                      const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.transparent, width: 0.0))),
                ),
                elevation: 1,
                hint: _dropDownWhere_2 == null
                    ? Text(
                        'куда',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(77, 77, 77, 0.5),
                        ),
                      )
                    : Text(
                        _dropDownWhere_2,
                        style: TextStyle(
                          color: Color.fromRGBO(77, 77, 77, 1),
                        ),
                      ),
                isExpanded: true,
                icon: Icon(
                  Icons.expand_more,
                  color: Color.fromRGBO(77, 77, 77, 0.5),
                ),
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 40, 0),
                  fontSize: 16,
                ),
                items: ['ДГТУ', 'ШАПКА', 'Сельмаш'].where((element) => element != _dropDownWhere_1).map(
                  (val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(
                        val,
                      ),
                    );
                  },
                ).toList(),
                onChanged: (val) {
                  setState(
                    () {
                      _dropDownWhere_2 = val;
                    },
                  );
                },
              ),
              decoration:
                  BoxDecoration(color: Color.fromRGBO(242, 242, 242, 1), borderRadius: BorderRadius.circular(10)),
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              "кол-во попутчиков",
              style: TextStyle(color: Color.fromRGBO(77, 77, 77, 0.5)),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 28,
              child: ListView.builder(
                itemCount: 4,
                scrollDirection: Axis.horizontal,
                itemBuilder: (ctx, index) => GestureDetector(
                  onTap: () {
                    if (index >= 1) {
                      _selectedpeople = index + 1;
                      print(_selectedpeople);
                      setState(() {});
                    }
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color:
                          _selectedpeople > index ? Color.fromARGB(255, 255, 40, 0) : Color.fromRGBO(179, 179, 179, 1),
                      shape: BoxShape.circle,
                    ),
                    child: null,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 50.0,
              child: Center(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 12, right: 10),
                      child: Text(
                        "₽",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(77, 77, 77, 0.5), fontSize: 25),
                      ),
                    ),
                    Expanded(
                        child: TextField(
                      controller: _price,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        color: Color.fromRGBO(77, 77, 77, 1),
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'цена поездки',
                        hintStyle: TextStyle(
                          color: Color.fromRGBO(77, 77, 77, 0.5),
                          fontSize: 16,
                        ),
                      ),
                      cursorColor: Color.fromARGB(255, 255, 40, 0),
                      onChanged: (value) {
                        if (_price.text.isNotEmpty) {
                          _price_int = int.parse(_price.text);
                        }
                        setState(() {});
                      },
                    ))
                  ],
                ),
              ),
              decoration:
                  BoxDecoration(color: Color.fromRGBO(242, 242, 242, 1), borderRadius: BorderRadius.circular(10)),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                Text(
                  'цена для каждого: ',
                  style: TextStyle(
                    color: Color.fromRGBO(77, 77, 77, 0.5),
                  ),
                ),
                Text(
                  _price.text.isNotEmpty ? (_price_int / _selectedpeople).toStringAsFixed(2).toString() + '₽' : "0₽",
                  style: TextStyle(
                    color: Color.fromRGBO(77, 77, 77, 0.5),
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 65,
            ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  if (_dropDownWhere_1 != null && _dropDownWhere_2 != null) {
                    _reg_event2();
                  }
                },
                child: Text(
                  'Создать',
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
    ));
  }
}
