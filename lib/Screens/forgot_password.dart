import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  void sendResetEmail(BuildContext context, String email) async {
    String username = 'crisander.publicmarket@gmail.com';
    String password = 'hwzwtlrxiczruiwf';

    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'PUBLIC MARKET TEST')
      ..recipients.add(email)
      ..subject = 'Reset Password'
      ..html = '''
          <p>Instructions for resetting your password:</p>
          <p>Click the button below to reset your password:</p>
          <p><a href="https://example.com/reset-password">Reset Password</a></p>
          ''';

    try {
      await send(message, smtpServer);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Email Sent'),
          content: Text('Check your email for instructions on how to reset your password.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error sending email: $e');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred while sending the email.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 32.0),
            const Text(
              'Forgot your password?',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Enter your email address below and we\'ll send you instructions on how to reset your password.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () => sendResetEmail(context, emailController.text),
              child: const Text('RESET PASSWORD'),
            ),
          ],
        ),
      ),
    );
  }
}
