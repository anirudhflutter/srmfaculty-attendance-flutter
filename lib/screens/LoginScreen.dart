import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srm_faculty_attendance/Common/Services.dart';
import 'package:srm_faculty_attendance/Common/constants.dart' as cnst;
import 'package:srm_faculty_attendance/firebaseauth/firebase/auth/phone_auth/verify.dart';
import 'package:srm_faculty_attendance/firebaseauth/providers/phone_auth.dart';

import '../CustomTextField.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ProgressDialog pr;

  TextEditingController edtname = new TextEditingController();
  TextEditingController edtmobile = new TextEditingController();
  TextEditingController edtemail = new TextEditingController();
  TextEditingController edtaddress = new TextEditingController();
  TextEditingController edtdepartment = new TextEditingController();
  TextEditingController edtdesignation = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PersistentBottomSheetController _sheetController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _displayName;
  String _mobileNo;
  bool _loading = false;
  List getallData = [];

  @override
  void dispose() {
    super.dispose();
    edtname.dispose();
    edtmobile.dispose();
    edtemail.dispose();
    edtaddress.dispose();
    edtdepartment.dispose();
    edtdesignation.dispose();
  }

  @override
  void initState() {
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(
        message: "Please Wait",
        borderRadius: 10.0,
        progressWidget: Container(
          padding: EdgeInsets.all(15),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(cnst.appPrimaryMaterialColor),
          ),
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        messageTextStyle: TextStyle(
            color: Colors.red, fontSize: 17.0, fontWeight: FontWeight.w600));
    // TODO: implement initState
    super.initState();
  }

  showMsg(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final scaffoldKey =
  GlobalKey<ScaffoldState>(debugLabel: "scaffold-get-phone");

  _showSnackBar(String text) {
    final snackBar = SnackBar(
      content: Text('$text'),
    );
//    if (mounted) Scaffold.of(context).showSnackBar(snackBar);
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  startPhoneAuth({String login}) async {
    if(login == "") {
      SharedPreferences sharedPreferences = await SharedPreferences
          .getInstance();
      sharedPreferences.setString(cnst.mobilenumber, edtmobile.text);
      sharedPreferences.setString(cnst.name, edtname.text);
      sharedPreferences.setString(cnst.email, edtemail.text);
      sharedPreferences.setString(cnst.address, edtaddress.text);
      sharedPreferences.setString(cnst.department, edtdepartment.text);
      sharedPreferences.setString(cnst.designation, edtdesignation.text);
    }
    else{
      SharedPreferences sharedPreferences = await SharedPreferences
          .getInstance();
      sharedPreferences.setString(cnst.mobilenumber, edtmobile.text);
      sharedPreferences.setString(cnst.name, edtname.text);
      sharedPreferences.setString(cnst.email, edtemail.text);
      sharedPreferences.setString(cnst.address, edtaddress.text);
      sharedPreferences.setString(cnst.department, edtdepartment.text);
      sharedPreferences.setString(cnst.designation, edtdesignation.text);
    }
    final phoneAuthDataProvider =
    Provider.of<PhoneAuthDataProvider>(context, listen: false);
    phoneAuthDataProvider.loading = true;
    bool validPhone = await phoneAuthDataProvider.instantiate(
        phoneNumberField: edtmobile,
        dialCode: "+91",
        onCodeSent: () {
          print("startedphoneauth");
          if(login=="login"){
            Navigator.of(context).pushReplacement(CupertinoPageRoute(
                builder: (BuildContext context) =>
                    PhoneAuthVerify(register: false,)));
          }
          else{
            Navigator.of(context).pushReplacement(CupertinoPageRoute(
                builder: (BuildContext context) =>
                    PhoneAuthVerify(register: true,)));
          }
        },
        onFailed: () {
          _showSnackBar(phoneAuthDataProvider.message);
        },
        onError: () {
          _showSnackBar(phoneAuthDataProvider.message);
        });
    if (!validPhone) {
      phoneAuthDataProvider.loading = false;
      _showSnackBar("Oops! Number seems invaild");
      return;
    }
  }

  checkFaculty({String login}) async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        pr.show();
        Services.getAllData().then((data) async {
          pr.hide();
          bool userfound = false;
          if(login=="login"){
            if (data["Data"] != 0) {
              getallData = data["Data"];
              for(int i=0;i<getallData.length;i++){
                if(getallData[i]["mobile"] == edtmobile.text){
                  userfound = true;
                  startPhoneAuth(login: login);
                  break;
                }
              }
              if(!userfound){
                showMsg("Mobile number not found please register first");
              }
            }
            else{
              showMsg("Mobile number not found please register first");
            }
          }
          else{
            if (data["Data"] != 0) {
              getallData = data["Data"];
              for(int i=0;i<getallData.length;i++){
                if(getallData[i]["mobile"] == edtmobile.text){
                  userfound = true;
                  showMsg("Already Registered Please Login");
                  break;
                }
              }
              if(!userfound){
                startPhoneAuth(login: login);
              }
            }
            else{
              startPhoneAuth(login: login);
            }
          }
        }, onError: (e) {
          pr.hide();
          showMsg("Try Again.");
        });
      } else {
        pr.hide();
        showMsg("No Internet Connection.");
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    Widget filledButton(String text, Color splashColor, Color highlightColor,
        Color fillColor, Color textColor,
        {void function()}
        ) {
      return RaisedButton(
        highlightElevation: 0.0,
        splashColor: splashColor,
        highlightColor: highlightColor,
        elevation: 0.0,
        color: Colors.blue,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
        child: Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          function();
        },
      );
    }

    String validateMobile(String value) {
      String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
      RegExp regExp = new RegExp(pattern);
      if (value.length == 0) {
        return 'Please enter mobile number';
      }
      else if (!regExp.hasMatch(value)) {
        return 'Please enter valid mobile number';
      }
      return null;
    }

    void loginSheet() {
      _sheetController = _scaffoldKey.currentState
          .showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).canvasColor),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0)),
            child: Container(
              child: ListView(
                children: <Widget>[
                  Container(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.close,
                          size: 30.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    height: 50,
                    width: 50,
                  ),
                  SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        autovalidate: _autoValidate,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height:MediaQuery.of(context).size.height*0.1,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 140,
                              child: Container(
                                child: Image.asset('assets/images/srm-logo.png',
                                  fit: BoxFit.fill,),
                                alignment: Alignment.center,
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(bottom: 20, top: 60),
                                child: CustomTextField(
                                  onSaved: (input) {
                                    _mobileNo = input;
                                  },
                                  controller: edtmobile,
                                  keyboardType: TextInputType.number,
                                  validator: validateMobile,
                                  icon: Icon(Icons.mobile_friendly),
                                  hint: "Mobile Number",
                                )),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: _loading == true
                                  ? CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    primaryColor),
                              )
                                  : Container(
                                child: RaisedButton(
                                  highlightElevation: 0.0,
                                  splashColor: Colors.blue,
                                  highlightColor: Colors.blue,
                                  elevation: 0.0,
                                  color: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(30.0)),
                                  child: Text(
                                    "LOGIN",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () {
                                    if(edtmobile.text == ""){
                                      Fluttertoast.showToast(
                                          msg: "Please enter mobile number first",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.TOP,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    }
                                    else{
                                      checkFaculty(login : "login");
                                    }
                                  },
                                ),
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      )),
                ],
              ),
              height: MediaQuery.of(context).size.height / 1.1,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
            ),
          ),
        );
      });
    }

    outlineButton(void function()) {
      return RaisedButton(
        highlightElevation: 0.0,
        splashColor: Colors.blue,
        highlightColor: Colors.blue,
        elevation: 0.0,
        color: Colors.blue,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
        child: Text(
          "REGISTER",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          function();
        },
      );
    }

    String emailValidator(String value) {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (value.isEmpty) return '*Required';
      if (!regex.hasMatch(value))
        return '*Enter a valid email';
      else
        return null;
    }

    void registerSheet() {
      _sheetController = _scaffoldKey.currentState
          .showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).canvasColor),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0)),
            child: Container(
              child: ListView(
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 10,
                          top: 10,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.close,
                              size: 30.0,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      ],
                    ),
                    height: 50,
                    width: 50,
                  ),
                  SingleChildScrollView(
                      child: Form(
                        child: Column(children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 140,
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  child: Align(
                                    child: Container(
                                      width: 130,
                                      height: 130,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).primaryColor),
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                ),
                                Positioned(
                                  child: Container(
                                    child: Image.asset('assets/images/srm-logo.png',
                                      fit: BoxFit.fill,),
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                bottom: 17,
                                top: 50,
                              ),
                              child: CustomTextField(
                                icon: Icon(Icons.account_circle),
                                hint: "DISPLAY NAME",
                                controller: edtname,
                                validator: (input) =>
                                input.isEmpty ? "*Required" : null,
                                onSaved: (input) => _displayName = input,
                              )),
                          Padding(
                              padding: EdgeInsets.only(bottom: 17),
                              child: CustomTextField(
                                icon: Icon(Icons.mobile_friendly),
                                controller: edtmobile,
                                keyboardType: TextInputType.number,
                                validator: (input) =>
                                input.isEmpty ? "*Required" : null,
                                hint: "Mobile No.",
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                bottom: 17,
                              ),
                              child: CustomTextField(
                                icon: Icon(Icons.email),
                                controller: edtemail,
                                validator: emailValidator,
                                hint: "EMAIL",
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                bottom: 17,
                              ),
                              child: CustomTextField(
                                icon: Icon(Icons.location_on),
                                controller: edtaddress,
                                hint: "ADDRESS",
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                bottom: 17,
                              ),
                              child: CustomTextField(
                                icon: Icon(Icons.email),
                                controller: edtdepartment,
                                hint: "DEPARTMENT",
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                bottom: 17,
                              ),
                              child: CustomTextField(
                                icon: Icon(Icons.email),
                                controller: edtdesignation,
                                hint: "DESIGNATION",
                              )),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: MediaQuery.of(context).viewInsets.bottom),
                            child: _loading
                                ? CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  primaryColor),
                            )
                                : Container(
                              child: RaisedButton(
                                highlightElevation: 0.0,
                                splashColor: Colors.blue,
                                highlightColor: Colors.blue,
                                elevation: 0.0,
                                color: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(30.0)),
                                child: Text(
                                  "REGISTER",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                                ),
                                onPressed: () {
                                  print("register tapped");
                                  if(edtname.text == "" || edtmobile.text == "" || edtemail.text=="" || edtaddress.text=="" || edtdepartment.text==""
                                      || edtdesignation.text==""){
                                    Fluttertoast.showToast(
                                        msg: "Please fill all the fields",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.TOP,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  }
                                  else{
                                    checkFaculty();
                                  }
                                  // function();
                                },
                              ),
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ]),
                        key: _formKey,
                        autovalidate: _autoValidate,
                      )),
                ],
              ),
              height: MediaQuery.of(context).size.height / 1.1,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
            ),
          ),
        );
      });
    }

    bodyWidget(){
      return Column(
        children: <Widget>[
          // logo(),
          SizedBox(
            height:MediaQuery.of(context).size.height*0.3,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 140,
            child: Container(
              child: Image.asset('assets/images/srm-logo.png',
                fit: BoxFit.fill,),
              alignment: Alignment.center,
            ),
          ),
          Padding(
            child: Container(
              child: filledButton("LOGIN", primaryColor, Colors.blue,
                  Colors.white, primaryColor, function : loginSheet),
              height: 50,
            ),
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
                left: 20,
                right: 20),
          ),
          Padding(
            child: Container(
              child: outlineButton(registerSheet),
              height: 50,
            ),
            padding: EdgeInsets.only(top: 10, left: 20, right: 20),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      );
    }

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        body: bodyWidget());
  }
}
