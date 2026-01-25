import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/router_notifier.dart';

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
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    return authState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Please sign in to view your profile.')));
        }
        
        final profileAsync = ref.watch(userProfileProvider(user.uid));
        
        return profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return const Scaffold(body: Center(child: Text('Profile not found.')));
            }
            
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppTheme.secondaryNavy),
                  onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
                ),
                title: Text(
                  'MY PROFILE',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppTheme.secondaryNavy,
                  ),
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  _buildProfileHeader(profile),
                                  const SizedBox(height: 32),
                                  _buildStatsRow(user.uid),
                                ],
                              ),
                            ),
                            const SizedBox(width: 48),
                            // Right Column
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  _buildProfileMenu(context, ref, isWide),
                                  const SizedBox(height: 32),
                                  _buildCertificatesSection(),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildProfileHeader(profile),
                            const SizedBox(height: 32),
                            _buildStatsRow(user.uid),
                            const SizedBox(height: 40),
                            _buildProfileMenu(context, ref, false),
                            const SizedBox(height: 40),
                            _buildCertificatesSection(),
                          ],
                        ),
                  ),
                ),
              ),
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildProfileHeader(dynamic profile) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: () => _pickAndUploadImage(context, ref, (ref.read(authStateProvider).value?.uid ?? '')),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.radiantGold.withValues(alpha: 0.3), width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.deepEmerald.withValues(alpha: 0.1),
                      backgroundImage: (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                        ? NetworkImage(profile.photoUrl!) 
                        : NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(profile.displayName)}&background=004D40&color=fff'),
                    ),
                  ),
                  if (_isUploading)
                    const CircularProgressIndicator(color: AppTheme.radiantGold)
                  else
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.radiantGold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
            ),
            _RankBadge(rank: profile.rank),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          profile.displayName,
          style: GoogleFonts.montserrat(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryNavy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.role == 'admin' ? 'Administrator' : 'Dedicated Seeker of Knowledge', 
          style: GoogleFonts.roboto(
            color: AppTheme.slateGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(String uid) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Courses Done', 
            value: ref.watch(userCourseCountProvider(uid)).when(
              data: (count) => '$count',
              loading: () => '...',
              error: (_, __) => '0',
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: _StatCard(label: 'Hours Studied', value: '42.5'),
        ),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context, WidgetRef ref, bool isWide) {
    final profile = ref.watch(currentUserProfileProvider).value;
    final isAdmin = profile?.role.toLowerCase() == 'admin';

    return Column(
      children: [
        if (isAdmin)
          _buildMenuOption(
            context, 
            'Admin Panel', 
            Icons.admin_panel_settings_outlined, 
            color: AppTheme.radiantGold,
            onTap: () => context.go('/admin')
          ),
        _buildMenuOption(
          context, 
          'Account Settings', 
          Icons.person_outline, 
          onTap: () => context.push('/profile/settings')
        ),
        _buildMenuOption(
          context, 
          'Payment History', 
          Icons.payment_outlined, 
          onTap: () => context.push('/profile/payments')
        ),
        _buildMenuOption(
          context, 
          'App Language', 
          Icons.language_outlined, 
          onTap: () => context.push('/profile/language')
        ),
        _buildMenuOption(
          context, 
          'Support & FAQ', 
          Icons.help_outline, 
          onTap: () => context.push('/profile/support')
        ),
        _buildMenuOption(
          context, 
          'Logout', 
          Icons.logout, 
          color: Colors.redAccent, 
          onTap: () async {
            await ref.read(authRepositoryProvider).signOut();
            if (context.mounted) {
              context.go('/');
            }
          }
        ),
      ],
    );
  }

  Widget _buildMenuOption(BuildContext context, String label, IconData icon, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.secondaryNavy),
      title: Text(
        label,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.w600,
          color: color ?? AppTheme.secondaryNavy,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }

  Widget _buildCertificatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earned Certificates',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryNavy,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.slateGrey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              const Icon(Icons.workspace_premium_outlined, color: Colors.grey, size: 48),
              const SizedBox(height: 16),
              const Text('No certificates earned yet', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref, String uid) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 75);

    if (image == null) return;

    setState(() => _isUploading = true);
    
    try {
      final bytes = await image.readAsBytes();
      await ref.read(userRepositoryProvider).uploadProfilePicture(uid, bytes);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated successfully!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.deepEmerald,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.slateGrey,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
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
