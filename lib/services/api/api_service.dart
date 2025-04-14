import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client client = http.Client();

  // Headers comunes
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // GET request
  Future<dynamic> get(String endpoint) async {
    final response = await client.get(
      Uri.parse(endpoint),
      headers: _headers,
    );
    
    return _processResponse(response);
  }

  // POST request
  Future<dynamic> post(String endpoint, dynamic data) async {
    final response = await client.post(
      Uri.parse(endpoint),
      headers: _headers,
      body: json.encode(data),
    );
    
    return _processResponse(response);
  }

  // PUT request
  Future<dynamic> put(String endpoint, dynamic data) async {
    final response = await client.put(
      Uri.parse(endpoint),
      headers: _headers,
      body: json.encode(data),
    );
    
    return _processResponse(response);
  }

  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    final response = await client.delete(
      Uri.parse(endpoint),
      headers: _headers,
    );
    
    return _processResponse(response);
  }

  // Procesar respuesta
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}