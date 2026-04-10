import 'package:dio/dio.dart';

class MockAuthService {
  static Future<Response> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock response - accept any non-empty credentials
    return Response(
      data: {
        'access_token': 'mock_token_123456',
        'role': 'pemerintah',
        'user': {
          'id': 1,
          'username': username,
          'email': '$username@mock.test',
          'name': 'Mock User',
        }
      },
      statusCode: 200,
      requestOptions: RequestOptions(path: '/api/login'),
    );
  }

  static Future<Response> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Response(
      data: {'message': 'Logout successful'},
      statusCode: 200,
      requestOptions: RequestOptions(path: '/api/logout'),
    );
  }

  static Future<Response> register(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return Response(
      data: {
        'access_token': 'mock_token_123456',
        'user': {
          'id': 1,
          'username': data['username'],
          'email': data['email'],
          'name': data['name'],
        }
      },
      statusCode: 201,
      requestOptions: RequestOptions(path: '/api/register'),
    );
  }

  static Future<Response> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Response(
      data: {
        'user': {
          'id': 1,
          'username': 'mockuser',
          'email': 'mockuser@test.com',
          'name': 'Mock User',
          'role': 'pemerintah',
        }
      },
      statusCode: 200,
      requestOptions: RequestOptions(path: '/api/profile'),
    );
  }
}
