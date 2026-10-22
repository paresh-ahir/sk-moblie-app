import 'package:flutter/material.dart';
import 'package:saleskido/core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Version', 'v.1.10.2'),
      ('Privacy Policy', null),
      ('Third-party Licenses', null),
      ('Terms of Use', null),
      ('Platform Rules', null),
      ('Support', null),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final item = items[i];
          return ListTile(
            title: Text(item.$1),
            trailing: item.$2 != null
                ? Text(
                    item.$2!,
                    style: const TextStyle(color: AppColors.textSecondary),
                  )
                : const Icon(Icons.chevron_right, color: AppColors.textHint),
            onTap: item.$2 == null ? () {} : null,
          );
        },
      ),
    );
  }
}
