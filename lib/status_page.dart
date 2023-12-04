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
import 'package:posmotrim_app/home_page_placeholder.dart';


class StatusPage extends StatefulWidget {
  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage>{

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Text(
      'Status',
      style: TextStyle(color: Colors.white),
    );
  }
}