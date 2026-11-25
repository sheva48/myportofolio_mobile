import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('Menu menampilkan identitas dan warna kartu', (tester) async {
    await tester.pumpWidget(MyApp(apiClient: testApi()));
    for (final label in [
      'MyPortfolio',
      '2506622033',
      'Sheva Aquila Mahardika',
      'PBP A',
      'Selamat datang di MyPortfolio Mobile!',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    final colors = {
      'Lihat Proyek': Colors.blue.shade700,
      'Tambah Proyek': Colors.green.shade700,
      'Tambah Sertifikasi': Colors.purple.shade700,
      'Logout': Colors.red.shade700,
    };
    for (final entry in colors.entries) {
      expect(
        tester
            .widget<Material>(
              find.descendant(
                of: find.widgetWithText(ItemCard, entry.key),
                matching: find.byType(Material),
              ),
            )
            .color,
        entry.value,
      );
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
      await tester.pumpWidget(MyApp(apiClient: testApi()));
      await tester.ensureVisible(find.text('Logout'));
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(find.text('Kamu belum login.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
