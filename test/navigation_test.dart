import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

void main() {
  testWidgets('Kartu sertifikasi membuka form dan mendukung tombol kembali', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.text('Tambah Sertifikasi'));
    await tester.tap(find.text('Tambah Sertifikasi'));
    await tester.pumpAndSettle();
    expect(find.byType(CertificationFormPage), findsOneWidget);
    expect(
      Navigator.canPop(tester.element(find.byType(CertificationFormPage))),
      isTrue,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(CertificationFormPage), findsNothing);
  });

  testWidgets('Drawer membuka sertifikasi, Home, dan Add Project', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    for (final destination in ['Home', 'Add Project']) {
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Tambah Sertifikasi'));
      await tester.pumpAndSettle();
      expect(find.byType(CertificationFormPage), findsOneWidget);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, destination));
      await tester.pumpAndSettle();
      expect(find.byType(CertificationFormPage), findsNothing);
      expect(
        destination == 'Home'
            ? find.byType(MyHomePage)
            : find.byType(ProjectFormPage),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Drawer mengganti halaman tanpa menumpuk route', (tester) async {
    await tester.pumpWidget(const MyApp());

    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.text('My Portfolio'), findsOneWidget);
      expect(
        find.text('Explore personal projects and experiences!'),
        findsOneWidget,
      );

      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.byType(MyHomePage), findsNothing);
      expect(
        Navigator.canPop(tester.element(find.byType(ProjectFormPage))),
        isFalse,
      );
      expect(
        tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
        isFalse,
      );

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
      expect(
        Navigator.canPop(tester.element(find.byType(MyHomePage))),
        isFalse,
      );
      expect(
        tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
