import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saleskido/core/theme/app_colors.dart';
import 'package:saleskido/features/auth/providers/auth_provider.dart';
import 'package:saleskido/services/dashboard_service.dart';
import 'package:saleskido/shared/widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = DashboardService();
  bool _loading = true;
  Map<String, dynamic> _stats = {};
  List<dynamic> _latestLeads = [];
  List<double> _chartValues = [0, 0, 0, 0, 0];

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
      final results = await Future.wait([
        _service.overAllTotal(companyId: auth.companyId, createBy: auth.userId),
        _service.leadList(companyId: auth.companyId, createBy: auth.userId),
        _service.leadGraph(companyId: auth.companyId, createBy: auth.userId),
      ]);

      final statsRes = results[0];
      final leadsRes = results[1];
      final graphRes = results[2];

      Map<String, dynamic> stats = {};
      if (statsRes['data'] is Map) {
        stats = Map<String, dynamic>.from(statsRes['data'] as Map);
      } else if (statsRes['data'] != null) {
        stats = {'raw': statsRes['data']};
      }

      List<dynamic> leads = [];
      final leadData = leadsRes['data'];
      if (leadData is List) {
        leads = leadData;
      } else if (leadData is Map && leadData['leads'] is List) {
        leads = leadData['leads'] as List;
      } else if (leadData is Map && leadData['data'] is List) {
        leads = leadData['data'] as List;
      }

      List<double> chart = [2, 4, 3, 6, 5];
      final gData = graphRes['data'];
      if (gData is List && gData.isNotEmpty) {
        chart = gData
            .take(5)
            .map((e) {
              if (e is num) return e.toDouble();
              if (e is Map) {
                return (e['count'] ?? e['total'] ?? e['value'] ?? 0).toDouble();
              }
              return 0.0;
            })
            .toList()
            .cast<double>();
        while (chart.length < 5) {
          chart.add(0);
        }
      }

      if (!mounted) return;
      setState(() {
        _stats = stats;
        _latestLeads = leads.take(5).toList();
        _chartValues = chart;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _num(dynamic key, [List<String>? alts]) {
    dynamic v = _stats[key];
    if (v == null && alts != null) {
      for (final a in alts) {
        if (_stats[a] != null) {
          v = _stats[a];
          break;
        }
      }
    }
    if (v is Map) v = v['count'] ?? v['total'] ?? v['value'];
    return (v ?? 0).toString();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final firstName = auth.userName.split(' ').first;

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hi $firstName,',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  StatCard(
                    title: 'Total Leads',
                    value: _num('totalLeads', ['total_leads', 'TotalLeads']),
                    percent: '+1.2%',
                    positive: true,
                  ),
                  StatCard(
                    title: 'Raw Leads',
                    value: _num('rawLeads', ['raw_leads', 'RawLeads']),
                    percent: '-1.2%',
                    positive: false,
                  ),
                  StatCard(
                    title: 'Pending Leads',
                    value: _num('pendingLeads', ['pending_leads', 'PendingLeads']),
                    percent: '0%',
                    positive: true,
                    accentColor: AppColors.info,
                  ),
                  StatCard(
                    title: 'Total Quotation',
                    value: _num('totalQuotation', [
                      'total_quotation',
                      'TotalQuotation',
                      'quotations',
                    ]),
                    percent: '+6.2%',
                    positive: true,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Latest Leads',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Expanded(child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                                Expanded(child: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                                Expanded(child: Text('City', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                              ],
                            ),
                          ),
                          if (_latestLeads.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No leads yet',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            )
                          else
                            ..._latestLeads.map((lead) {
                              final m = Map<String, dynamic>.from(lead as Map);
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        (m['name'] ?? m['leadName'] ?? '-').toString(),
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        (m['phone'] ?? m['mobile'] ?? '-').toString(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        (m['city'] ?? m['City'] ?? '-').toString(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Lead Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 180,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (_chartValues.reduce((a, b) => a > b ? a : b) + 2)
                              .clamp(5, double.infinity),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) {
                                  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
                                  final i = v.toInt();
                                  if (i < 0 || i >= days.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    days[i],
                                    style: const TextStyle(fontSize: 11),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: List.generate(_chartValues.length, (i) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: _chartValues[i],
                                  color: AppColors.primary,
                                  width: 18,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
