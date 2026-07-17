import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:3000/api/user";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:3000/api/user";
    } else {
      return "http://localhost:3000/api/user";
    }
  }

  Future<Map<String, dynamic>?> fetchPatientData(String hn) async {
    final url = Uri.parse('$baseUrl/search/$hn');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.isNotEmpty ? data[0] as Map<String, dynamic> : null;
      }
      return null;
    } catch (e) {
      print("Error fetching patient: $e");
      return null;
    }
  }

  Future<List<dynamic>> searchPatientsByName(String firstName, String lastName) async {
    final Map<String, String> queryParams = {};
    if (firstName.isNotEmpty) queryParams['fname'] = firstName;
    if (lastName.isNotEmpty) queryParams['lname'] = lastName;

    final url = Uri.parse('$baseUrl/searchname').replace(queryParameters: queryParams);
    
    print("Calling API: $url"); // เพื่อตรวจสอบ URL ใน Console

    try {
      final response = await http.get(url);
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Error searching by name: $e");
      return [];
    }
  }

  Future<List<dynamic>> fetchPatientHistory(String hn) async {
    final url = Uri.parse('$baseUrl/history/$hn');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Error fetching history: $e");
      return [];
    }
  }
}
