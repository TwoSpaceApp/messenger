import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Display',
            children: [
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Customization',
                subtitle: 'Theme, colors, and shapes',
                onTap: () => context.push('/settings/customization'),
              ),
              _SettingsTile(
                icon: Icons.brightness_4_outlined,
                title: 'Dark Mode',
                trailing: Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (_) {},
                ),
              ),
              _SettingsTile(
                icon: Icons.text_fields,
                title: 'Text Size',
                subtitle: 'Adjust text size',
                onTap: () {},
              ),
            ],
          ),
          _SettingsSection(
            title: 'Privacy & Security',
            children: [
              _SettingsTile(
                icon: Icons.lock_outline,
                title: 'Privacy Settings',
                onTap: () => context.push('/settings/privacy'),
              ),
              _SettingsTile(
                icon: Icons.verified_user_outlined,
                title: 'Two-Factor Authentication',
                onTap: () => context.push('/settings/2fa'),
              ),
              _SettingsTile(
                icon: Icons.security_outlined,
                title: 'Blocked Users',
                onTap: () => context.push('/settings/blocked'),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Notifications',
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notification Settings',
                onTap: () => context.push('/settings/notifications'),
              ),
              _SettingsTile(
                icon: Icons.volume_up_outlined,
                title: 'Sounds',
                trailing: Switch(value: true, onChanged: (_) {}),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Account',
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                title: 'Profile',
                onTap: () => context.push('/settings/profile'),
              ),
              _SettingsTile(
                icon: Icons.mail_outline,
                title: 'Email Address',
                subtitle: 'user@example.com',
                onTap: () => context.push('/settings/email'),
              ),
              _SettingsTile(
                icon: Icons.storage_outlined,
                title: 'Storage',
                subtitle: '2.5 GB of 10 GB used',
                onTap: () => context.push('/settings/storage'),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Other',
            children: [
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => context.push('/settings/help'),
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'About TwoSpace',
                onTap: () => context.push('/settings/about'),
              ),
              _SettingsTile(
                icon: Icons.logout,
                title: 'Sign Out',
                titleColor: Colors.red,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(title, style: TextStyle(color: titleColor)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
