import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/features/auth/providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, this.activeRoute = 'dashboard'});

  final String activeRoute;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        backgroundImage: auth.profileImage != null &&
                                auth.profileImage!.isNotEmpty
                            ? NetworkImage(auth.profileImage!)
                            : null,
                        child: auth.profileImage == null ||
                                auth.profileImage!.isEmpty
                            ? Text(
                                auth.userName.isNotEmpty
                                    ? auth.userName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/home?tab=4');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          'Mr. ${auth.userName}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          auth.designation.isEmpty
                              ? 'Team Member'
                              : auth.designation,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _item(context, Icons.dashboard_outlined, 'Dashboard', 'dashboard',
                      () => context.go('/home?tab=0')),
                  _item(context, Icons.groups_outlined, 'Lead management', 'leads',
                      () => context.go('/home?tab=1')),
                  _item(context, Icons.description_outlined, 'Quotation', 'quotation',
                      () => context.go('/home?tab=3')),
                  _item(context, Icons.chat, 'My whatsapp', 'whatsapp',
                      () => context.go('/home?tab=2')),
                  _item(context, Icons.assessment_outlined, 'Report', 'report',
                      () {
                    Navigator.pop(context);
                    context.push('/reports');
                  }),
                  _item(context, Icons.thumb_up_alt_outlined, 'Billing & plans',
                      'billing', () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Billing opens in web portal')),
                    );
                  }),
                  _item(context, Icons.info_outline, 'About', 'about', () {
                    Navigator.pop(context);
                    context.push('/about');
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await auth.logout();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(Icons.logout, color: AppColors.textPrimary),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  const Spacer(),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Sales',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: 'Kido',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    String route,
    VoidCallback onTap,
  ) {
    final active = activeRoute == route;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: active ? Colors.white : AppColors.textPrimary),
        title: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textPrimary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }
}
