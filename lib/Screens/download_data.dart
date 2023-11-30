import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:public_market/Screens/home_screen.dart';
import 'package:public_market/Screens/login_screen.dart';
import 'package:public_market/Screens/profile_screen.dart';
import 'package:public_market/Screens/settings_screen.dart';
import 'package:public_market/Screens/setup_screen.dart';
import 'package:public_market/Screens/summary.dart';
import 'package:public_market/Screens/upload_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:public_market/Screens/modernalertdialog.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'ProfileData.dart';
import 'globals.dart';

void main() {
  runApp(MaterialApp(
    home: DownloadData(),
  ));
}

class DownloadData extends StatefulWidget {

  @override
  _DownloadDataState createState() => _DownloadDataState();
}

class _DownloadDataState extends State<DownloadData> {
  final ipAddress = IpAddressSingleton().ipAddress;
  final username = UsernameSingleton().username;
  TextEditingController usernameController = TextEditingController();
  bool backButtonDisabled = true;
  Future<dynamic>? _futureJSONResponse;
  List<dynamic>? _ambulantVendors;
  List<dynamic>? _cashTickets;

  // bool _showAmbulantVendorsTable = false;
  bool _showCashTicketsTable = false;

  BuildContext? _dialogContext;

  @override
  void initState() {
    super.initState();
    _futureJSONResponse = fetchJSONResponse();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    super.dispose();
    BackButtonInterceptor.add(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    return true;
  }

  Future<dynamic> fetchJSONResponse() async {



    var userId = usernameController.text;
    final response = await http.get(Uri.parse(
        '$ipAddress/udp.php?objectcode=ajaxMobilePMRList&type=Download&userid=$username'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      _ambulantVendors = jsonData['ambulantvendors'];
      _cashTickets = jsonData['cashtickets'];
      return jsonData;
    } else {
      throw Exception('Failed to fetch JSON response');
    }
  }

  Future<void> saveToDatabase() async {
    var userId = usernameController.text;
    final externalDirectory = await getExternalStorageDirectory();
    final databasePath = externalDirectory!.path;
    final databaseFile = File(path.join(databasePath, 'downloaded_data.db'));
    var response = await http.get(Uri.parse(
        '$ipAddress/udp.php?objectcode=ajaxMobilePMRList&type=Download&userid=$username'));

    if (response.statusCode == 200) {
      final database = await openDatabase(
        databaseFile.path,
        version: 1,
        // Change version number if needed
        onCreate: (db, version) async {
          print("onCreate callback executed");
          await db.execute(
              'CREATE TABLE IF NOT EXISTS ambulant_vendors (vendorcode TEXT, vendorname TEXT)');
          await db.execute(
              'CREATE TABLE IF NOT EXISTS cash_tickets (denomination TEXT UNIQUE)');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // Perform updates if needed (e.g., alter tables, add columns, etc.)
        },
      );

      final batch = database.batch();

      // Delete all existing data in the 'ambulant_vendors' and 'cash_tickets' tables
      batch.delete('ambulant_vendors');
      batch.delete('cash_tickets');

      if (_ambulantVendors != null) {
        for (final vendor in _ambulantVendors!) {
          batch.insert('ambulant_vendors', {
            'vendorcode': vendor['vendorcode'],
            'vendorname': vendor['vendorname'],
          });
        }
      }

      if (_cashTickets != null && _cashTickets!.isNotEmpty) {
        for (final ticket in _cashTickets!) {
          final denomination = ticket['denomination'];
          final trimmedDenomination = denomination.length > 5
              ? denomination.substring(0, 5)
              : denomination;

          batch.insert('cash_tickets', {
            'denomination': trimmedDenomination,
          });
        }
      }

      await batch.commit();
      await database.close();

      if (_cashTickets != null && _cashTickets!.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) => ModernAlertDialog(
            title: 'Success',
            description: 'Data saved to the database.',
          ),
        );
      }
    } else {
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
                  builder: (context) => DownloadData(),
                ),
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {


    return WillPopScope(
      onWillPop: () async {
        if (backButtonDisabled) {
          // If the back button is disabled, open the app's drawer
          Scaffold.of(context).openDrawer();
          return false; // Prevent navigating back
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black,
            size: 40,

            /// set the color of the AppBar buttons
          ),
          title: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 50, 0),
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
        drawer: SafeArea(
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
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
                ListTile(
                  leading: Icon(Icons.home, color: Colors.blue[900]),
                  title: Text('AMBULANT COLLECTION ',
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
                      style:
                      TextStyle(color: Colors.blue[900], fontSize: 18.0)),
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
                  title: Text('UPLOAD DATA',
                      style: TextStyle(color: Colors.black, fontSize: 18.0)),
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
                  title: Text('PROFILE',
                      style: TextStyle(color: Colors.black, fontSize: 18.0)),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen()),
                    );
                  },
                ),
                Divider(), // Add a divider before the Logout button
                ListTile(
                  leading: Icon(Icons.logout,
                      color: Colors.red), // Set the icon color to red
                  title: Text('LOGOUT',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 18.0)), // Keep the text color black
                  onTap: () {
                    TrxnoSingleton().reset();
                    // TODO: log out user and navigate to Login Screen
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                          (route) =>
                      false, // Remove all existing routes from the stack
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'AMBULANT COLLECTION',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Color(
                      0xFF2366e8), // Set the color to the hexadecimal color code
                  borderRadius: BorderRadius.circular(25),
                ),
                child: MaterialButton(
                  minWidth: 200,
                  child: Text(
                    'DOWNLOAD DATA',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    saveToDatabase();
                    setState(() {
                      // _showAmbulantVendorsTable = true;
                      _showCashTicketsTable = true;
                    });
                  },
                ),
              ),

              // SizedBox(height: 20),
              //
              // if (_showAmbulantVendorsTable)
              //   SingleChildScrollView(
              //     scrollDirection: Axis.vertical,
              //     child: _buildAmbulantVendorsTable(_ambulantVendors),
              //   ),


            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildAmbulantVendorsTable(List<dynamic>? data) {
  //   if (data != null && data.isNotEmpty) {
  //     final columns = [
  //       DataColumn(label: Text('Vendor Code')),
  //       DataColumn(label: Text('Vendor Name')),
  //     ];
  //
  //     final rows = data.map<DataRow>((item) {
  //       return DataRow(
  //         cells: [
  //           DataCell(Text(item['vendorcode'].toString())),
  //           DataCell(Text(item['vendorname'].toString())),
  //         ],
  //       );
  //     }).toList();
  //
  //     return DataTable(columns: columns, rows: rows);
  //   } else {
  //     return Text('No ambulant vendors available');
  //   }
  // }
  //
  // Widget _buildCashTicketsTable(List<dynamic>? data) {
  //   if (data != null && data.isNotEmpty) {
  //     return Text("");
  //   } else {
  //     return Text('No cash tickets available');
  //   }
  // }
}
