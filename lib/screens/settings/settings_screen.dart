import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ProfileCard(),
          const Gap(24),
          _SettingsSection(
            title: 'Preferences',
            tiles: [
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) => _SettingsTile(
                  icon: state.isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: state.isDark,
                    onChanged: (_) =>
                        context.read<ThemeBloc>().add(ToggleTheme()),
                    activeThumbColor: AppTheme.primaryLight,
                  ),
                ),
              ),
              const _SettingsTile(
                icon: Icons.currency_rupee_rounded,
                title: 'Currency',
                subtitle: 'Indian Rupee (₹)',
                trailing: Icon(Icons.chevron_right_rounded),
              ),
              const _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Daily reminders & alerts',
                trailing: Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const Gap(16),
          const _SettingsSection(
            title: 'Data',
            tiles: [
              _SettingsTile(
                icon: Icons.download_outlined,
                title: 'Export Data',
                subtitle: 'Download as CSV',
                trailing: Icon(Icons.chevron_right_rounded),
              ),
              _SettingsTile(
                icon: Icons.backup_outlined,
                title: 'Backup & Restore',
                trailing: Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const Gap(16),
          const _SettingsSection(
            title: 'Security',
            tiles: [
              _SettingsTile(
                icon: Icons.fingerprint_rounded,
                title: 'Biometric Lock',
                trailing: Switch(
                  value: false,
                  onChanged: null,
                  activeThumbColor: AppTheme.primaryLight,
                ),
              ),
            ],
          ),
          const Gap(16),
          const _SettingsSection(
            title: 'About',
            tiles: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'App Version',
                subtitle: '1.0.0',
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                trailing: Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const Gap(32),
          Center(
            child: Text(
              'Finance Companion ✦ Made with Flutter & BLoC',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: .4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryLight, Color(0xFF9B94FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 28)),
            ),
          ),
          const Gap(16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Finance Companion User',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  const _SettingsSection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryLight,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .04),
                      blurRadius: 10,
                    )
                  ],
          ),
          child: Column(
            children: tiles.asMap().entries.map((e) {
              final tile = e.value;
              final isLast = e.key == tiles.length - 1;
              return Column(
                children: [
                  tile,
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: .05),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryLight, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 12))
          : null,
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
