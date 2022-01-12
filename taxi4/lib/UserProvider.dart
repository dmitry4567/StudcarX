// ignore_for_file: file_names, non_constant_identifier_names
import 'package:flutter/cupertino.dart';

class UserProvider extends ChangeNotifier {
  String username;
  String firstname;
  String secondname;
  int grade;

  String get get_username => username;
  String get get_firstname => firstname;
  String get get_secondname => secondname;
  int get get_grade => grade;

  void changeData(String newUsername, String newFirstname, String newSecondname, int newGrade) {
    username = newUsername;
    firstname = newFirstname;
    secondname = newSecondname;
    grade = newGrade;
    notifyListeners();
  }

  void changeGrade(int newGrade) {
    grade = newGrade;
    notifyListeners();
  }
}
