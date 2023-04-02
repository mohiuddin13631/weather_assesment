import 'dart:convert';

import 'package:assesment/http/custom_http.dart';
import 'package:assesment/model/current_model.dart';
import 'package:assesment/model/forecast_model.dart';
import 'package:assesment/model/week_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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

    position = await Geolocator.getCurrentPosition();
    loadData();
    loadForecastData();
    return await Geolocator.getCurrentPosition();
  }

  Position? position;
  CurrentWeatherModel? currentWeatherModel;

  Future<CurrentWeatherModel> loadData()async{
    String url = "https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=bf881cd668c8bd1799a36d79a42c897b&units=metric";

    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    print(data);
    setState(() {
      currentWeatherModel = CurrentWeatherModel.fromJson(data);
    });
    return currentWeatherModel!;
  }

  WeeklyForecast? weeklyForecast;
  List<WeeklyForecast> weeklyData = [];
  WeekModel? weekModel;
  loadForecastData() async {
    String url = "http://api.weatherapi.com/v1/forecast.json?key= 4a536faf63724b8a86a50958232603 &q=Dhaka&days=7&aqi=no&alerts=no";
    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    setState(() {
      weekModel = WeekModel.fromJson(data);
    });
    // for(var i in data){
    //   WeeklyForecast weeklyForecast = WeeklyForecast(
    //     date: i['forecast']['forecastday']
    //   );
    // }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _determinePosition();
    // loadData();
  }
  @override
  Widget build(BuildContext context) {
    return currentWeatherModel != null && weekModel != null? Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            height: 400,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20)
            ),
            child: Column(
              children: [
                SizedBox(height: 20,),
                Text(currentWeatherModel!.name.toString(),style: TextStyle(fontSize: 30),),
                SizedBox(height: 11,),
                Text("${Jiffy(DateTime.now()).format('MMMM do yy, h:mm a') }"),
                SizedBox(height: 20,),
                Image.network("https://openweathermap.org/img/wn/${currentWeatherModel!.weather![0].icon}@2x.png"),
                Text(currentWeatherModel!.weather![0].main.toString(),style: TextStyle(fontSize: 20),),
                SizedBox(height: 10,),
                Text("${currentWeatherModel!.main!.temp?.toInt()} °C",style: TextStyle(fontSize: 25),),
                Text("Feels like: ${currentWeatherModel!.main!.feelsLike.toString()}"),
                Text("Humidity: ${currentWeatherModel!.main!.humidity.toString()}")
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            height: 200,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: weekModel!.forecast!.forecastday!.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 10),
                  height: 30,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(21)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("${Jiffy(weekModel!.forecast!.forecastday![index].date).format('EEE, h:mm') }"),
                      Image.network(weekModel!.forecast!.forecastday![index].day!.condition!.icon.toString()),
                      Align(
                          child: Text(weekModel!.forecast!.forecastday![index].day!.condition!.text.toString(),textAlign: TextAlign.center,))
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 40,)
        ],
      ),
    ):Center(child: CircularProgressIndicator());
  }
}
