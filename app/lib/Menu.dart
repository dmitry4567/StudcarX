// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_3/ApplicPage.dart';
import 'package:flutter_application_3/ProfilePage.dart';
import 'Lenta.dart';

class Menu extends StatefulWidget {
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  int currentIndex = 0;

  callPage(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return Lenta();
      case 1:
        return ApplicPage();
      case 2:
        return ProfilePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: callPage(currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          iconSize: 26,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color.fromARGB(255, 255, 40, 0),
          currentIndex: currentIndex,
          onTap: (value) {
            currentIndex = value;
            setState(() {});
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_rounded,
                color: Colors.white,
              ),
              title: Text(
                '',
                style: TextStyle(
                  color: Color.fromARGB(255, 153, 154, 158),
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_outlined,
                color: Colors.white,
              ),
              title: Text(
                '',
                style: TextStyle(
                  color: Color.fromARGB(255, 153, 154, 158),
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.directions_car_filled,
                color: Colors.white,
              ),
              title: Text(
                '',
                style: TextStyle(
                  color: Color.fromARGB(255, 153, 154, 158),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
