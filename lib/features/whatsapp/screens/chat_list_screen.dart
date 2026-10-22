import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/features/auth/providers/auth_provider.dart';
import 'package:saleskido/services/whatsapp_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _service = WhatsappService();
  bool _loading = true;
  List<dynamic> _active = [];
  List<dynamic> _requesting = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    if (auth.companyId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final body = {
        'loginUserId': auth.userId,
        'userId': auth.userId,
      };
      final results = await Future.wait([
        _service.activeChats(auth.companyId, body: body),
        _service.requestingChats(auth.companyId, body: body),
      ]);
      List<dynamic> parse(Map res) {
        final data = res['data'];
        if (data is List) return data;
        if (data is Map) {
          return (data['chatRooms'] ??
                  data['leads'] ??
                  data['data'] ??
                  data['docs'] ??
                  []) as List? ??
              [];
        }
        return [];
      }

      if (!mounted) return;
      setState(() {
        _active = parse(results[0]);
        _requesting = parse(results[1]);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
        child: const Icon(Icons.chat, color: Colors.white),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabs,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Active (${_active.length})'),
              Tab(text: 'Requesting (${_requesting.length})'),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _list(_active),
                      _list(_requesting),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _list(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No chats', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final m = Map<String, dynamic>.from(items[i] as Map);
          final name = (m['name'] ??
                  m['leadName'] ??
                  m['whatsappName'] ??
                  m['customerName'] ??
                  'Contact')
              .toString();
          final last = (m['lastMessage'] ??
                  m['message'] ??
                  m['recentMessage'] ??
                  '')
              .toString();
          final phone = (m['whatsappNumber'] ??
                  m['phone'] ??
                  m['mobile'] ??
                  '')
              .toString();
          String time = '';
          final raw = m['updatedAt'] ?? m['lastMessageTime'] ?? m['createdAt'];
          if (raw != null) {
            try {
              time = DateFormat('h:mm a').format(DateTime.parse(raw.toString()));
            } catch (_) {}
          }

          return ListTile(
            onTap: () => context.push('/chat', extra: {
              'name': name,
              'phone': phone,
              'chatRoom': m,
            }),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'C',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              last.isEmpty ? phone : last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            trailing: Text(
              time,
              style: const TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          );
        },
      ),
    );
  }
}
