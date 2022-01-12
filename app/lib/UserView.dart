// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_application_3/UserProvider.dart';
import 'package:provider/src/provider.dart';

import 'config.dart';

class UserViewPage extends StatefulWidget {
  @override
  _UserViewPageState createState() => _UserViewPageState();
}

class _UserViewPageState extends State<UserViewPage> {
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
              children: [
                ClipOval(
                  child: Container(
                    width: 200,
                    height: 200,
                    child: Image.network(
                      Config.ip + '/getimages/' + context.read<UserProvider>().username + '.png',
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.low,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 100,
                            height: 100,
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
                SizedBox(
                  height: 15,
                ),
                Text(
                  "персональные данные",
                  style: TextStyle(
                    color: Color.fromRGBO(77, 77, 77, 0.5),
                  ),
                ),
                Container(
                  height: 40,
                  child: ListView.builder(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (_, i) {
                        return Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 40,
                            width: 40,
                            child: i < 3
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
