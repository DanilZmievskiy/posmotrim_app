import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:posmotrim_app/main.dart';
import 'package:posmotrim_app/signin_page.dart';

class SignUpPage extends StatefulWidget {

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

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
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => SignInPage()), (Route<dynamic> route) => false);
              },
              child: Text("Eсть аккаунт?  Ввойди!", style: TextStyle(color: Colors.white))
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
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmpassController = new TextEditingController();
  TextEditingController birthdayController = new TextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      margin: EdgeInsets.only(top: 30.0),
      child: Column(
        children: <Widget>[
          txtEmail("Email", Icons.email),
          SizedBox(height: 10.0),
          txtUsername("Username", Icons.person),
          SizedBox(height: 10.0),
          txtPassword("Password", Icons.lock),
          SizedBox(height: 10.0),
          txtConfirmPass("Confirm Password", Icons.lock),
          SizedBox(height: 10.0),
          txtBirthday("Birthday", Icons.date_range),
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

  Material txtUsername(String title, IconData icon) {
    return Material(
      child: TextFormField(
        controller: usernameController,
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

  Material txtConfirmPass(String title, IconData icon) {
    return Material(
      child: TextFormField(
        controller: confirmpassController,
        style: TextStyle(color: Colors.black54),
        decoration: InputDecoration(
            hintText: title,
            hintStyle: TextStyle(color: Colors.black54),
            icon: Icon(icon)
        ),
      ),
    );
  }

  Material txtBirthday(String title, IconData icon) {
    return Material(
      child: TextFormField(
        controller: birthdayController,
        style: TextStyle(color: Colors.black54),
        decoration: InputDecoration(
            hintText: title,
            hintStyle: TextStyle(color: Colors.black54),
            icon: Icon(icon)
        ),
        onTap: () async {
          DateTime? pickeddate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1923),
              lastDate: DateTime.now());

          if(pickeddate != null) {
            setState(() {
              birthdayController.text = DateFormat('yyyy-MM-dd').format(pickeddate);
            });
          }
        },
      ),
    );
  }

  signUp(String email, username, password, confirmpass, birthday) async {
    String newformat = "T00:00:00.000Z";
    String today = DateFormat('yyyy-MM-ddTHH:mm:ss.S').format(DateTime.now()) + "Z";

    Map data = {
      'email': email,
      'password': password,
      'is_active': true,
      'is_superuser': false,
      'is_verified': false,
      'username': username,
      'birthday': birthday + newformat,
      'created_at': today
    };
    var body = json.encode(data);

    var response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_HTTP']}/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: body
    );
    //print(response);
    //print(json.decode(response.body));
    if(response.statusCode == 201) {
      print('OKKKK');
      setState(() {
        _isLoading = false;
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => SignInPage()), (Route<dynamic> route) => false);
      });
    }
    else {
      print("ERRRRROOOORRRR");
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
          signUp(
              emailController.text,
              usernameController.text,
              passwordController.text,
              confirmpassController.text,
              birthdayController.text,
          );
        },
        child: Text("Sign Up", style: TextStyle(color: Colors.white70)),
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
