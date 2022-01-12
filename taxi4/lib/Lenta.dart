// ignore_for_file: file_names, prefer_const_constructors, curly_braces_in_flow_control_structures
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/UserProvider.dart';
import 'package:flutter_application_3/UserView.dart';
import 'package:flutter_application_3/config.dart';
import 'package:flutter_application_3/custom_expansion_tile.dart' as custom;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Lenta extends StatefulWidget {
  const Lenta({Key key}) : super(key: key);

  @override
  _LentaState createState() => _LentaState();
}

class _LentaState extends State<Lenta> {
  IO.Socket socket;
  SharedPreferences pref;
  String username;

  @override
  void initState() {
    super.initState();
    connect();
    _future = _getRequest();
  }

  void dispose() {
    socket.close();
    super.dispose();
  }

  void connect() {
    socket = IO.io(Config.ip + '/', <String, dynamic>{
      'transports': ['websocket'],
      'forceNew': true
    });
    socket.connect();
    socket.on("message", (msg) {
      print(msg);
      setState(() {
        _future = _getRequest();
      });
    });
  }

  _addusername2(String idd) async {
    String url = Config.ip + '/add';
    Map data = {'idd': idd, 'username': Provider.of<UserProvider>(context, listen: false).username};
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
      setState(() {
        _future = _getRequest();
      });
      print('ok');
    }

