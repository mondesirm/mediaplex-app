import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:either_dart/either.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mediaplex/utils/my_error.dart';

class ApiService {
  static final ApiService _apiService = ApiService._internal();

  factory ApiService() => _apiService;

  ApiService._internal();

  Uri getUri(String endpoint, {bool isDb = false}) => Uri.parse((isDb ? dotenv.env['DB_URL'] : dotenv.env['IPTV_URL'])! + endpoint);

  Future<Map<String, String>> getHeaders() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString('token').toString();
    return { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json' };
  }

  Future<Either<MyError, List<Map<String, dynamic>>>> getAll(String endpoint, {bool isDb = false}) async {
    Uri uri = getUri(endpoint, isDb: isDb);
    var response = await http.get(uri, headers: await getHeaders());

    if (response.statusCode == 200) return Right(List<Map<String, dynamic>>.from(jsonDecode(response.body.toString())));
    if (response.statusCode >= 500) return const Left(MyError(key: AppError.SERVER_ERROR));
    return Left(MyError(key: AppError.ERROR_DETECTED, message: jsonDecode(response.body)['detail']));
  }

  Future<Either<MyError, Map<String, dynamic>>> get(String endpoint, {bool isDb = false}) async {
    Uri uri = getUri(endpoint, isDb: isDb);
    var response = await http.get(uri, headers: await getHeaders());

    if (response.statusCode == 200) return Right(jsonDecode(response.body.toString()));
    if (response.statusCode >= 500) return const Left(MyError(key: AppError.SERVER_ERROR));
    return Left(MyError(key: AppError.ERROR_DETECTED, message: jsonDecode(response.body)['detail']));
  }
 Future<Either<MyError, List<dynamic>>> getList(String endpoint, {bool isDb = false}) async {
    Uri uri = getUri(endpoint, isDb: isDb);
    var response = await http.get(uri, headers: await getHeaders());

    if (response.statusCode == 200) return Right(jsonDecode(response.body.toString()));
    if (response.statusCode >= 500) return const Left(MyError(key: AppError.SERVER_ERROR));
    return Left(MyError(key: AppError.ERROR_DETECTED, message: jsonDecode(response.body)['detail']));
  }


  Future<Either<MyError, Map<String, dynamic>>> post(String endpoint, Map<String, dynamic> requestBody, {bool isDb = false}) async {
    Uri uri = getUri(endpoint, isDb: isDb);
    var response = await http.post(uri, body: jsonEncode(requestBody), headers: await getHeaders());

    if (response.statusCode == 200) return Right(jsonDecode(response.body));
    if (response.statusCode >= 500) return const Left(MyError(key: AppError.SERVER_ERROR));
    return Left(MyError(key: AppError.ERROR_DETECTED, message: jsonDecode(response.body)['detail']));
  }

  Future<Either<MyError, Map<String, dynamic>>> patch(String endpoint, Map<String, dynamic> requestBody, {bool isDb = false}) async {
    Uri uri = getUri(endpoint, isDb: isDb);
    var response = await http.patch(uri, body: jsonEncode(requestBody), headers: await getHeaders());

    if (response.statusCode == 200) return Right(jsonDecode(response.body));
    if (response.statusCode >= 500) return const Left(MyError(key: AppError.SERVER_ERROR));
    return Left(MyError(key: AppError.ERROR_DETECTED, message: jsonDecode(response.body)['detail']));
  }

  Future<Either<MyError, dynamic>> delete(String endpoint, {bool isDb = false}) async {
    Uri uri = getUri(endpoint, isDb: isDb);
    var response = await http.delete(uri, headers: await getHeaders());

    if (response.statusCode == 200) return Right(jsonDecode(response.body));
    if (response.statusCode >= 500) return const Left(MyError(key: AppError.SERVER_ERROR));
    return Left(MyError(key: AppError.ERROR_DETECTED, message: jsonDecode(response.body)['detail']));
  }
}