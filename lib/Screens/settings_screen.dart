import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:public_market/Screens/login_screen.dart';
import 'package:public_market/Screens/modernalertdialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'globals.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController terminalIdController = TextEditingController();
  final TextEditingController trxnoController = TextEditingController();
  final TextEditingController ipAddressController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  List<dynamic>? _lguSetup;
  List<dynamic>? _lguLogo;
  Future<dynamic>? _futureJSONResponse;

  String? selectedServer; // Use a nullable String
  String? ipAddressLAN;
  String? ipAddressWAN;
  bool matchFound = false;
  late SharedPreferences prefs;

  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    initSharedPreferences();
    _initDb();
  }


  @override
  void dispose() {
    super.dispose();
    BackButtonInterceptor.add(myInterceptor);
  }

  void initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    String? savedServer = prefs.getString('selectedServer');
    String? savedIpAddressLAN = prefs.getString('ipAddressLAN') ?? '';
    String? savedIpAddressWAN = prefs.getString('ipAddressWAN') ?? '';

    setState(() {
      selectedServer = savedServer;
      if (selectedServer == 'PRODUCTION SERVER (LAN)') {
        ipAddressController.text = savedIpAddressLAN;
      } else if (selectedServer == 'PRODUCTION SERVER (WAN)') {
        ipAddressController.text = savedIpAddressWAN;
      }
    });

    print('Selected Server: $selectedServer');
    print('LAN IP Address: $savedIpAddressLAN');
    print('WAN IP Address: $savedIpAddressWAN');
  }

  Future<void> _initDb() async {
    final path = await _localPath;
    final databasePath = '$path/setup_data.db';
    Database database = await openDatabase(databasePath, version: 1,
        onCreate: (db, version) async {

          await db.execute('''
        CREATE TABLE IF NOT EXISTS lgu_setup(
          municipality TEXT UNIQUE,
          city TEXT,
          province TEXT
        )
      ''');
          await db.execute('''
        CREATE TABLE IF NOT EXISTS lgu_logo(
          logo TEXT
        )
      ''');
        });

    _lguSetup = await database.query('lgu_setup');
    _lguLogo = await database.query('lgu_logo');

    print(_lguSetup);
    print(_lguLogo);
    database.close();
  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();

    return directory!.path;
  }

  Future<dynamic> fetchJSONResponse() async {
    try {
      var ipAddress = ipAddressController.text;

      final response = await http.get(
        Uri.parse('$ipAddress/udp.php?objectcode=ajaxMobilePMRList&type=Download'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _lguSetup = jsonData['city'];
        _lguLogo = jsonData['logo'];

        return jsonData;
      } else {
        throw Exception('Failed to fetch JSON response. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchJSONResponse: $e');
      throw Exception('Failed to fetch JSON response: $e');
    }
  }

  Future<void> saveToDatabase() async {
    try {
      var ipAddress = ipAddressController.text;

      final externalDirectory = await getExternalStorageDirectory();
      final databasePath = externalDirectory!.path;
      final databaseFile = File(path.join(databasePath, 'setup_data.db'));
      var response = await http.get(
        Uri.parse('$ipAddress/udp.php?objectcode=ajaxMobilePMRList&type=Download'),
      );

      if (response.statusCode == 200) {
        final database = await openDatabase(
          databaseFile.path,
          version: 1,
          onCreate: (db, version) async {
            print("onCreate callback executed");

            await db.execute(
                'CREATE TABLE IF NOT EXISTS lgu_setup (municipality TEXT UNIQUE, city TEXT, province TEXT)');
            await db.execute(
                'CREATE TABLE IF NOT EXISTS lgu_logo (logo TEXT)');
          },
        );

        final batch = database.batch();

        batch.delete('lgu_setup');
        batch.delete('lgu_logo');


        if (_lguLogo != null && _lguLogo != null) {

          // Assuming _lguLogo is a string containing Base64 encoded data
          String cleanedLogo = _lguLogo.toString();
// Check if the string starts and ends with brackets
          if (cleanedLogo.startsWith('[') && cleanedLogo.endsWith(']')) {
            // Remove the starting and ending brackets
            cleanedLogo = cleanedLogo.substring(1, cleanedLogo.length - 1);
          }

          batch.insert('lgu_logo', {
            'logo': cleanedLogo,  // Use the cleaned logo string without brackets
          });

          for (final setup in _lguSetup!) {
            batch.insert('lgu_setup', {
              'municipality': setup['municipality'],
              'city': setup['city'],
              'province': setup['province'],
            });
          }
          await batch.commit(); // Commit the changes to the database
        }

        else {
          showDialog(
            context: context,
            builder: (context) {
              return ModernAlertDialog(
                title: 'Connection Error',
                description: 'Please check for network connection.',
                onOkPressed: () {
                  Navigator.of(context).pop(); // Close the dialog

                  // Navigate to the home screen page
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(),
                    ),
                  );
                },
              );
            },
          );
        }
      } else {
        throw Exception('Failed to fetch data from the server. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in saveToDatabase: $e');
      throw Exception('Failed to save data to the database: $e');
    }
  }


  Future<void> savePreferences() async {
    if (selectedServer == 'PRODUCTION SERVER (LAN)') {
      await prefs.setString('ipAddressLAN', ipAddressController.text);
    } else if (selectedServer == 'PRODUCTION SERVER (WAN)') {
      await prefs.setString('ipAddressWAN', ipAddressController.text);
    }

    print('Saved IP Address: ${ipAddressController.text}');
  }

  Future<void> _fetchDataFromDatabase() async {
    final nextNo = trxnoController.text;
    if (nextNo.isEmpty) {
      return;
    }

    final externalDir = await getExternalStorageDirectory();
    final databasePath = externalDir!.path;

    final directory = Directory(databasePath);
    final files = directory.listSync();

    for (final file in files) {
      if (file is File &&
          path.basename(file.path).startsWith('Records_') &&
          path.basename(file.path).endsWith('.db') &&
          !file.path.endsWith('.db-journal')) {
        final database = await openDatabase(file.path, version: 1);

        final List<Map<String, dynamic>> records = await database.query(
          'ambulantcollections',
          where: 'docno = ?',
          whereArgs: [nextNo],
        );

        if (records.isNotEmpty) {
          setState(() {
            matchFound = true;
          });
          return;
        }
      }
    }

    setState(() {
      matchFound = false;
    });

    // Check matchFound and all fields before showing success alert
    if (!ipAddressController.text.isEmpty &&
        !terminalIdController.text.isEmpty &&
        !trxnoController.text.isEmpty) {
      _showAlertDialogAndNavigate('Information set successfully.');
    }
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    return true;
  }
  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return ModernAlertDialog(
          title: 'Alert',
          description: message,
        );
      },
    );
  }
  void _showAlertDialogAndNavigate(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return ModernAlertDialog(
          title: 'Alert',
          description: message,
        );
      },
    ).then((_) {
      if (message == 'Information set successfully.') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 50, 0),
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 60,
                ),
              ),
            ),
          ),
          elevation: 0,
          toolbarHeight: 80,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'SETTINGS',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              //changelog select a  production server first
              TextField(
                controller: ipAddressController,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  // Save IP address whenever it changes
                  savePreferences();
                },
                decoration: InputDecoration(
                  hintText: '  APPLICATION SERVER IP',
                  labelText: '  APPLICATION SERVER IP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  labelStyle: TextStyle(fontSize: 20),
                  hintStyle: TextStyle(
                    fontSize: 20,
                    color: Colors.grey, // Change this color to the one you want
                  ),
                ),
                style: TextStyle(fontSize: 30),
                textAlignVertical: TextAlignVertical.bottom,
                enabled: selectedServer != null, // Disable the text field if no radio button is selected
              ),


              const SizedBox(height: 10),
              Row(
                children: [
                  Radio(
                    value: 'PRODUCTION SERVER (LAN)',
                    groupValue: selectedServer,
                    onChanged: (value) {
                      setState(() {
                        selectedServer = value as String;
                        // Update the IP address field based on the selected server
                        if (selectedServer == 'PRODUCTION SERVER (LAN)') {
                          ipAddressController.text = prefs.getString('ipAddressLAN') ?? '';
                        } else if (selectedServer == 'PRODUCTION SERVER (WAN)') {
                          ipAddressController.text = prefs.getString('ipAddressWAN') ?? '';
                        }
                        savePreferences();
                      });
                    },
                  ),
                  Text(
                    'PRODUCTION SERVER (LAN)',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),

              Row(
                children: [
                  Radio(
                    value: 'PRODUCTION SERVER (WAN)',
                    groupValue: selectedServer,
                    onChanged: (value) {
                      setState(() {
                        selectedServer = value as String;
                        // Update the IP address field based on the selected server
                        if (selectedServer == 'PRODUCTION SERVER (LAN)') {
                          ipAddressController.text = prefs.getString('ipAddressLAN') ?? '';
                        } else if (selectedServer == 'PRODUCTION SERVER (WAN)') {
                          ipAddressController.text = prefs.getString('ipAddressWAN') ?? '';
                        }
                        savePreferences();
                      });
                    },
                  ),
                  Text(
                    'PRODUCTION SERVER (WAN)',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),

              TextField(
                controller: terminalIdController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '  TERMINAL ID',
                  labelText: '  TERMINAL ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  labelStyle: TextStyle(fontSize: 20),
                  hintStyle: TextStyle(
                    fontSize: 20,
                    color: Colors.grey, // Change this color to the one you want
                  ),
                ),
                style: TextStyle(fontSize: 30),
                textAlignVertical: TextAlignVertical.bottom,
              )
              ,
              const SizedBox(height: 10),
              TextField(
                controller: trxnoController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '  AMBULANT COLLECTION NEXT NO.',
                  labelText: '  AMBULANT COLLECTION NEXT NO.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  labelStyle: TextStyle(fontSize: 20),
                  hintStyle: TextStyle(
                    fontSize: 20,
                    color: Colors.grey, // Change this color to the one you want
                  ),
                  errorText: matchFound ? 'Matching record found. Cannot proceed.' : null,
                ),
                style: TextStyle(fontSize: 30),
                textAlignVertical: TextAlignVertical.bottom,
              )
              ,

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      minimumSize: const Size(120, 50),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      fetchJSONResponse();
                      saveToDatabase();
                      if (ipAddressController.text.isEmpty ||
                          terminalIdController.text.isEmpty ||
                          trxnoController.text.isEmpty) {
                        _showAlertDialog('Please fill in all fields.');
                      } else {
                        IpAddressSingleton().ipAddress = ipAddressController.text;
                        TerminalIdSingleton().terminalId = terminalIdController.text;
                        TrxnoSingleton().trxno = int.parse(trxnoController.text);

                        // Check the database for matching records
                        _fetchDataFromDatabase();

                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2366e8),
                      minimumSize: const Size(120, 50),
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}