    return reply;
  }

  _delEvent(String idd) async {
    String url = Config.ip + '/delevent';
    Map data = {'idd': idd};
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
      setState(() {
        _future = _getRequest();
      });
      print('ok');
    }

    return reply;
  }

  _delUser(String idd) async {
    String url = Config.ip + '/deluser';
    Map data = {'idd': idd, 'username': Provider.of<UserProvider>(context, listen: false).username};
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
      setState(() {
        _future = _getRequest();
      });
      print('ok');
    }

    return reply;
  }

  Future<List<Event>> _getRequest() async {
    try {
      final data = await http.get(Uri.parse(Config.ip + '/list'));

      var responseData = json.decode(data.body);

      //print(responseData);

      var i = 0;
      List<Event> events = [];

      for (var u in responseData) {
        var f = [];
        Event neww = Event(
            u["idd"], u["time"], u["place"], u["route"], u["max_people"], u["price"], u["people"], u["usercreate"]);
        for (int j = 0; j < u["people"].length; j++) {
          f.add(int.parse((u["people"][j]["grade"])));
        }
        neww.alla = f;
        events.add(neww);
        i++;
      }

      return events;
    } catch (e) {
      print(e);
    }
  }

  _Dialog(String firstname, String secondname, String imageUrl, int grade) {
    return showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 16,
            child: Container(
              margin: EdgeInsets.only(left: 10),
              width: double.infinity,
              height: 180,
              child: Row(
                children: [
                  ClipOval(
                    child: Container(
                      width: 150,
                      height: 150,
                      child: Image.network(
                        'http://192.168.1.105:9090/getimages/' + imageUrl + '.png',
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.low,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 255, 40, 0),
                                // value: loadingProgress.expectedTotalBytes !=
                                //         null
                                //     ? loadingProgress.cumulativeBytesLoaded /
                                //         loadingProgress.expectedTotalBytes
                                //     : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 120,
                      padding: EdgeInsets.only(left: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstname + "\n" + secondname,
                            style: TextStyle(fontSize: 25),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 31,
                            child: ListView.builder(
                                itemCount: grade,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (_, i) {
                                  return Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: 31,
                                      width: 31,
                                      child: i < grade
                                          ? Image.asset(
                                              "assets/icon1.png",
                                            )
                                          : Image.asset(
                                              "assets/icon2.png",
                                              scale: 53,
                                            ),
                                    ),
                                  );
                                }),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  var _future;
  bool isExpanded = false;
  bool isDelete = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
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
                    style: TextStyle(color: Color.fromARGB(255, 255, 40, 0), fontSize: 30, fontWeight: FontWeight.w500),
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
                            child: GestureDetector(
                              onLongPress: () {
                                if (snapshot.data[index].usercreate == context.read<UserProvider>().username) {
                                  _delEvent(snapshot.data[index].idd);
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 30),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 30),
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
                                                  margin: EdgeInsets.only(top: 4),
                                                  width: double.infinity,
                                                  alignment: Alignment.topCenter,
                                                  height: 117,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              snapshot.data[index].time,
                                                              style: TextStyle(
                                                                  fontSize: 30, color: Color.fromRGBO(77, 77, 77, 1)),
                                                            ),
                                                            Container(
                                                              //color: Colors.black38,
                                                              width: 140,
                                                              height: 41,
                                                              margin: EdgeInsets.only(left: 10),
                                                              child: Container(
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                      snapshot.data[index].route,
                                                                      style: TextStyle(
                                                                          fontSize: 16,
                                                                          color: Color.fromRGBO(77, 77, 77, 0.7)),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 3,
                                                                    ),
                                                                    Container(
                                                                      height: 14,
                                                                      child: ListView.builder(
                                                                          scrollDirection: Axis.horizontal,
                                                                          shrinkWrap: true,
                                                                          itemCount: snapshot.data[index].max_people,
                                                                          itemBuilder: (_, int g) {
                                                                            return g <
                                                                                    snapshot.data[index].people.length
                                                                                ? TweenAnimationBuilder<double>(
                                                                                    tween: Tween<double>(
                                                                                        begin: 0.0, end: 1.0),
                                                                                    curve: Curves.ease,
                                                                                    duration:
                                                                                        const Duration(seconds: 1),
                                                                                    builder: (BuildContext context,
                                                                                        double opacity, Widget child) {
                                                                                      return Opacity(
                                                                                          opacity: opacity,
                                                                                          child: Container(
                                                                                            width: 14,
                                                                                            height: 14,
                                                                                            margin: EdgeInsets.only(
                                                                                                right: 4),
                                                                                            decoration: BoxDecoration(
                                                                                              color: Color.fromARGB(
                                                                                                  255, 255, 40, 0),
                                                                                              shape: BoxShape.circle,
                                                                                            ),
                                                                                            child: null,
                                                                                          ));
                                                                                    })
                                                                                : Container(
                                                                                    width: 14,
                                                                                    height: 14,
                                                                                    margin: EdgeInsets.only(right: 4),
                                                                                    decoration: BoxDecoration(
                                                                                      color: Color.fromRGBO(
                                                                                          179, 179, 179, 1),
                                                                                      shape: BoxShape.circle,
                                                                                    ),
                                                                                    child: null,
                                                                                  );
                                                                          }),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Text(
                                                        "₽ " + snapshot.data[index].price,
                                                        style: TextStyle(color: Color.fromRGBO(77, 77, 77, 0.7)),
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
                                                    return TweenAnimationBuilder<double>(
                                                        tween: Tween<double>(begin: 0.0, end: 1.0),
                                                        curve: Curves.ease,
                                                        duration: const Duration(seconds: 1),
                                                        builder: (BuildContext context, double opacity, Widget child) {
                                                          return Opacity(
                                                            opacity: opacity,
                                                            child: GestureDetector(
                                                              onTap: () {
                                                                // _Dialog(
                                                                //     snapshot
                                                                //             .data[
                                                                //                 index]
                                                                //             .people[ind]
                                                                //         ["name"],
                                                                //     "sef",
                                                                //     snapshot
                                                                //             .data[
                                                                //                 index]
                                                                //             .people[ind]
                                                                //         ["name"],
                                                                //     int.parse(snapshot
                                                                //             .data[
                                                                //                 index]
                                                                //             .people[ind]
                                                                //         [
                                                                //         "grade"]));
                                                              },
                                                              child: Container(
                                                                height: 32,
                                                                margin: EdgeInsets.only(top: 10, left: 15, right: 15),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Container(
                                                                          margin: EdgeInsets.only(right: 10),
                                                                          width: 25,
                                                                          height: 25,
                                                                          child: ClipOval(
                                                                            child: Image.network(
                                                                              Config.ip +
                                                                                  '/getimages/' +
                                                                                  snapshot.data[index].people[ind]
                                                                                      ["name"] +
                                                                                  '.png',
                                                                              filterQuality: FilterQuality.low,
                                                                              fit: BoxFit.cover,
                                                                              errorBuilder:
                                                                                  (context, error, stackTrace) =>
                                                                                      Container(
                                                                                width: 25,
                                                                                height: 25,
                                                                                decoration: BoxDecoration(
                                                                                  color:
                                                                                      Color.fromARGB(255, 255, 40, 0),
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                                child: null,
                                                                              ),
                                                                              loadingBuilder: (BuildContext context,
                                                                                  Widget child,
                                                                                  ImageChunkEvent loadingProgress) {
                                                                                if (loadingProgress == null)
                                                                                  return child;
                                                                                return Center(
                                                                                  child: SizedBox(
                                                                                    width: 25,
                                                                                    height: 25,
                                                                                    child: CircularProgressIndicator(
                                                                                      color: Color.fromARGB(
                                                                                          255, 255, 40, 0),
                                                                                      // value: loadingProgress.expectedTotalBytes !=
                                                                                      //         null
                                                                                      //     ? loadingProgress.cumulativeBytesLoaded /
                                                                                      //         loadingProgress.expectedTotalBytes
                                                                                      //     : null,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          snapshot.data[index].people[ind]["name"]
                                                                              .toString(),
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
                                                                          child: Container(
                                                                            height: 32,
                                                                            width: 32,
                                                                            child:
                                                                                i < (snapshot.data[index].gradeint[ind])
                                                                                    ? Image.asset(
                                                                                        "assets/icon1.png",
                                                                                      )
                                                                                    : Image.asset(
                                                                                        "assets/icon2.png",
                                                                                        scale: 53,
                                                                                      ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  }),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              FlatButton(
                                                height: 50,
                                                minWidth: double.infinity,
                                                color: snapshot.data[index].people
                                                        .where((element) =>
                                                            element['name'] == context.read<UserProvider>().username)
                                                        .isEmpty
                                                    ? snapshot.data[index].people.length ==
                                                            snapshot.data[index].max_people
                                                        ? Color(0xffcccccc)
                                                        : snapshot.data[index].people.length <
                                                                snapshot.data[index].max_people
                                                            ? Color(0xffff2800)
                                                            : Color(0xff000000)
                                                    : snapshot.data[index].people.length <
                                                            snapshot.data[index].max_people + 1
                                                        ? Color(0xffcccccc)
                                                        : Color(0xff000000),
                                                textColor: Colors.white,
                                                splashColor: Colors.white,
                                                child: Text(
                                                  snapshot.data[index].people
                                                          .where((element) =>
                                                              element['name'] == context.read<UserProvider>().username)
                                                          .isEmpty
                                                      ? snapshot.data[index].people.length ==
                                                              snapshot.data[index].max_people
                                                          ? "Нет места"
                                                          : snapshot.data[index].people.length <
                                                                  snapshot.data[index].max_people
                                                              ? "Я поеду"
                                                              : "null"
                                                      : snapshot.data[index].people.length <
                                                              snapshot.data[index].max_people + 1
                                                          ? "Отменить"
                                                          : "null",
                                                  style: TextStyle(
                                                      fontSize: 17, color: Colors.white, fontWeight: FontWeight.w500),
                                                ),
                                                onPressed: () {
                                                  if (snapshot.data[index].people.length <
                                                      snapshot.data[index].max_people) {
                                                    if (snapshot.data[index].people
                                                        .where((element) =>
                                                            element['name'] == context.read<UserProvider>().username)
                                                        .isEmpty) {
                                                      _addusername2(snapshot.data[index].idd);
                                                    } else {
                                                      _delUser(snapshot.data[index].idd);
                                                    }
                                                  } else if (!snapshot.data[index].people
                                                      .where((element) =>
                                                          element['name'] == context.read<UserProvider>().username)
                                                      .isEmpty) {
                                                    _delUser(snapshot.data[index].idd);
                                                  }
                                                },
                                              ),
                                            ],
                                            onExpansionChanged: (bool expanding) =>
                                                setState(() => this.isExpanded = expanding),
                                          ),
                                          Positioned(
                                            top: 65,
                                            child: Center(
                                                child: Column(
                                              children: [
                                                Text(
                                                  'собираемся тут:',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromRGBO(77, 77, 77, 0.7),
                                                  ),
                                                ),
                                                Text(
                                                  snapshot.data[index].place,
                                                  style: TextStyle(fontSize: 28, color: Color.fromRGBO(77, 77, 77, 1)),
                                                )
                                              ],
                                            )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ));
                      }),
                );
            }
          }),
    );
  }
}

class Event {
  String idd;
  String time;
  String route;
  String place;
  int max_people;
  String price;
  String usercreate;
  List people;
  List gradeint;

  set alla(List s) {
    gradeint = s;
  }

  Event(this.idd, this.time, this.place, this.route, this.max_people, this.price, this.people, this.usercreate);
}
