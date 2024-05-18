import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapa/components/auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profilePictureUrl; // Change to nullable type

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if (currentUser.providerData.any((userInfo) =>
          userInfo.providerId == GoogleAuthProvider.PROVIDER_ID)) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signInSilently();
        if (googleUser != null) {
          setState(() {
            _profilePictureUrl = googleUser.photoUrl;
          });
          // Store email to Firestore
          await _storeEmailToFirestore(currentUser.uid, currentUser.email!);
        }
      } else {
        setState(() {
          _profilePictureUrl = null;
        });
      }
    }
  }

  Future<void> _storeEmailToFirestore(String uid, String email) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      await userRef.set({'email': email}, SetOptions(merge: true));
      print('Email stored to Firestore for user $uid');
    } catch (e) {
      print('Error storing email to Firestore: $e');
    }
  }

  Future<void> signUserOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthPage(),
        ),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  // Display profile picture or default icon based on the URL
                  backgroundColor: const Color(0xFF5BABCD),
                  radius: 50,
                  child: _profilePictureUrl != null
                      ? ClipOval(
                          child: Image.network(
                            _profilePictureUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.account_circle,
                          size: 100,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(width: 20),
                Text(
                  '${FirebaseAuth.instance.currentUser!.email}',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add any future content here
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: () => signUserOut(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: const Color(0xFF5BABCD),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
