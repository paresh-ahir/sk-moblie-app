import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/features/auth/providers/auth_provider.dart';
import 'package:saleskido/services/quotation_service.dart';

class QuotationListScreen extends StatefulWidget {
  const QuotationListScreen({super.key});

  @override
  State<QuotationListScreen> createState() => _QuotationListScreenState();
}

class _QuotationListScreenState extends State<QuotationListScreen> {
  final _service = QuotationService();
  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    if (auth.companyId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await _service.list(companyId: auth.companyId);
      List<dynamic> items = [];
      final data = res['data'];
      if (data is List) {
        items = data;
      } else if (data is Map) {
        items = (data['quotations'] ?? data['data'] ?? data['docs'] ?? [])
                as List? ??
            [];
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

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('approv')) return AppColors.success;
    if (s.contains('pend')) return AppColors.warning;
    if (s.contains('reject') || s.contains('cancel')) return AppColors.error;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create quotation coming soon')),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Text(
                            'No quotations found',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final m = Map<String, dynamic>.from(_items[i] as Map);
                        final id = (m['_id'] ?? '').toString();
                        final client = (m['clientName'] ??
                                m['leadName'] ??
                                m['name'] ??
                                'Client')
                            .toString();
                        final amount = (m['grandTotal'] ??
                                m['total'] ??
                                m['amount'] ??
                                0)
                            .toString();
                        final status =
                            (m['status'] ?? m['quotationStatus'] ?? 'Pending')
                                .toString();
                        String date = '-';
                        final rawDate = m['createdAt'] ?? m['date'];
                        if (rawDate != null) {
                          try {
                            date = DateFormat('dd MMM yyyy, hh:mm a')
                                .format(DateTime.parse(rawDate.toString()));
                          } catch (_) {
                            date = rawDate.toString();
                          }
                        }
                        final color = _statusColor(status);

                        return InkWell(
                          onTap: () =>
                              context.push('/quotation-detail', extra: id),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        client,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  date,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₹ $amount',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
