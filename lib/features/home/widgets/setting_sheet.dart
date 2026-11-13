
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingSheet extends StatelessWidget {
  const SettingSheet({super.key});

  // LOGOUT FUNCTION
  Future<void> _logout(BuildContext context) async {
    // Confirmation Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout from your account?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client.auth.signOut();

      // AuthGate akan menangani navigasi ke Login.
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),

            // DRAG HANDLE
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 16),

            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.all(8),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // CONTENT
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ACCOUNT & PROFILE
                    _buildSectionTitle('Account & Profile'),
                    _buildItemGroup(
                      children: [
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Profile Information',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.manage_accounts_outlined,
                          title: 'Edit Profile',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.shield_outlined,
                          title: 'Account Security',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // PREFERENCES
                    _buildSectionTitle('Preferences'),
                    _buildItemGroup(
                      children: [
                        _buildMenuItem(
                          icon: Icons.payments_outlined,
                          title: 'Default Currency',
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.event_repeat_outlined,
                          title: 'Monthly Budget Reset Date',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // DELETE ACCOUNT
                    _buildSectionTitle('Delete Account'),
                    _buildItemGroup(
                      children: [
                        _buildMenuItem(
                          icon: Icons.delete_outline,
                          title: 'Delete Account',
                          isDestructive: true,
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // LOGOUT
                    _buildSectionTitle('Session'),
                    _buildItemGroup(
                      children: [
                        _buildMenuItem(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          isDestructive: true,
                          onTap: () => _logout(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION TITLE
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ITEM GROUP
  Widget _buildItemGroup({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // MENU ITEM
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final itemColor = isDestructive ? Colors.red : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: itemColor,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: itemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
