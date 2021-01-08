import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String scanResult = '';

  Future scanQRCode() async {
    String cameraScanResult = await scanner.scan();
    setState(() {
      scanResult = cameraScanResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance System"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height*0.4,
            ),
            Container(
              color: Colors.blue,
              child: RaisedButton(
                color: Colors.blue,
                onPressed: () {
                  scanQRCode();
                },
                child: Text("Scan QR Code",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            scanResult == '' || scanResult == null ? Text('Result will be displayed here') : Text(scanResult),
          ],
        ),
      ),
    );
  }
}
