import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _techStack = '';
  String _projectUrl = '';
  String _imageUrl = '';
  bool _isSubmitting = false;

  String? _required(String? value, String label, {int? maxLength}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label tidak boleh kosong!';
    if (maxLength != null && text.length > maxLength) {
      return '$label maksimal $maxLength karakter.';
    }
    return null;
  }

  String? _url(String? value, {bool optional = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return optional ? null : 'URL proyek wajib diisi.';
    final uri = Uri.tryParse(text);
    if (text.length > 200 ||
        uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        RegExp(r'\s').hasMatch(text)) {
      return 'Gunakan URL HTTP/HTTPS yang valid, maksimal 200 karakter.';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      final token = context.read<AuthState>().token;
      if (token == null) return;
      final project = await context.read<ApiClient>().createProject(
        Project(
          title: _title,
          description: _description,
          techStack: _techStack,
          projectUrl: _projectUrl,
          projectImageUrl: _imageUrl,
        ),
        token: token,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Proyek: ${project.title}'),
                Text('Deskripsi: ${project.description}'),
                Text('Teknologi: ${project.techStack}'),
                Text('Tautan: ${project.projectUrl}'),
                Text(
                  'URL Gambar: ${project.projectImageUrl.isEmpty ? "-" : project.projectImageUrl}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) _formKey.currentState!.reset();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      if (error is ApiException && error.statusCode == 401) {
        context.read<AuthState>().clearSession();
        await ensureLoggedIn(context);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _field(
    String label, {
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        enabled: !_isSubmitting,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorMaxLines: 3,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project Form'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _field(
                  'Nama Proyek',
                  onSaved: (value) => _title = value!.trim(),
                  validator: (value) =>
                      _required(value, 'Nama proyek', maxLength: 255),
                ),
                _field(
                  'Deskripsi Proyek',
                  maxLines: 5,
                  onSaved: (value) => _description = value!.trim(),
                  validator: (value) => _required(value, 'Deskripsi proyek'),
                ),
                _field(
                  'Teknologi yang Digunakan',
                  hint: 'Flutter, Django',
                  onSaved: (value) => _techStack = value!.trim(),
                  validator: (value) =>
                      _required(value, 'Teknologi', maxLength: 255),
                ),
                _field(
                  'Tautan Proyek',
                  keyboardType: TextInputType.url,
                  hint: 'https://example.com',
                  onSaved: (value) => _projectUrl = value!.trim(),
                  validator: _url,
                ),
                _field(
                  'URL Gambar Proyek (opsional)',
                  keyboardType: TextInputType.url,
                  onSaved: (value) => _imageUrl = value!.trim(),
                  validator: (value) => _url(value, optional: true),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
