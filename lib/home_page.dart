import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:posmotrim_app/signin_page.dart';
import 'package:posmotrim_app/movie.dart';
import 'package:posmotrim_app/user_page.dart';
import 'package:posmotrim_app/status_page.dart';
import 'package:posmotrim_app/home_page_placeholder.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>{

  late SharedPreferences sharedPreferences;

  int _selectedIndex = 0;

  final _widgetOptions = [
    MainPagePlaceholder(),
    StatusPage(),
    UserPage()
  ];

  @override
  void initState() {
    checkLoginStatus();
    super.initState();
  }


  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => SignInPage()), (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Posmotrim", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black45,
        actions: <Widget>[
          TextButton(
              onPressed: () {
                sharedPreferences.clear();
                sharedPreferences.commit();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => SignInPage()), (Route<dynamic> route) => false);
              },
              child: Text("Log Out", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade900,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(60.0),
          boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: Colors.teal,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            tabBorderRadius: 100,
            gap: 8,
            tabs: const [
              GButton(
                icon: Icons.home,
                text: "Home",
              ),
              GButton(
                icon: Icons.bookmark_border,
                text: "Status",
              ),
              GButton(
                icon: Icons.person_2_outlined,
                text: "User",
              )
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
    );
  }
}