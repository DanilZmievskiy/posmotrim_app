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

  late SharedPreferences sharedPreferences;
  Map<String, dynamic>? currentUser;
  var userStatus = [];
  var watchSt = [];
  var watchedSt = [];
  var willSt = [];
  var quitSt = [];

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    final response = await http.get(
        Uri.parse('${dotenv.env['BACKEND_HTTP']}/users/me'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
    );
    if (response.statusCode == 200) {
      setState(() {
        currentUser = json.decode(response.body);
      });
      fetchUserStatus();
    } else {
      throw Exception('Не удалось получить данные о пользователе');
    }
  }

  Future refresh() async {
    String? token = sharedPreferences.getString('token');
    final response = await http.get(
        Uri.parse('${dotenv.env['BACKEND_HTTP']}/statuses/${currentUser!['id']}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
    );
    if (response.statusCode == 200) {
      setState(() {
        userStatus = json.decode(utf8.decode(response.bodyBytes));
        watchedSt.clear();
        watchSt.clear();
        willSt.clear();
        quitSt.clear();
        for(var st in userStatus) {
          if(st['status'] == 'Смотрю') {
            watchSt.add(st);
          } else if(st['status'] == 'Посмотрел') {
            watchedSt.add(st);
          } else if(st['status'] == 'Буду смотреть') {
            willSt.add(st);
          } else if(st['status'] == 'Бросил') {
            quitSt.add(st);
          }
        }
      });
    } else {
      throw Exception('Не удалось получить данные о статусах пользователя');
    }
  }

  Future<void> fetchUserStatus() async {
    String? token = sharedPreferences.getString('token');
    final response = await http.get(
        Uri.parse('${dotenv.env['BACKEND_HTTP']}/statuses/${currentUser!['id']}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
    );
    if (response.statusCode == 200) {
      setState(() {
        userStatus = json.decode(utf8.decode(response.bodyBytes));
        for(var st in userStatus) {
          if(st['status'] == 'Смотрю') {
            watchedSt.add(st);
          } else if(st['status'] == 'Посмотрел') {
            watchedSt.add(st);
          } else if(st['status'] == 'Буду смотреть') {
            willSt.add(st);
          } else if(st['status'] == 'Бросил') {
            quitSt.add(st);
          }
        }
      });
    } else {
      throw Exception('Не удалось получить данные о статусах пользователя');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            isScrollable: true,
            unselectedLabelColor: Colors.black,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.black,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(
                child: Container(
                  height: 40,
                  padding: EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text('Смотрю', style: TextStyle(color: Colors.lightGreen),)),
                ),
              ),
              Tab(
                child: Container(
                  height: 40,
                  padding: EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.black, width: 1)),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text('Посмотрел', style: TextStyle(color: Colors.blue),)),
                ),
              ),
              Tab(
                child: Container(
                  height: 40,
                  padding: EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.black, width: 1)),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text('Буду смотреть', style: TextStyle(color: Colors.yellow),)),
                ),
              ),
              Tab(
                child: Container(
                  height: 40,
                  padding: EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.black, width: 1)),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text('Бросил', style: TextStyle(color: Colors.red))),
                ),
              )
            ],
          ),
          backgroundColor: Colors.grey,
        ),
        body: TabBarView(
          children: [
            Container(
              color: Colors.grey.shade900,
              child: RefreshIndicator(
                onRefresh: refresh,
                child: GridView.builder(
                  itemCount: watchSt.length,
                  padding: EdgeInsets.only(top: 15.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    final status = watchSt[index];
                    final movie_id = status['film_id'];
                    return movieCard(movie_id);
                  },
                ),
              )
            ),
            Container(
                color: Colors.grey.shade900,
                child: RefreshIndicator(
                  onRefresh: refresh,
                  child: GridView.builder(
                    itemCount: watchedSt.length,
                    padding: EdgeInsets.only(top: 15.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      final status = watchedSt[index];
                      final movie_id = status['film_id'];
                      return movieCard(movie_id);
                    },
                  ),
                )
            ),
            Container(
                color: Colors.grey.shade900,
                child: RefreshIndicator(
                  onRefresh: refresh,
                  child: GridView.builder(
                    itemCount: willSt.length,
                    padding: EdgeInsets.only(top: 15.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      final status = willSt[index];
                      final movie_id = status['film_id'];
                      return movieCard(movie_id);
                    },
                  ),
                )
            ),
            Container(
                color: Colors.grey.shade900,
                child: RefreshIndicator(
                  onRefresh: refresh,
                  child: GridView.builder(
                    itemCount: quitSt.length,
                    padding: EdgeInsets.only(top: 15.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      final status = quitSt[index];
                      final movie_id = status['film_id'];
                      return movieCard(movie_id);
                    },
                  ),
                )
            )
          ],
        ),
      )
    );
  }

  Widget movieCard(movie_id) => GestureDetector(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            'https://www.kinopoisk.ru/images/film_big/${movie_id}.jpg',
            height: 150,
            width: 150,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
      ],
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MoviePage(
            filmId: movie_id,
          ),
        ),
      );
    },
  );
}