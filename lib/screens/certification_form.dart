import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class CertificationFormPage extends StatefulWidget {
  const CertificationFormPage({super.key});

  @override
  State<CertificationFormPage> createState() => _CertificationFormPageState();
}

class _CertificationFormPageState extends State<CertificationFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _issuer = '';
  String _credentialUrl = '';

  String? _validateText(String? value, String label, int maxLength) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label wajib diisi.';
    if (text.length > maxLength) {
      return '$label maksimal $maxLength karakter.';
    }
    return null;
  }

  String? _validateUrl(String? value) {
    final error = _validateText(value, 'URL kredensial', 2000);
    if (error != null) return error;
    final text = value!.trim();
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        RegExp(r'\s').hasMatch(text)) {
      return 'Masukkan URL http:// atau https:// yang valid.';
    }
    return null;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    FocusScope.of(context).unfocus();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ringkasan Sertifikasi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama Sertifikasi: $_name'),
              const SizedBox(height: 8),
              Text('Penerbit: $_issuer'),
              const SizedBox(height: 8),
              Text('URL Kredensial: $_credentialUrl'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Sertifikasi'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nama Sertifikasi',
                    hintText: 'Contoh: Flutter Development',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      _validateText(value, 'Nama sertifikasi', 100),
                  onSaved: (value) => _name = value!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Penerbit',
                    hintText: 'Nama lembaga penerbit sertifikasi',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) => _validateText(value, 'Penerbit', 100),
                  onSaved: (value) => _issuer = value!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'URL Kredensial',
                    hintText: 'https://example.com/sertifikat',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  validator: _validateUrl,
                  onSaved: (value) => _credentialUrl = value!.trim(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _submitForm,
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
