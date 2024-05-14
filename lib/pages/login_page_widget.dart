import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/button.dart';
import '../components/icon_tile.dart';
import '../components/my_textfield.dart';
import '../services/auth_service.dart';

class LoginPageWidget extends StatefulWidget {
  final Function()? onTap;
  const LoginPageWidget({super.key, required this.onTap});

  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  void signInUser() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    try {
       await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
        );
      Navigator.pop(context); 
    } on FirebaseAuthException catch (e) { 
      
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
    //FirebseAuth.instance.signOut(); sa settings page pa ni kung mag sign out
  }

  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF5BABCD),
            title: Center(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w900,
                )
              ),
            ),
          );
        });
  }
  @override
  Widget build(BuildContext context) { 
    return SafeArea(
        child: Scaffold(
            body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                vertical: 50, horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo_with_name2.png',
                width: 300,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // logo ^^
          Text(
            'LOGIN',
            style: GoogleFonts.montserrat(
                textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 50,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none)),
          ), //LOGIN
          Align(
              alignment: const AlignmentDirectional(-1, 0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(38, 14, 0, 10),
                child: Text(
                  'Welcome back!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.none)),
                ),
              )), // welcomeback

          // TEXTFIELD NANA DIRI
          MyTextField(
            controller: emailController,
            hintText: 'Email',
            obscureText: false,
          ),

          MyTextField(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true),
          //signup button
          MyButton(
            onTap: signInUser, 
            text: 'Sign in'
          ),
          
          //linya
          const SizedBox(
            height: 20,
          ),
          const Divider(
            indent: 60,
            endIndent: 60,
            thickness: 1.5,
            color: Colors.black,
          ),

          Container(
            alignment: Alignment.center,
            child: const Text(
              'Or sign in with:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.w400,
              ),
              //sign in with
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Padding(
            // google apple auth
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SquareTile(
                  imagePath: 'assets/icons/google.png',
                  onTap: () => AuthService().signInWithGoogle()
                  
                ),
                SquareTile(
                  imagePath: 'assets/icons/apple.png',
                  onTap: () => AuthService().signInWithApple()
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),

          //no account sihn up
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account?",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(width: 5), // Add some space between the texts
              GestureDetector(
                onTap: widget.onTap,
                child: const Text('Sign up',
                    style: TextStyle(
                      color: Color(0xFF5BABCD),
                      fontSize: 15,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.normal,
                    )),
              ),
            ],
          )
        ],
      ),
    )));
  }
}
