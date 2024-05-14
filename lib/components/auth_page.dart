import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import 'login_or_register_page.dart';


class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.error != null){
            return const Scaffold(
              body: Center(
                child: Text('Invalid Credentials',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Montserrat'
                ),),
              ),
            );
          }
          else if(snapshot.hasData) {
            //if logged in
            return const HomePage();
          } else {
            //no account
            return const LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
