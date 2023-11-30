import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:public_market/Screens/download_data.dart';
import 'package:public_market/Screens/login_screen.dart';
import 'package:intl/intl.dart';
import 'package:public_market/Screens/summary.dart';
import 'package:public_market/Screens/upload_data.dart';
import 'package:public_market/Screens/setup_screen.dart';
import 'package:public_market/Screens/settings_screen.dart';
import 'package:public_market/Screens/profile_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:nyx_printer/nyx_printer.dart';

class HomeScreen extends StatelessWidget {
  final dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PUBLIC MARKET TICKETING',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReceiptPrinterScreen(),
    );
  }
}

class ReceiptPrinterScreen extends StatefulWidget {
  @override
  _ReceiptPrinterScreenState createState() => _ReceiptPrinterScreenState();
}

class _ReceiptPrinterScreenState extends State<ReceiptPrinterScreen> {

  late Database _database;
  final _nyxPrinterPlugin = NyxPrinter();


  TextEditingController barcodeController = TextEditingController();
  TextEditingController trxnoController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController vendornameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController unitpriceController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();

  void _computeTotal() {
    final qty = int.tryParse(quantityController.text) ?? 0;
    final unitPrice = double.tryParse(unitpriceController.text) ?? 0.0;
    final total = qty * unitPrice;
    totalAmountController.text = total.toStringAsFixed(2);
  }
  void _clearFields() {
    barcodeController.clear();
    trxnoController.clear();
    vendornameController.clear();
    quantityController.clear();
    unitpriceController.clear();
    totalAmountController.clear();
  }



  Future<void> _createPdf() async {
    try {
      final image = await rootBundle.load('assets/images/img.png');
      await _nyxPrinterPlugin.printImage(
        image.buffer.asUint8List(),
      );
      final double lineSpacing = 0;
      Future<void> printCustomText(
          String text,
          NyxTextFormat textFormat,
          double lineSpacing,
          ) async {
        await _nyxPrinterPlugin.printText(
          text,
          textFormat: textFormat,
        );

        // Move the cursor down to the next line with specified line spacing
      }


      // Set the desired line spacing value (you can adjust this as needed)

      await _nyxPrinterPlugin.printText(
        "BAYAN NG BAYAMBANG \nLALAWIGAN NG PANGASINAN ",
        textFormat: NyxTextFormat(
          align: NyxAlign.center,
          textSize: 26,
        ),
      );

      await _nyxPrinterPlugin.printText(
        "------------------------------------------------\t PUBLIC MARKET TICKET \t ------------------------------------------------",
        textFormat: NyxTextFormat(
          align: NyxAlign.center,
        ),
      );
      String transaction = "TRANSACTION NUMBER :  ";
      String transactionNumber = trxnoController.text;

      String transactionText = "$transaction" + transactionNumber;

      await _nyxPrinterPlugin.printText(
        transactionText,
        textFormat: NyxTextFormat(
          textSize: 20,
        ),
      );

      String date = "DATE                                    :  ";

      String dateNumber = dateController.text;

      String dateText = "$date" + dateNumber;

      await _nyxPrinterPlugin.printText(
        dateText,
        textFormat: NyxTextFormat(
          textSize: 20,
        ),
      );

      String vendor = "VENDOR NAME                  :  ";

      String vendorNumber = vendornameController.text;

      String vendorText = "$vendor" + vendorNumber;

      await _nyxPrinterPlugin.printText(
        vendorText,
        textFormat: NyxTextFormat(
          textSize: 20,
        ),
      );
      String quantity = "QUANTITY                           :  ";

      String quantityNumber = quantityController.text;

      String quantityText = "$quantity" + quantityNumber;

      await _nyxPrinterPlugin.printText(
        quantityText,
        textFormat: NyxTextFormat(
          textSize: 20,
        ),
      );
      String unitprice = "UNIT PRICE                        :  ";

      String unitpriceNumber = unitpriceController.text;

      String unitpriceText = "$unitprice" + unitpriceNumber;

      await _nyxPrinterPlugin.printText(
        unitpriceText,
        textFormat: NyxTextFormat(
          textSize: 20,
        ),
      );
      String totalamount = "TOTAL AMOUNT               :  ";

      String totalamountNumber = totalAmountController.text;

      String totalamountText = "$totalamount" + totalamountNumber;

      await _nyxPrinterPlugin.printText(
        totalamountText,
        textFormat: NyxTextFormat(
          textSize: 20,
        ),
      );

      await _nyxPrinterPlugin.printQrCode(
        '${trxnoController.text}',
        width: 200,
        height: 200,
      );
    } catch (e) {}


  }

  Future<List<int>> _readImageData(String imagePath) async {
    final file = File(imagePath);
    return await file.readAsBytes();
  }

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _setDateToCurrent();
  }


