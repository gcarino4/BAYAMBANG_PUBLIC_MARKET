import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:public_market/Screens/login_screen.dart';
import 'package:public_market/Screens/settings_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SettingsScreen()),
      );
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<File>(
          future: getImageFromExternalStorage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError || !snapshot.hasData) {
              // Display default image when external storage is empty or there's an error
              return Image.asset(
                'assets/images/logo.png',
                height: 300,
                width: 300,
              );
            } else {
              // Use the image from external storage when available
              return Image.file(
                snapshot.data!,
                height: 300,
                width: 300,
              );
            }
          },
        ),
      ),
    );

  }
}
