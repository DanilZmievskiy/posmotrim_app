import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:posmotrim_app/sigup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:posmotrim_app/main.dart';
import 'package:posmotrim_app/home_page.dart';

class SignInPage extends StatefulWidget {

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal,
            Colors.black54,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter
        ),
      ),
      child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
        children: <Widget>[
          headerSection(),
          textSection(),
          buttonSection(),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => SignUpPage()), (Route<dynamic> route) => false);
              },
              child: Text("Нет аккаунта?  Зарегистрируйся!", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 70.0, vertical: 150.0),
      child: Text("Posmotrim", style: TextStyle(color: Colors.white)),
    );
  }

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      margin: EdgeInsets.only(top: 100.0),
      child: Column(
        children: <Widget>[
          txtEmail("Email", Icons.email),
          SizedBox(height: 30.0),
          txtPassword("Password", Icons.lock),
        ],
      ),
    );
  }

  Material txtEmail(String title, IconData icon) {
    return Material(
      child: TextFormField(
        controller: emailController,
        style: TextStyle(color: Colors.black54),
        decoration: InputDecoration(
            hintText: title,
            hintStyle: TextStyle(color: Colors.black54),
            icon: Icon(icon)
        ),
      ),
    );
  }

  Material txtPassword(String title, IconData icon) {
    return Material(
      child: TextFormField(
        controller: passwordController,
        style: TextStyle(color: Colors.black54),
        decoration: InputDecoration(
            hintText: title,
            hintStyle: TextStyle(color: Colors.black54),
            icon: Icon(icon)
        ),
      ),
    );
  }

  signIn(String email, password) async {
    Map data = {
      'username': email,
      'password': password,
    };
    var jsonData = null;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.parse('${dotenv.env['BACKEND_HTTP']}/auth/jwt/login'),
      body: data
    );
    if(response.statusCode == 200) {
      jsonData = json.decode(response.body);
      setState(() {
        _isLoading = false;
        sharedPreferences.setString('token', jsonData['access_token']);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()), (Route<dynamic> route) => false);
      });
    }
    else {
      print(response.body);
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      margin: EdgeInsets.only(top: 30.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isLoading = true;
          });
          signIn(emailController.text, passwordController.text);
        },
        child: Text("Sign In", style: TextStyle(color: Colors.white70)),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          primary: Colors.green
        ),
      ),
    );
  }
}
