

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:public_market/Screens/download_data.dart';
import 'package:public_market/Screens/home_screen.dart';
import 'package:public_market/Screens/login_screen.dart';
import 'package:public_market/Screens/profile_screen.dart';
import 'package:public_market/Screens/settings_screen.dart';
import 'package:public_market/Screens/setup_screen.dart';
import 'package:public_market/Screens/summary.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:public_market/Screens/modernalertdialog.dart';
import 'globals.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
class UploadData extends StatefulWidget {
  @override
  _UploadDataState createState() => _UploadDataState();
}

class _UploadDataState extends State<UploadData> {
  List<Map<String, dynamic>> records = [];
  List<String> databaseFiles = [];
  String? selectedDatabase;
  bool backButtonDisabled = true;

  TextEditingController usernameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    fetchDatabaseFiles();

  }

  @override
  void dispose() {
    BackButtonInterceptor.add(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    return true;
  }
  Future<void> fetchDatabaseFiles() async {
    final externalDir = await getExternalStorageDirectory();
    final databasePath = externalDir!.path; // Use external storage directory path
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
      selectedDatabase =
      databaseFiles.isNotEmpty ? databaseFiles.first : null;
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
    mutableRecords.sort((a, b) {
      final String? uploadStatusA = a['upload_status'];
      final String? uploadStatusB = b['upload_status'];

      // Handle the possibility of 'upload_status' being null.
      if (uploadStatusA == null && uploadStatusB != null) {
        return -1; // a should come before b
      } else if (uploadStatusA != null && uploadStatusB == null) {
        return 1; // b should come before a
      } else if (uploadStatusA != null && uploadStatusB != null) {
        // Compare the upload_status field as strings.
        return uploadStatusA.compareTo(uploadStatusB);
      }
      return 0; // No change in order for other cases
    });

    setState(() {
      records = mutableRecords;
    });

    database.close();
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

    String csv =  ListToCsvConverter().convert(csvData);

    final directory = await getExternalStorageDirectory();

    // Customize the filename based on the selected database or date
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
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

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return ModernAlertDialog(
          title: 'Alert',
          description: message,
          onOkPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => UploadData()),
            );
          },
        );
      },
    );
  }

  void _showUploadResults(List<Map<String, dynamic>> uploadResults) {
    final successfulUploads = uploadResults
        .where((result) => result['returnStatus'] == 'Save Successful')
        .toList();

    final errors = uploadResults
        .where((result) => result['returnStatus'] != 'Save Successful')
        .toList();

    String description = '';

    if (errors.isEmpty) {
      description = 'All data has been uploaded successfully.';
    } else {
      description = 'Failed to upload data for some records.';
    }

    showDialog(
      context: context,
      builder: (context) {
        return ModernAlertDialog(
          title: 'Upload Results',
          description: description,
          onOkPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => UploadData()),
            );
          },
        );
      },
    );
  }






  void _handleError(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return ModernAlertDialog(
          title: 'Error',
          description: 'An error occurred: $errorMessage',
          onOkPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            // You can add any additional action here if needed
          },
        );
      },
    );
  }

  Future<void> uploadDataToAPI() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false, // Disable dismissing the dialog by tapping outside
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false, // Disable the back button
            child: CustomProgressDialog(
              message: 'Please wait while data is being uploaded...',
            ),
          );
        },
      );

      final List<Map<String, dynamic>>? data = await retrieveDataFromDatabase();

      if (data == null || data.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return ModernAlertDialog(
              title: 'Upload Results',
              description: 'No data to upload',
              onOkPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // You can add any additional action here if needed
              },
            );
          },
        );
        return;
      }


      final List<Map<String, dynamic>> recordsToUpload = data
          .where((record) =>
      record['upload_status'] != 'UPLOADED' &&
          record['upload_status'] != 'ERROR')
          .toList();

      if (recordsToUpload.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return ModernAlertDialog(
              title: 'Upload Results',
              description: 'All data has been uploaded',
              onOkPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // You can add any additional action here if needed
              },
            );
          },
        );
        return;
      }


      final terminalId = TerminalIdSingleton().terminalId;
      final ipAddress = IpAddressSingleton().ipAddress;
      final username = UsernameSingleton().username;
      var userId = usernameController.text;
      print('IP Address: $ipAddress'); // Print IP address

      // Store results in a list
      final List<Map<String, dynamic>> uploadResults = [];

      for (final record in recordsToUpload) {
        final jsonData = jsonEncode([record]);
        final url =
            '$ipAddress/udp.php?objectcode=ajaxMobilePMRPost&type=Upload&terminalid=$terminalId&userid=$username&ambulantcollections={"ambulantcollections":$jsonData}';

        print('Final URL: $url'); // Print the final URL

        final response = await http.post(Uri.parse(url), body: jsonData);
        final int recordId = record['id'] as int;
        String returnStatus = 'Unknown'; // Default value for returnStatus

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final pickItems = responseBody['pickitems'] as List<dynamic>;

          if (pickItems.isNotEmpty) {
            returnStatus = pickItems[0]['returnstatus'] as String;

            if (returnStatus.startsWith('Invalid Transaction')) {
              print('Invalid TRX');
              await updateUploadStatusWithError([recordId]);
            } else if (returnStatus.startsWith('Save Successful')) {
              await updateUploadStatus([recordId]);
            }
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return ModernAlertDialog(
                  title: 'Upload Results',
                  description: 'ERROR',
                  onOkPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    // You can add any additional action here if needed
                  },
                );
              },
            );
          }

        } else {
          showDialog(
            context: context,
            builder: (context) {
              return ModernAlertDialog(
                title: 'Upload Results',
                description: 'Failed to upload data for record ${record['id']}. Error: ${response.reasonPhrase}',
                onOkPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // You can add any additional action here if needed
                },
              );
            },
          );
          // Update upload_status for failed record
          await updateUploadStatusWithError([recordId]);
        }


        // Store the result in the list
        uploadResults.add({'recordId': recordId, 'returnStatus': returnStatus});
      }
      _showUploadResults(uploadResults);
      // Close the uploading dialog
      // Navigator.of(context).pop();

      // Display all return statuses at the end


      // ...
    } catch (e) {
      print('Error uploading data: $e');
      _handleError('An error occurred while uploading data');
    }

  }

  Future<void> updateUploadStatusWithError(List<int> recordIds) async {
    if (selectedDatabase == null || recordIds.isEmpty) {
      return;
    }

    final externalDir = await getExternalStorageDirectory();
    final databasePath = externalDir!.path;
    final database = await openDatabase(
      path.join(databasePath, selectedDatabase!),
      version: 1,
    );

    for (final recordId in recordIds) {
      await database.update(
        'ambulantcollections',
        {'upload_status': 'ERROR'},
        where: 'id = ?',
        whereArgs: [recordId],
      );
    }

    database.close();
  }

  Future<void> updateUploadStatus(List<int> recordIds) async {
    if (selectedDatabase == null || recordIds.isEmpty) {
      return;
    }

    final externalDir = await getExternalStorageDirectory();
    final databasePath = externalDir!.path;
    final database = await openDatabase(
      path.join(databasePath, selectedDatabase!),
      version: 1,
    );

    for (final recordId in recordIds) {
      await database.update(
        'ambulantcollections',
        {'upload_status': 'UPLOADED'},
        where: 'id = ?',
        whereArgs: [recordId],
      );
    }

    database.close();
  }

  String getOverallUploadStatus() {
    if (records.isEmpty) {
      return "No records available.";
    }

    int uploadedCount = 0;
    for (final record in records) {
      final uploadStatus = record['upload_status'];
      if (uploadStatus != null && uploadStatus == 'UPLOADED') {
        uploadedCount++;
      }
    }

    return "$uploadedCount/${records.length} records uploaded.";
  }

  Future<String?> retrieveDataAndConvertToJson() async {
    final List<Map<String, dynamic>>? data = await retrieveDataFromDatabase();
    if (data == null) {
      return null;
    }
    final jsonData = jsonEncode(data);
    return jsonData;
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
      },child:Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme:  IconThemeData(
            color: Colors.black,
            size: 40, // Set the size of the AppBar buttons
          ),
          title: Center(
            child: Padding(
              padding:  EdgeInsets.fromLTRB(0, 0, 0, 0),
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
      drawer: buildSidebar(),
      // Add the sidebar here
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
                        MaterialPageRoute(builder: (_) => UploadData()),
                      );
                    },
                  ),
                ),
              ],
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
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final id = record['id'];
                final vendorCode = record['vendorcode'];
                final docNo = record['docno'];
                final date = record['date'];
                final vendorName = record['vendorname'];
                final quantity = record['quantity'];
                final unitPrice = record['unitprice'];
                final lineTotal = record['linetotal'];
                final totalAmount = record['totalamount'];
                final uploadStatus = record['upload_status'];

                // Determine text color based on upload_status
                Color statusColor = Colors.grey; // Default color
                if (uploadStatus == 'ERROR') {
                  statusColor = Colors.red;
                } else if (uploadStatus == 'UPLOADED') {
                  statusColor = Colors.green;
                }

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
                          style: TextStyle(fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Doc Number: $docNo',
                          style: TextStyle(fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Vendor Name: $vendorName',
                          style: TextStyle(fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Date: $date',
                          style: TextStyle(fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Quantity: $quantity',
                          style: TextStyle(fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Unit Price: $unitPrice',
                          style: TextStyle(fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Line Total: $lineTotal',
                          style: TextStyle(fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Total Amount: $totalAmount',
                          style: TextStyle(fontWeight: FontWeight.normal), // Set text color
                        ),
                        Text(
                          'Upload Status: ${uploadStatus != null ? uploadStatus.replaceAll('null', 'PENDING') : 'PENDING'}',
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
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
            onPressed: uploadDataToAPI,
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF2366e8), // Set the button color to the specified value
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25), // Set the border radius to 25
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.0), // Add padding to the button
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Use min to adjust the size based on content
              children: [
                Icon(
                  Icons.upload,
                  size: 30.0,
                  color: Colors.white, // Set the icon color
                ),
                SizedBox(width: 6.0), // Adjusted the SizedBox width
                Text(
                  'UPLOAD',
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
              title: Text('UPLOAD DATA', style: TextStyle(color: Colors.blue[900], fontSize: 18.0)),
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
                // TODO: log out user aListTile(
                //                   leading: Icon(Icons.logout, color: Colors.red), // Set the icon color to red
                //                   title: Text('LOGOUT', style: TextStyle(color: Colors.red)), // Keep the text color black
                //                   onTap: () {
                //                     TrxnoSingleton().reset();
                //                     // TODO: log out user and navigate to Login Screen
                //                     Navigator.pushAndRemoveUntil(
                //                       context,
                //                       MaterialPageRoute(builder: (_) => LoginScreen()),
                //                           (route) => false, // Remove all existing routes from the stack
                //                     );
                //                   },nd navigate to Login Screen
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

  Widget _buildReadOnlyTextField(String text, {Color? textColor}) {
    return TextField(
      decoration: InputDecoration(
        labelText: text,
        border: InputBorder.none,
        enabled: false,
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      style: TextStyle(fontSize: 14),

    );

  }
}
class CustomProgressDialog extends StatelessWidget {
  final String message;

  CustomProgressDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.upload_file, // Replace with the printer icon you prefer
                size: 48, // Adjust the size as needed
                color: Colors.blue, // Adjust the color as needed
              ),
              SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}