import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraTheme.backgroundPrimary,
      appBar: AppBar(
        title: const Text('User Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          Container(
            color: AuraTheme.backgroundSecondary,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AuraTheme.brandColor,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'TerraByte',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'terrabYte#1234',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AuraTheme.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(context, Icons.account_circle, 'My Account'),
          _buildSettingsTile(context, Icons.privacy_tip, 'Privacy & Safety'),
          const Divider(),
          _buildSettingsTile(context, Icons.color_lens, 'Appearance'),
          _buildSettingsTile(context, Icons.notifications, 'Notifications'),
          const Divider(),
          _buildSettingsTile(
            context,
            Icons.logout,
            'Log Out',
            textColor: AuraTheme.dangerColor,
            iconColor: AuraTheme.dangerColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title, {
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AuraTheme.textMuted),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? AuraTheme.textNormal),
      ),
      trailing: const Icon(Icons.chevron_right, color: AuraTheme.textMuted),
      onTap: () {},
    );
  }
}
