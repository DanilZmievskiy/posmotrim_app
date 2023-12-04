import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MoviePage extends StatefulWidget {
  final int filmId;
  final Key? key;

  MoviePage({required this.filmId, this.key}) : super(key: key);

  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  late Map<String, dynamic>? movieData;
  List<dynamic>? recommendations;

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
