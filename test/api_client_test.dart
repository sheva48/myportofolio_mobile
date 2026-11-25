import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

void main() {
  test('Model menerima ID integer, URL null, dan tidak mengirim ID', () {
    final project = Project.fromJson({
      'id': 12,
      'title': 'Portofolio',
      'description': 'Django',
      'tech_stack': 'Dart',
      'project_url': null,
      'project_image_url': null,
    });
    expect(project.id, 12);
    expect(project.projectImageUrl, '');
    expect(project.projectUrl, '');
    expect(project.toJson().containsKey('id'), isFalse);
    expect(project.toJson()['tech_stack'], 'Dart');
  });

  test('GET proyek publik dan POST memakai payload serta token', () async {
    final requests = <http.Request>[];
    final api = ApiClient(
      baseUrl: 'https://example.com/',
      client: MockClient((request) async {
        requests.add(request);
        final data = {
          'id': 3,
          'title': 'Portofolio',
          'description': 'Django',
          'tech_stack': 'Flutter',
          'project_url': 'https://example.com',
          'project_image_url': '',
        };
        return http.Response(
          jsonEncode(request.method == 'GET' ? [data] : data),
          request.method == 'GET' ? 200 : 201,
        );
      }),
    );
    final projects = await api.getProjects();
    expect(projects.single.id, 3);
    expect(
      requests.first.url.toString(),
      'https://example.com/api/v1/projects/',
    );
    expect(requests.first.headers.containsKey('Authorization'), isFalse);
    await api.createProject(projects.single, token: 'secret-test');
    expect(requests.last.headers['Authorization'], 'Token secret-test');
    expect(jsonDecode(requests.last.body), projects.single.toJson());
  });

  test('Login menyimpan token dan logout mencabutnya', () async {
    final requests = <http.Request>[];
    final auth = AuthState(
      ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          return request.url.path.endsWith('token/')
              ? http.Response('{"token":"test-key"}', 200)
              : http.Response('', 204);
        }),
      ),
    );
    var notifications = 0;
    auth.addListener(() => notifications++);
    await auth.login('owner', 'password');
    expect(auth.token, 'test-key');
    expect(jsonDecode(requests.first.body), {
      'username': 'owner',
      'password': 'password',
    });
    await auth.logout();
    expect(requests.last.headers['Authorization'], 'Token test-key');
    expect(auth.isLoggedIn, isFalse);
    expect(notifications, 2);
  });

  test('Logout tetap menghapus sesi lokal ketika server gagal', () async {
    final auth = AuthState(
      ApiClient(
        client: MockClient((_) async => http.Response('private error', 500)),
      ),
      initialToken: 'test-key',
    );
    await expectLater(auth.logout(), throwsA(isA<ApiException>()));
    expect(auth.token, isNull);
  });

  test('Kegagalan koneksi dipetakan ke pesan yang aman', () async {
    final api = ApiClient(
      client: MockClient(
        (_) async => throw http.ClientException('internal URL'),
      ),
    );
    await expectLater(
      api.getProjects(),
      throwsA(
        isA<ApiException>().having((error) => error.statusCode, 'status', 0),
      ),
    );
    expect(
      apiErrorMessage(const ApiException(500, 'private error')),
      isNot(contains('private error')),
    );
  });
}
