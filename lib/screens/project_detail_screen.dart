import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Proyek'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(project.description),
              const SizedBox(height: 16),
              Text('Teknologi: ${project.techStack}'),
              const SizedBox(height: 8),
              SelectableText(
                'URL Proyek: ${project.projectUrl.isEmpty ? "-" : project.projectUrl}',
              ),
              if (project.projectImageUrl.isNotEmpty) ...[
                const SizedBox(height: 16),
                Image.network(
                  project.projectImageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, error, stackTrace) =>
                      const Text('Gambar tidak dapat dimuat.'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
