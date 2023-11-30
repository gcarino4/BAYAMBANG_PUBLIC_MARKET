// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:csv/csv.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:public_market/Screens/download_data.dart';
// import 'package:public_market/Screens/login_screen.dart';
// import 'package:intl/intl.dart';
// import 'package:public_market/Screens/summary.dart';
// import 'package:public_market/Screens/upload_data.dart';
// import 'package:public_market/Screens/setup_screen.dart';
// import 'package:public_market/Screens/settings_screen.dart';
// import 'package:public_market/Screens/profile_screen.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:printing/printing.dart';
//
// class HomeScreen extends StatelessWidget {
//   final dateController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Receipt Printer',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: ReceiptPrinterScreen(),
//     );
//   }
// }
//
// class ReceiptPrinterScreen extends StatefulWidget {
//   @override
//   _ReceiptPrinterScreenState createState() => _ReceiptPrinterScreenState();
// }
//
// class _ReceiptPrinterScreenState extends State<ReceiptPrinterScreen> {
//   TextEditingController barcodeController = TextEditingController();
//   TextEditingController trxnoController = TextEditingController();
//   TextEditingController dateController = TextEditingController();
//   TextEditingController vendornameController = TextEditingController();
//   TextEditingController quantityController = TextEditingController();
//   TextEditingController unitpriceController = TextEditingController();
//   TextEditingController totalAmountController = TextEditingController();
//
//   void _computeTotal() {
//     final qty = int.tryParse(quantityController.text) ?? 0;
//     final unitPrice = double.tryParse(unitpriceController.text) ?? 0.0;
//     final total = qty * unitPrice;
//     totalAmountController.text = total.toStringAsFixed(2);
//   }
//
//   void _createPdf() async {
//     final pdf = pw.Document();
//
//     // Load the logo image from the provided PNG file
//     final logoImage = pw.MemoryImage(
//       (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
//     );
//
//     // Generate the barcode
//     final barcode = pw.BarcodeWidget(
//       data: '${trxnoController.text}',
//       barcode: pw.Barcode.qrCode(),
//       width: 300,
//       height: 180,
//       drawText: false,
//     );
//
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat(700, double.infinity),
//         build: (pw.Context context) {
//           return pw.Container(
//             padding: pw.EdgeInsets.zero,
//             child: pw.Center(
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Container(
//                     alignment: pw.Alignment.center,
//                     child: pw.Image(
//                       logoImage,
//                       width: 200,
//                       fit: pw.BoxFit.contain,
//                     ),
//                   ),
//                   pw.SizedBox(height: 5),
//                   pw.Container(
//                     alignment: pw.Alignment.center,
//                     child: pw.Text(
//                       'BAYAN NG BAYAMBANG',
//                       style: pw.TextStyle(
//                         fontSize: 50,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   pw.Container(
//                     alignment: pw.Alignment.center,
//                     child: pw.Text(
//                       'PROVINCE OF PANGASINAN',
//                       style: pw.TextStyle(
//                         fontSize: 30,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   pw.Container(
//                     alignment: pw.Alignment.center,
//                     child: pw.Text(
//                       '-----------------------------------------------------------\nPUBLIC MARKET TICKET\n-----------------------------------------------------------',
//                       style: pw.TextStyle(
//                         fontSize: 35,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                       textAlign: pw.TextAlign.center,
//                     ),
//                   ),
//                   pw.SizedBox(height: 10),
//                   pw.Container(
//                     alignment: pw.Alignment.center,
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Row(
//                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                           children: [
//
//                             pw.Text(
//                               '${barcodeController.text}',
//                               style: pw.TextStyle(fontSize: 35),
//                             ),
//                           ],
//                         ),
//                         pw.SizedBox(height: 5),
//                         pw.Row(
//                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                           children: [
//                             pw.Text(
//                               'TRANSACTION NUMBER :',
//                               style: pw.TextStyle(
//                                 fontSize: 35,
//                                 fontWeight: pw.FontWeight.bold,
//                               ),
//                             ),
//                             pw.Text(
//                               '${trxnoController.text}',
//                               style: pw.TextStyle(fontSize: 35),
//                             ),
//                           ],
//                         ),
//                         pw.SizedBox(height: 5),
//                         pw.Row(
//                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                           children: [
//                             pw.Text(
//                               'DATE:',
//                               style: pw.TextStyle(
//                                 fontSize: 35,
//                                 fontWeight: pw.FontWeight.bold,
//                               ),
//                             ),
//                             pw.Text(
//                               '${dateController.text}',
//                               style: pw.TextStyle(fontSize: 35),
//                             ),
//                           ],
//                         ),
//                         pw.SizedBox(height: 5),
//                         pw.Row(
//                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                           children: [
//                             pw.Text(
//                               'VENDOR NAME:',
//                               style: pw.TextStyle(
//                                 fontSize: 35,
//                                 fontWeight: pw.FontWeight.bold,
//                               ),
//                             ),
//                             pw.Text(
//                               '${vendornameController.text}',
//                               style: pw.TextStyle(fontSize: 35),
//                             ),
//                           ],
//                         ),
//                         pw.SizedBox(height: 5),
//                         pw.Row(
//                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                           children: [
//                             pw.Text(
//                               'QUANTITY:',
//                               style: pw.TextStyle(
//                                 fontSize: 35,
//                                 fontWeight: pw.FontWeight.bold,
//                               ),
//                             ),
//                             pw.Text(
//                               '${quantityController.text}',
//                               style: pw.TextStyle(fontSize: 35),
//                             ),
//                           ],
//                         ),
//                         pw.SizedBox(height: 5),
//                         pw.Row(
//                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                           children: [
//                             pw.Text(
//                               'UNIT PRICE:',
//                               style: pw.TextStyle(
//                                 fontSize: 35,
//                                 fontWeight: pw.FontWeight.bold,
//                               ),
//                             ),
//                             pw.Text(
//                               '${unitpriceController.text}',
//                               style: pw.TextStyle(fontSize: 35),
//                             ),
//                           ],
//                         ),
//                         pw.SizedBox(height: 5),
//                         pw.Row(
//                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                           children: [
//                             pw.Text(
//                               'TOTAL AMOUNT:',
//                               style: pw.TextStyle(
//                                 fontSize: 35,
//                                 fontWeight: pw.FontWeight.bold,
//                               ),
//                             ),
//                             pw.Text(
//                               '${totalAmountController.text}',
//                               style: pw.TextStyle(fontSize: 35),
//                             ),
//                           ],
//                         ),
//                         pw.SizedBox(height: 10),
//                         pw.Container(
//                           alignment: pw.Alignment.center,
//                           child: pw.Column(
//                             children: [
//                               barcode,
//                               pw.SizedBox(height: 10),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//
//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async {
//         // Set the value of the dateController before generating the PDF
//         final now = DateTime.now();
//         final formattedDate = DateFormat('MM/dd/yyyy').format(now);
//         dateController.text = formattedDate;
//
//         return pdf.save();
//       },
//       dynamicLayout: true,
//     );
//   }
//
//   Future<List<int>> _readImageData(String imagePath) async {
//     final file = File(imagePath);
//     return await file.readAsBytes();
//   }
//
//   @override
//   void dispose() {
//     barcodeController.dispose();
//     trxnoController.dispose();
//     dateController.dispose();
//     vendornameController.dispose();
//     quantityController.dispose();
//     unitpriceController.dispose();
//     totalAmountController.dispose();
//     super.dispose();
//   }
//
//   Future<String> get _localPath async {
//     final directory = await getExternalStorageDirectory();
//     final now = DateTime.now();
//     final dateFormat = DateFormat('yyyy-MM-dd');
//     final folderPath =
//         '${directory!.path}/${dateFormat.format(now)}'; // com.example.publicmarket_sqlite/2023-05-30
//     await Directory(folderPath).create(recursive: true);
//     return folderPath;
//   }
//
//   Future<File> get _localFile async {
//     final path = await _localPath;
//     final trxno = trxnoController.text;
//     return File('$path/receipt_$trxno.csv');
//   }
//
//   void printReceipt() async {
//     String barcode = barcodeController.text;
//     String trxno = trxnoController.text;
//     String date = dateController.text;
//     String vendorname = vendornameController.text;
//     double? unitprice = double.tryParse(unitpriceController.text);
//     int? quantity = int.tryParse(quantityController.text);
//
//     if (barcode != null &&
//         trxno != null &&
//         date != null &&
//         vendorname != null &&
//         quantity != null) {
//       double totalAmount = quantity * unitprice!;
//
//       List<List<dynamic>> csvData = [
//         [
//           'Barcode',
//           'TrxNo',
//           'Date',
//           'VendorName',
//           'Quantity',
//           'UnitPrice',
//           'Total'
//         ],
//         [barcode, trxno, date, vendorname, quantity, unitprice, totalAmount],
//       ];
//
//       String csvString = ListToCsvConverter().convert(csvData);
//
//       final file = await _localFile;
//       await file.writeAsString(csvString);
//
//       setState(() {
//         totalAmountController.text = totalAmount.toStringAsFixed(2);
//       });
//       print('Receipt printed to ${file.path}');
//     } else {
//       print('Please fill in all the fields.');
//     }
//     _createPdf();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         iconTheme: IconThemeData(
//           color: Colors.black,
//           size: 40,
//
//           /// set the color of the AppBar buttons
//         ),
//         title: Center(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 0, 50, 0),
//             child: Center(
//               child: Image.asset(
//                 'assets/images/logo.png', // replace this with the path to your image
//                 height: 60, // set the height of the image
//               ),
//             ),
//           ),
//         ),
//         elevation: 0,
//         toolbarHeight: 80,
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => HomeScreen()),
//               );
//             },
//             icon: Icon(Icons.add),
//             color: Colors.black,
//             iconSize: 40, // set the size of the icon
//           ),
//         ],
//       ),
//       drawer: SafeArea(
//         child: Drawer(
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: <Widget>[
//               Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('assets/images/marketbanner.png'),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 15),
//               ListTile(
//                 leading: Icon(Icons.home),
//                 title: Text('AMBULANT COLLECTION ',
//                     style: TextStyle(color: Colors.black)),
//                 onTap: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => HomeScreen()),
//                   );
//                 },
//               ),
//
//               ListTile(
//                 leading: Icon(Icons.cloud_download),
//                 title: Text('DOWNLOAD DATA',
//                     style: TextStyle(color: Colors.black)),
//                 onTap: () {
//                   // TODO: navigate to Download Data Screen
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => DownloadData()),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.cloud_upload),
//                 title:
//                 Text('UPLOAD DATA', style: TextStyle(color: Colors.black)),
//                 onTap: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => UploadData()),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.list),
//                 title: Text('SUMMARY OF TRANSACTION', style: TextStyle(color: Colors.black)),
//                 onTap: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => Summary()),
//                   );
//                 },
//               ),
//
//               ListTile(
//                 leading: Icon(Icons.build),
//                 title: Text('SET UP', style: TextStyle(color: Colors.black)),
//                 onTap: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => SetUp()),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.settings),
//                 title: Text('SETTINGS', style: TextStyle(color: Colors.black)),
//                 onTap: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => SettingsScreen()),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.person),
//                 title: Text('PROFILE', style: TextStyle(color: Colors.black)),
//                 onTap: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => ProfileScreen()),
//                   );
//                 },
//               ),
//               Divider(), // Add a divider before the Logout button
//               ListTile(
//                 leading: Icon(Icons.logout),
//                 title: Text('LOGOUT', style: TextStyle(color: Colors.black)),
//                 onTap: () {
//                   // TODO: log out user and navigate to Login Screen
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => LoginScreen()),
//                         (route) =>
//                     false, // Remove all existing routes from the stack
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Text(
//                     'AMBULANT COLLECTION',
//                     style:
//                     TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 TextField(
//                   keyboardType:
//                   TextInputType.number, // set the keyboard to numeric only
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly
//                   ], // only
//                   controller: barcodeController, // allow digits
//                   decoration: InputDecoration(
//                     labelText: 'Barcode',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       flex: 1,
//                       child: TextField(
//                         keyboardType: TextInputType
//                             .number, // set the keyboard to numeric only
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly
//                         ], //
//                         controller: trxnoController, // only allow digits
//                         decoration: InputDecoration(
//                           labelText: ' Trx No.',
//                           border: OutlineInputBorder(
//                             borderRadius:
//                             BorderRadius.all(Radius.circular(10.0)),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     Expanded(
//                       flex: 1,
//                       child: TextField(
//                         readOnly: true,
//                         decoration: InputDecoration(
//                           labelText: 'Date',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                           ),
//                           suffixIcon: Icon(Icons.calendar_today),
//                         ),
//                         controller: dateController, // set the controller for the text field
//                         onTap: () async {
//                           final DateTime currentDate = DateTime.now();
//                           final DateTime? selectedDate = await showDatePicker(
//                             context: context,
//                             initialDate: currentDate,
//                             firstDate: DateTime(1900),
//                             lastDate: DateTime(2100),
//                           );
//                           if (selectedDate != null) {
//                             // update the value of the text field with the selected date
//                             String formattedDate = DateFormat('MM/dd/yyyy').format(selectedDate);
//                             dateController.text = formattedDate;
//                           } else {
//                             // If no date is selected, fill the field with the current date
//                             String formattedDate = DateFormat('MM/dd/yyyy').format(currentDate);
//                             dateController.text = formattedDate;
//                           }
//                         },
//                       ),
//                     ),
//
//                   ],
//                 ),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: vendornameController,
//                   decoration: InputDecoration(
//                     labelText: 'Vendor Name',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//
//                 // ...
//                 Row(
//                   children: [
//                     DataTable(
//                       columns: [
//                         DataColumn(
//                           label: Container(
//                             padding: EdgeInsets.all(10),
//                             child: Text(
//                               'Qty',
//                               style: TextStyle(
//                                 fontSize: 15,
//                               ),
//                             ),
//                           ),
//                         ),
//                         DataColumn(
//                           label: Container(
//                             padding: EdgeInsets.all(10),
//                             child: Text(
//                               'Unit Price',
//                               style: TextStyle(
//                                 fontSize: 15,
//                               ),
//                             ),
//                           ),
//                         ),
//                         DataColumn(
//                           label: Container(
//                             padding: EdgeInsets.all(10),
//                             child: Text(
//                               'Total',
//                               style: TextStyle(
//                                 fontSize: 15,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                       rows: [
//                         DataRow(
//                           cells: [
//                             DataCell(
//                               Container(
//                                 height: 100,
//                                 child: TextField(
//                                   controller: quantityController,
//                                   keyboardType: TextInputType.number,
//                                   inputFormatters: [
//                                     FilteringTextInputFormatter.digitsOnly
//                                   ],
//                                   onChanged: (_) => _computeTotal(),
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               Container(
//                                 height: 50,
//                                 child: TextField(
//                                   controller: unitpriceController,
//                                   keyboardType: TextInputType.numberWithOptions(
//                                       decimal: true),
//                                   onChanged: (_) => _computeTotal(),
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               Container(
//                                 height: 80,
//                                 child: TextFormField(
//                                   controller: totalAmountController,
//                                   readOnly: true,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//
//                 SizedBox(height: 20),
//                 Table(
//                   border: TableBorder.all(
//                     borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                   ),
//                   columnWidths: {
//                     0: FlexColumnWidth(2),
//                     1: FlexColumnWidth(1),
//                     2: FlexColumnWidth(2),
//                   },
//                   children: [
//                     TableRow(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Grand Total:',
//                                 style: TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Expanded(
//                                 child: TextFormField(
//                                   controller: totalAmountController,
//                                   readOnly: true,
//                                   textAlign: TextAlign.right,
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 //grandtotal
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: printReceipt,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.print, size: 30.0),
//                       SizedBox(width: 10.0),
//                       Text('Print'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
