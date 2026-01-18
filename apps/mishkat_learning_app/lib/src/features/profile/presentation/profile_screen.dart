import 'package:flutter/material.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Header
            const Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                   CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage('https://placeholder.com/200'),
                  ),
                  _RankBadge(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ahmad Al-Farsi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Dedicated Seeker of Knowledge', style: TextStyle(color: AppTheme.textGrey)),
            const SizedBox(height: 32),

            // Stats Grid
            Row(
              children: [
                _buildStatItem('3', 'Courses Done'),
                const SizedBox(width: 16),
                _buildStatItem('12.5h', 'Hours Studied'),
              ],
            ),
            const SizedBox(height: 32),

            // Certificates Section
            _buildSectionHeader('Earned Certificates'),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCertCard('Islamic Jurisprudence'),
                  _buildCertCard('Theology 101'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Menu List
            _buildMenuItem(Icons.settings_outlined, 'Account Settings'),
            _buildMenuItem(Icons.language_outlined, 'App Language'),
            _buildMenuItem(Icons.help_outline, 'Support & FAQ'),
            _buildMenuItem(Icons.logout, 'Logout', isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.textGrey.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryEmerald)),
            Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCertCard(String title) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryEmerald,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.workspace_premium, color: AppTheme.accentGold, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const Spacer(),
          const Icon(Icons.download_outlined, color: Colors.white70, size: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppTheme.secondaryNavy),
      title: Text(label, style: TextStyle(color: isDestructive ? Colors.red : AppTheme.secondaryNavy)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentGold,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Text(
        'SEEKER',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
