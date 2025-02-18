import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/classes/weather_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:weather_app/modules/home/components/input.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<WeatherData>? _weatherData;
  String inputValue = '';

  void _handleInputValueChange(String value) {
    setState(() {
      inputValue = value;
      _weatherData = _fetchWeather();
    });
  }

  @override
  initState() {
    super.initState();
    _weatherData = _fetchWeather();
  }

  Future<WeatherData> _fetchWeather() async {
    try {
      String apiKey = dotenv.env['WEATHER_API_KEY']!;
      Position position = await Geolocator.getCurrentPosition();
      String latLong =
          '${position.latitude.toString()},${position.longitude.toString()}';

      String filter = inputValue.isNotEmpty ? inputValue : latLong;

      final response = await http.get(
        Uri.parse(
          'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$filter&aqi=yes',
        ),
      );
      if (response.statusCode == 200) {
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
                  Input(
                    title: AppLocalizations.of(context)!.enterLocation,
                    value: inputValue,
                    onInputChange: _handleInputValueChange,
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
