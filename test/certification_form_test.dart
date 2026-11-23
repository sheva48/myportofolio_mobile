import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';

Future<void> submit(WidgetTester tester) async {
  final button = find.widgetWithText(ElevatedButton, 'Simpan');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> fillForm(
  WidgetTester tester, {
  String name = 'Flutter Dasar',
  String issuer = 'Lembaga Pelatihan',
  String url = 'https://example.com/sertifikat/123',
}) async {
  for (final entry in [name, issuer, url].asMap().entries) {
    await tester.enterText(
      find.byType(TextFormField).at(entry.key),
      entry.value,
    );
  }
}

void main() {
  testWidgets('Menolak kolom kosong, spasi, panjang berlebih, dan URL salah', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CertificationFormPage()));
    for (final value in ['', '   ']) {
      await fillForm(tester, name: value, issuer: value, url: value);
      await submit(tester);
      for (final label in ['Nama sertifikasi', 'Penerbit', 'URL kredensial']) {
        expect(find.text('$label wajib diisi.'), findsOneWidget);
      }
      expect(find.byType(AlertDialog), findsNothing);
    }

    await fillForm(
      tester,
      name: 'a' * 101,
      issuer: 'b' * 101,
      url: 'https://example.com/${'a' * 2000}',
    );
    await submit(tester);
    expect(
      find.text('Nama sertifikasi maksimal 100 karakter.'),
      findsOneWidget,
    );
    expect(find.text('Penerbit maksimal 100 karakter.'), findsOneWidget);
    expect(find.text('URL kredensial maksimal 2000 karakter.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    for (final url in [
      'example.com',
      'https://',
      'ftp://example.com',
      'https://example.com/ada spasi',
    ]) {
      await fillForm(tester, url: url);
      await submit(tester);
      expect(
        find.text('Masukkan URL http:// atau https:// yang valid.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    }
  });

  testWidgets('Dialog menampilkan isian terbaru dan Tutup kembali ke form', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CertificationFormPage()));
    await fillForm(
      tester,
      name: ' Flutter Dasar ',
      issuer: ' Lembaga Pelatihan ',
    );
    await submit(tester);
    expect(find.text('Nama Sertifikasi: Flutter Dasar'), findsOneWidget);
    expect(find.text('Penerbit: Lembaga Pelatihan'), findsOneWidget);
    expect(
      find.text('URL Kredensial: https://example.com/sertifikat/123'),
      findsOneWidget,
    );
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text(' Flutter Dasar '), findsOneWidget);

    await fillForm(tester, name: 'Sertifikasi Baru');
    await submit(tester);
    expect(find.text('Nama Sertifikasi: Sertifikasi Baru'), findsOneWidget);
    expect(find.text('Nama Sertifikasi: Flutter Dasar'), findsNothing);
  });

  testWidgets('Simpan terjangkau pada layar sempit dengan keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MaterialApp(home: CertificationFormPage()));
    await fillForm(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    await submit(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
