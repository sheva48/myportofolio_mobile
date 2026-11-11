import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('Menu Burhan menampilkan identitas dan pesan setiap tombol', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(432, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());

    for (final label in [
      'MyPortfolio',
      '2406000001',
      'Burhan',
      'PBP A',
      'Selamat datang di MyPortfolio Mobile!',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    for (final action in ['Lihat Proyek', 'Tambah Proyek', 'Logout']) {
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
      expect(find.text('Kamu telah menekan tombol $action!'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1440, 600),
  ]) {
    testWidgets('Menu tetap dapat digunakan pada layar $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Logout'));
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
