import 'package:flutter/material.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/services/lead_service.dart';

class LeadDetailScreen extends StatefulWidget {
  const LeadDetailScreen({super.key, required this.leadId});

  final String leadId;

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _loading = true;
  Map<String, dynamic> _lead = {};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res = await LeadService().find(widget.leadId);
      final data = res['data'];
      if (!mounted) return;
      setState(() {
        _lead = data is Map
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{};
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (_lead['name'] ?? _lead['leadName'] ?? 'Lead').toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Activities'),
            Tab(text: 'Notes'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _overview(),
                const Center(child: Text('Activities')),
                const Center(child: Text('Notes')),
                const Center(child: Text('Documents')),
              ],
            ),
    );
  }

  Widget _overview() {
    final rows = {
      'Phone': (_lead['phone'] ?? _lead['mobile'] ?? '-').toString(),
      'Email': (_lead['email'] ?? '-').toString(),
      'City': (_lead['city'] ?? '-').toString(),
      'Stage': (_lead['stage'] ?? _lead['status'] ?? '-').toString(),
      'Source': (_lead['source'] ?? '-').toString(),
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: rows.entries
          .map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.key,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
