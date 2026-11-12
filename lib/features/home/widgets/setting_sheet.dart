// setting_sheet.dart

import 'package:flutter/material.dart';

class SettingSheet extends StatelessWidget {
  const SettingSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Mengikuti tinggi konten
          children: [
            const SizedBox(height: 12),
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Header (Title & Close Button) - Sesuai layout Row kamu
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

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SECTION: Account & Profile ---
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

                    // --- SECTION: Preferences ---
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

                    // --- SECTION: Delete Account ---
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
                    const SizedBox(height: 32), // Spacing bawah
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper: Judul Section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF9CA3AF), // Abu-abu terang
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Widget Helper: Kotak Abu-abu Pembungkus Item
  Widget _buildItemGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Warna background abu-abu sangat muda
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // Widget Helper: Baris Menu (Menu Item)
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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