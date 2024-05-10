import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:public_market/Screens/home_screen.dart';
import 'package:public_market/Screens/login_screen.dart';
import 'package:public_market/Screens/download_data.dart';
import 'package:public_market/Screens/setup_screen.dart';
import 'package:public_market/Screens/settings_screen.dart';
import 'package:public_market/Screens/profile_screen.dart';
import 'package:public_market/Screens/summary.dart';
import 'package:public_market/Screens/summary.dart';
import 'package:public_market/Screens/upload_data.dart';
import 'globals.dart';
import 'ProfileData.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final terminalId = TerminalIdSingleton().terminalId;
// Declare the timer variable
  bool backButtonDisabled = true;
  bool homeButtonDisabled = true;
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
 // Start the session timer when the screen is initialized
  }

  Future<File> getImageFromExternalStorage() async {
    // Get the external storage directory
    Directory? externalDir = await getExternalStorageDirectory();

    if (externalDir == null) {
      throw FileSystemException("External storage directory not found.");
    }

    // Construct the file path
    String filePath = '${externalDir.path}/my_image.png';

    // Check if the file exists and is not empty
    File imageFile = File(filePath);
    if (!await imageFile.exists() || (await imageFile.length() == 0)) {
      // If the file doesn't exist or is empty, return null
      return Future.error(FileSystemException("Image file not found or empty."));
    }

    // Return the file
    return imageFile;
  }


// Example usage:
  void main() async {
    try {
      File imageFile = await getImageFromExternalStorage();
      // Now you can use 'imageFile' wherever you need
      print("Image file retrieved: ${imageFile.path}");
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void dispose() {
   // Cancel the timer when the screen is disposed
    super.dispose();
    BackButtonInterceptor.add(myInterceptor);
  }


  @override
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    return true;
  }
  Widget build(BuildContext context) {
    final apiResponseProvider = Provider.of<ApiResponseProvider>(context);

    // Access the apiResponseData from the provider
    final responseData = apiResponseProvider.apiResponseData;
    return WillPopScope(
        onWillPop: () async {
      if (backButtonDisabled) {
        // If the back button is disabled, open the app's drawer
        Scaffold.of(context).openDrawer();
        return false; // Prevent navigating back
      }
      return false;
    },child: Scaffold(
      appBar:  AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 40,
        ),
        title: Row(
          mainAxisAlignment:
          MainAxisAlignment.center, // Center the logo horizontally
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 50, 0),
              child: FutureBuilder<File>(
                future: getImageFromExternalStorage(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    // Display default image when external storage is empty or there's an error
                    return Image.asset(
                      'assets/images/logo.png',
                      height: 60,
                    );
                  } else {
                    // Use the image from external storage when available
                    return Image.file(
                      snapshot.data!,
                      height: 60,
                    );
                  }
                },
              ),
            ),
          ],
        ),
        elevation: 0,
        toolbarHeight: 80,
        actions: const [
          // Add your actions here
        ],
      ),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // Drawer header with an image
              Container(
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/marketbanner.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 15),
              // List of drawer items
              ListTile(
                leading: Icon(Icons.home, color: Colors.blue[900]),
                title: Text('AMBULANT COLLECTION',
                    style: TextStyle(color: Colors.black, fontSize: 18.0)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.cloud_download, color: Colors.blue[900]),
                title: Text('DOWNLOAD DATA',
                    style: TextStyle(color: Colors.black, fontSize: 18.0)),
                onTap: () {
                  // TODO: navigate to Download Data Screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => DownloadData()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.cloud_upload, color: Colors.blue[900]),
                title:
                Text('UPLOAD DATA', style: TextStyle(color: Colors.black, fontSize: 18.0)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => UploadData()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.list, color: Colors.blue[900]),
                title: Text('SUMMARY OF TRANSACTION',
                    style: TextStyle(color: Colors.black, fontSize: 18.0)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => Summary()),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.person, color: Colors.blue[900]),
                title: Text('PROFILE', style: TextStyle(color:Colors.blue[900], fontSize: 18.0)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ProfileScreen()),
                  );
                },
              ),
              Divider(), // Add a divider before the Logout button
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red), // Set the icon color to red
                title: Text('LOGOUT', style: TextStyle(color: Colors.red, fontSize: 18.0)), // Keep the text color black
                onTap: () {
                  TrxnoSingleton().reset();
                  // TODO: log out user and navigate to Login Screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                        (route) => false, // Remove all existing routes from the stack
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 130.0,
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
              ),
              child: Consumer<ApiResponseProvider>(
                builder: (context, apiResponseProvider, _) {
                  if (responseData != null) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                'assets/images/profile.png',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 60),
                        Text(
                          '${responseData.username}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          '${responseData.companyCode}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Company Code',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          '${responseData.branchCode}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Branch Code',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          '${responseData.companyName}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Company Name',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          '${responseData.branchName}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Branch Name',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          '$terminalId',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Terminal ID',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    );
                    } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.signal_wifi_off, // You can choose an appropriate icon
                          size: 100, // Adjust the icon size as needed
                          color: Colors.redAccent, // Adjust the icon color as needed
                        ),
                        SizedBox(height: 16), // Add some spacing between the icon and text
                        Text(
                          "Please connect to the internet to view this page.",
                          style: TextStyle(
                            fontSize: 20, // Adjust the font size as needed
                            color: Colors.black, // Adjust the text color as needed
                          ),
                        ),
                      ],
                    );
                  }


                },
              ),
            ),
          ],
        ),
      ),   ),
    );
  }
}
