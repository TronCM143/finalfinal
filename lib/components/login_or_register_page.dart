import 'package:flutter/material.dart';

import '../pages/login_page_widget.dart';
import '../pages/signup_page.dart';


class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  //show login page initial
  bool showLoginPage = true;

  //toggle
  void toggle() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPageWidget(
        onTap: toggle,
      );
    } else {
      return SignUpPageWidget(
        onTap: toggle,
      );
    }
  }
}