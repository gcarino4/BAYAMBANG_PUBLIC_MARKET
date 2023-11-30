
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:public_market/Screens/download_data.dart';
import 'package:public_market/Screens/home_screen.dart';
import 'package:public_market/Screens/login_screen.dart';
import 'package:public_market/Screens/profile_screen.dart';
import 'package:public_market/Screens/settings_screen.dart';
import 'package:public_market/Screens/setup_screen.dart';
import 'package:public_market/Screens/upload_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
class Summary extends StatefulWidget {
  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  List<Map<String, dynamic>> records = [];
  List<String> databaseFiles = [];
  String? selectedDatabase;
  Timer? _sessionTimer;
  String? searchText = ''; // Store the search text
  bool backButtonDisabled = true;
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    fetchDatabaseFiles();

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
  Future<void> fetchDatabaseFiles() async {
    final externalDir = await getExternalStorageDirectory();
    final databasePath =
        externalDir!.path; // Use external storage directory path
    final directory = Directory(databasePath);
    final files = directory.listSync();
    final databaseFileNames = files
        .where((file) =>
    file is File &&
        path.basename(file.path).startsWith('Records_') &&
        !file.path.endsWith('.db-journal'))
        .map((file) => path.basename(file.path))
        .toList();

    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month}-${now.day}";
    final currentDateDatabase =
        'Records_$formattedDate.db'; // Adjust the filename format as needed

    print('Current Date Database: $currentDateDatabase'); // Debugging line

    if (databaseFileNames.contains(currentDateDatabase)) {
      // Remove the current date database from the list
      databaseFileNames.remove(currentDateDatabase);
    }

    // Insert the current date database at the beginning
    databaseFileNames.insert(0, currentDateDatabase);

    setState(() {
      databaseFiles = databaseFileNames;
      selectedDatabase = databaseFiles.isNotEmpty ? databaseFiles.first : null;
    });

