import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:posmotrim_app/signin_page.dart';
import 'package:posmotrim_app/movie.dart';


class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>{

  late SharedPreferences sharedPreferences;

  Map<String, dynamic> currentUser = {};


  @override
  void initState() {
    fetchCurrentUser();
    super.initState();
  }

  Future<void> fetchCurrentUser() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    print("Bearer $token");
    final response = await http.get(
        Uri.parse('${dotenv.env['BACKEND_HTTP']}/users/me'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
    );
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        currentUser = json.decode(response.body);
      });
    } else {
      throw Exception('Не удалось получить данные о пользователе');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 50),

        const Icon(
          Icons.person,
          size: 80,
          color: Colors.white,
        ),

        const SizedBox(height: 10),

        Text(
          currentUser['email'].toString(),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60)
        ),

        const SizedBox(height: 50),

        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Text(
            "Details:",
            style: TextStyle(color: Colors.white70, fontSize: 25)
          ),
        ),

        Text(
            currentUser['username'].toString(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 20)
        ),

        const SizedBox(height: 20),

        Text(
            currentUser['birthday'].toString().substring(0, 10),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 20)
        )
      ],
    );
  }
}
