import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../state/auth_controller.dart';
import '../state/home_tab_controller.dart';
import '../state/learning_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'course_details_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  static const _languages = ['All', 'Python', 'Dart', 'JavaScript', 'HTML/CSS', 'SQL'];

  final _search = TextEditingController();
  String _language = 'All';
  CourseLevel? _level;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool get _filtering =>
      _search.text.trim().isNotEmpty || _language != 'All' || _level != null;

  List<Course> _visible(List<Course> all) {
    final q = _search.text.trim().toLowerCase();
    final list = all.where((c) {
      if (_language != 'All' && c.language != _language) return false;
      if (_level != null && c.level != _level) return false;
      if (q.isEmpty) return true;
      return c.title.toLowerCase().contains(q) ||
          c.language.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q);
    }).toList();
    return list..sort((a, b) => b.rating.compareTo(a.rating));
  }

  void _clearFilters() => setState(() {
        _search.clear();
        _language = 'All';
        _level = null;
      });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    final learning = context.watch<LearningController>();
    final courses = _visible(learning.courses);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: learning.loadCourses,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, ${user?.firstName ?? 'Student'} 👋',
                          style: const TextStyle(color: AppColors.grey)),
                      const SizedBox(height: 2),
                      const Text('What will you code today?',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context
                      .read<HomeTabController>()
                      .go(HomeTabController.profile),
                  child: UserAvatar(user: user, radius: 22),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search courses',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(_search.clear),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            _ChipRow(
              children: [
                for (final lang in _languages)
                  PillChip(
                    label: lang,
                    selected: _language == lang,
                    onTap: () => setState(() => _language = lang),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _ChipRow(
              children: [
                PillChip(
                  label: 'All levels',
                  selected: _level == null,
                  onTap: () => setState(() => _level = null),
                ),
                for (final level in CourseLevel.values)
                  PillChip(
                    label: level.label,
                    selected: _level == level,
                    onTap: () => setState(() => _level = level),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SectionTitle(_filtering
                ? 'Results (${courses.length})'
                : 'Popular courses'),
            const SizedBox(height: 12),
            if (learning.loading && learning.courses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (learning.error != null && learning.courses.isEmpty)
              _EmptyState(
                icon: Icons.wifi_off_rounded,
                message: learning.error!,
                action: 'Try again',
                onAction: learning.loadCourses,
              )
            else if (courses.isEmpty)
              _EmptyState(
                icon: Icons.search_off_rounded,
                message: 'No courses match your search.',
                action: 'Clear filters',
                onAction: _clearFilters,
              )
            else
              for (final course in courses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CourseCard(
                    course: course,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CourseDetailsScreen(courseId: course.id),
                    )),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Center(child: children[i]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.action,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.grey),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey)),
          TextButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    );
  }
}
