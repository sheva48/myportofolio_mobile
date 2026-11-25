import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'test_helpers.dart';

Future<void> submitForm(WidgetTester tester) async {
  final saveButton = find.widgetWithText(ElevatedButton, 'Simpan');
  await tester.pumpAndSettle();
  await tester.ensureVisible(saveButton);
  await tester.pumpAndSettle();
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}

Future<void> fillProject(WidgetTester tester) async {
  for (final entry in [
    'MyPortfolio',
    'Portofolio Sheva',
    'Flutter, Django',
    'https://example.com/portfolio',
    '',
  ].asMap().entries) {
    await tester.enterText(
      find.byType(TextFormField).at(entry.key),
      entry.value,
    );
  }
}

void main() {
  testWidgets('Menolak isian wajib kosong, spasi, serta URL salah', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(const ProjectFormPage(), loggedIn: true));
    for (final value in ['', '   ']) {
      for (var i = 0; i < 5; i++) {
        await tester.enterText(find.byType(TextFormField).at(i), value);
      }
      await submitForm(tester);
      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Teknologi tidak boleh kosong!'), findsOneWidget);
      expect(find.text('URL proyek wajib diisi.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    }
    await fillProject(tester);
    await tester.enterText(find.byType(TextFormField).at(3), 'example.com');
    await submitForm(tester);
    expect(
      find.text('Gunakan URL HTTP/HTTPS yang valid, maksimal 200 karakter.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'POST memakai token dan dialog baru tampil setelah server berhasil',
    (tester) async {
      http.Request? submitted;
      final api = ApiClient(
        client: MockClient((request) async {
          submitted = request;
          return http.Response(
            jsonEncode({
              'id': 7,
              ...jsonDecode(request.body) as Map<String, dynamic>,
            }),
            201,
          );
        }),
      );
      await tester.pumpWidget(
        testApp(const ProjectFormPage(), loggedIn: true, api: api),
      );
      await fillProject(tester);
      await submitForm(tester);
      expect(submitted!.headers['Authorization'], 'Token test-token');
      expect(jsonDecode(submitted!.body), {
        'title': 'MyPortfolio',
        'description': 'Portofolio Sheva',
        'tech_stack': 'Flutter, Django',
        'project_url': 'https://example.com/portfolio',
        'project_image_url': '',
      });
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Nama Proyek: MyPortfolio'), findsOneWidget);
      expect(find.text('Teknologi: Flutter, Django'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      for (final field in tester.widgetList<EditableText>(
        find.byType(EditableText),
      )) {
        expect(field.controller.text, isEmpty);
      }
    },
  );

  for (final status in [400, 401, 403, 500]) {
    testWidgets('POST $status tidak menampilkan dialog berhasil', (
      tester,
    ) async {
      final api = ApiClient(
        client: MockClient(
          (_) async => http.Response('private server detail', status),
        ),
      );
      await tester.pumpWidget(
        testApp(const ProjectFormPage(), loggedIn: true, api: api),
      );
      await fillProject(tester);
      await submitForm(tester);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.textContaining('private server detail'), findsNothing);
      if (status == 401) {
        expect(find.text('Username'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
      } else {
        expect(find.byType(SnackBar), findsOneWidget);
      }
    });
  }

  testWidgets('Tombol Simpan terjangkau pada layar ponsel dengan keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(testApp(const ProjectFormPage(), loggedIn: true));
    await fillProject(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    await submitForm(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
