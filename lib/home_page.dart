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


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>{

  late SharedPreferences sharedPreferences;

  var movieData = [];
  var horrorData = [];
  var dramaData = [];

  @override
  void initState() {
    checkLoginStatus();
    fetchMoviesByGenreData();
    fetchHorrorData();
    fetchDramaData();
    super.initState();
  }

  Future<void> fetchMoviesByGenreData() async {
    var requestBody = Uri.encodeFull("комедия/10");
    final response = await http.get(Uri.parse('${dotenv.env['BACKEND_HTTP']}/films/top_films_by_genre/$requestBody'));
    if (response.statusCode == 200) {
      setState(() {
        final decodedResponse = utf8.decode(response.bodyBytes);
        movieData = json.decode(decodedResponse);
      });
    } else {
      throw Exception('Не удалось получить данные о фильме');
    }
  }

  Future<void> fetchHorrorData() async {
    var requestBody = Uri.encodeFull("ужасы/10");
    final response = await http.get(Uri.parse('${dotenv.env['BACKEND_HTTP']}/films/top_films_by_genre/$requestBody'));
    if (response.statusCode == 200) {
      setState(() {
        final decodedResponse = utf8.decode(response.bodyBytes);
        horrorData = json.decode(decodedResponse);
      });
    } else {
      throw Exception('Не удалось получить данные о фильме');
    }
  }

  Future<void> fetchDramaData() async {
    var requestBody = Uri.encodeFull("драма/10");
    final response = await http.get(Uri.parse('${dotenv.env['BACKEND_HTTP']}/films/top_films_by_genre/$requestBody'));
    if (response.statusCode == 200) {
      setState(() {
        final decodedResponse = utf8.decode(response.bodyBytes);
        dramaData = json.decode(decodedResponse);
      });
    } else {
      throw Exception('Не удалось получить данные о фильме');
    }
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'Топ 10 в жанре комедия:',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 300.0,
              child: ListView.separated(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                itemCount: movieData!.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 12);
                },
                itemBuilder: (context, index) {
                  final movie = movieData![index];
                  return movieCard(movie);
                },
              ),
            ),
            Text(
              'Топ 10 в жанре ужасы:',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 300.0,
              child: ListView.separated(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                itemCount: horrorData!.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 12);
                },
                itemBuilder: (context, index) {
                  final movie = horrorData![index];
                  return movieCard(movie);
                },
              ),
            ),
            Text(
              'Топ 10 в жанре драма:',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 300.0,
              child: ListView.separated(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                itemCount: dramaData!.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 12);
                },
                itemBuilder: (context, index) {
                  final movie = dramaData![index];
                  return movieCard(movie);
                },
              ),
            )
          ],
        ),
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
          ),
        ),
      ),
    );
  }

  Widget movieCard(movie) => GestureDetector(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            'https://www.kinopoisk.ru/images/film_big/${movie['kinopoisk_id']}.jpg',
            height: 200,
            width: 200,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movie['name'].toString(),
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2, // Максимальное количество строк
          overflow: TextOverflow.ellipsis, // Обрезание текста, если не помещается
        ),
      ],
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MoviePage(
            filmId: movie['kinopoisk_id'],
          ),
        ),
      );
    },
  );
}