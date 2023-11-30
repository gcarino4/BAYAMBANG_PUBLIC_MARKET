import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:image_picker/image_picker.dart';

import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'registration.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
        CREATE TABLE registration (
          id INTEGER PRIMARY KEY,
          rsbsa TEXT,
          fname TEXT,
          lname TEXT,
          birthdate TEXT,
          email TEXT,
          phone TEXT(11),
          password TEXT
          image TEXT
        )
      ''');
        });
  }

  Future<int> insertRegistration(Map<String, dynamic> registration) async {
    final db = await this.db;
    return await db!.insert('registration', registration);
  }

  Future<List<Map<String, dynamic>>> getAllRegistrations() async {
    final db = await this.db;
    return await db!.query('registration');
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Existing fields
  String _rsbsa = '';
  String _fname = '';
  String _lname = '';
  String? _email;
  String _password = '';
  String _phone = '';
  TextEditingController _dateController = TextEditingController();
  // New image field
  File? _imageFile;

  late Database _database;

  Future<void> _selectImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'registration.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE registration (
          id INTEGER PRIMARY KEY,
          rsbsa TEXT,
          fname TEXT,
          lname TEXT,
          birthdate TEXT,
          email TEXT,
          phone TEXT(11),
          password TEXT,
          image TEXT
        )
''');
      },
    );
  }

  Future<int> insertRegistration(Map<String, dynamic> registration) async {
    return await _database.insert('registration', registration);
  }

  Future<List<Map<String, dynamic>>> getAllRegistrations() async {
    return await _database.query('registration');
  }

  void createAccountPressed(BuildContext context) async {
    // Validate user input
    if (_rsbsa.isEmpty ||
        _fname.isEmpty ||
        _lname.isEmpty ||
        _password.isEmpty ||
        _phone.isEmpty) {
      // Show an error message or perform some validation handling
      return;
    }

    String? base64Image = null; // Declare the variable with a default value
    if (_imageFile != null) {
      List<int> imageBytes = await _imageFile!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    // Insert registration details into the database
    Map<String, dynamic> registration = {
      'rsbsa': _rsbsa,
      'fname': _fname,
      'lname': _lname,
      'birthdate': _dateController.text,
      'email': _email,
      'phone': _phone,
      'password': _password,
      'image':
      base64Image, // Add the base64 encoded image to the registration map
    };
    await insertRegistration(registration);

    // Save registrations to a CSV file
    final registrations = await getAllRegistrations();
    final csvData = [
      [
        'ID',
        'RSBSA',
        'First Name',
        'Last Name',
        'Birthdate',
        'Email',
        'Phone',
        'Password',
        'Image Path'
      ], // Add the header
      ...registrations.map((registration) => [
        registration['id'],
        registration['rsbsa'],
        registration['fname'],
        registration['lname'],
        registration['birthdate'],
        registration['email'],
        registration['phone'],
        registration['password'],
        registration['image'], // Add the image path to each registration entry
      ]),
    ];
    final csvFile = const ListToCsvConverter().convert(csvData);
    final output = await getExternalStorageDirectory();
    final outputFile = File('${output!.path}/registrations.csv');
    await outputFile.writeAsString(csvFile);
    print(outputFile.path);

    // Navigate to HomeScreen after successful registration
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );

    // Print the registration details to the console
    print(registration);
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildImagePicker() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Image',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 8.0),
          GestureDetector(
            onTap: _selectImage,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue.withOpacity(.1),
                borderRadius: BorderRadius.circular(15.0),
              ),
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.image),
                  SizedBox(width: 8.0),
                  Text(
                    _imageFile != null
                        ? 'Image selected'
                        : 'Tap to select an image',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: _imageFile != null ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.lightGreen,
        ),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 50, 0),
            child: Image.asset(
              'assets/logo.png',
              height: 36,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 30.0),
              Text(
                'To start your journey with us, please take a moment to verify your RSBSA Number with your personal information',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15.0,
                  color: Colors.grey,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30.0),
                  Text(
                    'RSBSA Number',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'xx-xxxxxxx-xxx',
                      filled: true,
                      fillColor: Colors.lightBlue.withOpacity(.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    onChanged: (value) {
                      _rsbsa = value;
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'First Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.lightBlue.withOpacity(.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                          ),
                          onChanged: (value) {
                            _fname = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.lightBlue.withOpacity(.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                          ),
                          onChanged: (value) {
                            _lname = value;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birthdate',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'dd/mm/yyyy',
                      filled: true,
                      fillColor: Colors.lightBlue.withOpacity(.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    controller: _dateController,
                    onTap: () async {
                      final DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        String formattedDate =
                        DateFormat('MM/dd/yyyy').format(selectedDate);
                        _dateController.text = formattedDate;
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email (Optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    onChanged: (value) {
                      _email = value;
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cellphone Number',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    decoration: InputDecoration(
                      hintText: '09xxxxxxxxx',
                      filled: true,
                      fillColor: Colors.lightBlue.withOpacity(.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    onChanged: (value) {
                      _phone = value;
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    onChanged: (value) {
                      _password = value;
                    },
                  ),
                ],
              ),
              SizedBox(height: 30.0),
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () {
                    createAccountPressed(context); // Pass the BuildContext
                  },
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              _buildImagePicker(), // Add the image picker widget
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
