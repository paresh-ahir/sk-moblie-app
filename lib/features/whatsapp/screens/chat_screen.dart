import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/features/auth/providers/auth_provider.dart';
import 'package:saleskido/services/whatsapp_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.args});

  final Map<String, dynamic> args;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _service = WhatsappService();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _loading = true;
  List<dynamic> _messages = [];
  Map<String, dynamic>? _replyTo;

  String get _name => (widget.args['name'] ?? 'Chat').toString();
  String get _phone => (widget.args['phone'] ?? '').toString();
  Map<String, dynamic> get _room =>
      Map<String, dynamic>.from((widget.args['chatRoom'] as Map?) ?? {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    try {
      final res = await _service.getMessages(
        auth.userId,
        body: {
          'whatsappNumber': _phone,
          'loginUserId': auth.userId,
          'company_id': auth.companyId,
          'chatRoomId': _room['_id'],
        },
      );
      List<dynamic> msgs = [];
      final data = res['data'];
      if (data is List) {
        msgs = data;
      } else if (data is Map) {
        msgs = (data['messages'] ?? data['data'] ?? []) as List? ?? [];
      }
      if (!mounted) return;
      setState(() {
        _messages = msgs;
        _loading = false;
      });
      _scrollToEnd();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final auth = context.read<AuthProvider>();
    final optimistic = {
      'message': text,
      'body': text,
      'isSender': true,
      'fromMe': true,
      'createdAt': DateTime.now().toIso8601String(),
      if (_replyTo != null) 'replyTo': _replyTo,
    };
    setState(() {
      _messages = [..._messages, optimistic];
      _controller.clear();
      _replyTo = null;
    });
    _scrollToEnd();
    try {
      await _service.sendMessage({
        'message': text,
        'whatsappNumber': _phone,
        'loginUserId': auth.userId,
        'company_id': auth.companyId,
        'chatRoomId': _room['_id'],
        if (_replyTo != null) 'replyMessageId': _replyTo!['_id'],
      });
    } catch (_) {}
  }

  void _showMessageMenu(Map<String, dynamic> msg) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _replyTo = msg);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(
                  ClipboardData(
                    text: (msg['message'] ?? msg['body'] ?? '').toString(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.push_pin_outlined),
              title: const Text('Pin'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Text(
                _name.isNotEmpty ? _name[0].toUpperCase() : 'C',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_name, style: const TextStyle(fontSize: 16)),
                const Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.chatBg,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) {
                        final m = Map<String, dynamic>.from(_messages[i] as Map);
                        final mine = m['fromMe'] == true ||
                            m['isSender'] == true ||
                            m['sender'] == true;
                        final text =
                            (m['message'] ?? m['body'] ?? m['text'] ?? '')
                                .toString();
                        String time = '';
                        final raw = m['createdAt'] ?? m['timestamp'];
                        if (raw != null) {
                          try {
                            time = DateFormat('h:mm a')
                                .format(DateTime.parse(raw.toString()));
                          } catch (_) {}
                        }
                        return Align(
                          alignment:
                              mine ? Alignment.centerRight : Alignment.centerLeft,
                          child: GestureDetector(
                            onLongPress: () => _showMessageMenu(m),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: mine
                                    ? AppColors.chatOutgoing
                                    : AppColors.chatIncoming,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (m['replyTo'] != null)
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(6),
                                        border: const Border(
                                          left: BorderSide(
                                            color: AppColors.primary,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        (m['replyTo']['message'] ??
                                                m['replyTo']['body'] ??
                                                '')
                                            .toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(text),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    time,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          if (_replyTo != null)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (_replyTo!['message'] ?? _replyTo!['body'] ?? '').toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _replyTo = null),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type '/' for canned message",
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.attach_file),
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
