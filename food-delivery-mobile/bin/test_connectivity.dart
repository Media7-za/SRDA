import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3001',
    connectTimeout: const Duration(seconds: 5),
    headers: {'Content-Type': 'application/json'},
  ));

  print('🚀 Testing Driver Login Connectivity...');
  print('Target: http://localhost:3001/api/auth/driver/login');

  try {
    print('\n[Test 1] Attempting login with driver1@example.com / password...');
    final response = await dio.post('/api/auth/driver/login', data: {
      'email': 'driver1@example.com',
      'password': 'password',
    });

    if (response.statusCode == 200) {
      print('✅ Success! Status: ${response.statusCode}');
      print('Response Data: ${response.data}');
    } else {
      print('❌ Failed with status: ${response.statusCode}');
      print('Response: ${response.data}');
    }
  } on DioException catch (e) {
    print('❌ Network Error: ${e.message}');
    if (e.response != null) {
      print('Response Status: ${e.response?.statusCode}');
      print('Response Body: ${e.response?.data}');
    }
  }

  try {
    print('\n[Test 2] Attempting login with WRONG password...');
    final response = await dio.post('/api/auth/driver/login', data: {
      'email': 'driver1@example.com',
      'password': 'wrong_password',
    });
    print('❌ Warning: Should have failed but got status ${response.statusCode}');
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      print('✅ Correctly rejected with 401: ${e.response?.data}');
    } else {
      print('❌ Unexpected error: ${e.message}');
    }
  }

  print('\n🏁 Connectivity Test Complete.');
}
