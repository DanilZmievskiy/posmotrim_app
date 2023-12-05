import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MoviePage extends StatefulWidget {
  final int filmId;
  final Key? key;

  MoviePage({required this.filmId, this.key}) : super(key: key);

  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {

  late SharedPreferences sharedPreferences;

  Map<String, dynamic>? movieData;
  List<dynamic>? recommendations;
  Map<String, dynamic>? currentUser;
  Map<String, dynamic>? currentStatus;

  var dropdownValue;

  @override
  void initState() {
    super.initState();
    fetchMovieData();
  }

  Future<void> fetchMovieData() async {
    final response = await http.get(Uri.parse('${dotenv.env['BACKEND_HTTP']}/films/${widget.filmId}'));
    if (response.statusCode == 200) {
      setState(() {
        final decodedResponse = utf8.decode(response.bodyBytes);
        movieData = json.decode(decodedResponse);
      });
      fetchRecommendations();
      fetchCurrentUser();
    } else {
      throw Exception('Не удалось получить данные о фильме');
    }
  }

  Future<void> fetchRecommendations() async {
    final response = await http.get(Uri.parse('${dotenv.env['BACKEND_HTTP']}/films/${widget.filmId}/recommendations'));
    if (response.statusCode == 200) {
      setState(() {
        final decodedResponse = utf8.decode(response.bodyBytes);
        recommendations = json.decode(decodedResponse);
      });
    } else {
      throw Exception('Не удалось получить рекомендации');
    }
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
      fetchCurrentStatus();
    } else {
      throw Exception('Не удалось получить данные о пользователе');
    }
  }

  Future<void> fetchCurrentStatus() async {
    String? token = sharedPreferences.getString('token');
    final response = await http.get(
        Uri.parse('${dotenv.env['BACKEND_HTTP']}/statuses/${currentUser!['id']}/${movieData!['kinopoisk_id']}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
    );
    if (response.statusCode == 200) {
      setState(() {
        final decodedResponse = utf8.decode(response.bodyBytes);
        currentStatus = json.decode(decodedResponse);
        dropdownValue = currentStatus!['status'];
      });
    } else if(response.statusCode == 404) {
      setState(() {
        currentStatus = null;
      });
    } else {
      throw Exception('Не удалось получить рекомендации');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: Color(0xFF131313),
      body: movieData != null
          ? SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 457,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://www.kinopoisk.ru/images/film_big/${movieData!['kinopoisk_id']}.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    movieData!['name'].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${movieData!['genres'].join(', ')}',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 16.94 / 14,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${movieData!['description']}',
                    style: TextStyle(
                      color: Color(0xFF706E6E),
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 21.78 / 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RoundedInfoBox(
                        value: '${movieData!['rating_imdb']}',
                      ),
                      RoundedInfoBox(
                        value: '${movieData!['film_length']} мин',
                      ),
                      RoundedInfoBox(
                        value: '${movieData!['year']}',
                      ),
                      DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.bookmark_border),
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: Colors.black,
                        underline: Container(
                          height: 2,
                          color: Colors.white,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                          updateStatus(newValue!);
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'Смотрю',
                            child: Text("Смотрю"),
                          ),
                          DropdownMenuItem(
                            value: 'Посмотрел',
                            child: Text("Посмотрел"),
                          ),
                          DropdownMenuItem(
                            value: 'Буду смотреть',
                            child: Text("Буду смотреть"),
                          ),
                          DropdownMenuItem(
                            value: 'Бросил',
                            child: Text("Бросил"),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Рекомендации:',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  if (recommendations != null)
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recommendations!.length,
                        itemBuilder: (context, index) {
                          final recommendation = recommendations![index];
                          final recommendationFilmId = recommendation['kinopoisk_id'];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MoviePage(
                                    filmId: recommendationFilmId,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 150,
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    'https://www.kinopoisk.ru/images/film_big/${recommendation['kinopoisk_id']}.jpg',
                                  height: 150,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  recommendation['name'].toString().toUpperCase(),
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
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  updateStatus (String new_status) async {
    Map data = {
      "user_id": currentUser!['id'],
      "film_id": movieData!['kinopoisk_id'],
      "status": new_status
    };

    String? token = sharedPreferences.getString('token');
    var body = json.encode(data);
    //print(body);
    final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_HTTP']}//statuses/update/{user_id}/{film_id}/{status}/{rating}'),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Bearer $token"
        },
      body: body
    );
    if(response.statusCode != 200) {
      print(response.body);
    }

  }
}

class RoundedInfoBox extends StatelessWidget {
  final String value;

  const RoundedInfoBox({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        value,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
