import 'package:dio/dio.dart';
import '../models/app_config.dart';
import 'package:get_it/get_it.dart';

class HttpService {
  final Dio dio = Dio();

  AppConfig? _appConfig;
  String? _base_url;

    Map<String, String> get headers => {
        'Accept': 'application/json',
        'x-cg-demo-api-key': 'CG-EfsoKSHjDca6hKojSbJi4uht'
      };

  HttpService(){
    _appConfig = GetIt.instance.get<AppConfig>();
    _base_url = _appConfig!.COIN_API_BASE_URL;
  }

  Future<Response?> get(String _path) async{
    try {
      String _url = "$_base_url$_path";
      Response _response = await dio.get(_url,options: Options(headers: headers)); 
      //print(_response);
      return _response;
    } catch (e){
      print("HTTPService unabel to perform get request");
      print(e);
    }
  }
}