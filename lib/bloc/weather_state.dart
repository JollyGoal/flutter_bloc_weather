part of 'weather_bloc.dart';

@immutable
abstract class WeatherState extends Equatable {
  @override
  List<Object> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherError extends WeatherState {
  final String _message;

  WeatherError(this._message);

  String get message => _message;
}

class WeatherLoaded extends WeatherState {
  final WeatherModel _weatherData;

  WeatherLoaded(this._weatherData);

  WeatherModel get weatherData => _weatherData;

  @override
  List<Object> get props => [_weatherData];
}
