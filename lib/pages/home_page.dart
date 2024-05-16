import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapa/components/auth_page.dart';
import 'package:mapa/pages/profile_pdage.dart';

import '../map.dart';
import 'devices_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

void signUserOut(BuildContext context) {
  FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
        builder: (context) =>
            AuthPage()), // Replace AuthPage with your actual authentication page
  );
}

class _HomePageState extends State<HomePage> {
  int myIndex = 0;
  List<Widget> navigationList = const [
    //1map 2devices 3account
    MapPage(),
    DevicesPage(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 30,
              child: IndexedStack(
                index: myIndex,
                children: navigationList,
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 25,
                width: double.infinity,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        // Wrap CurvedNavigationBar with SizedBox
        height: kBottomNavigationBarHeight,
        child: CurvedNavigationBar(
          backgroundColor: Colors.white,
          animationDuration: const Duration(milliseconds: 400),
          color: const Color(0xFF5BABCD),
          items: const [
            Icon(
              Icons.home,
              size: 30,
              color: Colors.white,
            ),
            Icon(Icons.devices, size: 30, color: Colors.white),
            Icon(Icons.account_circle, size: 30, color: Colors.white),
          ],
          onTap: (index) {
            setState(() {
              myIndex = index;
            });
          },
        ),
      ),
    );
  }
}
