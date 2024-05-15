import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapa/pages/profile_pdage.dart';

import '../map.dart';
import 'devices_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

void signUserOut() {
  FirebaseAuth.instance.signOut();
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
      appBar: AppBar(backgroundColor: const Color(0xFF5BABCD), actions: const [
        IconButton(
          onPressed: signUserOut,
          icon: Icon(
            Icons.logout,
          ),
        )
      ]),
      //body:indexedStack(children: navigationList, index: myIndex,) sunod kung kayo na ang map
      body: Center(
        child: IndexedStack(
          children: navigationList,
          index: myIndex,
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 400),
        color: const Color(0xFF5BABCD),
        items: const [
          Icon(Icons.home, size: 30, color: Colors.white,),
          Icon(Icons.devices, size: 30, color: Colors.white),
          Icon(Icons.account_circle, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
          ),
    );
  }
}
