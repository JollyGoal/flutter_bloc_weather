import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_weather/bloc/weather_bloc.dart';
import 'package:flutter_bloc_weather/repository/models/weather_model.dart';
import 'package:flutter_bloc_weather/repository/network/weather_repo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[900],
        body: BlocProvider<WeatherBloc>(
          create: (context) => WeatherBloc(WeatherApi()),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SearchPage(),
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cityController = TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            child: FlareActor(
              "assets/WorldSpin.flr",
              fit: BoxFit.contain,
              animation: "roll",
            ),
            height: 300,
            width: 300,
          ),
        ),
        BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, state) {
            if (state is WeatherError) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is WeatherInitial)
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      "Search Weather",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      "Instantly",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w200,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    TextFormField(
                      controller: cityController,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (value) {
                        if (value.length > 0) {
                          context
                              .bloc<WeatherBloc>()
                              .add(FetchWeatherEvent(value));
                          cityController.clear();
                        } else {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please write correct city name"),
                            ),
                          );
                        }
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white70,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.blue,
                            style: BorderStyle.solid,
                          ),
                        ),
                        hintText: "City Name",
                        hintStyle: const TextStyle(color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: () {
                          if (cityController.text.length > 0) {
                            context
                                .bloc<WeatherBloc>()
                                .add(FetchWeatherEvent(cityController.text));
                            cityController.clear();
                          } else {
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please write correct city name"),
                              ),
                            );
                          }
                        },
                        color: Colors.lightBlue,
                        child: Text(
                          "Search",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            else if (state is WeatherLoading)
              return buildLoading();
            else if (state is WeatherLoaded)
              return ShowWeather(
                weather: state.weatherData,
                cityName: cityController.text,
              );
            else
              return buildError(context);
          },
        )
      ],
    );
  }

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildError(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            "Error! Please try again",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 50,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: () {
                context.bloc<WeatherBloc>().add(ResetWeather());
              },
              color: Colors.lightBlue,
              child: Text(
                "<- Back to search",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowWeather extends StatelessWidget {
  final WeatherModel weather;
  final String cityName;

  const ShowWeather({
    @required this.weather,
    @required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 32, left: 32, top: 10),
      child: Column(
        children: [
          Text(
            cityName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            weather.getTemp.round().toString() + "C",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 50,
            ),
          ),
          Text(
            "Temperature",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    weather.getMinTemp.round().toString() + "C",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 30,
                    ),
                  ),
                  Text(
                    "Min Temperature",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    weather.getMaxTemp.round().toString() + "C",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 30,
                    ),
                  ),
                  Text(
                    "Max Temperature",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 50,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: () {
                context.bloc<WeatherBloc>().add(ResetWeather());
              },
              color: Colors.lightBlue,
              child: Text(
                "<- Back to search",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
