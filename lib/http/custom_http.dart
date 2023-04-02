import 'dart:convert';

import 'package:geolocator/geolocator.dart';

import '../model/current_model.dart';
import 'package:http/http.dart' as http;

class CustomHttpRequest{
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    position  = await Geolocator.getCurrentPosition();
    print(position!.latitude);
    loadData();

    return await Geolocator.getCurrentPosition();
  }
  static Position? position;
  static CurrentWeatherModel? currentWeatherModel;

  static Future<CurrentWeatherModel> loadData()async{
    String url = "https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=bf881cd668c8bd1799a36d79a42c897b&units=metric";

    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    print(data);
    currentWeatherModel = CurrentWeatherModel.fromJson(data);
    // print("custom print");
    // print(currentWeatherModel!.sys!.country);
    return currentWeatherModel!;
  }
}