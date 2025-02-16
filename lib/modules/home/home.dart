import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/classes/weather_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<WeatherData>? _weatherData;

  @override
  initState() {
    super.initState();
    _weatherData = _fetchWeather();
  }

  Future<WeatherData> _fetchWeather() async {
    try {
      String apiKey = dotenv.env['WEATHER_API_KEY']!;
      Position position = await Geolocator.getCurrentPosition();
      print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");

      String latLong =
          position.latitude.toString() + ',' + position.longitude.toString();

      final response = await http.get(
        Uri.parse(
          'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$latLong&aqi=yes',
        ),
      );
      if (response.statusCode == 200) {
        print(response.body);
        return WeatherData.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to fetch weather data');
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Failed to fetch weather data: $e');
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.title),
      ),
      body: Center(
        child: FutureBuilder<WeatherData>(
          future: _weatherData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final weather = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter a location',
                      ),
                    ),
                  ),
                  Text(
                    'Location: ${weather.location.name} ${weather.location.region} (${weather.location.country})',
                  ),
                  Text('Temperature: ${weather.current.tempC}°C'),
                  Text(' ${weather.current.condition.text}'),
                  Image.network('http:${weather.current.condition.icon}'),
                ],
              );
            } else {
              return Text('No data available');
            }
          },
        ),
      ),
    );
  }
}
