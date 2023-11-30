import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String loggedInUsername = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _login(context),
                child: Text('Login'),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    // Perform validation
    if (_formKey.currentState!.validate()) {
      final Database database = await _openDatabase();

      // Check if the user exists in the database
      final List<Map<String, dynamic>> result = await database.rawQuery(
        'SELECT * FROM users WHERE username = ? AND password = ?',
        [username, password],
      );

      if (result.isNotEmpty) {
        final String birthdate = result[0]['birthdate'];
        final String fullname = result[0]['fullname'];

        // User authenticated, navigate to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              loggedInBirthdate: birthdate,
              loggedInFullName: fullname,
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Login Failed'),
              content: Text('Invalid username or password.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    }
  }


  Future<Database> _openDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String dbPath = join(databasesPath, 'my_database.db');

    // Create and open the database
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create the users table
        await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT,
              password TEXT
            )
          ''');
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}
class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController(); // New field
  final TextEditingController _fullnameController = TextEditingController(); // New field
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate; // New field to store the selected date

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password.';
                  }
                  return null;
                },
              ),
              GestureDetector(
                onTap: () => _selectDate(context), // Open date picker on tap
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _birthdateController,
                    decoration: InputDecoration(labelText: 'Birthdate'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your birthdate.';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              TextFormField(
                controller: _fullnameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _register(context),
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _birthdateController.text = _selectedDate!.toString();
      });
    }
  }

  Future<void> _register(BuildContext context) async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    final String birthdate = _birthdateController.text.trim(); // New field
    final String fullname = _fullnameController.text.trim(); // New field

    // Perform validation
    if (_formKey.currentState!.validate()) {
      final Database database = await _openDatabase();

      // Check if the username is already taken
      final List<Map<String, dynamic>> result = await database.rawQuery(
        'SELECT * FROM users WHERE username = ?',
        [username],
      );

      if (result.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Registration Failed'),
              content: Text('Username already taken.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      } else {
        // Insert the new user into the database
        await database.rawInsert(
          'INSERT INTO users (username, password, birthdate, fullname) VALUES (?, ?, ?, ?)', // Include new fields
          [username, password, birthdate, fullname], // Include new fields
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Registration Successful'),
              content: Text('You have successfully registered.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<Database> _openDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String dbPath = join(databasesPath, 'my_database.db');

    // Create and open the database
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create the users table
        await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT,
              password TEXT,
              birthdate TEXT,
              fullname TEXT
            )
          ''');
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _birthdateController.dispose();
    _fullnameController.dispose();
    super.dispose();
  }
}



class HomePage extends StatelessWidget {
  final String loggedInBirthdate;
  final String loggedInFullName;

  HomePage({required this.loggedInBirthdate, required this.loggedInFullName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Birthdate: $loggedInBirthdate',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Full Name: $loggedInFullName',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}





