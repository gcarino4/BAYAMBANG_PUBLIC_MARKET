import 'package:flutter/material.dart';

class ModernAlertDialog extends StatefulWidget {
  const ModernAlertDialog({
    Key? key,
    required this.title,
    required this.description,
    this.onOkPressed,
  }) : super(key: key);

  final String title, description;
  final VoidCallback? onOkPressed; // New parameter

  @override
  _ModernAlertDialogState createState() => _ModernAlertDialogState();
}


class _ModernAlertDialogState extends State<ModernAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15),
            Text(
              "${widget.title}",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "${widget.description}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
            SizedBox(height: 20),
            Divider(
              height: 1,
              color: Colors.grey,
            ),
            // Add the actions here
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (widget.onOkPressed != null) {
                  widget.onOkPressed!(); // Call the callback function
                }
              },
              child: Text(
                "OK",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

