import 'dart:convert';

FacultyRegisterData facultyRegisterDataFromJson(String str) => FacultyRegisterData.fromJson(json.decode(str));

String facultyRegisterDataToJson(FacultyRegisterData data) => json.encode(data.toJson());

class FacultyRegisterData {
  FacultyRegisterData({
    this.isSuccess,
    this.message,
  });

  bool isSuccess;
  String message;

  factory FacultyRegisterData.fromJson(Map<String, dynamic> json) => FacultyRegisterData(
    isSuccess: json["IsSuccess"],
    message: json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "IsSuccess": isSuccess,
    "Message": message,
  };
}


FacultyAttendance facultyAttendanceFromJson(String str) => FacultyAttendance.fromJson(json.decode(str));

String facultyAttendanceToJson(FacultyAttendance data) => json.encode(data.toJson());

class FacultyAttendance {
  FacultyAttendance({
    this.isSuccess,
    this.data,
    this.message,
  });

  bool isSuccess;
  List<facultydata> data;
  String message;

  factory FacultyAttendance.fromJson(Map<String, dynamic> json) => FacultyAttendance(
    isSuccess: json["IsSuccess"],
    data: List<facultydata>.from(json["Data"].map((x) => facultydata.fromJson(x))),
    message: json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "IsSuccess": isSuccess,
    "Data": List<dynamic>.from(data.map((x) => x.toJson())),
    "Message": message,
  };
}

class facultydata {
  facultydata({
    this.id,
    this.facultyData,
    this.date,
    this.time,
    this.lat,
    this.long,
    this.v,
  });

  String id;
  FacultyData facultyData;
  String date;
  String time;
  String lat;
  String long;
  int v;

  factory facultydata.fromJson(Map<String, dynamic> json) => facultydata(
    id: json["_id"],
    facultyData: FacultyData.fromJson(json["facultyData"]),
    date: json["date"],
    time: json["time"],
    lat: json["lat"],
    long: json["long"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "facultyData": facultyData.toJson(),
    "date": date,
    "time": time,
    "lat": lat,
    "long": long,
    "__v": v,
  };
}

class FacultyData {
  FacultyData({
    this.id,
    this.name,
    this.mobile,
    this.email,
    this.address,
    this.department,
    this.designation,
    this.v,
  });

  String id;
  String name;
  String mobile;
  String email;
  String address;
  String department;
  String designation;
  int v;

  factory FacultyData.fromJson(Map<String, dynamic> json) => FacultyData(
    id: json["_id"],
    name: json["name"],
    mobile: json["mobile"],
    email: json["email"],
    address: json["address"],
    department: json["department"],
    designation: json["designation"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "mobile": mobile,
    "email": email,
    "address": address,
    "department": department,
    "designation": designation,
    "__v": v,
  };
}