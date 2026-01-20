import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import '../../courses/data/progress_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Please sign in to view your profile.'));
        }
        
        final profileAsync = ref.watch(userProfileProvider(user.uid));
        
        return profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return const Center(child: Text('Profile not found.'));
            }
            
            return Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Profile Header
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            GestureDetector(
                              onTap: () => _pickAndUploadImage(context, ref, user.uid),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: AppTheme.deepEmerald.withValues(alpha: 0.1),
                                    backgroundImage: (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                                      ? NetworkImage(profile.photoUrl!) 
                                      : NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(profile.displayName)}&background=004D40&color=fff'),
                                  ),
                                  if (_isUploading)
                                    const CircularProgressIndicator(color: AppTheme.radiantGold)
                                  else
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.radiantGold,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            _RankBadge(rank: profile.rank),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.displayName,
                        style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        profile.role == 'admin' ? 'Administrator' : 'Dedicated Seeker of Knowledge', 
                        style: const TextStyle(color: AppTheme.slateGrey),
                      ),
                      const SizedBox(height: 32),

                      // Stats Grid
                      Row(
                        children: [
                          ref.watch(userCourseCountProvider(user.uid)).when(
                            data: (count) => _buildStatItem(count.toString(), 'Courses Done'),
                            loading: () => _buildStatItem('...', 'Courses Done'),
                            error: (_, __) => _buildStatItem('!', 'Courses Done'),
                          ),
                          const SizedBox(width: 16),
                          _buildStatItem('${(profile.studyTimeMinutes / 60).toStringAsFixed(1)}h', 'Hours Studied'),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Certificates Section
                      if (profile.certificates.isNotEmpty) ...[
                        _buildSectionHeader('Earned Certificates'),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: profile.certificates.length,
                            itemBuilder: (context, index) => _buildCertCard(profile.certificates[index]),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Menu List
                      _buildMenuItem(context, ref, Icons.settings_outlined, 'Account Settings'),
                      _buildMenuItem(context, ref, Icons.history_outlined, 'Payment History', onTap: () => context.push('/profile/payments')),
                      _buildMenuItem(context, ref, Icons.language_outlined, 'App Language'),
                      _buildMenuItem(context, ref, Icons.help_outline, 'Support & FAQ'),
                      _buildMenuItem(context, ref, Icons.logout, 'Logout', isDestructive: true),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, __) => Scaffold(body: Center(child: Text('Error: $err'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, __) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref, String uid) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image == null) return;

    setState(() => _isUploading = true);
    
    try {
      final bytes = await image.readAsBytes();
      await ref.read(userRepositoryProvider).uploadProfilePicture(uid, bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.deepEmerald)),
            Text(label, style: const TextStyle(color: AppTheme.slateGrey, fontSize: 12)),
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
        color: AppTheme.deepEmerald,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.workspace_premium, color: AppTheme.radiantGold, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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
        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, WidgetRef ref, IconData icon, String label, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppTheme.slateGrey),
      title: Text(label, style: TextStyle(color: isDestructive ? Colors.red : AppTheme.slateGrey)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () async {
        if (onTap != null) {
          onTap();
          return;
        }
        if (isDestructive && label == 'Logout') {
          await ref.read(authRepositoryProvider).signOut();
          if (context.mounted) context.go('/login');
        }
      },
    );
  }
}

class _RankBadge extends StatelessWidget {
  final String rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.radiantGold,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        rank.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
