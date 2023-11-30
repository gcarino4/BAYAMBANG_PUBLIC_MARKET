import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:public_market/Screens/download_data.dart';
import 'package:public_market/Screens/login_screen.dart';
import 'package:intl/intl.dart';
import 'package:public_market/Screens/scanner.dart';
import 'package:public_market/Screens/summary.dart';
import 'package:public_market/Screens/upload_data.dart';
import 'package:public_market/Screens/profile_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:nyx_printer/nyx_printer.dart';
import 'package:path/path.dart' as path;
import 'globals.dart';
import 'package:public_market/Screens/modernalertdialog.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomeScreen extends StatelessWidget {
  final dateController = TextEditingController();

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PUBLIC MARKET TICKETING',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReceiptPrinterScreen(qrCodeData: '',),
    );
  }
}

class ReceiptPrinterScreen extends StatefulWidget {
  final String qrCodeData; // Add this line to accept QR code data

  ReceiptPrinterScreen({required this.qrCodeData, Key? key}) : super(key: key);

  @override
  _ReceiptPrinterScreenState createState() => _ReceiptPrinterScreenState();
}

class _ReceiptPrinterScreenState extends State<ReceiptPrinterScreen> {
  bool backButtonDisabled = true;
  late Database _database;
  final _nyxPrinterPlugin = NyxPrinter();

  List<String> denominations = [];
  List<Map<String, dynamic>> ambulantVendors = [];
  List<TextEditingController> lineTotalControllers = [];
  List<TextEditingController> quantityControllers = [];
  List<TextEditingController> unitpriceControllers = [];

  TextEditingController vendorcodeController = TextEditingController();
  TextEditingController docnoController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController vendornameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController unitpriceController = TextEditingController();
  TextEditingController linetotalController = TextEditingController();
  TextEditingController totalamountController = TextEditingController();

  void _computeTotal({
    required int rowIndex,
    required TextEditingController quantityController,
    required TextEditingController unitpriceController,
    required TextEditingController linetotalController,
  }) {
    final qty = int.tryParse(quantityController.text) ?? 0;
    final unitPrice = double.tryParse(unitpriceController.text) ?? 0.0;
    final total = qty * unitPrice;

    linetotalController.text = total.toStringAsFixed(0);

    // Store the computed line total in the lineTotalControllers list
    lineTotalControllers[rowIndex] = linetotalController;

    updateGrandTotal(); // Update the grand total whenever a line total changes
  }

  double calculateGrandTotal(List<TextEditingController> lineTotalControllers) {
    double grandTotal = 0.0;
    for (var controller in lineTotalControllers) {
      grandTotal += double.tryParse(controller.text) ?? 0.0;
    }
    return grandTotal;
  }

  void updateGrandTotal() {
    double grandTotal = calculateGrandTotal(lineTotalControllers);
    totalamountController.text = grandTotal.toStringAsFixed(2);
  }

