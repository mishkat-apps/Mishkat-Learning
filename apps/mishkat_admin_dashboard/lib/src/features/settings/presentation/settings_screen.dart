import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mishkat_admin_dashboard/src/features/auth/data/auth_repository.dart';
import 'package:mishkat_admin_dashboard/src/core/theme/admin_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
    // Pre-fill name if available
    final user = ref.read(authStateProvider).value;
    if (user?.displayName != null) {
      _nameController.text = user!.displayName!;
    }
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${info.version} (build ${info.buildNumber})';
    });
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      // final auth = ref.read(authRepositoryProvider);
      // TODO: Implement update profile in repository
      // For now, we simulate success
      await Future.delayed(const Duration(seconds: 1));
      
      // Force refresh of auth state if needed, though firebase updates stream automatically usually
      await FirebaseAuth.instance.currentUser?.updateDisplayName(_nameController.text);
      await FirebaseAuth.instance.currentUser?.reload();
      
      // NOTE: Ideally verify if AuthRepository has update profile capability. 
      // Previous view of auth_repository.dart showed basic auth methods.
      // I'll proceed with UI construction and placeholder logic or try to use a repo extension if I edit it.
      // Let's actually add the method to the repo in the next step.

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPasswordReset() async {
     final user = ref.read(authStateProvider).value;
     if (user?.email == null) return;
     
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Password reset email sent (simulation)')),
     );
     // Same here, need repo method.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.scaffoldBackground,
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Profile Settings'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Display Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) => v!.isEmpty ? 'Name required' : null,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _isLoading ? null : _updateProfile,
                          child: const Text('Update Profile'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Security'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  subtitle: const Text('Send a password reset email to your registered address.'),
                  trailing: OutlinedButton(
                    onPressed: _sendPasswordReset,
                    child: const Text('Reset Password'),
                  ),
                ),
              ),
               const SizedBox(height: 32),
              _buildSectionHeader('System Info'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _infoRow('App Version', _version.isEmpty ? 'Loading...' : _version),
                      const Divider(),
                      _infoRow('Environment', 'Production (Firebase)'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
