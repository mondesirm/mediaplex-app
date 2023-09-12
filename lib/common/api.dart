import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:either_dart/either.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/utils/my_error.dart';

class ApiService {
  static final ApiService _apiService = ApiService._internal();

  factory ApiService() => _apiService;

  ApiService._internal();

  Uri getUri(String endpoint, {bool isDb = false}) => Uri.parse((isDb ? MyTheme.dbURL : MyTheme.iptvURl) + endpoint);

  Future<Map<String, String>> getHeaders() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString('session').toString();
    return { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json' };
  }

  Future<Either<MyError, Map<String, dynamic>>> getData(String endpoint, {bool isDb = false}) async {
    Uri uri = getUri(endpoint, isDb: isDb);
    var response = await http.get(uri);

    if (response.statusCode == 200) return Right(jsonDecode(response.body.toString()));
    if (response.statusCode >= 500) return const Left(MyError(key: AppError.SERVER_ERROR));
    return Left(MyError(key: AppError.ERROR_DETECTED, message: jsonDecode(response.body)['detail']));
  }

  Future<Either<MyError, Map<String, dynamic>>> postData(String endpoint, Map<String, dynamic> requestBody, {bool isDb = false}) async {
    Uri uri = getUri(endpoint, isDb: isDb);
    var response = await http.post(uri, body: jsonEncode(requestBody), headers: { 'Content-Type': 'application/json' });

    if (response.statusCode == 200) return Right(jsonDecode(response.body));
    if (response.statusCode >= 500) return const Left(MyError(key: AppError.SERVER_ERROR));
    return Left(MyError(key: AppError.ERROR_DETECTED, message: jsonDecode(response.body)['detail']));
  }

  Future<Either<MyError, Map<String, dynamic>>> postHeaderData(String endpoint, Map<String, dynamic> requestBody, {bool isDb = false}) async {
    Uri uri = getUri(endpoint, isDb: isDb);
    var response = await http.post(uri, body: jsonEncode(requestBody), headers: await getHeaders());

    if (response.statusCode == 200) return Right(jsonDecode(response.body));
    if (response.statusCode >= 500) return const Left(MyError(key: AppError.SERVER_ERROR));
    return Left(MyError(key: AppError.ERROR_DETECTED, message: jsonDecode(response.body)['detail']));
  }

  Future<Either<MyError, List<dynamic>>> getAllData(String endpoint, {bool isDb = false}) async {
    Uri uri = getUri(endpoint, isDb: isDb);
    var response = await http.get(uri, headers: await getHeaders());

    if (response.statusCode == 200) return Right(jsonDecode(response.body.toString()) as List<dynamic>);
    if (response.statusCode >= 500) return const Left(MyError(key: AppError.SERVER_ERROR));
    return Left(MyError(key: AppError.ERROR_DETECTED, message: jsonDecode(response.body)['detail']));
  }

  Future<Either<MyError, dynamic>> deleteData(String endpoint, Map<String, dynamic> requestBody, {bool isDb = false}) async {
    Uri uri = getUri(endpoint, isDb: isDb);
    var response = await http.delete(uri, body: jsonEncode(requestBody), headers: await getHeaders());

    if (response.statusCode == 200) return Right(jsonDecode(response.body));
    if (response.statusCode >= 500) return const Left(MyError(key: AppError.SERVER_ERROR));
    return Left(MyError(key: AppError.ERROR_DETECTED, message: jsonDecode(response.body)['detail']));
  }
}