  Future<void> _createPdf() async {
    try {
      // final image = await rootBundle.load('assets/images/img.png');
      // await _nyxPrinterPlugin.printImage(image.buffer.asUint8List());

      await SunmiPrinter.initPrinter();
      await SunmiPrinter.bindingPrinter();
      await SunmiPrinter.startTransactionPrint(true);

      await SunmiPrinter.printText(
        "BAYAN NG BAYAMBANG \nLALAWIGAN NG PANGASINAN \n------------------------------------\t PUBLIC MARKET TICKET \t ------------------------------------",
        style: SunmiStyle(
          align: SunmiPrintAlign.CENTER,
          fontSize: SunmiFontSize.MD,

        ),
      );

      // Print line items data

      String transaction = "TRANSACTION NUMBER : ";
      String transactionNumber = docnoController.text;
      String date = "DATE               : ";

      String dateNumber = dateController.text;

      String vendor = "VENDOR NAME        : ";

      String vendorNumber = vendornameController.text;
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.printText(
        "$transaction $transactionNumber\n$date $dateNumber\n$vendor $vendorNumber\n--------------------------------",
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
        ),
      );

      await SunmiPrinter.printRow(cols: [
        ColumnMaker(
          text: "QUANTITY",
          width: 10,
          align: SunmiPrintAlign.LEFT,
        ),
        ColumnMaker(
          // text: "UNIT PRICE",
          width: 10,
          align: SunmiPrintAlign.CENTER,
        ),
        ColumnMaker(
          text: "UNIT PRICE",
          width: 10,
          align: SunmiPrintAlign.RIGHT,
        ),
      ]);
      // await SunmiPrinter.printText(
      //   "--------------------------------",
      //   style: SunmiStyle(
      //     fontSize: SunmiFontSize.MD,
      //
      //   ),
      //
      // );
      for (int i = 0; i < denominations.length; i++) {
        String quantityText = quantityControllers[i].text;
        String unitPriceText = unitpriceControllers[i].text;

        // Skip printing if both quantity and unit price are empty
        if (quantityText.isNotEmpty && unitPriceText.isNotEmpty) {
          String quantityLine = quantityText.padRight(16);
          String unitPriceLine = unitPriceText.padRight(16);
          await SunmiPrinter.printRow(cols: [
            ColumnMaker(
              text: "$quantityLine",
              width: 10,
              align: SunmiPrintAlign.LEFT,
            ),
            ColumnMaker(
              // text: "$unitPriceLine",
              width: 10,
              align: SunmiPrintAlign.CENTER,
            ),
            ColumnMaker(
              text: "$unitPriceLine",
              width: 10,
              align: SunmiPrintAlign.RIGHT,
            ),
          ]);
          // await SunmiPrinter.printText(
          //   "--------------------------------",
          //   style: SunmiStyle(
          //     fontSize: SunmiFontSize.MD,
          //
          //   ),
          //
          // );
          // await SunmiPrinter.printText(
          //   "$quantityLine                             ₱$unitPriceLine---------------------------------------------------- ",
          //   style: SunmiStyle(
          //     align: SunmiPrintAlign.CENTER,
          //     fontSize: SunmiFontSize.MD,
          //   ),
          // );
        }
      }

      // await SunmiPrinter.printText(
      //   "--------------------------------",
      //   style: SunmiStyle(
      //     fontSize: SunmiFontSize.MD,
      //
      //   ),
      //
      // );
      String totalamount = "TOTAL AMOUNT :  ₱";

      String totalamountNumber = totalamountController.text;

      String totalamountText = "$totalamount$totalamountNumber";
      await SunmiPrinter.setCustomFontSize(30);
      await SunmiPrinter.printText(
        totalamountText,
        style: SunmiStyle(
          bold: true,
          align: SunmiPrintAlign.CENTER,

          // fontSize: SunmiFontSize.MD,

          // style: NyxFontStyle.bold,
        ),
      );
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printQRCode(
        vendorcodeController.text,

        // style: NyxFontStyle.bold,

        // width: 100,
        // height: 100,
      );
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.lineWrap(1);
    } catch (e) {
      // Handle exceptions
    }
  }
  Future<void> _nyxprinter() async {
    try {
      // final image = await rootBundle.load('assets/images/img.png');
      // await _nyxPrinterPlugin.printImage(image.buffer.asUint8List());

      await _nyxPrinterPlugin.printText(
        "BAYAN NG BAYAMBANG \nLALAWIGAN NG PANGASINAN \n------------------------------------------------\t PUBLIC MARKET TICKET \t ------------------------------------------------",
        textFormat: NyxTextFormat(
          align: NyxAlign.center,
          textSize: 20,
        ),
      );

      // Print line items data



      String transaction = "TRANSACTION NUMBER :  ";
      String transactionNumber = docnoController.text;
      String date = "DATE                                    :  ";

      String dateNumber = dateController.text;

      String vendor = "VENDOR NAME                  :  ";

      String vendorNumber = vendornameController.text;

      await _nyxPrinterPlugin.printText(
        "$transaction $transactionNumber\n$date $dateNumber\n$vendor $vendorNumber\n------------------------------------------------\nQUANTITY                                UNIT PRICE\n------------------------------------------------",
        textFormat: NyxTextFormat(
          textSize: 20,

        ),

      );

      for (int i = 0; i < denominations.length; i++) {
        String quantityText = quantityControllers[i].text;
        String unitPriceText = unitpriceControllers[i].text;

        // Skip printing if both quantity and unit price are empty
        if (quantityText.isNotEmpty && unitPriceText.isNotEmpty) {
          String quantityLine = quantityText.padRight(16);
          String unitPriceLine = unitPriceText.padRight(16);

          await _nyxPrinterPlugin.printText(
            "$quantityLine                             ₱$unitPriceLine---------------------------------------------------- ",
            textFormat: NyxTextFormat(
              align: NyxAlign.center,
              textSize: 20,
            ),
          );
        }
      }


      String totalamount = "TOTAL AMOUNT :  ₱";

      String totalamountNumber = totalamountController.text;

      String totalamountText = "$totalamount$totalamountNumber";

      await _nyxPrinterPlugin.printText(
        totalamountText,
        textFormat: NyxTextFormat(
          align: NyxAlign.center,
          textSize: 25,
          style: NyxFontStyle.bold,
        ),
      );

      await _nyxPrinterPlugin.printQrCode(
        vendorcodeController.text,
        width: 100,
        height: 100,
      );
    } catch (e) {
      // Handle exceptions
    }
  }
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    final trxno = TrxnoSingleton().trxno;
    // final qrcode = VendorcodeSingleton().qrcode;
    // vendorcodeController.text = qrcode.toString(); // Convert to string
    docnoController.text = trxno.toString(); // Convert to string
    vendorcodeController.text = widget.qrCodeData;
    _initDatabase();
    _setDateToCurrent();
    _loadData();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    // Increment vendor code and document number
  }

  void _setDateToCurrent() {
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('MM/dd/yyyy').format(currentDate);
    dateController.text = formattedDate;
  }

  Future<void> _fetchDataFromDatabase() async {
    final vendorcode = vendorcodeController.text;
    if (vendorcode.isEmpty) {
      return; // No vendorcode, nothing to fetch
    }

    final externalDir = await getExternalStorageDirectory();
    final databasePath = externalDir!.path;

    final directory = Directory(databasePath);
    final files = directory.listSync();

    for (final file in files) {
      if (file is File &&
          path.basename(file.path).startsWith('Records_') &&
          !file.path.endsWith('.db-journal')) {
        final database = await openDatabase(file.path, version: 1);
        final List<Map<String, dynamic>> records = await database.query(
          'ambulantcollections',
          where: 'vendorcode = ?',
          whereArgs: [vendorcode],
        );

        if (records.isNotEmpty) {
          final record =
          records[0]; // Assuming there's only one record per vendorcode

          vendornameController.text = record['vendorname'];

          return; // Exit the loop after finding the first match
        }

        // No matching records found in ambulantcollections, let's fetch from downloaded_data.db
        final downloadedDatabase = await openDatabase(
          path.join(databasePath, 'downloaded_data.db'),
          version: 1,
        );

        final ambulantVendors = await downloadedDatabase.query(
          'ambulant_vendors',
          where: 'vendorcode = ?',
          whereArgs: [vendorcode],
        );

        if (ambulantVendors.isNotEmpty) {
          final vendorname = ambulantVendors[0]['vendorname'];
          if (vendorname != null) {
            vendornameController.text = vendorname.toString();
          } else {
            // Handle the case when vendorname is null
          }
        }
      }
    }
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
            CREATE TABLE ambulantcollections(
              id INTEGER PRIMARY KEY,
              vendorcode TEXT,
              docno TEXT,
              date TEXT,
              vendorname TEXT,
              quantity INTEGER,
              unitprice REAL,
              linetotal REAL,
              totalamount REAL,
              upload_status INTEGER
            )
          ''');
        });
  }

  @override
  void dispose() {
    BackButtonInterceptor.add(myInterceptor);
    vendorcodeController.dispose();
    docnoController.dispose();
    dateController.dispose();
    vendornameController.dispose();
    quantityController.dispose();
    unitpriceController.dispose();
    linetotalController.dispose();
    totalamountController.dispose();
    // _qrInfoController.dispose();

    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    return true;
  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();

    return directory!.path;
  }

  void printReceipt() async {
    String vendorcode = vendorcodeController.text;
    String docno = docnoController.text;
    String date = dateController.text;
    String vendorname = vendornameController.text;

    // Check if any required fields or line total controllers are empty
    if (vendorcode.isEmpty ||
        docno.isEmpty ||
        date.isEmpty ||
        vendorname.isEmpty ||
        (!lineTotalControllers
            .any((controller) => controller.text.isNotEmpty))) {
      // Show an alert dialog if any of the required fields are empty
      showDialog(
        context: context,
        builder: (context) {
          return ModernAlertDialog(
            title: 'Fields Empty',
            description: 'Please fill in all required fields.',
            onOkPressed: () {
              // Navigator.of(context).pop(); // Close the dialog

              // Navigate to the home screen page
              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(
              //     builder: (context) => HomeScreen(),
              //   ),
              // );
            },
          );
        },
      );
      return; // Exit the function without proceeding to printing
    }

    if (lineTotalControllers.isEmpty) {
      print("No line items to print.");
      return;
    }

    List<Map<String, dynamic>> rowDataList = [];

    // Iterate through the lineTotalControllers list to collect data from each row
    for (int i = 0; i < lineTotalControllers.length; i++) {
      TextEditingController quantityController = quantityControllers[i];
      TextEditingController unitpriceController = unitpriceControllers[i];
      TextEditingController linetotalController = lineTotalControllers[i];

      int? quantity = int.tryParse(quantityController.text) ?? 0;
      double? unitprice = double.tryParse(unitpriceController.text) ?? 0.0;
      double? linetotal = double.tryParse(linetotalController.text) ?? 0.0;

      rowDataList.add({
        'quantityController': quantityController,
        'unitpriceController': unitpriceController,
        'linetotalController': linetotalController,
        'quantity': quantity,
        'unitprice': unitprice,
        'linetotal': linetotal,
      });
    }

    // Calculate total amount based on the rowDataList
    double totalamount =
    rowDataList.fold(0.0, (sum, data) => sum + data['linetotal']);

    // Save data to the SQLite database
    // Save data to the SQLite database for non-empty lineTotalControllers
    for (var rowData in rowDataList) {
      if (rowData['linetotal'] > 0) {
        await _database.insert('ambulantcollections', {
          'vendorcode': vendorcode,
          'docno': docno,
          'date': date,
          'vendorname': vendorname,
          'quantity': rowData['quantity'],
          'unitprice': rowData['unitprice'],
          'linetotal': rowData['linetotal'],
          'totalamount': totalamount,
        });
      }
    }

    setState(() {
      totalamountController.text = totalamount.toStringAsFixed(2);
    });

    // Now that the database insert is complete, create the PDF and print

showPrintingDialog(context);
    await _createPdf();

    await _nyxprinter();
    await _fetchDataFromDatabase();

    print('Receipt saved to SQLite database.');

    // Dismiss the dialog

    // Clear the fields after successful printing
    _clearFields();

    // Increment vendor code and document number
    incrementControllers();

    // Navigate to the HomeScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void _clearFields() {
    vendornameController.clear();
    quantityController.clear();
    unitpriceController.clear();
    linetotalController.clear();
    totalamountController.clear();
  }

  void incrementControllers() {
    // Increment vendor code and document number
    // int currentVendorCode = VendorcodeSingleton().qrcode;
    int currentDocNo = TrxnoSingleton().trxno;

    // Increment the values
    // currentVendorCode++;
    currentDocNo++;

    // Update the Singleton instances with the new values
    // VendorcodeSingleton().qrcode = currentVendorCode;
    TrxnoSingleton().trxno = currentDocNo;

    // Update the controllers with the new values as strings
    // vendorcodeController.text = currentVendorCode.toString();
    docnoController.text = currentDocNo.toString();
  }

  Future<void> _loadData() async {
    final path = await _localPath;
    final databasePath = '$path/downloaded_data.db';
    Database database = await openDatabase(databasePath, version: 1,
        onCreate: (db, version) async {
          await db.execute('''
        CREATE TABLE IF NOT EXISTS cash_tickets(
          id INTEGER PRIMARY KEY,
          denomination TEXT
        )
      ''');
          await db.execute('''
        CREATE TABLE IF NOT EXISTS ambulant_vendors(
          id INTEGER PRIMARY KEY,
          vendorcode TEXT,
          vendorname TEXT
        )
      ''');
        });

    // Count the items in the 'denomination' column of 'cash_tickets'
    int? denominationCount = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM cash_tickets'));
    List<Map<String, dynamic>> cashTicketsData =
    await database.query('cash_tickets');
    List<String> extractedDenominations = cashTicketsData
        .map<String>((row) => row['denomination'] as String)
        .toList();

    ambulantVendors = await database.query('ambulant_vendors');

    setState(() {
      denominations = extractedDenominations;
    });

    print('Total denominations: $denominationCount');
    print(denominations);
    print(ambulantVendors);
  }

  List<Map<String, dynamic>> generateRowsData() {
    List<Map<String, dynamic>> rowDataList = [];
    for (int index = 0; index < denominations.length; index++) {
      TextEditingController quantityController = TextEditingController();
      TextEditingController unitpriceController = TextEditingController();
      TextEditingController linetotalController = TextEditingController();

      lineTotalControllers.add(linetotalController);
      quantityControllers.add(quantityController);
      unitpriceControllers.add(unitpriceController);

      // Set the unit price based on the selected denomination
      unitpriceController.text = denominations[index];

      rowDataList.add({
        'quantityController': quantityController,
        'unitpriceController': unitpriceController,
        'linetotalController': linetotalController,
      });
    }
    return rowDataList;
  }

  List<DataRow> generateRows() {
    List<Map<String, dynamic>> rowDataList = generateRowsData();

    return List.generate(rowDataList.length, (index) {
      TextEditingController quantityController =
      rowDataList[index]['quantityController'];
      TextEditingController unitpriceController =
      rowDataList[index]['unitpriceController'];
      TextEditingController linetotalController =
      rowDataList[index]['linetotalController'];

      // Extract the denomination and remove the decimal point
      double denomination = double.tryParse(denominations[index]) ?? 0.0;
      int unitPriceAsInt = denomination.toInt();

      // Set the unit price in the controller as an integer
      unitpriceController.text = unitPriceAsInt.toString();

      return DataRow(
        cells: [

          DataCell(
            SizedBox(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      int currentValue = int.tryParse(quantityController.text) ?? 0;
                      if (currentValue >  0) {
                        quantityController.text = (currentValue - 1).toString();
                        _computeTotal(
                          rowIndex: index,
                          quantityController: quantityController,
                          unitpriceController: unitpriceController,
                          linetotalController: linetotalController,
                        );
                      }
                    },
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 4, right: 8),
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (_) => _computeTotal(
                          rowIndex: index,
                          quantityController: quantityController,
                          unitpriceController: unitpriceController,
                          linetotalController: linetotalController,
                        ),
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      int currentValue = int.tryParse(quantityController.text) ?? 0;
                      quantityController.text = (currentValue + 1).toString();
                      _computeTotal(
                        rowIndex: index,
                        quantityController: quantityController,
                        unitpriceController: unitpriceController,
                        linetotalController: linetotalController,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),


          DataCell(
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1),
                child: SizedBox(
                  height: 50,
                  width: 40,
                  child: TextFormField(
                    controller: unitpriceController,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(horizontal: 5),
                    ),
                    maxLines: 1,
                    maxLength: 6,
                  ),
                ),
              ),
            ),
          ),
          DataCell(
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1),
                child: SizedBox(
                  height: 80,
                  child: TextFormField(
                    controller: linetotalController,
                    readOnly: true,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

    });
  }
  void showPrintingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        // Define a function to close the dialog after 1 second
        void closeDialog() {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
        }

        // Call the function to close the dialog
        closeDialog();

        return WillPopScope(
          onWillPop: () async => false, // Disable the back button
          child: CustomProgressDialog(
            message: 'Printing receipt...',
          ),
        );
      },
    );
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
                child: Image.asset(
                  'assets/images/logo.png', // replace this with the path to your image
                  height: 60, // set the height of the image
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
                      style: TextStyle(color: Colors.blue[900], fontSize: 18.0)),
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
                  leading: Icon(Icons.logout,
                      color: Colors.red), // Set the icon color to red
                  title: Text('LOGOUT',
                      style: TextStyle(
                          color: Colors.red, fontSize: 18.0)), // Keep the text color black
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'AMBULANT COLLECTION',
                      style: TextStyle(
                          fontSize: 35.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Column(
                    children: [],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          controller: vendorcodeController,
                          decoration: InputDecoration(
                            labelText: 'Vendor Code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.keyboard_return),
                              color: Color(0xFF2366e8),// Enter button icon

                              onPressed: () {
                                _fetchDataFromDatabase(); // Call your function when the button is pressed
                              },
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 30,
                          ),
                          textAlignVertical: TextAlignVertical.bottom,
                          onChanged: (value) {
                            // This function will be called when the user types in the TextField
                            _fetchDataFromDatabase();
                          },
                        )
,

                      ),
                      IconButton(
                        icon: Icon(Icons.qr_code_scanner, color: Color(0xFF2366e8), size: 40.0), // Adjust the color and size as per your requirements
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const QRViewExample(),
                          ));
                        },
                      ),

                    ],
                  )
                  ,


                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: double
                              .infinity, // Ensure the container takes the full available width
                          child: TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            controller: docnoController,
                            enabled: false, // Set to false to make it read-only
                            decoration: InputDecoration(
                              labelText: 'Trx No.',
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                    color: Colors
                                        .black), // Set the border color to black
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical:
                                  10.0), // Adjust the vertical padding as needed
                              labelStyle: TextStyle(
                                fontSize: 20, // Adjust the font size as needed
                                color:
                                Colors.grey, // Adjust the color as needed
                              ),
                            ),

                            style: TextStyle(
                                fontSize:
                                30), // Adjust the font size of the entered text as needed
                            textAlignVertical: TextAlignVertical
                                .bottom, // Align the text to the bottom of the TextField
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: double
                              .infinity, // Ensure the container takes the full available width
                          child: TextField(
                            readOnly: true,
                            style: TextStyle(
                                fontSize:
                                30), // Increase the font size to 30 for the date text
                            decoration: InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                              ),
                              suffixIcon: Icon(Icons.calendar_today),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical:
                                  10.0), // Adjust the vertical padding as needed
                              labelStyle: TextStyle(
                                fontSize:
                                20, // Adjust the font size of the label as needed
                                color:
                                Colors.grey, // Adjust the color as needed
                              ),
                            ),
                            controller:
                            dateController, // set the controller for the text field
                            onTap: () async {
                              final DateTime currentDate = DateTime.now();
                              final DateTime? selectedDate =
                              await showDatePicker(
                                context: context,
                                initialDate: currentDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
                              if (selectedDate != null) {
                                // update the value of the text field with the selected date
                                String formattedDate = DateFormat('MM/dd/yyyy')
                                    .format(selectedDate);
                                dateController.text = formattedDate;
                              } else {
                                // If no date is selected, fill the field with the current date
                                String formattedDate = DateFormat('MM/dd/yyyy')
                                    .format(currentDate);
                                dateController.text = formattedDate;
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: vendornameController,
                    decoration: const InputDecoration(
                      labelText: 'Vendor Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical:
                          10), // Adjust the vertical padding as needed
                      labelStyle: TextStyle(
                          fontSize:
                          20), // Adjust the font size of the label as needed
                    ),
                    style: TextStyle(
                        fontSize:
                        30), // Adjust the font size of the entered text as needed
                    textAlignVertical: TextAlignVertical
                        .bottom, // Align the text to the bottom of the TextField
                    onSubmitted: (_) {
                      // You can choose to perform an action or not here
                      // For example, you can uncomment the line below to call _fetchDataFromDatabase:
                      // _fetchDataFromDatabase();
                    },
                  ),

                  const SizedBox(height: 20),
                  // ...
                  Row(
                    children: [
                      DataTable(
                        columnSpacing:
                        25, // Set the spacing between columns to 0
                        columns: [
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 10), // Adjust padding as needed
                              height: 40.0,
                              child: const Text(
                                'Qty',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 5), // Adjust padding as needed
                              height: 40.0,
                              child: const Text(
                                'Unit Price',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 10), // Adjust padding as needed
                              height: 40.0,
                              child: const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: generateRows(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Table(
                    border: TableBorder.all(
                      borderRadius:
                      const BorderRadius.all(Radius.circular(10.0)),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment
                                .bottom, // Align the content to the bottom
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment
                                    .end, // Align the text to the bottom of the cell
                                children: [
                                  Text(
                                    'Grand Total:',
                                    style: TextStyle(
                                      fontSize:
                                      30, // Increase the font size to 30
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height:
                                      50.0,
                                      width: 70.0,// Set the desired height for the cell
                                      child: TextFormField(
                                        controller: totalamountController,
                                        readOnly: true,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize:
                                          30, // Increase the font size to 30
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  //grandtotal
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Show the dialog


                      printReceipt(); // Call your printReceipt function here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                          0xFF2366e8), // Set the button color to the specified value
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            25), // Set the border radius to 25
                      ),
                      minimumSize: const Size(70,
                          80), // Increase the height to 80 or adjust as needed
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center the text and icon horizontally
                      children: [
                        Icon(
                          Icons.print,
                          size: 60.0,
                          color: Colors.white, // Set the icon color
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          'Print',
                          style: TextStyle(
                            color: Colors.white, // Set the text color
                            fontSize: 40, // Set the font size
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Add the code you provided here
                ],
              ),
            ),
          ),
        ),
      ),
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
                Icons
                    .local_printshop_outlined, // Replace with the printer icon you prefer
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
// void main() {
//   runApp(HomeScreen());
// }