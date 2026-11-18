import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

Future<void> submitForm(WidgetTester tester) async {
  final saveButton = find.widgetWithText(ElevatedButton, 'Save');
  await tester.ensureVisible(saveButton);
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Form menolak nama dan deskripsi kosong atau hanya spasi', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));

    for (final input in ['', '   ']) {
      await tester.enterText(find.byType(TextFormField).at(0), input);
      await tester.enterText(find.byType(TextFormField).at(1), input);
      await submitForm(tester);

      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    }

    await tester.enterText(find.byType(TextFormField).at(0), 'MyPortfolio');
    await submitForm(tester);
    expect(find.text('Nama proyek tidak boleh kosong!'), findsNothing);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
  });

  testWidgets('Dialog menampilkan seluruh input dan OK mereset semua field', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));
    await tester.enterText(find.byType(TextFormField).at(0), 'MyPortfolio');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Portofolio Sheva',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'Flutter, Django');
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'https://example.com/portfolio',
    );
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    for (final category in [
      'Web Development',
      'Mobile Development',
      'Machine Learning',
      'Data Science',
      'Other',
    ]) {
      expect(find.text(category), findsWidgets);
    }
    await tester.tap(find.text('Mobile Development').last);
    await tester.pumpAndSettle();
    await submitForm(tester);

    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    for (final text in [
      'Nama Proyek: MyPortfolio',
      'Deskripsi: Portofolio Sheva',
      'Kategori: Mobile Development',
      'Teknologi: Flutter, Django',
      'Tautan: https://example.com/portfolio',
    ]) {
      expect(find.text(text), findsOneWidget);
    }

    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    for (final field in tester.widgetList<EditableText>(
      find.byType(EditableText),
    )) {
      expect(field.controller.text, isEmpty);
    }
    expect(
      tester
          .state<FormFieldState<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .value,
      'Web Development',
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Proyek Kedua');
    await tester.enterText(find.byType(TextFormField).at(1), 'Deskripsi baru');
    await submitForm(tester);
    expect(find.text('Nama Proyek: Proyek Kedua'), findsOneWidget);
    expect(find.text('Deskripsi: Deskripsi baru'), findsOneWidget);
    expect(find.text('Kategori: Web Development'), findsOneWidget);
    expect(find.text('Teknologi: '), findsOneWidget);
    expect(find.text('Tautan: '), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1440, 600),
  ]) {
    testWidgets('Form dan dialog dapat digulir pada layar $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));

      await tester.enterText(find.byType(TextFormField).at(0), 'Proyek Sheva');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        List.filled(30, 'Deskripsi proyek yang panjang.').join(' '),
      );
      await submitForm(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.widgetWithText(TextButton, 'OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
