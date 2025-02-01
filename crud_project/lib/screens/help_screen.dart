import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HelpScreen(),
    );
  }
}

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  // Function to send email
  Future<void> sendEmail(String name, String email, String description) async {
    final Uri emailURL = Uri(
      scheme: 'mailto',
      path: 'support@example.com', // Replace with the recipient's email
      query: Uri.encodeFull(
        'subject=Help Request&body=Name: $name\nEmail: $email\nDescription: $description',
      ),
    );

    if (await canLaunch(emailURL.toString())) {
      await launch(emailURL.toString());
      // Show a "Done!" message after email is sent
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Done!')),
      );
      // Clear the fields after sending the email
      _nameController.clear();
      _emailController.clear();
      _descriptionController.clear();
    } else {
      throw 'Could not send email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Name field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Email field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Your Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Description field
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Describe your issue',
                border: OutlineInputBorder(),
              ),
              maxLines: 5, // Allows multiple lines of input
            ),
            SizedBox(height: 16),
            // Button to send the email
            ElevatedButton(
              onPressed: () {
                // Get the text from the fields and send the email
                String name = _nameController.text;
                String email = _emailController.text;
                String description = _descriptionController.text;

                if (name.isNotEmpty && email.isNotEmpty && description.isNotEmpty) {
                  sendEmail(name, email, description);
                } else {
                  // Show an error if any field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields')),
                  );
                }
              },
              child: Text('Send Help Email'),
            ),
          ],
        ),
      ),
    );
  }
}
