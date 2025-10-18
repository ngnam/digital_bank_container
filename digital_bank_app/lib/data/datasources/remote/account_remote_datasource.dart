import 'package:dio/dio.dart';
import '../../models/account_model.dart';

class AccountRemoteDataSource {
  final Dio dio;
  AccountRemoteDataSource({Dio? dio}) : dio = dio ?? Dio();

  Future<AccountModel> fetchAccount(String id) async {
    // Placeholder: replace URL with actual endpoint
    final response = await dio.get('https://api.example.com/accounts/$id');
    return AccountModel.fromJson(response.data as Map<String, dynamic>);
  }
}
