// ignore_for_file: file_names
// ignore_for_file: file_names, prefer_const_constructors, curly_braces_in_flow_control_structures
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter_application_3/EditUser.dart';
import 'package:flutter_application_3/LoginPage.dart';
import 'package:flutter_application_3/UserProvider.dart';
import 'package:flutter_application_3/config.dart';
import 'package:flutter_application_3/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:avatar_view/avatar_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/Lenta.dart';
import 'package:flutter_application_3/custom_expansion_tile.dart' as custom;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cross_file_image/cross_file_image.dart';

class EditUserPage extends StatefulWidget {
  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  upload(File imageFile) async {
    var stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse(Config.ip + "/image");
    var request = http.MultipartRequest("POST", uri);
    var multipartFile = http.MultipartFile('file', stream, length, filename: basename(imageFile.path));
    request.fields['name'] = Provider.of<UserProvider>(this.context, listen: false).get_username;
    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
      _deleteImageFromCache(
          '${Config.ip + '/getimages/' + Provider.of<UserProvider>(this.context, listen: false).get_username + '.png'}');
      showBottomToast("фото обновлено", true);
      setState(() {});
    });
  }

  Future _deleteImageFromCache(String url) async {
    await CachedNetworkImage.evictFromCache(url);
  }

  final toast = FToast();

  void initState() {
    super.initState();
    toast.init(this.context);
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

  SharedPreferences pref;
  ImagePicker picker = ImagePicker();
  XFile image;

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
                GestureDetector(
                  onTap: () async {
                    image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                    upload(File(image.path));
                    setState(() {});
                  },
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      children: [
                        CachedNetworkImage(
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
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.error,
                            color: Colors.transparent,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Center(
                          child: Icon(
                            Icons.add_outlined,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ],
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
                  margin: EdgeInsets.only(top: 10, right: 35, left: 35),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                          right: 12,
                          child: Icon(
                            Icons.edit,
                            color: Color.fromRGBO(77, 77, 77, 0.5),
                            size: 20,
                          )),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          //controller: _logincontroller,
                          style: TextStyle(color: Colors.black),
                          cursorWidth: 1,
                          cursorColor: Color.fromARGB(255, 255, 40, 0),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Имя",
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(77, 77, 77, 1),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  decoration:
                      BoxDecoration(color: Color.fromRGBO(242, 242, 242, 1), borderRadius: BorderRadius.circular(10)),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, right: 35, left: 35),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                          right: 12,
                          child: Icon(
                            Icons.edit,
                            color: Color.fromRGBO(77, 77, 77, 0.5),
                            size: 20,
                          )),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          //controller: _logincontroller,
                          style: TextStyle(color: Colors.black),
                          cursorWidth: 1,
                          cursorColor: Color.fromARGB(255, 255, 40, 0),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Фамилия",
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(77, 77, 77, 1),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  decoration:
                      BoxDecoration(color: Color.fromRGBO(242, 242, 242, 1), borderRadius: BorderRadius.circular(10)),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  margin: EdgeInsets.only(top: 20, right: 35, left: 35),
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      //_login(_logincontroller.text, _passcontroller.text);
                    },
                    child: Text(
                      'Сохранить',
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
                  margin: EdgeInsets.only(top: 10, right: 35, left: 35),
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      pref = await SharedPreferences.getInstance();
                      pref.clear();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (route) => false);
                    },
                    child: Text(
                      'сменить аккаунт',
                      style: TextStyle(color: Color.fromRGBO(77, 77, 77, 0.5), fontWeight: FontWeight.w500),
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
