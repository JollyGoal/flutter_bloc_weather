import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_weather/repository/models/weather_model.dart';
import 'package:flutter_bloc_weather/repository/network/weather_repo.dart';
import 'package:meta/meta.dart';

part 'weather_event.dart';

part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherRepo _weatherRepo;

  WeatherBloc(this._weatherRepo) : super(WeatherInitial());

  @override
  Stream<WeatherState> mapEventToState(
    WeatherEvent event,
  ) async* {
    if (event is FetchWeatherEvent) {
      yield WeatherLoading();

      try {
        WeatherModel weatherModel =
            await _weatherRepo.getWeather(event._cityName);
        yield WeatherLoaded(weatherModel);
      } on WeatherRepoException catch (e) {
        yield WeatherError(e.msg);
      } catch (e) {
        yield WeatherError('Something went wrong in network logic.');
      }
    } else if (event is ResetWeather) yield WeatherInitial();
  }
}
