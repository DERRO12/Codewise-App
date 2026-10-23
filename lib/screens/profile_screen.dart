import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../state/auth_controller.dart';
import '../state/home_tab_controller.dart';
import '../state/learning_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editProfile(BuildContext context) async {
    final auth = context.read<AuthController>();
    final controller = TextEditingController(text: auth.user?.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit profile'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Full name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().length < 2) return;
    await auth.updateName(name);
    if (context.mounted) showSnack(context, 'Profile updated.');
  }

  void _showCertificates(BuildContext context) {
    final done = context.read<LearningController>().completedCourses;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _Sheet(
        title: 'My certificates',
        children: done.isEmpty
            ? const [
                Text('Finish every lesson in a course to earn its certificate.',
                    style: TextStyle(color: AppColors.grey)),
              ]
            : [
                for (final c in done)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.workspace_premium,
                        color: AppColors.yellow, size: 32),
                    title: Text(c.title),
                    subtitle: const Text('Certificate of completion'),
                  ),
              ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    var reminders = true;
    var newCourses = false;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => _Sheet(
          title: 'Notifications',
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Daily learning reminder'),
              subtitle: const Text('Keep your streak going'),
              value: reminders,
              onChanged: (v) => setState(() => reminders = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('New courses'),
              value: newCourses,
              onChanged: (v) => setState(() => newCourses = v),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _Sheet(
        title: 'Settings',
        children: [
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0 · demo data'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.restart_alt, color: AppColors.red),
            title: const Text('Reset my progress'),
            subtitle: const Text('Clears enrolments, lessons and streak'),
            onTap: () async {
              Navigator.pop(sheetContext);
              await context.read<LearningController>().resetProgress();
              if (context.mounted) showSnack(context, 'Progress reset.');
            },
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => const _Sheet(
        title: 'Help & support',
        children: [
          _Faq('How do I unlock the next lesson?',
              'Finish the exercise at the end of the current lesson.'),
          _Faq('How is my quiz score calculated?',
              'It is the share of exercise answers you got right the first time you completed each lesson.'),
          _Faq('How does the streak work?',
              'Complete at least one lesson every day to grow your streak.'),
        ],
      ),
    );
  }

  Future<void> _logOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can log back in at any time.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final tabs = context.read<HomeTabController>();
    await context.read<AuthController>().logOut();
    tabs.go(HomeTabController.home);
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Center(child: UserAvatar(user: user, radius: 44, borderWidth: 3)),
          const SizedBox(height: 14),
          Text(user?.name ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(user?.email ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey)),
          const SizedBox(height: 14),
          Center(
            child: OutlinedButton(
              onPressed: () => _editProfile(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(150, 40),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
              child: const Text('Edit profile'),
            ),
          ),
          const SizedBox(height: 24),
          Material(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _MenuRow(
                    icon: Icons.workspace_premium_outlined,
                    label: 'My certificates',
                    onTap: () => _showCertificates(context)),
                const Divider(height: 1),
                _MenuRow(
                    icon: Icons.notifications_none,
                    label: 'Notifications',
                    onTap: () => _showNotifications(context)),
                const Divider(height: 1),
                _MenuRow(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => _showSettings(context)),
                const Divider(height: 1),
                _MenuRow(
                    icon: Icons.help_outline,
                    label: 'Help & support',
                    onTap: () => _showHelp(context)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => _logOut(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.red, width: 2),
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minTileHeight: 54,
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppColors.yellow),
      ),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq(this.question, this.answer);

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(answer, style: const TextStyle(color: AppColors.grey)),
        ],
      ),
    );
  }
}
