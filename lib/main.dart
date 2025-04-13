import 'dart:convert';

import 'package:coincapapp/models/app_config.dart';
import 'package:coincapapp/pages/home_page.dart';
import 'package:coincapapp/services/http_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await loadConfig();
  registerHTTPService();
  //GetIt.instance.get<HttpService>().get("/coins/bitcoin");
  runApp(const MyApp());
}

Future<void> loadConfig() async{
  String _configContent = await rootBundle.loadString("assets/config/main.json");
  Map _configData = jsonDecode(_configContent);
  GetIt.instance.registerSingleton<AppConfig>(
    AppConfig(COIN_API_BASE_URL: _configData["COIN_API_BASE_URL"],)
  );
}

void registerHTTPService(){
  GetIt.instance.registerSingleton<HttpService>(
    HttpService(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoinCap',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color.fromRGBO(88, 60, 197, 1.0)
      ),
      home: HomePage(),
    );
  }
}
