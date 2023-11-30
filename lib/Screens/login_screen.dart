import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:public_market/Screens/settings_screen.dart';
import 'package:public_market/Screens/home_screen.dart';
import 'package:public_market/Screens/modernalertdialog.dart';

import 'ProfileData.dart';
import 'globals.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  String apiResponse = '';
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    // Load the 'Remember Me' preference from local storage during initialization
    loadRememberMePreference();
  }

  Future<void> loadRememberMePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        // If 'Remember Me' is enabled, load the saved username and password
        usernameController.text = prefs.getString('username') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }


  Future<void> saveRememberMePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
    if (!value) {
      // If 'Remember Me' is disabled, also remove the saved username and password
      await prefs.remove('username');
      await prefs.remove('password');
      await prefs.remove('md5Password');
    }
  }

  Future<void> login() async {
    try {
      var userId = usernameController.text;
      var password = passwordController.text;
      var md5Password = md5.convert(utf8.encode(password)).toString();
      UsernameSingleton().username = userId;
      final ipAddress = IpAddressSingleton().ipAddress;

      var url =
          '$ipAddress/ajaxlogin.php?userid=$userId&password=$md5Password';

      var headers = <String, String>{
        // Remove the hardcoded session ID
        // 'Cookie': 'PHPSESSID=a34a6lhkoqs7gmob1rj2sbqcd0',
      };

      var response = await http.get(Uri.parse(url), headers: headers);

      if (TrxnoSingleton().trxno != 0) {
        if (response.statusCode == 200) {
          setState(() {
            apiResponse = response.body;
          });

          // Print the API response data
          print(apiResponse);

          // Check if login is valid based on the response
          if (apiResponse.contains('Login Successful')) {
            // Clean the data and extract the desired fields
            saveRememberMePreference(rememberMe);
            if (rememberMe) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('username', userId);
              await prefs.setString('password', password);
              await prefs.setString('md5Password', md5Password);
            }

            var jsonResponse = json.decode(apiResponse);
            var loginData = jsonResponse['login'] as List<dynamic>;

            if (loginData.isNotEmpty) {
              var userDataJson = loginData[0];

              // Extract the specific fields
              String userId = userDataJson['userid'] ?? '';
              String username = userDataJson['username'] ?? '';
              String companyCode = userDataJson['companycode'] ?? '';
              String branchCode = userDataJson['branchcode'] ?? '';
              String companyName = userDataJson['companyname'] ?? '';
              String branchName = userDataJson['branchname'] ?? '';

              // Create a new ApiResponseData object
              ApiResponseData responseData = ApiResponseData(
                userId: userId,
                username: username,
                companyCode: companyCode,
                branchCode: branchCode,
                companyName: companyName,
                branchName: branchName,
              );

              // Get the instance of ApiResponseProvider using Provider.of<T>
              final apiResponseProvider =
              Provider.of<ApiResponseProvider>(context, listen: false);

              // Update the provider with the cleaned ApiResponseData object
              apiResponseProvider.setApiResponseData(responseData);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );

            } else {
              // Handle the case when "login" key is empty or not found
              print('login data is empty or not found in the API response.');
            }
          } else if (apiResponse.contains('Invalid User ID')) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ModernAlertDialog(
                  title: 'Error',
                  description: 'Invalid User ID/Password!',
                );
              },
            );
          } else if (apiResponse.contains('Your account is lockout')) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ModernAlertDialog(
                  title: 'Error',
                  description:
                  'Your account got locked out!\n\nPlease Contact Support.',
                );
              },
            );
          } else {
            // Handle other cases if needed
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ModernAlertDialog(
                  title: 'Error',
                  description: 'Unknown error occurred!',
                );
              },
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ModernAlertDialog(
                title: 'Error',
                description:
                'Failed to connect to the server.\nPlease check your IP address and network connection.',
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ModernAlertDialog(
              title: 'Error',
              description: 'Please configure settings before logging in.',
            );
          },
        );
      }
    } catch (e) {
      // Show an alert dialog for the exception
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ModernAlertDialog(
            title: 'Error',
            description: 'Please configure settings before logging in.',
          );
        },
      );
      print('Error occurred: $e');
    }
  }
  String savedUsername = UsernameSingleton().username;
  Future<void> offlineLogin() async {
    // Check if 'Remember Me' is enabled
    if (rememberMe) {
      var userId = usernameController.text;
      var password = passwordController.text;
      var md5Password = md5.convert(utf8.encode(password)).toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      var savedUsername = prefs.getString('username') ?? '';
      var savedPassword = prefs.getString('password') ?? '';
      var savedMd5Password = prefs.getString('md5Password') ?? '';

      if (userId == savedUsername && md5Password == savedMd5Password) {
        if (TrxnoSingleton().trxno != 0) {
          // Offline login successful
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ModernAlertDialog(
                title: 'Error',
                description: 'Please configure settings before logging in.',
              );
            },
          );
          print('Error occurred');
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ModernAlertDialog(
              title: 'Offline Login Failed',
              description: 'Please check your credentials.',
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ModernAlertDialog(
            title: 'Offline Login Error',
            description: 'Please enable "Remember Me" and provide credentials.',
          );
        },
      );
    }
  }

  ButtonStyle customButtonStyle = ElevatedButton.styleFrom(
    primary: const Color(0xFF2366e8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    padding: EdgeInsets.symmetric(
        vertical: 10, horizontal: 50), // Adjust vertical value
  );
  ButtonStyle offlinecustomButtonStyle = ElevatedButton.styleFrom(
    primary: Colors.grey,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    padding: EdgeInsets.symmetric(
        vertical: 10, horizontal: 50), // Adjust vertical value
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width > 600 ? 400 : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '10.0.0', // Replace with your version number
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18, // Adjust the font size as needed
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: Color(0xFF2366e8),
                          size: 40, // Adjust the size as needed
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SettingsScreen()),
                          );
                        },
                      ),
                      SizedBox(width: 8), // Adjust the spacing between icon and text

                    ],
                  ),


                  Image.asset(
                    'assets/images/logo.png',
                    width: 275,
                    height: 275,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'PUBLIC MARKET TICKETING',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF2366e8)),
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 25,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF2366e8)),
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 25,
                      ),
                      labelStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        child: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                      ),
                      Text(
                        'Remember Me',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: login,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 50,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    style: customButtonStyle,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: offlineLogin,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 50,
                      ),
                      child: Text(
                        'Offline',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    style: offlinecustomButtonStyle,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
  ));
}
