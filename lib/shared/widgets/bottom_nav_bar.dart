import 'package:flutter/material.dart';
import 'package:saleskido/core/theme/app_colors.dart';

class SkBottomNavBar extends StatelessWidget {
  const SkBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.groups_outlined,
              activeIcon: Icons.groups,
              label: 'Lead Manage',
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            const SizedBox(width: 48),
            _NavItem(
              icon: Icons.description_outlined,
              activeIcon: Icons.description,
              label: 'Quotation',
              selected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              selected: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class SkWhatsAppFab extends StatelessWidget {
  const SkWhatsAppFab({super.key, required this.onPressed, this.active = false});

  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: AppColors.primary,
          elevation: 4,
          child: const Icon(Icons.chat, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 4),
        Text(
          'My WhatsApp',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
