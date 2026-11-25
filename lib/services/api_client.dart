import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) =>
      Uri.parse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}$path');

  Future<http.Response> _request(Future<http.Response> request) async {
    try {
      final response = await request.timeout(const Duration(seconds: 20));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(response.statusCode, response.body);
      }
      return response;
    } on TimeoutException {
      throw const ApiException(0, 'Server terlalu lama merespons.');
    } on http.ClientException {
      throw const ApiException(0, 'Tidak dapat terhubung ke server.');
    }
  }

  Future<List<Project>> getProjects() async {
    final response = await _request(
      _client.get(
        _uri('/api/v1/projects/'),
        headers: {'Accept': 'application/json'},
      ),
    );
    final items = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return items
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _request(
      _client.post(
        _uri('/api/v1/projects/'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(project.toJson()),
      ),
    );
    return Project.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _request(
      _client.post(
        _uri('/api/v1/auth/token/'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      ),
    );
    return (jsonDecode(response.body) as Map<String, dynamic>)['token']
        as String;
  }

  Future<void> logout({required String token}) async {
    await _request(
      _client.post(
        _uri('/api/v1/auth/logout/'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
      ),
    );
  }

  void close() => _client.close();
}

// Jangan tampilkan response mentah Django ke pengguna.
String apiErrorMessage(Object error) {
  if (error is ApiException) {
    return switch (error.statusCode) {
      0 => error.message,
      400 => 'Isian tidak diterima server. Periksa data atau kredensial kamu.',
      401 => 'Sesi berakhir. Silakan login kembali.',
      403 => 'Akun ini tidak memiliki izin untuk menambahkan proyek.',
      _ => 'Permintaan gagal (${error.statusCode}). Coba lagi nanti.',
    };
  }
  return 'Data dari server tidak dapat diproses. Coba lagi nanti.';
}
