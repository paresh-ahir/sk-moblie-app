import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/features/auth/providers/auth_provider.dart';
import 'package:saleskido/services/lead_service.dart';

class LeadListScreen extends StatefulWidget {
  const LeadListScreen({super.key});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  final _service = LeadService();
  final _search = TextEditingController();
  bool _loading = true;
  List<dynamic> _leads = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({String? search}) async {
    final auth = context.read<AuthProvider>();
    if (auth.companyId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await _service.list(
        companyId: auth.companyId,
        search: search,
      );
      List<dynamic> leads = [];
      final data = res['data'];
      if (data is List) {
        leads = data;
      } else if (data is Map) {
        leads = (data['leads'] ?? data['data'] ?? data['docs'] ?? []) as List? ??
            [];
      }
      if (!mounted) return;
      setState(() {
        _leads = leads;
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
        onPressed: () async {
          await context.push('/add-lead');
          _load(search: _search.text);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              onSubmitted: (v) => _load(search: v),
              decoration: InputDecoration(
                hintText: 'Search leads...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _load(search: _search.text),
                    child: _leads.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: Text(
                                  'No leads found',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: _leads.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final m = Map<String, dynamic>.from(_leads[i] as Map);
                              final id = (m['_id'] ?? '').toString();
                              final name =
                                  (m['name'] ?? m['leadName'] ?? 'Lead').toString();
                              final phone =
                                  (m['phone'] ?? m['mobile'] ?? '').toString();
                              final stage =
                                  (m['stage'] ?? m['status'] ?? '').toString();
                              return InkWell(
                                onTap: () => context.push('/lead-detail', extra: id),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            AppColors.primary.withValues(alpha: 0.12),
                                        child: Text(
                                          name.isNotEmpty ? name[0].toUpperCase() : 'L',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (phone.isNotEmpty)
                                              Text(
                                                phone,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 13,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (stage.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            stage,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
