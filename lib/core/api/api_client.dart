import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';
 
class ApiClient {
  final String baseUrl;
  final TokenStorage tokenStorage;
 
  ApiClient({required this.baseUrl, required this.tokenStorage});
 
  String _buildUrl(String endpoint) {
    final cleanBase =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return cleanBase + cleanEndpoint;
  }
 
  Future<Map<String, String>> _getHeaders({
    bool requiresAuth = false,
    Map<String, String>? customHeaders,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      ...?customHeaders,
    };
 
    if (requiresAuth) {
      final token = await tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }
    }
 
    return headers;
  }
 
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = true,
    Map<String, dynamic>? queryParams,
  }) async {
    Uri uri = Uri.parse(_buildUrl(endpoint));
 
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...queryParams.map((k, v) => MapEntry(k, v.toString())),
      });
    }
 
    final response = await http
        .get(uri, headers: await _getHeaders(requiresAuth: requiresAuth, customHeaders: headers))
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == HttpStatus.ok) {
      return jsonDecode(response.body);
    }

    throw Exception(_extractErrorMessage(response));
  }
 
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    final uri = Uri.parse(_buildUrl(endpoint));

    final response = await http
        .post(
          uri,
          headers: await _getHeaders(requiresAuth: requiresAuth, customHeaders: headers),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == HttpStatus.noContent) return {};
    if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.created) {
      if (response.body.isEmpty) return {};
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Se esperaba un objeto JSON en la respuesta.');
    }

    throw Exception(_extractErrorMessage(response));
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = body['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.join(', ');
    } catch (_) {}
    return 'Error ${response.statusCode}: ${response.reasonPhrase ?? "Error desconocido"}';
  }
 
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse(_buildUrl(endpoint));
 
    final response = await http
        .put(
          uri,
          headers: await _getHeaders(requiresAuth: requiresAuth, customHeaders: headers),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.noContent) {
      if (response.body.isEmpty) return true;
      return jsonDecode(response.body);
    }

    throw Exception(_extractErrorMessage(response));
  }
 
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse(_buildUrl(endpoint));
 
    final response = await http
        .patch(
          uri,
          headers: await _getHeaders(requiresAuth: requiresAuth, customHeaders: headers),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.noContent) {
      if (response.body.isEmpty) return true;
      return jsonDecode(response.body);
    }

    throw Exception(_extractErrorMessage(response));
  }
 
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse(_buildUrl(endpoint));
 
    final response = await http
        .delete(
          uri,
          headers: await _getHeaders(requiresAuth: requiresAuth, customHeaders: headers),
        )
        .timeout(const Duration(seconds: 30));
 
    if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.noContent) {
      if (response.body.isEmpty) return true;
      return jsonDecode(response.body);
    }
 
    throw HttpException('Error ${response.statusCode}: ${response.reasonPhrase}');
  }
}