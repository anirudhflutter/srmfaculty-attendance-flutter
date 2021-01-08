import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srm_faculty_attendance/Common/Services.dart';
import 'package:srm_faculty_attendance/Common/constants.dart' as cnst;
import 'package:srm_faculty_attendance/firebaseauth/providers/phone_auth.dart';
import 'dart:convert' as convert;

import 'package:srm_faculty_attendance/firebaseauth/utils/constants.dart';
import 'package:srm_faculty_attendance/screens/HomeScreen.dart';


class PhoneAuthVerify extends StatefulWidget {
  bool register;
  PhoneAuthVerify({this.register});
  /*
   *  cardBackgroundColor & logo values will be passed to the constructor
   *  here we access these params in the _PhoneAuthState using "widget"
   */
  final Color cardBackgroundColor = Color(0xFFFCA967);
  final String logo = Assets.firebase;
  final String appName = "Attendance App";

  @override
  _PhoneAuthVerifyState createState() => _PhoneAuthVerifyState();
}

class _PhoneAuthVerifyState extends State<PhoneAuthVerify> {
  double _height, _width, _fixedPadding;

  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  FocusNode focusNode5 = FocusNode();
  FocusNode focusNode6 = FocusNode();
  String code = "";

  @override
  void initState() {
    print(widget.register);
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
    super.initState();
  }

