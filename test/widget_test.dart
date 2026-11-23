import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

void main() {
  testWidgets(
    'Menu Sheva menampilkan identitas, warna, dan pesan setiap tombol',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(432, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MyApp());

      for (final label in [
        'MyPortfolio',
        '2506622033',
        'Sheva Aquila Mahardika',
        'PBP A',
        'Selamat datang di MyPortfolio Mobile!',
      ]) {
        expect(find.text(label), findsOneWidget);
      }

      final actionColors = {
        'Lihat Proyek': Colors.blue.shade700,
        'Tambah Proyek': Colors.green.shade700,
        'Tambah Sertifikasi': Colors.purple.shade700,
        'Logout': Colors.red.shade700,
      };

      for (final entry in actionColors.entries) {
        final action = entry.key;
        final cardMaterial = tester.widget<Material>(
          find.descendant(
            of: find.widgetWithText(ItemCard, action),
            matching: find.byType(Material),
          ),
        );
        expect(cardMaterial.color, entry.value);
        await tester.tap(find.text(action));
        await tester.pumpAndSettle();
        expect(find.text('Kamu telah menekan tombol $action!'), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (action == 'Tambah Proyek') {
          expect(find.byType(ProjectFormPage), findsOneWidget);
          final context = tester.element(find.byType(ProjectFormPage));
          expect(Navigator.canPop(context), isTrue);
          Navigator.pop(context);
          await tester.pumpAndSettle();
          expect(find.text('Sheva Aquila Mahardika'), findsOneWidget);
        } else if (action == 'Tambah Sertifikasi') {
          expect(find.byType(CertificationFormPage), findsOneWidget);
          Navigator.pop(tester.element(find.byType(CertificationFormPage)));
          await tester.pumpAndSettle();
        }
      }
    },
  );

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
