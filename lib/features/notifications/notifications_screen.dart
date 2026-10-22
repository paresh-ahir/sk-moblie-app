import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/features/auth/providers/auth_provider.dart';
import 'package:saleskido/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  final _filters = ['All', 'Message', 'Lead', 'Waiting Records', 'Task'];
  String _selected = 'All';
  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    try {
      final res = await _service.getNotifications(
        userId: auth.userId,
        companyId: auth.companyId,
      );
      List<dynamic> items = [];
      final data = res['data'];
      if (data is List) {
        items = data;
      } else if (data is Map) {
        items = (data['notifications'] ?? data['data'] ?? []) as List? ?? [];
      }
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _clearAll() async {
    final auth = context.read<AuthProvider>();
    await _service.clearAll({'userId': auth.userId});
    _load();
  }

  List<dynamic> get _filtered {
    if (_selected == 'All') return _items;
    return _items.where((e) {
      final m = Map<String, dynamic>.from(e as Map);
      final type = (m['type'] ?? m['category'] ?? '').toString().toLowerCase();
      return type.contains(_selected.toLowerCase().split(' ').first);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final selected = f == _selected;
                return ChoiceChip(
                  label: Text(f),
                  selected: selected,
                  onSelected: (_) => setState(() => _selected = f),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Spacer(),
                TextButton(onPressed: _clearAll, child: const Text('Clear All')),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('No notifications'))
                    : ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final m =
                              Map<String, dynamic>.from(_filtered[i] as Map);
                          final title = (m['title'] ??
                                  m['message'] ??
                                  m['description'] ??
                                  'Notification')
                              .toString();
                          String time = '';
                          final raw = m['createdAt'] ?? m['date'];
                          if (raw != null) {
                            try {
                              time = DateFormat('MMM d, yyyy h:mm a')
                                  .format(DateTime.parse(raw.toString()));
                            } catch (_) {}
                          }
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.notifications_none,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text(title),
                            subtitle: Text(
                              time,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