  final scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: "scaffold-verify-phone");

  @override
  Widget build(BuildContext context) {
    //  Fetching height & width parameters from the MediaQuery
    //  _logoPadding will be a constant, scaling it according to device's size
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _fixedPadding = _height * 0.025;

    final phoneAuthDataProvider =
        Provider.of<PhoneAuthDataProvider>(context, listen: false);

    phoneAuthDataProvider.setMethods(
      onStarted: onStarted,
      onError: onError,
      onFailed: onFailed,
      onVerified: onVerified,
      onCodeResent: onCodeResent,
      onCodeSent: onCodeSent,
      onAutoRetrievalTimeout: onAutoRetrievalTimeOut,
    );

    /*
     *  Scaffold: Using a Scaffold widget as parent
     *  SafeArea: As a precaution - wrapping all child descendants in SafeArea, so that even notched phones won't loose data
     *  Center: As we are just having Card widget - making it to stay in Center would really look good
     *  SingleChildScrollView: There can be chances arising where
     */
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.deepOrange.withOpacity(0.95),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: _getBody(),
          ),
        ),
      ),
    );
  }

  /*
   *  Widget hierarchy ->
   *    Scaffold -> SafeArea -> Center -> SingleChildScrollView -> Card()
   *    Card -> FutureBuilder -> Column()
   */
  Widget _getBody() => Card(
        color: Colors.white,
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: SizedBox(
          height: _height * 8 / 10,
          width: _width * 8 / 10,
          child: _getColumnBody(),
        ),
      );

  Widget _getColumnBody() => Column(
        children: <Widget>[
          //  Logo: scaling to occupy 2 parts of 10 in the whole height of device
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          Container(
            color: Color(0xFFf26f3c),
            child: Center(
              child: Hero(
                tag: "fromSplashToLangOrHome",
                child: SizedBox(
                    width: 390,
                    child: Image(
                      image: AssetImage('assets/images/srm-logo.png'),
                    )),
              ),
            ),
          ),

          // AppName:
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(widget.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700)),
          ),

          SizedBox(height: 20.0),

          //  Info text
          Row(
            children: <Widget>[
              SizedBox(width: 16.0),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: 'Please enter the ',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400)),
                      TextSpan(
                          text: 'One Time Password',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700)),
                      TextSpan(
                        text: ' sent to your mobile Number',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16.0),
            ],
          ),
          SizedBox(height: 16.0),
          PinCodeTextField(
            appContext: context,
            pastedTextStyle: TextStyle(
              color: Colors.green.shade600,
              fontWeight: FontWeight.bold,
            ),
            length: 6,
            keyboardType: TextInputType.number,
            obscureText: false,
            // obscuringCharacter: '*',
            animationType: AnimationType.fade,
            onCompleted: (pin) {
              code = pin;
              print("completed");
            },
          ),
          SizedBox(height: 32.0),

          RaisedButton(
            elevation: 16.0,
            onPressed: signIn,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'VERIFY',
                style: TextStyle(color: Colors.black, fontSize: 18.0),
              ),
            ),
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
          )
        ],
      );

  _showSnackBar(String text) {
    final snackBar = SnackBar(
      content: Text('$text'),
      duration: Duration(seconds: 2),
    );
//    if (mounted) Scaffold.of(context).showSnackBar(snackBar);
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  signIn() {
    if (code.length != 6) {
      _showSnackBar("Invalid OTP");
    }
    Provider.of<PhoneAuthDataProvider>(context, listen: false)
        .verifyOTPAndLogin(smsCode: code);
  }

  // This will return pin field - it accepts only single char
  Widget getPinField({String key, FocusNode focusNode}) => SizedBox(
        height: 40.0,
        width: 35.0,
        child: TextField(
          key: Key(key),
          expands: false,
//          autofocus: key.contains("1") ? true : false,
          autofocus: false,
          focusNode: focusNode,
          onChanged: (String value) {
            if (value.length == 1) {
              code += value;
              switch (code.length) {
                case 1:
                  FocusScope.of(context).requestFocus(focusNode2);
                  break;
                case 2:
                  FocusScope.of(context).requestFocus(focusNode3);
                  break;
                case 3:
                  FocusScope.of(context).requestFocus(focusNode4);
                  break;
                case 4:
                  FocusScope.of(context).requestFocus(focusNode5);
                  break;
                case 5:
                  FocusScope.of(context).requestFocus(focusNode6);
                  break;
                default:
                  FocusScope.of(context).requestFocus(FocusNode());
                  break;
              }
            }
          },
          maxLengthEnforced: false,
          textAlign: TextAlign.center,
          cursorColor: Colors.black,

          keyboardType: TextInputType.number,
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      );

  onStarted() {
    _showSnackBar("PhoneAuth started");
//    _showSnackBar(phoneAuthDataProvider.message);
  }

  onCodeSent() {
    _showSnackBar("OTP sent");
//    _showSnackBar(phoneAuthDataProvider.message);
  }

  onCodeResent() {
    _showSnackBar("OTP resent");
//    _showSnackBar(phoneAuthDataProvider.message);
  }

  ProgressDialog pr;
  bool isLoading = false;
  int currentLoading = 0;

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

  LoginFaculty(String mobileNumber) async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        pr.show();
        setState(() {
          isLoading = true;
        });
        var data = {
          "mobile": mobileNumber,
        };
        Services.LoginFaculty(data).then((data) async {
          pr.hide();
          SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
          print("response from login User function");
          print(data);
          if (data["IsSuccess"] == true) {
            pr.hide();
            sharedPreferences.setString(cnst.id, data["Data"][0]["_id"].toString());
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => HomeScreen()));
          } else {
            pr.hide();
            showMsg("${data["Message"]}");
          }
        }, onError: (e) {
          pr.hide();
          showMsg("Try Again.");
        });
      } else {
        setState(() {
          isLoading = false;
        });
        pr.hide();
        showMsg("No Internet Connection.");
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }



  RegisterFaculty(String mobileNumber) async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        pr.show();
        setState(() {
          isLoading = true;
        });
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();

        var data = {
          "name" : sharedPreferences.getString(cnst.name),
          "mobile" : sharedPreferences.getString(cnst.mobilenumber),
          "email" : sharedPreferences.getString(cnst.email),
          "address" : sharedPreferences.getString(cnst.address),
          "department" : sharedPreferences.getString(cnst.department),
          "designation" : sharedPreferences.getString(cnst.designation),
        };

        Services.RegisterFaculty(data).then((data) async {
          pr.hide();
          if (data.isSuccess == true) {
            Fluttertoast.showToast(
                msg: "${data.message}",
                backgroundColor: Colors.red,
                gravity: ToastGravity.TOP,
                toastLength: Toast.LENGTH_SHORT);
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomeScreen())
            );
          } else {
            pr.hide();
            showMsg(data.message);
          }
        }, onError: (e) {
          pr.hide();
          showMsg("Try Again.");
        });
      } else {
        setState(() {
          isLoading = false;
        });
        pr.hide();
        showMsg("No Internet Connection.");
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }

  onVerified() async {
    print("onverifiedcalled");
    _showSnackBar(
        "${Provider.of<PhoneAuthDataProvider>(context, listen: false).message}");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var number = sharedPreferences.getString(cnst.mobilenumber);
    if (widget.register == true) {
      RegisterFaculty(number);
    } else {
      LoginFaculty(number);
    }
  }

  onFailed() {
    _showSnackBar("PhoneAuth failed");
  }

  onError() {
//    _showSnackBar(phoneAuthDataProvider.message);
    print("onerrorcalled");
    _showSnackBar(
        "PhoneAuth error ${Provider.of<PhoneAuthDataProvider>(context, listen: false).message}");
  }

  onAutoRetrievalTimeOut() {
    _showSnackBar("PhoneAuth autoretrieval timeout");
//    _showSnackBar(phoneAuthDataProvider.message);
  }
}
