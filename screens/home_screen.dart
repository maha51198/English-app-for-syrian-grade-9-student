import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';
import '../models/content.dart';
import 'unit_detail_screen.dart';
import 'content_screen.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().loadAllContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('منصة الدراسة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: const Color.fromARGB(255, 214, 137, 132),
                  ),
                  const SizedBox(height: 16),
                  Text('حدث خطأ: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadAllContent(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 🔹 قسم الوحدات (يستخدم UnitDetailScreen)
                if (provider.units.isNotEmpty) ...[
                  _buildSectionHeader(
                    icon: Icons.book,
                    title: AppStrings.units,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  ...provider.units.asMap().entries.map(
                    (entry) => _buildContentCard(
                      entry.key + 1,
                      entry.value,
                      isUnit: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 🔹 قسم المراجعات (تنتقل مباشرة إلى ContentScreen)
                if (provider.reviews.isNotEmpty) ...[
                  _buildSectionHeader(
                    icon: Icons.assignment,
                    title: AppStrings.reviews,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 8),
                  ...provider.reviews.asMap().entries.map(
                    (entry) => _buildContentCard(
                      entry.key + 1,
                      entry.value,
                      isUnit: false,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 🔹 قسم المشاريع (تنتقل مباشرة إلى ContentScreen)
                if (provider.projects.isNotEmpty) ...[
                  _buildSectionHeader(
                    icon: Icons.build,
                    title: AppStrings.projects,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 8),
                  ...provider.projects.asMap().entries.map(
                    (entry) => _buildContentCard(
                      entry.key + 1,
                      entry.value,
                      isUnit: false,
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(
    int number,
    Content content, {
    required bool isUnit,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 209, 137, 132),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                content.title.english,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                content.title.arabic,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          if (isUnit) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UnitDetailScreen(content: content),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ContentScreen(content: content, initialSectionIndex: 0),
              ),
            );
          }
        },
      ),
    );
  }
}