// Function to set the current date in the "dateController"
  void _setDateToCurrent() {
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('MM/dd/yyyy').format(currentDate);
    dateController.text = formattedDate;
  }

  Future<void> _initDatabase() async {
    final path = await _localPath;
    final currentDate = DateTime.now();
    final formattedDate =
        '${currentDate.year}-${currentDate.month}-${currentDate.day}';
    final databasePath = '$path/Records_$formattedDate.db';
    _database = await openDatabase(databasePath, version: 1,
        onCreate: (db, version) async {
          await db.execute('''
        CREATE TABLE Records(
          id INTEGER PRIMARY KEY,
          barcode TEXT,
          trxno TEXT,
          date TEXT,
          vendorname TEXT,
          quantity INTEGER,
          unitprice REAL,
          totalAmount REAL
        )
      ''');
        });
  }

  @override
  void dispose() {
    barcodeController.dispose();
    trxnoController.dispose();
    dateController.dispose();
    vendornameController.dispose();
    quantityController.dispose();
    unitpriceController.dispose();
    totalAmountController.dispose();
    super.dispose();
  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();

    return directory!.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    final trxno = trxnoController.text;
    return File('$path/receipt_$trxno.db');
  }

  void printReceipt() async {
    String barcode = barcodeController.text;
    String trxno = trxnoController.text;
    String date = dateController.text;
    String vendorname = vendornameController.text;
    double? unitprice = double.tryParse(unitpriceController.text);
    int? quantity = int.tryParse(quantityController.text);

    if (barcode.isNotEmpty &&
        trxno.isNotEmpty &&
        date.isNotEmpty &&
        vendorname.isNotEmpty &&
        quantity != null &&
        unitprice != null) {
      double totalAmount = quantity * unitprice;

      // Save data to the SQLite database
      await _database.insert('Records', {
        'barcode': barcode,
        'trxno': trxno,
        'date': date,
        'vendorname': vendorname,
        'quantity': quantity,
        'unitprice': unitprice,
        'totalAmount': totalAmount,
      });

      setState(() {
        totalAmountController.text = totalAmount.toStringAsFixed(2);
      });

      // Now that the database insert is complete, create the PDF and print
      await _createPdf();

      print('Receipt saved to SQLite database.');

      // Clear the fields after successful printing
      _clearFields();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Incomplete Fields'),
            content: Text('Please fill in all the required fields.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }


  Future<void> fetchVendorDetails(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://120.28.166.211:5540/market/udp.php?objectcode=ajaxMobilePMRList&type=Download&userid=manager'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final ambulantVendors = jsonData['ambulantvendors'];
        final vendor = ambulantVendors.firstWhere(
              (v) => v['vendorcode'] == barcode,
          orElse: () => null,
        );

        if (vendor != null) {
          setState(() {
            vendornameController.text = vendor['vendorname'].toString();
            unitpriceController.text = '';
          });
        } else {
          setState(() {
            vendornameController.text = '';
            unitpriceController.text = '';
          });
        }
      } else {
        throw Exception('Failed to fetch JSON response');
      }
    } catch (error) {
      print('Error fetching vendor details: $error');
      setState(() {
        vendornameController.text = '';
        unitpriceController.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            icon: Icon(Icons.add),
            color: Colors.black,
            iconSize: 40, // set the size of the icon
          ),
        ],
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
                leading: Icon(Icons.home),
                title: Text('AMBULANT COLLECTION ',
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.cloud_download),
                title: Text('DOWNLOAD DATA',
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  // TODO: navigate to Download Data Screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => DownloadData()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.cloud_upload),
                title:
                Text('UPLOAD DATA', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => UploadData()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.list),
                title: Text('SUMMARY OF TRANSACTION',
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => Summary()),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.build),
                title: Text('SET UP', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => SetUp()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('SETTINGS', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => SettingsScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('PROFILE', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ProfileScreen()),
                  );
                },
              ),
              Divider(), // Add a divider before the Logout button
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('LOGOUT', style: TextStyle(color: Colors.black)),
                onTap: () {
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'AMBULANT COLLECTsION',
                    style:
                    TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  keyboardType:
                  TextInputType.number, // set the keyboard to numeric only
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ], // only
                  controller: barcodeController, // allow digits
                  decoration: InputDecoration(
                    labelText: 'Barcode',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: trxnoController,
                        onChanged: (_) {
                          fetchVendorDetails(trxnoController
                              .text); // Call the fetchVendorDetails function here
                        },
                        decoration: InputDecoration(
                          labelText: 'Trx No.',
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                          ),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        controller:
                        dateController, // set the controller for the text field
                        onTap: () async {
                          final DateTime currentDate = DateTime.now();
                          final DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: currentDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            // update the value of the text field with the selected date
                            String formattedDate =
                            DateFormat('MM/dd/yyyy').format(selectedDate);
                            dateController.text = formattedDate;
                          } else {
                            // If no date is selected, fill the field with the current date
                            String formattedDate =
                            DateFormat('MM/dd/yyyy').format(currentDate);
                            dateController.text = formattedDate;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextField(
                  controller: vendornameController,
                  decoration: InputDecoration(
                    labelText: 'Vendor Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // ...
                Row(
                  children: [
                    DataTable(
                      columns: [
                        DataColumn(
                          label: Container(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'Qty',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'Unit Price',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: [
                        DataRow(
                          cells: [
                            DataCell(
                              Container(
                                height: 100,
                                child: TextField(
                                  controller: quantityController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: (_) => _computeTotal(),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                height: 50,
                                child: TextField(
                                  controller: unitpriceController,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  onChanged: (_) => _computeTotal(),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                height: 80,
                                child: TextFormField(
                                  controller: totalAmountController,
                                  readOnly: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20),
                Table(
                  border: TableBorder.all(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  columnWidths: {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Grand Total:',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: totalAmountController,
                                  readOnly: true,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                //grandtotal
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: printReceipt,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.print, size: 30.0),
                      SizedBox(width: 10.0),
                      Text('Print'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
