import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/button.dart';
import '../components/icon_tile.dart';
import '../components/my_textfield.dart';
import '../services/auth_service.dart';

class SignUpPageWidget extends StatefulWidget {
  final Function()? onTap;
  const SignUpPageWidget({super.key, required this.onTap});

  @override
  State<SignUpPageWidget> createState() => _SignUpPageWidgetState();
}

class _SignUpPageWidgetState extends State<SignUpPageWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUpUser() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

        //create account
    try {
      //check password-confpass
      if(passwordController.text == confirmPasswordController.text){
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
        );
         Navigator.pop(context); 
      }else{
         Navigator.pop(context); 
        showErrorMessage('Password does not match');
      }
     
    } on FirebaseAuthException catch (e) { 
      //wala ga display ang methods!!!!
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
                    width: 350,
                    height: 160,
                    fit: BoxFit.fill,
              ),
            ),
          ),
          // logo ^^
          Text(
            'Sign up',
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
                  'Create account',
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
          //confpass
          MyTextField(
              controller: confirmPasswordController,
              hintText: 'Confirm Password',
              obscureText: true),
          //signup button
          MyButton(
            onTap: signUpUser,
            text: 'Sign up' ),

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
              'Or sign up with:',
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
           //alr have account 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account?",
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
                child: const Text('Sign in',
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
