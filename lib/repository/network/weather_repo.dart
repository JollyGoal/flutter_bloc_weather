import 'package:flutter_bloc_weather/repository/models/weather_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather?q=';
const String appKey = '43ea6baaad7663dc17637e22ee6f78f2';

abstract class WeatherRepo {
  /// Throws [WeatherRepoException].
  Future<WeatherModel> getWeather(String cityName);
}

class WeatherApi implements WeatherRepo {
  @override
  Future<WeatherModel> getWeather(String cityName) async {
    final String link = '$baseUrl$cityName&APPID=$appKey';

    final result = await http.get(link);

    if (result.statusCode != 200) {
      if (result.statusCode == 404) {
        throw WeatherRepoException(
            msg: 'City called $cityName does not exist in database');
      }
      throw WeatherRepoException(msg: 'Error calling API for city $cityName');
    }

    try {
      final WeatherModel resModel =
          WeatherModel.fromJson(jsonDecode(result.body)['main']);
      return resModel;
    } catch (e) {
      throw WeatherRepoException(
          msg: 'Failed to convert json data into WeatherModel');
    }
  }
}

class WeatherRepoException implements Exception {
  final String msg;

  const WeatherRepoException({this.msg});

  @override
  String toString() => (msg == null)
      ? "Weather Repository Exception"
      : "Weather Repository Exception: $msg";
}
