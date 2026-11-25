import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

ApiClient testApi() => ApiClient(
  client: MockClient((request) async {
    if (request.url.path.endsWith('auth/token/')) {
      return http.Response('{"token":"test-token"}', 200);
    }
    if (request.url.path.endsWith('auth/logout/')) {
      return http.Response('', 204);
    }
    if (request.method == 'GET') return http.Response('[]', 200);
    return http.Response(
      jsonEncode({
        'id': 1,
        ...jsonDecode(request.body) as Map<String, dynamic>,
      }),
      201,
    );
  }),
);

Widget testApp(Widget home, {bool loggedIn = false, ApiClient? api}) {
  final client = api ?? testApi();
  return MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: client),
      ChangeNotifierProvider(
        create: (_) =>
            AuthState(client, initialToken: loggedIn ? 'test-token' : null),
      ),
    ],
    child: MaterialApp(home: home),
  );
}
