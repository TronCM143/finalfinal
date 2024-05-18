import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page_widget.dart'; // Adjust the import as per your project structure

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggingOut = false; // To track the logout process

  void _logout() async {
    setState(() {
      _isLoggingOut = true; // Set the flag to true to indicate logging out
    });

    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const LoginPageWidget(onTap: null)),
      );
    } catch (e) {
      print('Error logging out: $e');
    } finally {
      setState(() {
        _isLoggingOut = false; // Reset the flag to false after logging out
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profile Page'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoggingOut
                  ? null
                  : _logout, // Disable button during logout process
              child: _isLoggingOut
                  ? const CircularProgressIndicator() // Show a progress indicator while logging out
                  : const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
