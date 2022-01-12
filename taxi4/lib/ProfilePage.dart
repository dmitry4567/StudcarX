// ignore_for_file: file_names, prefer_const_constructors, curly_braces_in_flow_control_structures
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter_application_3/EditUser.dart';
import 'package:flutter_application_3/config.dart';
import 'package:path/path.dart';
import 'package:avatar_view/avatar_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/Lenta.dart';
import 'package:flutter_application_3/custom_expansion_tile.dart' as custom;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cross_file_image/cross_file_image.dart';

import 'UserProvider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void initState() {
    super.initState();
    _future = _getRequest();
    _grade = _gradeUpdate();
  }

  _update_grade(List people, List grade, String idd) async {
    String url = Config.ip + '/update_grade';
    Map data = {'people': people, 'grade': grade, 'idd': idd};
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(data)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    var responseData = json.decode(reply);

    if (response.statusCode == 200) {
      print('ok');
      setState(() {
        _future = _getRequest();
        _grade = _gradeUpdate();
      });
    }
  }

  Future<List<Event2>> _getRequest() async {
    try {
      String url = Config.ip + '/list_grade';
      Map data = {'username': Provider.of<UserProvider>(this.context, listen: false).get_username};
      HttpClient httpClient = new HttpClient();
      HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode(data)));
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();
      httpClient.close();

      var responseData = json.decode(reply);

      List<Event2> events = [];

      for (var u in responseData) {
        Event2 neww = Event2(
          u["idd"],
          u["time"],
          u["place"],
          u["route"],
          u["max_people"],
          u["price"],
          u["people"],
          List.filled(u["people"].length, 0),
        );
        events.add(neww);
      }

      return events;
    } catch (e) {
      print(e);
    }
  }

  Future<int> _gradeUpdate() async {
    try {
      String url = Config.ip + '/get_grade';
      Map data = {'username': Provider.of<UserProvider>(this.context, listen: false).username};
      HttpClient httpClient = new HttpClient();
      HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode(data)));
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();
      httpClient.close();

      var jsonData = json.decode(reply);

      if (jsonData != Provider.of<UserProvider>(this.context, listen: false).get_grade) {
        Provider.of<UserProvider>(this.context, listen: false).changeGrade(jsonData);
      }

      return jsonData;
    } catch (e) {
      print(e);
    }
  }

  var _future;
  var _grade;
  bool isExpanded = false;
  ImagePicker picker = ImagePicker();
  SharedPreferences pref;
  XFile image;

  @override
  Widget build(BuildContext context) {
    int grade = Provider.of<UserProvider>(this.context, listen: false).get_grade;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 50),
              child: Row(
                children: [
                  // image != null
                  //     ? ClipOval(
                  //         child: SizedBox(
                  //           width: 120,
                  //           height: 120,
                  //           child: Image.file(File(image.path)),
                  //         ),
                  //       )
                  //     : Text("null"),
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CachedNetworkImage(
                      imageUrl:
                          '${Config.ip + '/getimages/' + Provider.of<UserProvider>(this.context, listen: false).get_username + '.png'}',
                      filterQuality: FilterQuality.low,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 255, 40, 0),
                            // value: loadingProgress.expectedTotalBytes !=
                            //         null
                            //     ? loadingProgress.cumulativeBytesLoaded /
                            //         loadingProgress.expectedTotalBytes
                            //     : null,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 120,
                      padding: EdgeInsets.only(left: 10),
                      //color: Colors.black38,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.watch<UserProvider>().firstname.toString() +
                                "\n" +
                                context.watch<UserProvider>().secondname.toString(),
                            style: TextStyle(fontSize: 27),
                          ),
                          Container(
                              height: 32,
                              child: FutureBuilder(
                                initialData: grade,
                                future: _grade,
                                builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                                  return ListView.builder(
                                    itemCount: snapshot.data,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemBuilder: (_, i) {
                                      return Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          height: 32,
                                          width: 32,
                                          child: Image.asset(
                                            "assets/icon1.png",
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              )),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (BuildContext context) => EditUserPage()));
                            },
                            child: Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.settings,
                                    size: 18,
                                    color: Color.fromRGBO(77, 77, 77, 0.5),
                                  ),
                                  Text(
                                    "настройки",
                                    style: TextStyle(
                                      color: Color.fromRGBO(77, 77, 77, 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "завершенные поездки",
              style: TextStyle(
                color: Color.fromRGBO(77, 77, 77, 0.5),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _future,
                builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 255, 40, 0),
                      ),
                    );
                  } else {
                    if (snapshot.data.isEmpty) {
                      return Center(
                        child: Text(
                          "Нет событий",
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 40, 0), fontSize: 30, fontWeight: FontWeight.w500),
                        ),
                      );
                    } else
                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (ctx, index) => TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          curve: Curves.ease,
                          duration: const Duration(seconds: 1),
                          builder: (BuildContext context, double opacity, Widget child) {
                            return Opacity(
                              opacity: opacity,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor: Colors.transparent,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        custom.ExpansionTile(
                                          headerBackgroundColor: Color.fromRGBO(242, 242, 242, 1),
                                          iconColor: Color.fromRGBO(77, 77, 77, 0.5),
                                          backgroundColor: Color.fromRGBO(242, 242, 242, 1),
                                          title: Column(
                                            children: [
                                              Container(
                                                //color: Colors.black26,
                                                margin: EdgeInsets.only(top: 6),
                                                width: double.infinity,
                                                alignment: Alignment.topCenter,
                                                height: 40,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            snapshot.data[index].time,
                                                            style: TextStyle(
                                                                fontSize: 30, color: Color.fromRGBO(77, 77, 77, 1)),
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets.only(left: 10),
                                                            height: 14,
                                                            child: ListView.builder(
                                                                scrollDirection: Axis.horizontal,
                                                                shrinkWrap: true,
                                                                itemCount: 4,
                                                                itemBuilder: (_, int g) {
                                                                  return g < snapshot.data[index].people.length
                                                                      ? Container(
                                                                          width: 14,
                                                                          height: 14,
                                                                          margin: EdgeInsets.only(right: 4),
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromARGB(255, 255, 40, 0),
                                                                            shape: BoxShape.circle,
                                                                          ),
                                                                          child: null,
                                                                        )
                                                                      : Container(
                                                                          width: 14,
                                                                          height: 14,
                                                                          margin: EdgeInsets.only(right: 4),
                                                                          decoration: BoxDecoration(
                                                                            color: Color.fromRGBO(179, 179, 179, 1),
                                                                            shape: BoxShape.circle,
                                                                          ),
                                                                          child: null,
                                                                        );
                                                                }),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          children: <Widget>[
                                            ListView.builder(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: snapshot.data[index].people.length,
                                                itemBuilder: (BuildContext context, int ind) {
                                                  return snapshot.data[index].people[ind]["name"] !=
                                                          context.read<UserProvider>().username
                                                      ? Container(
                                                          height: 32,
                                                          width: 32,
                                                          //color: Colors.grey,
                                                          margin: EdgeInsets.only(top: 10, left: 15, right: 15),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    width: 25,
                                                                    height: 25,
                                                                    margin: EdgeInsets.only(left: 10, right: 10),
                                                                    decoration: BoxDecoration(
                                                                      color: Color.fromARGB(255, 255, 40, 0),
                                                                      shape: BoxShape.circle,
                                                                    ),
                                                                    child: null,
                                                                  ),
                                                                  Text(
                                                                    snapshot.data[index].people[ind]["name"],
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(77, 77, 77, 0.7),
                                                                        fontSize: 16),
                                                                  ),
                                                                ],
                                                              ),
                                                              ListView.builder(
                                                                  itemCount: 5,
                                                                  scrollDirection: Axis.horizontal,
                                                                  shrinkWrap: true,
                                                                  itemBuilder: (_, i) {
                                                                    return Align(
                                                                      alignment: Alignment.center,
                                                                      child: GestureDetector(
                                                                        onTap: () {
                                                                          snapshot.data[index].grade_each_people[ind] =
                                                                              i + 1;
                                                                          setState(() {});
                                                                        },
                                                                        child: Container(
                                                                          height: 32,
                                                                          width: 32,
                                                                          child: i <
                                                                                  snapshot.data[index]
                                                                                      .grade_each_people[ind]
                                                                              ? Image.asset(
                                                                                  "assets/icon1.png",
                                                                                )
                                                                              : Image.asset(
                                                                                  "assets/icon2.png",
                                                                                  scale: 53,
                                                                                ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }),
                                                            ],
                                                          ),
                                                        )
                                                      : Container();
                                                }),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            FlatButton(
                                              height: 50,
                                              minWidth: double.infinity,
                                              color: Color(0xffff2800),
                                              textColor: Colors.white,
                                              splashColor: Colors.white,
                                              child: Text(
                                                'Завершить',
                                                style: TextStyle(
                                                    fontSize: 17, color: Colors.white, fontWeight: FontWeight.w500),
                                              ),
                                              onPressed: () {
                                                var f = [];
                                                var gr = [];
                                                bool error = false;
                                                for (int i = 0;
                                                    i < snapshot.data[index].grade_each_people.length;
                                                    i++) {
                                                  if (snapshot.data[index].grade_each_people[i] == 0) {
                                                    if (snapshot.data[index].people[i]["name"] !=
                                                        context.read<UserProvider>().username) {
                                                      error = true;
                                                    }
                                                  } else {
                                                    gr.add(snapshot.data[index].grade_each_people[i]);
                                                  }
                                                }
                                                if (!error) {
                                                  for (int i = 0; i < snapshot.data[index].people.length; i++) {
                                                    if (snapshot.data[index].people[i]["name"] !=
                                                        context.read<UserProvider>().username) {
                                                      f.add(snapshot.data[index].people[i]["name"]);
                                                    }
                                                  }
                                                  print(f);
                                                  print(gr);
                                                  _update_grade(f, gr, snapshot.data[index].idd);
                                                }
                                              },
                                            ),
                                          ],
                                          onExpansionChanged: (bool expanding) =>
                                              setState(() => this.isExpanded = expanding),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Event2 {
  String idd;
  String time;
  String route;
  String place;
  int max_people;
  String price;
  List people;
  List grade_each_people;
  List gradeint;

  set alla(List s) {
    gradeint = s;
  }

  Event2(this.idd, this.time, this.place, this.route, this.max_people, this.price, this.people, this.grade_each_people);
}
