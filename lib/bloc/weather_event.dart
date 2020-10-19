part of 'weather_bloc.dart';

@immutable
abstract class WeatherEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchWeatherEvent extends WeatherEvent {
  final String _cityName;

  FetchWeatherEvent(this._cityName);

  @override
  List<Object> get props => [_cityName];
}

class ResetWeather extends WeatherEvent {}
