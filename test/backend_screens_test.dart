import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'test_helpers.dart';

Future<void> login(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'owner');
  await tester.enterText(find.byType(TextFormField).at(1), 'password');
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

void main() {
  for (final source in ['kartu', 'drawer']) {
    testWidgets('Tamu harus login dari $source sebelum membuka form proyek', (
      tester,
    ) async {
      await tester.pumpWidget(MyApp(apiClient: testApi()));
      if (source == 'kartu') {
        await tester.tap(find.text('Tambah Proyek'));
      } else {
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add Project'));
      }
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
      await login(tester);
      expect(find.byType(ProjectFormPage), findsOneWidget);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Logout'), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, 'Logout'));
      await tester.pumpAndSettle();
      expect(find.text('Berhasil logout.'), findsOneWidget);
    });
  }

  testWidgets('Membatalkan login tidak membuka form proyek', (tester) async {
    await tester.pumpWidget(MyApp(apiClient: testApi()));
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
  });

  testWidgets('Login menolak input kosong dan kredensial salah', (
    tester,
  ) async {
    final api = ApiClient(
      client: MockClient((_) async => http.Response('private detail', 400)),
    );
    await tester.pumpWidget(testApp(const LoginScreen(), api: api));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Username wajib diisi.'), findsOneWidget);
    expect(find.text('Password wajib diisi.'), findsOneWidget);
    await login(tester);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('private detail'), findsNothing);
  });

  testWidgets('Daftar publik menampilkan loading, data, detail, dan refresh', (
    tester,
  ) async {
    final response = Completer<http.Response>();
    var requests = 0;
    final api = ApiClient(
      client: MockClient((_) {
        requests++;
        return response.future;
      }),
    );
    await tester.pumpWidget(testApp(const ProjectListScreen(), api: api));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    response.complete(
      http.Response(
        jsonEncode([
          {
            'id': 1,
            'title': 'Portofolio',
            'description': 'Aplikasi saya',
            'tech_stack': 'Django',
            'project_url': 'https://example.com',
            'project_image_url': '',
          },
        ]),
        200,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Portofolio'), findsOneWidget);
    expect(requests, 1);
    await tester.tap(find.text('Portofolio'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(find.text('Teknologi: Django'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(requests, 2);
  });

  testWidgets(
    'Daftar gagal dapat dicoba ulang dan hasil kosong bisa di-refresh',
    (tester) async {
      var requests = 0;
      final api = ApiClient(
        client: MockClient((_) async {
          requests++;
          return requests == 1
              ? http.Response('private error', 500)
              : http.Response('[]', 200);
        }),
      );
      await tester.pumpWidget(testApp(const ProjectListScreen(), api: api));
      await tester.pumpAndSettle();
      expect(find.text('Coba lagi'), findsOneWidget);
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada proyek.'), findsOneWidget);
      await tester.fling(
        find.byType(SingleChildScrollView).first,
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();
      expect(requests, 3);
    },
  );
}