    fetchRecords();
  }

  Future<void> fetchRecords() async {
    if (selectedDatabase == null) {
      return;
    }

    final externalDir = await getExternalStorageDirectory();
    final databasePath = externalDir!.path;

    final database = await openDatabase(
      path.join(databasePath, selectedDatabase!),
      version: 1,
    );

    final fetchedRecords = await database.query('ambulantcollections');

    // Convert the fetchedRecords to a mutable list.
    final mutableRecords = List<Map<String, dynamic>>.from(fetchedRecords);

    // Sort the mutableRecords list based on the upload_status column (assuming it's a String).
    setState(() {
      records = mutableRecords;
    });

    database.close();
  }

  String getOverallUploadStatus() {
    if (records.isEmpty) {
      return "No records available.";
    }

    return "${records.length} Available Records.";
  }

  Future<List<Map<String, dynamic>>?> retrieveDataFromDatabase() async {
    if (selectedDatabase == null) {
      return null;
    }

    final externalDir = await getExternalStorageDirectory();
    final databasePath = externalDir!.path;

    final database = await openDatabase(
      path.join(databasePath, selectedDatabase!),
      version: 1,
    );

    final fetchedRecords = await database.query('ambulantcollections');

    database.close();

    return fetchedRecords;
  }

  double calculateGrandTotal() {
    double grandTotal = 0.0;
    for (final record in records) {
      grandTotal += (record['linetotal'] as num).toDouble();
    }
    return grandTotal;
  }

  Future<void> exportToCSV() async {
    if (selectedDatabase == null) {
      return;
    }

    final externalDir = await getExternalStorageDirectory();
    final databasePath = externalDir!.path;
    final database = await openDatabase(
      path.join(databasePath, selectedDatabase!),
      version: 1,
    );

    final fetchedRecords = await database.query('ambulantcollections');

    database.close();

    final List<List<dynamic>> csvData = [
      fetchedRecords.first.keys.toList(),
      ...fetchedRecords.map((record) => record.values.toList()),
    ];

    String csv = ListToCsvConverter().convert(csvData);

    final directory = await getExternalStorageDirectory();

    // Customize the filename based on the selected database or date
    final now = DateTime.now();
    final formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final fileName = selectedDatabase != null
        ? '${selectedDatabase!.replaceAll('.db', '')}_$formattedDate.csv'
        : 'records_$formattedDate.csv';

    final file = File('${directory!.path}/$fileName');
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV file exported to ${file.path}'),
      ),
    );
  }

  List<Map<String, dynamic>> filterRecords() {
    if (searchText == null || searchText!.isEmpty) {
      return records; // Return all records if search text is empty
    }

    return records.where((record) {
      final docNo = record['docno'] ?? '';
      return docNo.toLowerCase() == searchText!.toLowerCase();
    }).toList();
  }

  Widget buildSidebar() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
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
              title:
              Text('DOWNLOAD DATA', style: TextStyle(color: Colors.black, fontSize: 18.0)),
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
              title: Text('UPLOAD DATA', style: TextStyle(color: Colors.black, fontSize: 18.0)),
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
                  style: TextStyle(color: Colors.blue[900], fontSize: 18.0)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => Summary()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.person, color: Colors.blue[900]),
              title: Text('PROFILE', style: TextStyle(color: Colors.black, fontSize: 18.0)),
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
            // Add more items as needed
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords =
    filterRecords(); // Filter records based on search text
    return WillPopScope(
      onWillPop: () async {
        if (backButtonDisabled) {
          // If the back button is disabled, open the app's drawer
          Scaffold.of(context).openDrawer();
          return false; // Prevent navigating back
        }
        return false;
      },child: Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.black,
            size: 40, // Set the size of the AppBar buttons
          ),
          title: Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png', // Replace this with the path to your image
                  height: 60, // Set the height of the image
                ),
              ),
            ),
          ),
          elevation: 0,
          toolbarHeight: 80,
          actions: [
            SizedBox(
              width: 60, // Set the width of the IconButton
              height: 60, // Set the height of the IconButton
              child: Align(
                alignment: Alignment
                    .centerRight, // Set the alignment of the IconButton
              ),
            ),
          ]),
      drawer: buildSidebar(), // Add the sidebar here
      body: Column(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the children horizontally
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedDatabase,
                    onChanged: (newValue) {
                      setState(() {
                        selectedDatabase = newValue;
                      });
                      fetchRecords();
                    },
                    items: databaseFiles
                        .where((fileName) => fileName.endsWith('.db'))
                        .map((fileName) {
                      return DropdownMenuItem<String>(
                        value: fileName,
                        child: Text(fileName),
                      );
                    })
                        .toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(0.0),
                  child: IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => Summary()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              width: 350, // Adjust the width according to your preference
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey), // Add a border
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    searchText = value; // Update search text
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by Doc No.',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              getOverallUploadStatus(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRecords.length, // Use filtered records
              itemBuilder: (context, index) {
                final record = filteredRecords[index];
                final id = record['id'];
                final vendorCode = record['vendorcode'];
                final docNo = record['docno'];
                final date = record['date'];
                final vendorName = record['vendorname'];
                final quantity = record['quantity'];
                final unitPrice = record['unitprice'];
                final lineTotal = record['linetotal'];
                final totalAmount = record['totalamount'];




                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ListTile(
                    title: Text('Record ID: $id'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _buildReadOnlyTextField('Vendor Code: $vendorCode'),
                        // _buildReadOnlyTextField('Doc No: $docNo'),
                        // _buildReadOnlyTextField('Date: $date'),
                        // _buildReadOnlyTextField('Vendor Name: $vendorName'),
                        // _buildReadOnlyTextField('Quantity: $quantity'),
                        // _buildReadOnlyTextField('Unit Price: $unitPrice'),
                        // _buildReadOnlyTextField('Line Total: $lineTotal'),
                        // _buildReadOnlyTextField('Total Amount: $totalAmount'),
                        Text(
                          'Vendor Code: $vendorCode',
                          style: TextStyle(
                              fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Doc Number: $docNo',
                          style: TextStyle(
                              fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Vendor Name: $vendorName',
                          style: TextStyle(
                              fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Date: $date',
                          style: TextStyle(
                              fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Quantity: $quantity',
                          style: TextStyle(
                              fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Unit Price: $unitPrice',
                          style: TextStyle(
                              fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Line Total: $lineTotal',
                          style: TextStyle(
                              fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Total Amount: $totalAmount',
                          style: TextStyle(
                              fontWeight: FontWeight.normal), // Set text color
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: exportToCSV,
            style: ElevatedButton.styleFrom(
              primary: Color(
                  0xFF2366e8), // Set the button color to the specified value
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(25), // Set the border radius to 25
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: 10.0), // Add padding to the button
            ),
            child: Row(
              mainAxisSize: MainAxisSize
                  .min, // Use min to adjust the size based on content
              children: [
                Icon(
                  Icons.backup_table,
                  size: 30.0,
                  color: Colors.white, // Set the icon color
                ),
                SizedBox(width: 6.0), // Adjusted the SizedBox width
                Text(
                  'EXPORT',
                  style: TextStyle(
                    color: Colors.white, // Set the text color
                    fontSize: 50, // Set the font size
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50.0),
        ],
      ),
    ),
    );
  }
}