import 'dart:convert';

import 'package:dio/dio.dart';
import '../Common/constants.dart' as cnst;
import 'ClassList.dart';

Dio dio = new Dio();

class Services {
  static Future<FacultyRegisterData> RegisterFaculty(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'api/faculty/register';
    print("RegisterFaculty url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        FacultyRegisterData saveData =
            new FacultyRegisterData(isSuccess: false,message: "No message found");
        print("RegisterFaculty Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.message = memberDataClass["Message"];
        saveData.isSuccess = memberDataClass["IsSuccess"];

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("RegisterFaculty Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<Map> LoginFaculty(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'api/faculty/login';
    print("LoginFaculty url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        print("LoginFaculty Response: " + response.data.toString());
        return response.data;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("LoginFaculty Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<FacultyAttendance> facultyAttendance(body) async {
    print(body.toString());
    String url = cnst.API_URL + 'api/attendance';
    print("FacultyAttendance url : " + url);
    try {
      final response = await dio.post(url, data: body);
      if (response.statusCode == 200) {
        FacultyAttendance saveData =
        new FacultyAttendance(isSuccess: false,message: "No message found");
        print("FacultyAttendance Response: " + response.data.toString());
        var memberDataClass = response.data;
        saveData.message = memberDataClass["Message"];
        saveData.isSuccess = memberDataClass["IsSuccess"];
        saveData.data = memberDataClass["Data"];

        return saveData;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("FacultyAttendance Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  static Future<Map> getAllData() async {
    String url = cnst.API_URL + 'api/faculty/getalldata';
    print("getAllData url : " + url);
    try {
      final response = await dio.post(url);
      if (response.statusCode == 200) {
        print("getAllData Response: " + response.data.toString());
        var memberDataClass = response.data;
        return memberDataClass;
      } else {
        throw Exception(response.data.toString());
      }
    } catch (e) {
      print("getAllData Error ${e.toString()}");
      throw Exception(e.toString());
    }
  }

}
