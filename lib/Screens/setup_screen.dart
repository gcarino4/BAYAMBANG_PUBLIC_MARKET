import 'package:flutter/material.dart';
import 'package:public_market/Screens/home_screen.dart';
import 'package:public_market/Screens/login_screen.dart';
import 'package:public_market/Screens/summary.dart';
import 'package:public_market/Screens/upload_data.dart';
import 'package:public_market/Screens/download_data.dart';
import 'package:public_market/Screens/settings_screen.dart';
import 'package:public_market/Screens/setup_screen.dart';
import 'package:public_market/Screens/profile_screen.dart';

import 'globals.dart';

class SetUp extends StatelessWidget {
  final TextEditingController terminalIdController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
          size: 40, /// set the color of the AppBar buttons
        ),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 50, 0),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png', // replace this with the path to your image
                height: 60, // set the height of the image
              ),
            ),
          ),
        ),
        elevation: 0,
        toolbarHeight: 80,
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'SET UP',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            TextFormField(
              controller: terminalIdController,
              decoration: InputDecoration(
                hintText: 'TERMINAL ID',
                labelText: 'TERMINAL ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),

            SizedBox(height: 10),

            TextFormField(

              decoration: InputDecoration(
                hintText: 'AMBULANT COLLECTION NEXT NO.',
                labelText: 'AMBULANT COLLECTION NEXT NO.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    TerminalIdSingleton().terminalId = terminalIdController.text;

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Success'),
                          content: Text('Terminal ID set successfully.'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Done'),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF03519D),
                    minimumSize: Size(120, 50), // adjust size as needed
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
